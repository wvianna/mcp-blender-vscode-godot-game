extends CharacterBody3D
class_name Lab404Player

## Controlador do jogador (POC 1).
## - Movimento: teclado (WASD/setas) + analógico esquerdo via ações semânticas (FR-002).
## - Câmera: mouse + analógico direito via ações `look_*` (FR-003).
## - Gravidade e colisão pelo CharacterBody3D/move_and_slide (FR-004).
## Proibido ler índices crus de botão/eixo aqui (FR-001/NFR-005): o Input Map é a única porta.

@export var speed := 4.0
@export var run_speed := 6.5
@export var gravity := 18.0
@export var mouse_sensitivity := 0.0025
## Velocidade de rotação da câmera com o analógico direito (rad/s no curso máximo).
@export var stick_sensitivity := 2.5
@export var pitch_limit_deg := 85.0

@onready var camera_pivot: Node3D = $CameraPivot

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _apply_look(event.relative.x * mouse_sensitivity, -event.relative.y * mouse_sensitivity)

func _physics_process(delta: float) -> void:
    _apply_stick_look(delta)
    _apply_gravity(delta)
    _apply_movement()
    move_and_slide()

func _apply_stick_look(delta: float) -> void:
    # Analógico direito só existe em parte dos adaptadores; sem eixos, o vetor vem zero.
    var look := Input.get_vector("look_left", "look_right", "look_up", "look_down")
    if look.is_zero_approx():
        return
    _apply_look(look.x * stick_sensitivity * delta, -look.y * stick_sensitivity * delta)

## Gira o corpo (yaw) e inclina a câmera (pitch). Exposto para testes.
func _apply_look(yaw_delta: float, pitch_delta: float) -> void:
    rotate_y(-yaw_delta)
    var limit := deg_to_rad(pitch_limit_deg)
    camera_pivot.rotation.x = clampf(camera_pivot.rotation.x + pitch_delta, -limit, limit)

func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta

func _apply_movement() -> void:
    var input_vec := Input.get_vector(
        "move_left", "move_right",
        "move_forward", "move_backward"
    )

    var direction := Vector3(input_vec.x, 0.0, input_vec.y)
    direction = global_transform.basis * direction
    direction.y = 0.0
    direction = direction.normalized()

    var current_speed := run_speed if Input.is_action_pressed("run") else speed

    velocity.x = direction.x * current_speed
    velocity.z = direction.z * current_speed
