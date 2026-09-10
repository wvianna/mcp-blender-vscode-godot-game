extends Node3D
class_name Lab404VerticalSlice

## Fase final do vertical slice (POC 6): ao entrar no corredor, ARIA revela o contexto e uma
## ala procedural (POC 5) é gerada; no fim dela está o núcleo de ARIA, que abre o epílogo
## com escolha (FR-028/FR-032). Integra a geração procedural no jogo, em vez de deixá-la solta.

signal revelation(text: String)
signal epilogue_requested

const WING_SEED := 404
const WING_MODULES := 4

var wing: Lab404LabGenerator = null
var core_area: Lab404Interactable = null

var _trigger: Area3D = null

func _ready() -> void:
    _create_corridor_trigger()

func _create_corridor_trigger() -> void:
    _trigger = Area3D.new()
    _trigger.name = "CorridorTrigger"
    _trigger.collision_layer = 4  # layer 3: gatilhos de roteiro
    _trigger.collision_mask = 1   # detecta corpos do jogador
    _trigger.position = Vector3(13.5, 1.1, 3.0)
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(4.0, 2.4, 2.6)
    shape.shape = box
    _trigger.add_child(shape)
    _trigger.body_entered.connect(_on_body_entered)
    add_child(_trigger)

func _on_body_entered(body: Node3D) -> void:
    if wing != null or not (body is Lab404Player):
        return
    revelation.emit("ARIA: a comunicação voltou. Agora entenda o que o Laboratório 404 testava de verdade.")
    open_wing()

## Gera a ala procedural e planta o núcleo de ARIA no módulo de contenção.
func open_wing() -> Lab404LabGenerator:
    if wing != null:
        return wing
    wing = Lab404LabGenerator.new()
    wing.name = "AlaProcedural"
    wing.position = Vector3(16.5, 0.0, 0.0)
    add_child(wing)
    wing.generate(WING_SEED, WING_MODULES)
    _plant_core()
    return wing

func _plant_core() -> void:
    for poi in wing.all_pois():
        if String(poi["poi"]) != "nucleo_aria":
            continue
        var grid: Vector2i = poi["module"]
        var base: Vector3 = wing.module_at(grid)["position"] + wing.position
        var alvo := Node3D.new()
        alvo.name = "NucleoARIA"
        alvo.position = base + Vector3(4.0, 1.3, 4.0)
        wing.add_child(alvo)

        var area := Lab404Interactable.new()
        area.name = "InteractionArea"
        area.prompt = "NÚCLEO DE ARIA"
        area.collision_layer = 2
        area.collision_mask = 0
        var shape := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = Vector3(2.6, 2.6, 2.6)
        shape.shape = box
        area.add_child(shape)
        area.interacted.connect(func(_actor: Node) -> void: epilogue_requested.emit())
        alvo.add_child(area)
        core_area = area
        return
