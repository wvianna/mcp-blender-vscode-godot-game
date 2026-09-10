extends Node3D
class_name Lab404SecurityCamera

## Câmera de segurança que passa a acompanhar o jogador quando ARIA "assume o controle"
## (doc de ambiente, §15 — Estado 4: "o laboratório está me observando").
## Fica parada até a comunicação ser restaurada; depois gira suavemente na direção do jogador.

signal tracking_changed(active: bool)

@export var target_path: NodePath = ^"../../Player"
@export var yaw_range_deg := 55.0
@export var turn_speed := 1.4

var _target: Node3D = null
var _base_yaw := 0.0
var _active := false

func _ready() -> void:
    _target = get_node_or_null(target_path) as Node3D
    _base_yaw = rotation.y
    Lab404Game.quest.completed.connect(_on_quest_completed)
    _set_active(Lab404Game.quest.is_complete())

func is_tracking() -> bool:
    return _active

func _on_quest_completed() -> void:
    _set_active(true)

func _set_active(value: bool) -> void:
    if _active == value:
        return
    _active = value
    tracking_changed.emit(_active)

func _process(delta: float) -> void:
    if not _active or _target == null:
        return
    var local := to_local(_target.global_position)
    if local.length_squared() < 0.01:
        return
    var limite := deg_to_rad(yaw_range_deg)
    var desejado := _base_yaw + clampf(atan2(-local.x, -local.z), -limite, limite)
    rotation.y = lerp_angle(rotation.y, desejado, clampf(turn_speed * delta, 0.0, 1.0))
