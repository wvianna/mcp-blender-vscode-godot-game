extends Node3D
class_name Lab404Npc

## NPC que reage ao estado do laboratório (FR-022).
## A fala é escolhida pela primeira condição satisfeita, na ordem declarada em `lines`.

@export var speaker := "TÉCNICO"
@export var default_line := "…"
@export var lines: Dictionary = {}

func current_line() -> String:
    for condition in lines.keys():
        if condition_met(String(condition)):
            return String(lines[condition])
    return default_line

## Condições aceitas: `flag:<nome>` e `quest:<id do passo>`.
func condition_met(condition: String) -> bool:
    if condition.begins_with("flag:"):
        return Lab404Game.state.get_flag(condition.substr(5))
    if condition.begins_with("quest:"):
        return Lab404Game.quest.is_done(condition.substr(6))
    return false
