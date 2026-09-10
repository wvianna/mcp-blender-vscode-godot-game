#!/usr/bin/env bash
# Executa o teste automatizado do POC 1 (headless).
#
# Uso:
#   tests/run_poc1.sh
#   GODOT=/caminho/para/godot tests/run_poc1.sh
#
# Saída: relatório PASS/FALHA no stdout; código de saída 0 = tudo passou.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot4}"

if ! command -v "$GODOT" >/dev/null 2>&1; then
    echo "Godot não encontrado. Defina GODOT=/caminho/do/godot." >&2
    exit 127
fi

cd "$ROOT"

# 1ª execução: importa recursos e gera o cache de class_name (`.godot/` não é versionado).
"$GODOT" --headless --path . --import >/dev/null 2>&1 || true

# Executa o teste (a cena chama `quit(0|1)`).
"$GODOT" --headless --path . res://tests/poc1_test.tscn
