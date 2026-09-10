extends Node
class_name Lab404MemoryStore

## Memória em quatro camadas (FR-023), separadas de propósito:
## - `session`: efêmera (reiniciada a cada execução);
## - `persistent`: estado salvo junto com o jogo;
## - `narrative`: o que o jogador/ARIA já sabem (lore revelada);
## - `history`: histórico conversacional com ARIA (limitado).

const HISTORY_LIMIT := 40

var session: Dictionary = {}
var persistent: Dictionary = {}
var narrative: Dictionary = {}
var history: Array = []

func remember_session(key: String, value: Variant) -> void:
    session[key] = value

func recall_session(key: String, default: Variant = null) -> Variant:
    return session.get(key, default)

func remember(key: String, value: Variant) -> void:
    persistent[key] = value

func recall(key: String, default: Variant = null) -> Variant:
    return persistent.get(key, default)

func learn(topic: String, text: String) -> void:
    narrative[topic] = text

func knows(topic: String) -> bool:
    return narrative.has(topic)

func knowledge() -> Dictionary:
    return narrative.duplicate()

func log(role: String, text: String) -> void:
    history.append({"role": role, "text": text, "t": Time.get_unix_time_from_system()})
    while history.size() > HISTORY_LIMIT:
        history.pop_front()

func recent(limit: int = 6) -> Array:
    return history.slice(maxi(0, history.size() - limit))

func clear() -> void:
    session.clear()
    persistent.clear()
    narrative.clear()
    history.clear()

func to_dict() -> Dictionary:
    return {
        "session": session.duplicate(),
        "persistent": persistent.duplicate(),
        "narrative": narrative.duplicate(),
        "history": history.duplicate(),
    }

func from_dict(data: Dictionary) -> void:
    session = data.get("session", {}).duplicate()
    persistent = data.get("persistent", {}).duplicate()
    narrative = data.get("narrative", {}).duplicate()
    history = data.get("history", []).duplicate()
