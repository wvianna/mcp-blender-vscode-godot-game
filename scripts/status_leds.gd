extends Node
class_name Lab404StatusLeds

## Pisca LEDs de status do laboratório (FR-014: feedback visual).
##
## O glTF não anima emissão de material (só posição/rotação/escala), então o "piscamento"
## documentado no detalhamento do ambiente é feito aqui: os LEDs são nós separados no GLB
## e este script alterna a visibilidade deles em períodos diferentes, dando a impressão de
## equipamento operando (verde piscando, âmbar oscilando, vermelho de alarme).

@export var led_paths: Array[NodePath] = []
## Período (s) de cada LED; o índice dá a volta na lista.
@export var periods: PackedFloat32Array = PackedFloat32Array([1.4, 0.9, 2.2, 3.0])
## Fração do período em que o LED fica aceso.
@export_range(0.05, 1.0, 0.01) var on_ratio := 0.6

var _leds: Array[Node3D] = []

func _ready() -> void:
    for caminho in led_paths:
        var no := get_node_or_null(caminho) as Node3D
        if no != null:
            _leds.append(no)

## Quantidade de LEDs resolvidos (usado pelos testes).
func led_count() -> int:
    return _leds.size()

## Estado do LED `index` no instante `seconds` — determinístico, o que torna o piscamento testável.
func is_lit(index: int, seconds: float) -> bool:
    if _leds.is_empty():
        return false
    var periodo := 1.0
    if periods.size() > 0:
        periodo = periods[index % periods.size()]
    if periodo <= 0.0:
        periodo = 1.0
    return fmod(seconds, periodo) < periodo * on_ratio

func _process(_delta: float) -> void:
    var agora := Time.get_ticks_msec() / 1000.0
    for i in _leds.size():
        _leds[i].visible = is_lit(i, agora)
