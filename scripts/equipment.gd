extends Node3D
class_name Lab404Equipment

## Equipamento com estado serializável (FR-012/CA-008): OFF, FAULT, READY, RUNNING.
## O estado vive aqui e é espelhado no autoload `Lab404Game` (fonte de verdade para save/quests).
## Feedback visual: `Label3D` flutuante criado em tempo de execução (FR-014).

enum State { OFF, FAULT, READY, RUNNING }

signal state_changed(id: String, state: State)

@export var id := ""
@export var display_name := ""
@export var initial_state: State = State.OFF
@export var show_indicator := true
@export var indicator_height := 1.5

var state: State = State.OFF
var _indicator: Label3D = null

func _ready() -> void:
    state = initial_state
    if show_indicator:
        _indicator = Label3D.new()
        _indicator.font_size = 48
        _indicator.pixel_size = 0.006
        _indicator.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        _indicator.no_depth_test = true
        _indicator.position = Vector3(0.0, indicator_height, 0.0)
        add_child(_indicator)
    _refresh_indicator()
    Lab404Game.register_equipment(self)

func set_state(value: State) -> void:
    if state == value:
        return
    state = value
    _refresh_indicator()
    state_changed.emit(id, state)
    Lab404Game.notify_equipment_changed(id, state)

func state_name() -> String:
    return state_to_name(state)

static func state_to_name(value: State) -> String:
    match value:
        State.OFF:
            return "OFF"
        State.FAULT:
            return "FAULT"
        State.READY:
            return "READY"
        State.RUNNING:
            return "RUNNING"
    return "OFF"

static func state_from_name(name: String) -> State:
    match name:
        "FAULT":
            return State.FAULT
        "READY":
            return State.READY
        "RUNNING":
            return State.RUNNING
    return State.OFF

func state_label() -> String:
    match state:
        State.OFF:
            return "DESLIGADO"
        State.FAULT:
            return "FALHA"
        State.READY:
            return "PRONTO"
        State.RUNNING:
            return "EM OPERAÇÃO"
    return "?"

func serialize() -> Dictionary:
    return {"id": id, "state": state_to_name(state)}

func deserialize(data: Dictionary) -> void:
    set_state(state_from_name(String(data.get("state", "OFF"))))

func _refresh_indicator() -> void:
    if _indicator == null:
        return
    _indicator.text = "%s\n%s" % [display_name, state_label()]
    var color := Color(0.7, 0.75, 0.8)
    match state:
        State.OFF:
            color = Color(0.62, 0.64, 0.68)
        State.FAULT:
            color = Color(1.0, 0.45, 0.35)
        State.READY:
            color = Color(0.95, 0.85, 0.4)
        State.RUNNING:
            color = Color(0.45, 1.0, 0.6)
    _indicator.modulate = color
