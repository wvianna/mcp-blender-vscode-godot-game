"""Adapter local de ARIA — POC 3 (FR-016…FR-021).

Responsabilidades:
- validar a entrada (pydantic);
- montar o prompt a partir de `config/aria_personality.json` + contexto do jogo;
- conversar com o Ollama local (timeout de 30 s);
- validar/limitar a intent devolvida a `ALLOWED_INTENTS`;
- nunca executar comandos: devolve apenas texto + intenção estruturada (FR-021).

Execução: uvicorn scripts.aria_adapter:app --reload --port 8000
"""

from __future__ import annotations

import json
import os
import re
import unicodedata
from pathlib import Path
from typing import Any, Dict, Optional, Tuple

import requests
from fastapi import FastAPI
from pydantic import BaseModel, Field, field_validator

OLLAMA_URL = os.environ.get("LAB404_OLLAMA_URL", "http://127.0.0.1:11434/api/chat")
MODEL = os.environ.get("LAB404_MODEL", "llama3.2:3b")
TIMEOUT = float(os.environ.get("LAB404_TIMEOUT", "30"))
PERSONALITY_PATH = Path(
    os.environ.get(
        "LAB404_PERSONALITY",
        Path(__file__).resolve().parent.parent / "config" / "aria_personality.json",
    )
)

ALLOWED_INTENTS = {"HINT", "DIAGNOSE", "LORE", "STATUS", "NONE"}

FALLBACK_DEFAULT = "A comunicação com ARIA está indisponível."


# --- modelos -----------------------------------------------------------------


class ChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=2000)
    game_state: Dict[str, Any] = Field(default_factory=dict)

    @field_validator("message")
    @classmethod
    def _not_blank(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("message não pode ser vazia")
        return value.strip()


class ChatResponse(BaseModel):
    text: str
    intent: str = "NONE"
    target: Optional[str] = None
    confidence: float = 1.0
    error: Optional[str] = None


# --- personalidade (FR-020) --------------------------------------------------


def load_personality(path: Path = PERSONALITY_PATH) -> Dict[str, Any]:
    """Carrega a personalidade versionada; em falha, devolve um mínimo utilizável."""
    try:
        with open(path, "r", encoding="utf-8") as handle:
            return json.load(handle)
    except Exception:
        return {"base_prompt": "Você é ARIA, supervisora do Laboratório 404.",
                "rules": [], "tones": {}, "fallback_text": FALLBACK_DEFAULT}


def fallback_text(personality: Optional[Dict[str, Any]] = None) -> str:
    personality = personality or load_personality()
    return str(personality.get("fallback_text") or FALLBACK_DEFAULT)


def build_system_prompt(personality: Dict[str, Any], game_state: Dict[str, Any]) -> str:
    parts = [str(personality.get("base_prompt", "")).strip()]
    for rule in personality.get("rules", []):
        parts.append("- %s" % rule)
    tone_key = str(game_state.get("tone", "neutra"))
    tones = personality.get("tones", {})
    if tone_key in tones:
        parts.append("Tom de voz (%s): %s" % (tone_key, tones[tone_key]))
    objective = game_state.get("objective")
    if objective:
        parts.append("Objetivo atual do técnico: %s." % objective)
    parts.append(
        "Responda SEMPRE com um objeto JSON de uma linha, sem texto fora dele:\n"
        '{"text": "<resposta em português>", "intent": "HINT|DIAGNOSE|LORE|STATUS|NONE", '
        '"confidence": 0.0}'
    )
    return "\n".join(parts)


# --- parsing e validação da saída (FR-017) ----------------------------------


def sanitize_intent(value: Any) -> str:
    candidate = re.sub(r"[^A-Za-z]", "", str(value or ""))
    candidate = unicodedata.normalize("NFKD", candidate).encode("ascii", "ignore").decode()
    candidate = candidate.upper()
    return candidate if candidate in ALLOWED_INTENTS else "NONE"


def parse_model_output(raw: str) -> Tuple[str, str, float]:
    """Extrai (texto, intent, confiança) da saída do modelo, tolerando ruído."""
    text = (raw or "").strip()
    if not text:
        return "", "NONE", 1.0

    payload: Optional[Dict[str, Any]] = None
    try:
        candidate = json.loads(text)
        if isinstance(candidate, dict):
            payload = candidate
    except json.JSONDecodeError:
        match = re.search(r"\{.*\}", text, re.DOTALL)
        if match:
            try:
                candidate = json.loads(match.group(0))
                if isinstance(candidate, dict):
                    payload = candidate
            except json.JSONDecodeError:
                payload = None

    if payload is None:
        return text, "NONE", 1.0

    reply = str(payload.get("text", "")).strip() or text
    intent = sanitize_intent(payload.get("intent", "NONE"))
    try:
        confidence = float(payload.get("confidence", 1.0))
    except (TypeError, ValueError):
        confidence = 1.0
    return reply, intent, max(0.0, min(1.0, confidence))


def call_ollama(system_prompt: str, message: str, url: str = OLLAMA_URL,
                model: str = MODEL, timeout: float = TIMEOUT) -> str:
    """Chama o Ollama e devolve o conteúdo bruto. Isolado para facilitar testes."""
    payload = {
        "model": model,
        "stream": False,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": message},
        ],
    }
    response = requests.post(url, json=payload, timeout=timeout)
    response.raise_for_status()
    return str(response.json().get("message", {}).get("content", ""))


# --- API ---------------------------------------------------------------------

app = FastAPI(title="Lab404 ARIA Adapter", version="0.3.0")


@app.get("/health")
def health() -> Dict[str, Any]:
    return {"status": "ok", "model": MODEL, "timeout": TIMEOUT,
            "allowed_intents": sorted(ALLOWED_INTENTS)}


@app.post("/chat", response_model=ChatResponse)
def chat(request: ChatRequest) -> ChatResponse:
    personality = load_personality()
    system_prompt = build_system_prompt(personality, request.game_state)

    try:
        raw = call_ollama(system_prompt, request.message)
    except Exception as exc:  # rede, timeout, modelo ausente…
        return ChatResponse(
            text=fallback_text(personality),
            intent="NONE",
            confidence=1.0,
            error="%s: %s" % (type(exc).__name__, exc),
        )

    text, intent, confidence = parse_model_output(raw)
    if not text:
        return ChatResponse(
            text=fallback_text(personality),
            intent="NONE",
            confidence=1.0,
            error="resposta vazia do modelo",
        )
    return ChatResponse(text=text, intent=intent, confidence=confidence)
