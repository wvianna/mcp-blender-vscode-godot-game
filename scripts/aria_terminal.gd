extends Control
class_name Lab404AriaTerminal

## Terminal de ARIA (FR-019): histórico, entrada de texto e resposta do adapter.
## O tom da ARIA (FR-024) e o objetivo atual vão no `game_state` enviado ao adapter.
## O jogo continua rodando; apenas o movimento do jogador é suspenso enquanto aberto.

@onready var _history: RichTextLabel = $Panel/Margin/VBox/History
@onready var _input: LineEdit = $Panel/Margin/VBox/InputRow/Input
@onready var _status: Label = $Panel/Margin/VBox/Status
@onready var _client: AriaClient = $Client

var _player: Node = null

func _ready() -> void:
    _client.reply_received.connect(_on_reply)
    _client.reply_failed.connect(_on_failed)
    _input.text_submitted.connect(_on_submit)
    visible = false

## Recebe o jogador para suspender/retomar o movimento (chamado pelo `main.gd`).
func setup_player(player: Node) -> void:
    _player = player

func open() -> void:
    visible = true
    _input.grab_focus()
    if _player != null:
        _player.set_physics_process(false)
    if _history.text.is_empty():
        _append("SISTEMA", "Terminal do Laboratório 404 — canal restrito.")
        _append("ARIA", "Sistema online. Você não deveria estar aqui.")
    _status.text = "canal: %s" % _client.endpoint

func close() -> void:
    visible = false
    if _player != null:
        _player.set_physics_process(true)

func is_open() -> bool:
    return visible

func _unhandled_input(event: InputEvent) -> void:
    if not visible:
        return
    if event.is_action_pressed("cancel") or event.is_action_pressed("pause"):
        close()
        get_viewport().set_input_as_handled()

func _on_submit(text: String) -> void:
    var message := text.strip_edges()
    if message.is_empty():
        return
    _input.clear()
    _append("VOCÊ", message)
    Lab404Game.memory.log("player", message)
    Lab404Sfx.play("ui")
    if not _client.ask(message, game_state()):
        _status.text = "aguarde a resposta anterior"
        return
    _status.text = "ARIA está processando…"

## Contexto enviado ao adapter (mantém a LLM informada, sem dar controle a ela).
func game_state() -> Dictionary:
    return {
        "objective": Lab404Game.quest.objective_text(),
        "flags": Lab404Game.state.serialize(),
        "tone": Lab404Game.state.get_value("aria_tone", "neutra"),
        "inventory": Lab404Game.inventory.ids(),
    }

func _on_reply(text: String, intent: String) -> void:
    _append("ARIA", text)
    Lab404Game.memory.log("aria", text)
    _status.text = "intent: %s" % intent
    Lab404Sfx.play("ui")

func _on_failed(reason: String) -> void:
    _status.text = "offline — %s" % reason

func _append(speaker: String, text: String) -> void:
    _history.append_text("[b]%s:[/b] %s\n" % [speaker, text])
