extends Node

## Teste automatizado do POC 3 (headless) — CA-009/CA-010.
## Não exige Ollama nem adapter em execução: valida as regras e o caminho de fallback.

const MAIN_SCENE := "res://scenes/main.tscn"

var _checks := 0
var _failures: PackedStringArray = []

func _ready() -> void:
    await get_tree().process_frame
    Lab404Game.reset()

    var main = load(MAIN_SCENE).instantiate()
    get_tree().root.add_child(main)
    await _wait_physics(10)

    var terminal = main.get_node_or_null("UI/ARIATerminal")
    _check("terminal de ARIA presente na cena", terminal != null)
    if terminal == null:
        _report()
        return
    var player = main.get_node("Player")
    var client = terminal.get_node_or_null("Client")
    _check("cliente HTTP presente", client != null)

    print("== CA-010: intents restritas ==")
    _check("intents permitidas conforme SPECIFICATION §6", _allowed_intents_ok())
    _check("sanitize: 'hint' → HINT", AriaClient.sanitize_intent("hint") == "HINT")
    _check("sanitize: ' DIAGNOSE ' → DIAGNOSE", AriaClient.sanitize_intent(" DIAGNOSE ") == "DIAGNOSE")
    _check("sanitize: 'EXECUTE' → NONE", AriaClient.sanitize_intent("EXECUTE") == "NONE")
    _check("sanitize: vazio → NONE", AriaClient.sanitize_intent("") == "NONE")

    print("== CA-009: adapter indisponível → fallback sem travar ==")
    var recebidas: Array = []
    var falhas: Array = []
    client.reply_received.connect(func(text: String, intent: String) -> void:
        recebidas.append({"text": text, "intent": intent})
    )
    client.reply_failed.connect(func(reason: String) -> void:
        falhas.append(reason)
    )

    var inicio := Time.get_ticks_msec()
    var enviado: bool = client.ask("ARIA, qual é o estado do laboratório?")
    _check("requisição enviada ao adapter", enviado)
    _check("cliente marcado como ocupado", client.is_busy())

    var limite_ms := int(client.timeout_seconds * 1000.0) + 4000
    while recebidas.is_empty() and Time.get_ticks_msec() - inicio < limite_ms:
        await get_tree().process_frame

    var decorrido := Time.get_ticks_msec() - inicio
    _check(
        "CA-009: resposta em %.2fs (< limite de %.1fs)" % [decorrido / 1000.0, limite_ms / 1000.0],
        not recebidas.is_empty() and decorrido < limite_ms
    )
    if not recebidas.is_empty():
        var texto := String(recebidas[0]["text"])
        var intent := String(recebidas[0]["intent"])
        _check("CA-009: resposta textual não vazia", not texto.is_empty())
        if texto == AriaClient.FALLBACK_TEXT:
            # Cenário exigido por CA-009: adapter/Ollama fora do ar.
            _check("CA-009: intent do fallback é NONE", intent == "NONE")
            _check("falha registrada para diagnóstico", not falhas.is_empty())
        else:
            # Ambiente de desenvolvimento com o adapter no ar: valida o caminho real
            # (as verificações de fallback acima valem com o adapter desligado).
            _check("CA-010: intent real em ALLOWED_INTENTS (%s)" % intent, intent in AriaClient.ALLOWED_INTENTS)
            print("  (nota: adapter online — verificações de fallback puladas neste ambiente)")
    _check("cliente liberado após a resposta", not client.is_busy())

    print("== FR-019/FR-021: terminal abre, envia e fecha ==")
    terminal.open()
    _check("terminal aberto", terminal.is_open())
    _check("movimento do jogador suspenso com o terminal aberto", not player.is_physics_processing())
    var contexto: Dictionary = terminal.game_state()
    _check("contexto enviado tem objetivo", contexto.has("objective"))
    _check("contexto enviado tem tom da ARIA", contexto.has("tone"))
    _check("contexto enviado tem flags de estado", contexto.has("flags"))
    _check("contexto enviado tem inventário", contexto.has("inventory"))
    terminal.close()
    _check("terminal fechado", not terminal.is_open())
    _check("movimento do jogador retomado", player.is_physics_processing())

    print("== FR-020: personalidade versionada fora dos scripts ==")
    var caminho := "res://config/aria_personality.json"
    _check("arquivo de personalidade existe", FileAccess.file_exists(caminho))
    var conteudo := FileAccess.get_file_as_string(caminho)
    _check("personalidade contém prompt base", "base_prompt" in conteudo)
    _check("personalidade contém tons", "tones" in conteudo)
    _check("personalidade contém fallback", "fallback_text" in conteudo)

    _report()

func _allowed_intents_ok() -> bool:
    var esperado := ["HINT", "DIAGNOSE", "LORE", "STATUS", "NONE"]
    if AriaClient.ALLOWED_INTENTS.size() != esperado.size():
        return false
    for intent in esperado:
        if intent not in AriaClient.ALLOWED_INTENTS:
            return false
    return true

func _check(label: String, condition: bool) -> void:
    _checks += 1
    if condition:
        print("  [PASS] %s" % label)
    else:
        _failures.append(label)
        print("  [FALHA] %s" % label)

func _wait_physics(frames: int) -> void:
    for _i in frames:
        await get_tree().physics_frame

func _report() -> void:
    print("")
    print("== RESULTADO POC 3: %d verificações, %d falha(s) ==" % [_checks, _failures.size()])
    for failure in _failures:
        print("  FALHA: %s" % failure)
    get_tree().quit(1 if _failures.size() > 0 else 0)
