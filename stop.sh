#!/usr/bin/env bash
# Encerra o jogo e o adapter de ARIA iniciados por ./start.sh.
#
# Como funciona: o Godot do snap roda confinado e RECUSA sinais externos
# ("Permissão negada", mesmo com SIGKILL). Então o encerramento é combinado:
# este script cria `.run/stop`, o jogo detecta (autoload `Lab404QuitWatch`) e sai
# sozinho. Se isso não bastar, tenta sinais e o fechamento da janela (wmctrl),
# e por fim orienta o comando manual com sudo.
#
# Uso:
#   ./stop.sh              # encerramento limpo (padrão)
#   LAB404_STOP_TIMEOUT=20 ./stop.sh
#
# Código de saída: 0 se tudo encerrou; 1 se o jogo resistiu.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_DIR="$ROOT/.run"
GAME_PID_FILE="$RUN_DIR/game.pid"
ARIA_PID_FILE="$RUN_DIR/aria.pid"
STOP_FILE="$RUN_DIR/stop"
TIMEOUT_GAME="${LAB404_STOP_TIMEOUT:-12}"

mkdir -p "$RUN_DIR"

# `/proc` em vez de `kill -0`: checar permissão com sinal 0 falha (EPERM) para
# processos confinados pelo snap mesmo estando vivos.
esta_encerrado() {
    local pid="$1"
    [ -d "/proc/$pid" ] || return 0
    local estado
    estado="$(awk '{print $3}' "/proc/$pid/stat" 2>/dev/null)"
    [ -z "$estado" ] && return 0
    [ "$estado" = "Z" ] && return 0
    return 1
}

# esperar_saida <pid> <segundos>
esperar_saida() {
    local pid="$1" limite="$2" i=0
    local passos=$((limite * 2))
    while [ "$i" -lt "$passos" ]; do
        esta_encerrado "$pid" && return 0
        sleep 0.5
        i=$((i + 1))
    done
    return 1
}

forcar_jogo() {
    local pid="$1"
    echo "  tentando sinais (o snap costuma recusar)…"
    kill -TERM "$pid" 2>/dev/null
    esperar_saida "$pid" 4 && { echo "  encerrado por SIGTERM."; return 0; }
    kill -KILL "$pid" 2>/dev/null
    esperar_saida "$pid" 4 && { echo "  encerrado por SIGKILL."; return 0; }

    if command -v wmctrl >/dev/null 2>&1; then
        echo "  tentando fechar a janela (wmctrl)…"
        wmctrl -c "Laboratório 404" 2>/dev/null || wmctrl -c "Godot" 2>/dev/null || true
        esperar_saida "$pid" 8 && { echo "  janela fechada."; return 0; }
    fi

    if command -v xwininfo >/dev/null 2>&1 && command -v xkill >/dev/null 2>&1; then
        echo "  tentando encerrar a janela via X11 (xkill)…"
        local wid
        wid="$(xwininfo -root -tree 2>/dev/null | grep -iE '"(laborat|godot)' | awk '{print $1}' | head -1)"
        if [ -n "$wid" ]; then
            xkill -id "$wid" >/dev/null 2>&1 || true
            esperar_saida "$pid" 8 && { echo "  janela encerrada via xkill."; return 0; }
        fi
    fi

    echo "  ATENÇÃO: o jogo continua em execução (PID $pid)."
    echo "  Confinamento do snap + sem gerenciador de janelas acessível. Use: sudo kill -9 $pid"
    return 1
}

STATUS=0

# --- jogo --------------------------------------------------------------------

game_pid=""
if [ -f "$GAME_PID_FILE" ]; then
    game_pid="$(cat "$GAME_PID_FILE")"
fi

if [ -n "$game_pid" ] && ! esta_encerrado "$game_pid"; then
    : >"$STOP_FILE"
    echo "Jogo: pedindo encerramento limpo (.run/stop)…"
    if esperar_saida "$game_pid" "$TIMEOUT_GAME"; then
        echo "Jogo: encerrado (PID $game_pid)."
    else
        forcar_jogo "$game_pid" || STATUS=1
    fi
    rm -f "$GAME_PID_FILE"
else
    # Sem PID registrado pode haver jogo iniciado à mão: o pedido vale igualmente.
    : >"$STOP_FILE"
    echo "Jogo: sem PID ativo registrado (iniciado em outro terminal?). Pedido .run/stop criado."
fi
rm -f "$STOP_FILE"

# --- adapter de ARIA ---------------------------------------------------------

if [ -f "$ARIA_PID_FILE" ]; then
    aria_pid="$(cat "$ARIA_PID_FILE")"
    if esta_encerrado "$aria_pid"; then
        echo "Adapter de ARIA: já não estava rodando."
    else
        kill -TERM "$aria_pid" 2>/dev/null
        if esperar_saida "$aria_pid" 5; then
            echo "Adapter de ARIA: encerrado (PID $aria_pid)."
        else
            kill -KILL "$aria_pid" 2>/dev/null
            if esperar_saida "$aria_pid" 3; then
                echo "Adapter de ARIA: encerrado à força (PID $aria_pid)."
            else
                echo "Adapter de ARIA: não encerrou (PID $aria_pid)." >&2
                STATUS=1
            fi
        fi
    fi
    rm -f "$ARIA_PID_FILE"
else
    echo "Adapter de ARIA: não estava rodando (sem PID registrado)."
fi

exit "$STATUS"
