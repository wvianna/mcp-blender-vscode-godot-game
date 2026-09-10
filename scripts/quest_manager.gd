extends Node
class_name Lab404QuestManager

## Missão RESTAURAR_COMUNICACAO (FR-013) — passos declarativos.
## Qualquer sistema conclui um passo pelo id; o HUD lê `status_lines()`/`objective_text()`.
## Passos só podem ser concluídos na ordem (evita progresso por acidente).

signal step_completed(step_id: String)
signal advanced(step_id: String)
signal completed

const MISSION_ID := "RESTAURAR_COMUNICACAO"

const STEPS: Array[Dictionary] = [
    {"id": "encontrar_fusivel", "text": "Localizar o fusível F-17"},
    {"id": "encontrar_modulo", "text": "Localizar o módulo RS-404"},
    {"id": "instalar_componentes", "text": "Instalar fusível e módulo no painel"},
    {"id": "reiniciar_clp", "text": "Reiniciar o CLP"},
    {"id": "diagnosticar_bomba", "text": "Diagnosticar a bomba hidráulica"},
    {"id": "abrir_porta", "text": "Abrir a porta do corredor"},
]

var _index := 0
var _done: Dictionary = {}

func current_index() -> int:
    return _index

func is_complete() -> bool:
    return _index >= STEPS.size()

func current_step() -> Dictionary:
    if is_complete():
        return {}
    return STEPS[_index]

func is_done(step_id: String) -> bool:
    return _done.has(step_id)

func complete(step_id: String) -> bool:
    if not _done.has(step_id):
        if not _is_reachable(step_id):
            return false
        _done[step_id] = true
        step_completed.emit(step_id)
    while _index < STEPS.size() and _done.has(String(STEPS[_index]["id"])):
        _index += 1
    if is_complete():
        completed.emit()
    else:
        advanced.emit(String(STEPS[_index]["id"]))
    return true

func status_lines() -> Array:
    var out: Array = []
    for i in STEPS.size():
        var id := String(STEPS[i]["id"])
        var done: bool = _done.has(id)
        out.append({
            "id": id,
            "text": String(STEPS[i]["text"]),
            "done": done,
            "current": i == _index,
            "marker": "[x]" if done else ("[>]" if i == _index else "[ ]"),
        })
    return out

func objective_text() -> String:
    if is_complete():
        return "Comunicação restaurada."
    return String(STEPS[_index]["text"])

func serialize() -> Dictionary:
    var done_ids: Array = []
    for key in _done.keys():
        done_ids.append(key)
    return {"index": _index, "done": done_ids}

func deserialize(data: Dictionary) -> void:
    _done.clear()
    for id in data.get("done", []):
        _done[String(id)] = true
    _index = clampi(int(data.get("index", 0)), 0, STEPS.size())
    while _index < STEPS.size() and _done.has(String(STEPS[_index]["id"])):
        _index += 1

func reset() -> void:
    _index = 0
    _done.clear()

func _is_reachable(step_id: String) -> bool:
    for i in STEPS.size():
        if String(STEPS[i]["id"]) == step_id:
            return i <= _index
    return false
