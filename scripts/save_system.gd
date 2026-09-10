extends RefCounted
class_name Lab404Save

## Save/load do progresso (FR-030) — JSON simples, sem banco de dados.
## Serializa todo o estado que importa para retomar a partida: flags, inventário,
## missão, memória (4 camadas) e estados de equipamento.

const DEFAULT_PATH := "user://lab404_save.json"
const VERSION := 1

static func save_game(path: String = DEFAULT_PATH) -> Error:
    var dados := {
        "version": VERSION,
        "saved_at": Time.get_datetime_string_from_system(),
        "state": Lab404Game.state.serialize(),
        "inventory": Lab404Game.inventory.to_dict(),
        "quest": Lab404Game.quest.serialize(),
        "memory": Lab404Game.memory.to_dict(),
        "equipment": equipment_snapshot(),
    }
    var arquivo := FileAccess.open(path, FileAccess.WRITE)
    if arquivo == null:
        return FileAccess.get_open_error()
    arquivo.store_string(JSON.stringify(dados, "  "))
    arquivo.close()
    return OK

static func load_game(path: String = DEFAULT_PATH) -> Error:
    if not FileAccess.file_exists(path):
        return ERR_FILE_NOT_FOUND
    var arquivo := FileAccess.open(path, FileAccess.READ)
    if arquivo == null:
        return FileAccess.get_open_error()
    var texto := arquivo.get_as_text()
    arquivo.close()

    var dados: Variant = JSON.parse_string(texto)
    if typeof(dados) != TYPE_DICTIONARY:
        return ERR_PARSE_ERROR

    Lab404Game.state.deserialize(dados.get("state", {}))
    Lab404Game.inventory.from_dict(dados.get("inventory", {}))
    Lab404Game.quest.deserialize(dados.get("quest", {}))
    Lab404Game.memory.from_dict(dados.get("memory", {}))
    restore_equipment(dados.get("equipment", {}))
    return OK

static func has_save(path: String = DEFAULT_PATH) -> bool:
    return FileAccess.file_exists(path)

static func delete_save(path: String = DEFAULT_PATH) -> void:
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

static func equipment_snapshot() -> Dictionary:
    var out: Dictionary = {}
    for id in Lab404Game.equipment.keys():
        var node: Lab404Equipment = Lab404Game.equipment[id]
        if is_instance_valid(node):
            out[String(id)] = node.serialize()
    return out

static func restore_equipment(dados: Dictionary) -> void:
    for id in dados.keys():
        var node: Lab404Equipment = Lab404Game.get_equipment(String(id))
        if node != null and dados[id] is Dictionary:
            node.deserialize(dados[id])
