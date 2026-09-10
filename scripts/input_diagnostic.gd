extends Control
class_name Lab404InputDiagnostic

## Tela de diagnóstico/calibração de input (FR-007/FR-008) — cena `scenes/input_test.tscn`.
##
## É a ÚNICA parte do projeto autorizada a ler índices crus de eixo/botão: o objetivo dela
## é justamente mapear adaptadores PS1→USB desconhecidos (ver `config/input_map.md`).
## O gameplay continua proibido de usar índices (FR-001/NFR-005).

signal closed

@export var default_deadzone := 0.15

const TRACKED_ACTIONS: PackedStringArray = [
    "move_forward", "move_backward", "move_left", "move_right",
    "look_left", "look_right", "look_up", "look_down",
    "interact", "cancel", "run", "flashlight", "inventory", "pause", "dialog_next",
]
const RAW_AXIS_COUNT := 8
const RAW_BUTTON_COUNT := 16

var deadzone := 0.15
var _standalone := false
var _hotplug_message := "hotplug: nenhum evento desde a abertura"

@onready var _status_label: Label = $Margin/VBox/StatusLabel
@onready var _devices_label: Label = $Margin/VBox/Columns/DevicesCol/DevicesLabel
@onready var _axes_label: Label = $Margin/VBox/Columns/AxesCol/AxesLabel
@onready var _buttons_label: Label = $Margin/VBox/Columns/ButtonsCol/ButtonsLabel
@onready var _deadzone_slider: HSlider = $Margin/VBox/DeadzoneRow/DeadzoneSlider
@onready var _deadzone_value: Label = $Margin/VBox/DeadzoneRow/DeadzoneValue

func _ready() -> void:
    Input.joy_connection_changed.connect(_on_joy_connection_changed)
    _deadzone_slider.value_changed.connect(_on_deadzone_changed)
    _deadzone_slider.value = default_deadzone
    _apply_deadzone(default_deadzone)
    _status_label.text = _hotplug_message

    # Executada sozinha (F6/CLI), age como tela cheia; instanciada no menu, começa oculta.
    _standalone = get_tree().current_scene == self
    if _standalone:
        visible = true

func _process(_delta: float) -> void:
    _refresh_devices()
    _refresh_axes()
    _refresh_buttons()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not visible:
        return
    if event.is_action_pressed("cancel") or event.is_action_pressed("pause"):
        _close()
        get_viewport().set_input_as_handled()

## Hotplug: registra o evento e atualiza a lista sem quebrar a execução (FR-008).
func _on_joy_connection_changed(device: int, connected: bool) -> void:
    var verb := "CONECTADO" if connected else "DESCONECTADO"
    _hotplug_message = "hotplug: joystick %d %s às %s" % [
        device, verb, Time.get_time_string_from_system()
    ]
    _status_label.text = _hotplug_message
    _refresh_devices()

## Zona morta configurável (FR-007), padrão 0.15. Exposto para testes.
func _on_deadzone_changed(value: float) -> void:
    _apply_deadzone(value)

func _apply_deadzone(value: float) -> void:
    deadzone = value
    for action in TRACKED_ACTIONS:
        if InputMap.has_action(action):
            InputMap.action_set_deadzone(action, value)
    _deadzone_value.text = "%.2f" % value

func _close() -> void:
    if _standalone:
        get_tree().quit()
        return
    visible = false
    closed.emit()

func _refresh_devices() -> void:
    var pads := Input.get_connected_joypads()
    if pads.is_empty():
        _devices_label.text = "(nenhum joystick conectado)"
        return
    var lines: PackedStringArray = []
    for id in pads:
        lines.append("#%d  %s" % [id, Input.get_joy_name(id)])
    _devices_label.text = "\n".join(lines)

func _refresh_axes() -> void:
    var pad := _first_pad_id()
    if pad < 0:
        _axes_label.text = "(sem joystick: eixos indisponíveis)"
        return
    var lines: PackedStringArray = []
    for axis in RAW_AXIS_COUNT:
        lines.append("eixo %d: %+.2f" % [axis, Input.get_joy_axis(pad, axis)])
    _axes_label.text = "\n".join(lines)

func _refresh_buttons() -> void:
    var pad := _first_pad_id()
    if pad < 0:
        _buttons_label.text = "(sem joystick: botões indisponíveis)"
        return
    var pressed: PackedStringArray = []
    for button in RAW_BUTTON_COUNT:
        if Input.is_joy_button_pressed(pad, button):
            pressed.append(str(button))
    _buttons_label.text = "pressionados: [%s]" % (
        ", ".join(pressed) if not pressed.is_empty() else "—"
    )

func _first_pad_id() -> int:
    var pads := Input.get_connected_joypads()
    return int(pads[0]) if not pads.is_empty() else -1

func _draw() -> void:
    var base_y := size.y - 130.0
    _draw_pad(Vector2(size.x * 0.5 - 170.0, base_y), "ANALÓGICO L", 0, 1)
    _draw_pad(Vector2(size.x * 0.5 + 170.0, base_y), "ANALÓGICO R", 2, 3)

func _draw_pad(center: Vector2, label: String, axis_x: int, axis_y: int) -> void:
    var half := 90.0
    var rect := Rect2(center - Vector2(half, half), Vector2(half * 2.0, half * 2.0))
    draw_rect(rect, Color(0.07, 0.09, 0.09, 1.0), true)
    draw_rect(rect, Color(0.35, 0.5, 0.42, 1.0), false, 2.0)
    draw_circle(center, half * deadzone, Color(0.3, 0.5, 0.42, 0.25))
    draw_line(center - Vector2(half, 0.0), center + Vector2(half, 0.0), Color(0.3, 0.5, 0.42, 0.5))
    draw_line(center - Vector2(0.0, half), center + Vector2(0.0, half), Color(0.3, 0.5, 0.42, 0.5))

    var pad := _first_pad_id()
    var text := label
    if pad >= 0:
        var stick := Vector2(Input.get_joy_axis(pad, axis_x), Input.get_joy_axis(pad, axis_y))
        draw_circle(center + stick * half, 7.0, Color(0.6, 1.0, 0.7, 1.0))
        text += "  (%.2f, %.2f)" % [stick.x, stick.y]
    else:
        text += "  (sem joystick)"
    draw_string(
        ThemeDB.fallback_font,
        center + Vector2(-half, -half - 10.0),
        text,
        HORIZONTAL_ALIGNMENT_LEFT,
        -1,
        16,
        Color(0.75, 0.95, 0.8, 1.0)
    )
