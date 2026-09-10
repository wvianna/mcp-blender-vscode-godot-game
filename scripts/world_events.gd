extends Node
class_name Lab404WorldEvents

## Eventos de mundo (FR-024): luzes conforme a energia e tom da ARIA conforme alertas.
## Portas já são governadas por flags no `Lab404Door` (FR-011).

signal alert_raised(text: String)

@export var lights_path: NodePath = ^"../Lights"
@export var accents_path: NodePath = ^"../Accents"
## Tempo que o jogador pode ignorar um alerta antes de a ARIA mudar de tom.
@export var alert_timeout := 90.0
## Luz operacional (energia restaurada) e instabilidade (sem energia).
@export var power_energy := 2.6
@export var power_color := Color(0.90, 0.92, 0.95)
@export var emergency_energy := 1.1
@export var emergency_color := Color(0.58, 0.66, 0.82)
## Acentos: beacons de emergência (vermelhos) e detalhes fixos (ciano/âmbar).
@export var beacon_energy := 1.8
@export var accent_energy := 1.5

var _alert_active := false
var _alert_elapsed := 0.0
var _flicker_time := 0.0

func _ready() -> void:
    Lab404Game.state.flag_changed.connect(_on_flag_changed)
    Lab404Game.quest.step_completed.connect(_on_step_completed)
    _apply_power()

func _process(delta: float) -> void:
    _flicker(delta)
    if not _alert_active:
        return
    _alert_elapsed += delta
    if _alert_elapsed >= alert_timeout:
        _alert_active = false
        Lab404Game.state.set_flag("aria_tone", "impaciente")
        Lab404Game.memory.remember("ignored_alerts", int(Lab404Game.memory.recall("ignored_alerts", 0)) + 1)
        alert_raised.emit("ARIA: você ignorou meu alerta. Vou ser mais breve daqui em diante.")

## Instabilidade (doc §15, estado 2): uma luminária oscila enquanto falta energia.
func _flicker(delta: float) -> void:
    _flicker_time += delta
    if Lab404Game.state.get_flag("power_restored"):
        return
    var lights := get_node_or_null(lights_path)
    if lights == null or lights.get_child_count() < 2:
        return
    var alvo := lights.get_child(1) as OmniLight3D
    if alvo == null:
        return
    alvo.light_energy = emergency_energy * (0.55 + 0.45 * absf(sin(_flicker_time * 7.0)))

func raise_alert(text: String) -> void:
    _alert_active = true
    _alert_elapsed = 0.0
    alert_raised.emit("ARIA: %s" % text)

func acknowledge_alert() -> void:
    _alert_active = false
    if String(Lab404Game.state.get_value("aria_tone", "neutra")) == "impaciente":
        Lab404Game.state.set_flag("aria_tone", "neutra")

func is_alert_active() -> bool:
    return _alert_active

func _on_flag_changed(key: String, value: Variant) -> void:
    if key == "power_restored" and bool(value):
        _apply_power()
        raise_alert("energia estabilizada; não permaneça no corredor.")

func _on_step_completed(_step_id: String) -> void:
    # Progresso da missão acalma a ARIA — ela volta a confiar no técnico.
    if String(Lab404Game.state.get_value("aria_tone", "neutra")) == "impaciente":
        Lab404Game.state.set_flag("aria_tone", "preocupada")

## Camadas de luz (doc §2/§18): operacional branca ↔ instabilidade; beacons vermelhos na
## emergência e acentos ciano/âmbar sempre presentes (sistemas ativos × sistemas em falha).
func _apply_power() -> void:
    var ligado := Lab404Game.state.get_flag("power_restored")

    var lights := get_node_or_null(lights_path)
    if lights != null:
        for child in lights.get_children():
            var light := child as OmniLight3D
            if light == null:
                continue
            light.light_energy = power_energy if ligado else emergency_energy
            light.light_color = power_color if ligado else emergency_color

    var accents := get_node_or_null(accents_path)
    if accents != null:
        for child in accents.get_children():
            var acento := child as OmniLight3D
            if acento == null:
                continue
            if String(acento.name).contains("Emg"):
                acento.light_energy = 0.0 if ligado else beacon_energy
            else:
                acento.light_energy = accent_energy
