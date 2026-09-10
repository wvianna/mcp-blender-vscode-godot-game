extends Control
class_name Lab404Hud

## HUD (FR-006 + POC 2): objetivo com passos, prompt contextual, feedback e kit técnico.
## Apenas apresentação — nenhuma regra de jogo mora aqui.

@onready var objective_label: Label = $ObjectivePanel/Margin/VBox/ObjectiveLabel
@onready var steps_list: VBoxContainer = $ObjectivePanel/Margin/VBox/Steps
@onready var prompt_label: Label = $PromptLabel
@onready var feedback_label: Label = $FeedbackLabel
@onready var feedback_timer: Timer = $FeedbackTimer
@onready var inventory_list: VBoxContainer = $InventoryPanel/Margin/VBox/Items

func _ready() -> void:
    feedback_timer.timeout.connect(_on_feedback_timeout)

func set_objective(text: String) -> void:
    objective_label.text = text

## `lines` vem de `Lab404QuestManager.status_lines()`.
func set_steps(lines: Array) -> void:
    _clear(steps_list)
    for line in lines:
        var label := Label.new()
        label.text = "%s %s" % [line.get("marker", "[ ]"), line.get("text", "")]
        label.add_theme_font_size_override("font_size", 13)
        if line.get("done", false):
            label.modulate = Color(0.68, 0.78, 0.7, 0.85)
        elif line.get("current", false):
            label.modulate = Color(0.65, 0.98, 0.72)
        else:
            label.modulate = Color(0.72, 0.75, 0.78, 0.7)
        steps_list.add_child(label)

## `entries` vem de `Lab404Inventory.entries()` (FR-010 — kit técnico).
func set_inventory(entries: Array) -> void:
    _clear(inventory_list)
    if entries.is_empty():
        var empty := Label.new()
        empty.text = "(vazio)"
        empty.add_theme_font_size_override("font_size", 13)
        empty.modulate = Color(0.6, 0.62, 0.65)
        inventory_list.add_child(empty)
        return
    for entry in entries:
        var label := Label.new()
        label.text = "· %s" % entry.get("name", entry.get("id", "?"))
        label.add_theme_font_size_override("font_size", 13)
        label.modulate = Color(0.8, 0.88, 0.8)
        inventory_list.add_child(label)

func show_prompt(text: String) -> void:
    prompt_label.text = text
    prompt_label.visible = true

func clear_prompt() -> void:
    prompt_label.visible = false

func show_feedback(text: String) -> void:
    feedback_label.text = text
    feedback_label.visible = true
    feedback_timer.wait_time = 3.0
    feedback_timer.start()

## Diálogo de NPC (POC 4): mesmo espaço do feedback, com duração maior.
func show_dialogue(speaker: String, text: String) -> void:
    feedback_label.text = "%s: %s" % [speaker, text]
    feedback_label.visible = true
    feedback_timer.wait_time = 8.0
    feedback_timer.start()

func _on_feedback_timeout() -> void:
    feedback_label.visible = false

func _clear(node: Node) -> void:
    for child in node.get_children():
        node.remove_child(child)
        child.queue_free()
