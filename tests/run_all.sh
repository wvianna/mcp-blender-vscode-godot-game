#!/usr/bin/env bash
# Executa toda a suíte automatizada (headless).
#
# Uso:
#   tests/run_all.sh
#   GODOT=/caminho/para/godot tests/run_all.sh
#
# Código de saída 0 = todas as cenas de teste passaram.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot4}"

if ! command -v "$GODOT" >/dev/null 2>&1; then
    echo "Godot não encontrado. Defina GODOT=/caminho/do/godot." >&2
    exit 127
fi

cd "$ROOT"

# 1ª execução: importa recursos (GLB, WAV) e gera o cache de class_name.
"$GODOT" --headless --path . --import >/dev/null 2>&1 || true

status=0
SCENE_TIMEOUT="${LAB404_TEST_TIMEOUT:-180}"
for scene in tests/poc[0-9]_test.tscn; do
    echo ""
    echo "### $scene"
    # PIDs que já existiam (resíduos de execuções anteriores não contam como travamento atual).
    antes="$(pgrep -f "res://$scene" 2>/dev/null | sort -u | tr '\n' ' ' || true)"

    # `timeout` evita que uma cena com erro de script trave a suíte inteira.
    if ! timeout "$SCENE_TIMEOUT" "$GODOT" --headless --path . "res://$scene"; then
        status=1
    fi

    # O snap do Godot recusa sinais (EPERM), então o `timeout` pode não encerrar a cena
    # travada: pedimos a saída pelo mesmo canal do stop.sh (autoload Lab404QuitWatch).
    depois="$(pgrep -f "res://$scene" 2>/dev/null | sort -u | tr '\n' ' ' || true)"
    if [ "$antes" != "$depois" ]; then
        echo "  cena resistiu ao timeout — pedindo encerramento via .run/stop"
        mkdir -p .run
        : >.run/stop
        sleep 2
        rm -f .run/stop
        restante="$(pgrep -f "res://$scene" 2>/dev/null | sort -u | tr '\n' ' ' || true)"
        if [ "$restante" != "$antes" ]; then
            echo "  ATENÇÃO: processo ainda ativo; use: sudo pkill -9 -f 'res://$scene'" >&2
            status=1
        else
            echo "  cena encerrada pelo pedido de parada"
        fi
    fi
done

# Testes do adapter Python (ignorados se o venv não existir).
if [ -x ".venv/bin/python" ]; then
    echo ""
    echo "### tests/test_aria_adapter.py"
    if ! timeout 120 ".venv/bin/python" tests/test_aria_adapter.py; then
        status=1
    fi
fi

echo ""
if [ "$status" -eq 0 ]; then
    echo "SUÍTE COMPLETA: OK"
else
    echo "SUÍTE COMPLETA: FALHAS (ver acima)"
fi
exit "$status"
