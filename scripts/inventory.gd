extends Node
class_name Lab404Inventory

## Inventário diegético (kit técnico) — FR-010.
## Guarda apenas dados; a apresentação é responsabilidade do HUD.

signal changed
signal item_added(item_id: String, display_name: String)
signal item_removed(item_id: String)

var _items: Dictionary = {}  # item_id -> display_name

func add_item(item_id: String, display_name: String) -> bool:
    if _items.has(item_id):
        return false
    _items[item_id] = display_name
    item_added.emit(item_id, display_name)
    changed.emit()
    return true

func remove_item(item_id: String) -> bool:
    if not _items.has(item_id):
        return false
    _items.erase(item_id)
    item_removed.emit(item_id)
    changed.emit()
    return true

func has_item(item_id: String) -> bool:
    return _items.has(item_id)

func get_display_name(item_id: String) -> String:
    return String(_items.get(item_id, item_id))

func ids() -> PackedStringArray:
    var out: PackedStringArray = []
    for key in _items.keys():
        out.append(String(key))
    return out

func entries() -> Array:
    var out: Array = []
    for item_id in _items.keys():
        out.append({"id": item_id, "name": _items[item_id]})
    return out

func clear() -> void:
    _items.clear()
    changed.emit()

func to_dict() -> Dictionary:
    return _items.duplicate()

func from_dict(data: Dictionary) -> void:
    _items = data.duplicate()
    changed.emit()
