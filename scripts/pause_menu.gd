extends Control
class_name Lab404PauseMenu

## Menu de pausa (FR-005 / CA-003).
## Fica em `process_mode = ALWAYS` para continuar recebendo input com a árvore pausada.
## Esc (teclado) e Start (joystick) chegam pela ação semântica `pause` (FR-001).

signal resume_requested
signal input_test_requested
signal quit_requested

@onready var _btn_continue: Button = $Center/Panel/Margin/VBox/BtnContinue
@onready var _btn_input_test: Button = $Center/Panel/Margin/VBox/BtnInputTest
@onready var _btn_quit: Button = $Center/Panel/Margin/VBox/BtnQuit

func _ready() -> void:
    _btn_continue.pressed.connect(_on_continue_pressed)
    _btn_input_test.pressed.connect(_on_input_test_pressed)
    _btn_quit.pressed.connect(_on_quit_pressed)

func open() -> void:
    visible = true
    _btn_continue.grab_focus()

func close() -> void:
    visible = false

func _unhandled_input(event: InputEvent) -> void:
    # Só reage quando visível; caso contrário o `main.gd` trata a abertura.
    if not visible:
        return
    if event.is_action_pressed("pause"):
        resume_requested.emit()
        get_viewport().set_input_as_handled()

func _on_continue_pressed() -> void:
    resume_requested.emit()

func _on_input_test_pressed() -> void:
    input_test_requested.emit()

func _on_quit_pressed() -> void:
    quit_requested.emit()
