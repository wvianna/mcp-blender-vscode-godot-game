extends Node3D
class_name Lab404Door

## Porta deslizante com trava por flag de estado (FR-011).
## Vive como nó FILHO do objeto importado do GLB (sufixo `-col`) e move o PAI por tween,
## para que a colisão caminhe junto com o visual.

signal opened
signal closed

@export var offset := Vector3(0.0, 2.15, 0.0)
@export var duration := 1.2
@export var locked := true
@export var unlocked_by_flag := "pump_ok"

var is_open := false

var _target: Node3D = null
var _closed_position := Vector3.ZERO
var _tween: Tween = null

func _ready() -> void:
    _target = get_parent() as Node3D
    if _target != null:
        _closed_position = _target.position

func is_locked() -> bool:
    return locked and not Lab404Game.state.get_flag(unlocked_by_flag)

func try_open() -> bool:
    if is_open:
        return true
    if is_locked():
        return false
    open()
    return true

func open() -> void:
    if is_open or _target == null:
        return
    is_open = true
    _set_visible(true)
    # `hide_on_arrive`: a folha corre para dentro do batente; mantê-la visível faria
    # ela reaparecer pela fenda do vão (o vão é mais alto que o batente decorativo).
    _move_to(_closed_position + offset, true)
    opened.emit()

func close() -> void:
    if not is_open or _target == null:
        return
    is_open = false
    _set_visible(true)
    _move_to(_closed_position)
    closed.emit()

func _set_visible(value: bool) -> void:
    if _target != null:
        _target.visible = value

func _move_to(target_position: Vector3, hide_on_arrive: bool = false) -> void:
    if _tween != null and _tween.is_valid():
        _tween.kill()
    _tween = create_tween()
    _tween.tween_property(_target, "position", target_position, duration)
    if hide_on_arrive:
        _tween.tween_callback(_set_visible.bind(false))
