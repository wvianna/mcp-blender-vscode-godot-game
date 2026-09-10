"""Testes do adapter de ARIA (POC 3) — sem depender de Ollama em execução.

Execução: .venv/bin/python tests/test_aria_adapter.py
"""

from __future__ import annotations

import os
import sys
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

import aria_adapter as adapter  # noqa: E402
from pydantic import ValidationError  # noqa: E402


class PersonalityTests(unittest.TestCase):
    def test_personality_file_loads(self) -> None:
        data = adapter.load_personality()
        self.assertIn("base_prompt", data)
        self.assertTrue(data.get("tones"))
        self.assertTrue(data.get("fallback_text"))

    def test_system_prompt_includes_intents_tone_and_objective(self) -> None:
        prompt = adapter.build_system_prompt(
            adapter.load_personality(),
            {"tone": "impaciente", "objective": "Reiniciar o CLP"},
        )
        self.assertIn("HINT", prompt)
        self.assertIn("impaciente", prompt.lower())
        self.assertIn("Reiniciar o CLP", prompt)


class ValidationTests(unittest.TestCase):
    def test_blank_message_rejected(self) -> None:
        with self.assertRaises(ValidationError):
            adapter.ChatRequest(message="   ")

    def test_message_too_long_rejected(self) -> None:
        with self.assertRaises(ValidationError):
            adapter.ChatRequest(message="x" * 2001)

    def test_game_state_optional(self) -> None:
        self.assertEqual(adapter.ChatRequest(message="oi").game_state, {})


class SanitizeTests(unittest.TestCase):
    def test_known_intents_accepted(self) -> None:
        for value in ["HINT", " hint ", "Diagnose", "lore", "status", "none"]:
            self.assertIn(adapter.sanitize_intent(value), adapter.ALLOWED_INTENTS)

    def test_unknown_becomes_none(self) -> None:
        self.assertEqual(adapter.sanitize_intent("EXECUTAR_COMANDO"), "NONE")
        self.assertEqual(adapter.sanitize_intent(""), "NONE")
        self.assertEqual(adapter.sanitize_intent(None), "NONE")


class ParseTests(unittest.TestCase):
    def test_json_output(self) -> None:
        text, intent, conf = adapter.parse_model_output(
            '{"text": "A bomba falhou.", "intent": "DIAGNOSE", "confidence": 0.8}'
        )
        self.assertEqual(text, "A bomba falhou.")
        self.assertEqual(intent, "DIAGNOSE")
        self.assertAlmostEqual(conf, 0.8)

    def test_json_embedded_in_text(self) -> None:
        text, intent, _ = adapter.parse_model_output(
            'Claro: {"text": "Olá, técnico.", "intent": "LORE"} — fim'
        )
        self.assertEqual(text, "Olá, técnico.")
        self.assertEqual(intent, "LORE")

    def test_plain_text_falls_back_to_none(self) -> None:
        text, intent, _ = adapter.parse_model_output("Apenas texto sem JSON.")
        self.assertEqual(text, "Apenas texto sem JSON.")
        self.assertEqual(intent, "NONE")

    def test_unknown_intent_in_json(self) -> None:
        _, intent, _ = adapter.parse_model_output('{"text": "x", "intent": "EXECUTE"}')
        self.assertEqual(intent, "NONE")


class ChatEndpointTests(unittest.TestCase):
    def test_success_path(self) -> None:
        model_reply = '{"text": "O CLP está em FALHA.", "intent": "DIAGNOSE", "confidence": 0.9}'
        with mock.patch.object(adapter, "call_ollama", return_value=model_reply):
            response = adapter.chat(adapter.ChatRequest(message="estado do CLP?"))
        self.assertEqual(response.intent, "DIAGNOSE")
        self.assertEqual(response.text, "O CLP está em FALHA.")
        self.assertIsNone(response.error)

    def test_ollama_down_returns_fallback(self) -> None:
        with mock.patch.object(adapter, "call_ollama", side_effect=RuntimeError("connection refused")):
            response = adapter.chat(adapter.ChatRequest(message="oi"))
        self.assertEqual(response.intent, "NONE")
        self.assertIn("indisponível", response.text.lower())
        self.assertIsNotNone(response.error)

    def test_empty_model_output_returns_fallback(self) -> None:
        with mock.patch.object(adapter, "call_ollama", return_value="   "):
            response = adapter.chat(adapter.ChatRequest(message="oi"))
        self.assertEqual(response.intent, "NONE")
        self.assertTrue(response.text)

    def test_timeout_default_is_30s(self) -> None:
        if "LAB404_TIMEOUT" not in os.environ:
            self.assertEqual(adapter.TIMEOUT, 30.0)

    def test_health_lists_allowed_intents(self) -> None:
        payload = adapter.health()
        self.assertEqual(set(payload["allowed_intents"]), adapter.ALLOWED_INTENTS)


if __name__ == "__main__":
    unittest.main(verbosity=2)
