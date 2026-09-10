extends Node

## Encerramento combinado com `./stop.sh`.
##
## O Godot instalado por snap roda em um *user namespace* próprio: sinais externos
## (`kill`) são recusados com "Permissão negada", mesmo sendo o mesmo usuário.
## Por isso o `stop.sh` não mata o processo — ele cria `.run/stop` e este nó encerra
## o jogo com calma, deixando o Godot fechar janela/áudio do jeito dele.
##
## Em builds exportadas `res://` é o PCK: o arquivo nunca existe e nada acontece.

const STOP_FILE := "res://.run/stop"
const POLL_SECONDS := 0.4

var _elapsed := 0.0

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
    _elapsed += delta
    if _elapsed < POLL_SECONDS:
        return
    _elapsed = 0.0
    if FileAccess.file_exists(STOP_FILE):
        print("Lab404: encerramento solicitado por .run/stop — saindo.")
        get_tree().quit(0)
