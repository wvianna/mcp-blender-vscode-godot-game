extends Node
class_name Lab404Interaction

## Interação por raycast (POC 1 — mínimo para a "área de teste" do ROADMAP).
## - `focus_changed`: o alvo interativo sob a mira mudou (alimenta o prompt do HUD, FR-006).
## - `interacted`: a ação `interact` acionou um alvo que expõe `interact(who)`.
## O sistema `Interactable` completo (T-011/FR-009) substitui este mínimo no POC 2.

signal interacted(target: Node3D)
signal focus_changed(target: Node3D)

@export var ray_path: NodePath = ^"../InteractionRay"

var _ray: RayCast3D = null
var _focus: Node3D = null

func _ready() -> void:
    _ray = get_node_or_null(ray_path) as RayCast3D

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        try_interact()

func _physics_process(_delta: float) -> void:
    var target := get_focus_target()
    if target == _focus:
        return
    _focus = target
    focus_changed.emit(_focus)

## Aciona o alvo sob a mira quando ele expõe `interact(who)`. Exposto para testes.
func try_interact() -> bool:
    var target := get_focus_target()
    if target == null:
        return false
    target.interact(get_parent())
    interacted.emit(target)
    return true

func get_focus_target() -> Node3D:
    if _ray == null or not _ray.is_colliding():
        return null
    var collider := _ray.get_collider()
    if collider is Node3D and collider.has_method("interact"):
        return collider as Node3D
    return null
