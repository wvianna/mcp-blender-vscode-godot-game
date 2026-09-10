extends Node

## Autoload `Lab404Game` — estado compartilhado do jogo (POC 2+).
## Mantém: estado/flags, inventário, missão, equipamentos e memória (POC 4).
## Nenhuma lógica de apresentação mora aqui.

var state: Lab404GameState
var inventory: Lab404Inventory
var quest: Lab404QuestManager
var memory: Lab404MemoryStore
var equipment: Dictionary = {}  # id -> Lab404Equipment

signal equipment_changed(id: String, state: int)

func _ready() -> void:
    state = Lab404GameState.new()
    inventory = Lab404Inventory.new()
    quest = Lab404QuestManager.new()
    memory = Lab404MemoryStore.new()
    add_child(state)
    add_child(inventory)
    add_child(quest)
    add_child(memory)

func register_equipment(node: Lab404Equipment) -> void:
    equipment[node.id] = node

func get_equipment(id: String) -> Lab404Equipment:
    return equipment.get(id)

func notify_equipment_changed(id: String, value: int) -> void:
    equipment_changed.emit(id, value)

func set_equipment_state(id: String, value: int) -> bool:
    var node: Lab404Equipment = equipment.get(id)
    if node == null:
        return false
    node.set_state(value)
    return true

## Restaura o estado inicial (usado por testes e pelo "novo jogo").
func reset() -> void:
    state.reset()
    inventory.clear()
    quest.reset()
    memory.clear()
    for id in equipment.keys():
        var node: Lab404Equipment = equipment[id]
        if is_instance_valid(node):
            node.set_state(Lab404Equipment.State.OFF)
