#!/usr/bin/env bash
# Inicia o Laboratório 404: adapter de ARIA (opcional) + jogo Godot.
#
# Uso:
#   ./start.sh                # jogo + adapter de ARIA (se o .venv existir)
#   ./start.sh --no-aria      # só o jogo
#   ./start.sh --fg           # jogo em primeiro plano (Ctrl+C encerra o jogo)
#   GODOT=/caminho/do/godot ./start.sh
#
# Logs e PIDs ficam em .run/ — encerre com ./stop.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_DIR="$ROOT/.run"
GODOT="${GODOT:-godot4}"
PORT="${LAB404_PORT:-8000}"

# Processos do snap recusam sinais (EPERM), então checamos via /proc — e não com `kill -0`.
esta_rodando() {
    local pid="$1"
    [ -d "/proc/$pid" ] || return 1
    local estado
    estado="$(awk '{print $3}' "/proc/$pid/stat" 2>/dev/null)"
    [ -n "$estado" ] && [ "$estado" != "Z" ]
}

GAME_PID_FILE="$RUN_DIR/game.pid"
ARIA_PID_FILE="$RUN_DIR/aria.pid"
GAME_LOG="$RUN_DIR/game.log"
ARIA_LOG="$RUN_DIR/aria.log"

WITH_ARIA=1
FOREGROUND=0

for arg in "$@"; do
    case "$arg" in
        --no-aria) WITH_ARIA=0 ;;
        --fg|--foreground) FOREGROUND=1 ;;
        -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
        *) echo "Argumento desconhecido: $arg (use --help)" >&2; exit 2 ;;
    esac
done

if ! command -v "$GODOT" >/dev/null 2>&1; then
    echo "Godot não encontrado. Defina GODOT=/caminho/do/godot." >&2
    exit 127
fi

if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
    echo "Sem display (DISPLAY/WAYLAND_DISPLAY): o jogo precisa de interface gráfica." >&2
    exit 1
fi

mkdir -p "$RUN_DIR"

# Pedido de parada anterior não pode derrubar a instância que está começando.
rm -f "$RUN_DIR/stop"

if [ -f "$GAME_PID_FILE" ] && esta_rodando "$(cat "$GAME_PID_FILE")"; then
    echo "O jogo já está rodando (PID $(cat "$GAME_PID_FILE")). Use ./stop.sh para encerrar." >&2
    exit 1
fi

# Primeira execução após clonar: importa GLB/WAV sem abrir janela.
if [ ! -d "$ROOT/.godot/imported" ]; then
    echo "Primeira execução: importando recursos…"
    "$GODOT" --headless --path "$ROOT" --import >/dev/null 2>&1 || true
fi

# Adapter de ARIA (POC 3): sem ele o jogo exibe o fallback — não é obrigatório.
if [ "$WITH_ARIA" -eq 1 ]; then
    if [ -x "$ROOT/.venv/bin/uvicorn" ]; then
        if [ -f "$ARIA_PID_FILE" ] && esta_rodando "$(cat "$ARIA_PID_FILE")"; then
            echo "Adapter de ARIA já estava rodando (PID $(cat "$ARIA_PID_FILE"))."
        else
            # `exec` para que o PID registrado seja o do uvicorn (e não o de uma subshell):
            # sem isso o `stop.sh` encerraria a subshell e deixaria o uvicorn órfão.
            ( cd "$ROOT" && exec nohup ".venv/bin/uvicorn" scripts.aria_adapter:app --port "$PORT" ) \
                >"$ARIA_LOG" 2>&1 &
            echo $! >"$ARIA_PID_FILE"
            echo "Adapter de ARIA: http://127.0.0.1:$PORT (log: .run/aria.log)"
        fi
    else
        echo "Aviso: .venv não encontrado — ARIA responderá com o texto de fallback."
    fi
fi

if [ "$FOREGROUND" -eq 1 ]; then
    echo "Iniciando o jogo em primeiro plano (Ctrl+C encerra o jogo; ./stop.sh encerra o adapter)."
    exec "$GODOT" --path "$ROOT"
fi

nohup "$GODOT" --path "$ROOT" >"$GAME_LOG" 2>&1 &
echo $! >"$GAME_PID_FILE"
echo "Jogo iniciado (PID $(cat "$GAME_PID_FILE")), log em .run/game.log."
echo "Controles: WASD/setas + mouse — E interage, Esc pausa, F5 salva, F9 carrega."
echo "Para encerrar: ./stop.sh"
