extends Control
class_name Lab404EpilogueUi

## UI do epílogo com escolha (FR-032). Depois da escolha, mostra o texto final
## e libera o encerramento da demonstração.

signal choice_made(choice: String)
signal restart_requested

@onready var _text: RichTextLabel = $Panel/Margin/VBox/Text
@onready var _buttons: VBoxContainer = $Panel/Margin/VBox/Buttons

func _ready() -> void:
    visible = false
    _text.text = "ARIA aguarda uma decisão sua.\n\nO núcleo está exposto e o laboratório, silencioso."
    for choice in Lab404Epilogue.CHOICES:
        var botao := Button.new()
        botao.name = "Btn_%s" % choice
        botao.text = label_for(choice)
        botao.pressed.connect(_on_choice.bind(choice))
        _buttons.add_child(botao)

func open() -> void:
    visible = true

func buttons() -> Array:
    return _buttons.get_children()

func final_text() -> String:
    return _text.text

static func label_for(choice: String) -> String:
    match choice:
        Lab404Epilogue.FOLLOW:
            return "Seguir as instruções de ARIA"
        Lab404Epilogue.REBOOT:
            return "Reiniciar o núcleo"
        _:
            return "Questionar ARIA"

## Exposto para testes: aplica a escolha como se o botão tivesse sido pressionado.
func choose(choice: String) -> void:
    _on_choice(choice)

func _on_choice(choice: String) -> void:
    _text.text = Lab404Epilogue.apply(choice)
    for child in _buttons.get_children():
        _buttons.remove_child(child)
        child.queue_free()
    var sair := Button.new()
    sair.name = "BtnFim"
    sair.text = "Encerrar demonstração"
    sair.pressed.connect(func() -> void: restart_requested.emit())
    _buttons.add_child(sair)
    choice_made.emit(choice)
