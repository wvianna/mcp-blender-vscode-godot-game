extends Area3D
class_name Lab404Interactable

## Interactable desacoplado (FR-009/CA-006).
## O `interaction.gd` do player detecta pelo raycast, o HUD mostra `get_prompt()`
## e a ação semântica `interact` chama `interact(actor)` → emite `interacted`.
## Requisitos opcionais (item) bloqueiam o uso e explicam o motivo.

signal interacted(actor: Node)
signal blocked(reason: String)

@export var prompt := "INTERAGIR"
@export var requires_item := ""
@export var consumed_item := ""
@export var one_shot := false

var used := false

func get_prompt() -> String:
    if used and one_shot:
        return ""
    if requires_item != "" and not Lab404Game.inventory.has_item(requires_item):
        return "%s — requer %s" % [prompt, Lab404Game.inventory.get_display_name(requires_item)]
    return prompt

func can_interact() -> bool:
    if used and one_shot:
        return false
    if requires_item != "" and not Lab404Game.inventory.has_item(requires_item):
        return false
    return true

func interact(actor: Node) -> void:
    if not can_interact():
        blocked.emit("Requer: %s" % Lab404Game.inventory.get_display_name(requires_item))
        return
    if consumed_item != "":
        Lab404Game.inventory.remove_item(consumed_item)
    used = true
    interacted.emit(actor)
