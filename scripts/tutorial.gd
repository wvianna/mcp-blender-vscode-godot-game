extends Node
class_name Lab404Tutorial

## Tutorial de controles dentro do jogo (FR-029) — dicas sequenciais no HUD,
## avançadas pela ação `dialog_next` (Enter/Espaço/X).

signal hint_shown(text: String)
signal finished

const HINTS: PackedStringArray = [
    "Use WASD/setas ou o analógico esquerdo para se mover.",
    "Olhe em volta com o mouse ou com o analógico direito.",
    "Aproxime-se de um objeto e pressione E (ou X) para interagir.",
    "Esc (ou Start) abre o menu — com o diagnóstico de input.",
    "Objetivo: restaurar a comunicação do Laboratório 404.",
]

var _index := 0
var _active := false

func start() -> void:
    _index = 0
    _active = true
    Lab404Game.state.set_flag("tutorial_done", false)
    hint_shown.emit(current_hint())

func advance() -> bool:
    if not _active:
        return false
    _index += 1
    if _index >= HINTS.size():
        _active = false
        Lab404Game.state.set_flag("tutorial_done", true)
        Lab404Game.memory.remember_session("tutorial_done", true)
        finished.emit()
        return true
    hint_shown.emit(current_hint())
    return true

func is_active() -> bool:
    return _active

func current_hint() -> String:
    if _index >= HINTS.size():
        return ""
    return String(HINTS[_index])

func progress() -> String:
    return "%d/%d" % [mini(_index + 1, HINTS.size()), HINTS.size()]
