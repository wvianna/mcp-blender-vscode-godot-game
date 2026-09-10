extends Node
class_name Lab404GameState

## Flags de estado global do laboratório (serializáveis).
## Valores podem ser bool, int ou String (ex.: `aria_tone`), daí `Variant`.

signal flag_changed(key: String, value: Variant)

const DEFAULTS := {
    "power_restored": false,
    "communication_restored": false,
    "plc_restarted": false,
    "aria_trusted": 0,
    "fuse_installed": false,
    "module_installed": false,
    "pump_ok": false,
    "aria_tone": "neutra",
    "epilogue": "",
}

var flags: Dictionary = DEFAULTS.duplicate()

func set_flag(key: String, value: Variant) -> void:
    if flags.get(key) == value:
        return
    flags[key] = value
    flag_changed.emit(key, value)

func get_flag(key: String) -> bool:
    return bool(flags.get(key, false))

func get_value(key: String, default: Variant = null) -> Variant:
    return flags.get(key, default)

func reset() -> void:
    flags = DEFAULTS.duplicate()

func serialize() -> Dictionary:
    return flags.duplicate()

func deserialize(data: Dictionary) -> void:
    flags = DEFAULTS.duplicate()
    for key in data.keys():
        flags[key] = data[key]
