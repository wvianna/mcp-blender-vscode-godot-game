extends Node

## Teste de integração AO VIVO do POC 3 (opcional, não faz parte da suíte padrão).
##
## Precisa do adapter de ARIA em execução (e um modelo no Ollama):
##   LAB404_MODEL=llama3.1:8b .venv/bin/uvicorn scripts.aria_adapter:app --port 8000 &
##   godot4 --headless --path . res://tests/poc3_live_test.tscn
##
## Sem adapter, encerra como IGNORADO (código 0): a suíte padrão não depende de rede.

const MAIN_SCENE := "res://scenes/main.tscn"
const BUDGET_SECONDS := 60.0

var _checks := 0
var _failures: PackedStringArray = []

func _ready() -> void:
    await get_tree().process_frame
    Lab404Game.reset()

    var main = load(MAIN_SCENE).instantiate()
    get_tree().root.add_child(main)
    await _wait_process(5)

    var terminal = main.get_node("UI/ARIATerminal")
    var client = terminal.get_node("Client")

    var recebidas: Array = []
    var falhas: Array = []
    client.reply_received.connect(func(text: String, intent: String) -> void:
        recebidas.append({"text": text, "intent": intent})
    )
    client.reply_failed.connect(func(reason: String) -> void:
        falhas.append(reason)
    )

    terminal.open()
    terminal._on_submit("ARIA, o que devo fazer primeiro no laboratório?")
    print("== POC 3 AO VIVO: mensagem enviada, aguardando o modelo local ==")

    var inicio := Time.get_ticks_msec()
    while recebidas.is_empty() and (Time.get_ticks_msec() - inicio) < int(BUDGET_SECONDS * 1000.0):
        await get_tree().process_frame

    if recebidas.is_empty():
        print("== POC 3 AO VIVO: IGNORADO (sem resposta em %.0f s — adapter fora do ar?) ==" % BUDGET_SECONDS)
        get_tree().quit(0)
        return

    var resposta: Dictionary = recebidas[0]
    var texto := String(resposta["text"])
    var intent := String(resposta["intent"])
    var decorrido := (Time.get_ticks_msec() - inicio) / 1000.0

    # Fallback significa adapter fora do ar: teste ao vivo é ignorado, não reprovado.
    if texto == AriaClient.FALLBACK_TEXT:
        print("== POC 3 AO VIVO: IGNORADO (adapter indisponível — resposta foi o fallback) ==")
        print("  motivo: %s" % (", ".join(falhas) if not falhas.is_empty() else "sem detalhe"))
        get_tree().quit(0)
        return

    print("== POC 3 AO VIVO: resposta em %.1f s ==" % decorrido)
    print("  texto: %s" % texto.substr(0, 200))
    print("  intent: %s" % intent)

    _check("resposta não vazia", not texto.is_empty())
    _check("intent dentro de ALLOWED_INTENTS (%s)" % intent, intent in AriaClient.ALLOWED_INTENTS)
    _check("não foi o fallback padrão", texto != AriaClient.FALLBACK_TEXT)
    _check("falhas de transporte: %d" % falhas.size(), true)
    _check("conversa registrada no histórico (>2 entradas)", Lab404Game.memory.recent().size() >= 2)

    _report()

func _check(label: String, condition: bool) -> void:
    _checks += 1
    if condition:
        print("  [PASS] %s" % label)
    else:
        _failures.append(label)
        print("  [FALHA] %s" % label)

func _wait_process(frames: int) -> void:
    for _i in frames:
        await get_tree().process_frame

func _report() -> void:
    print("")
    print("== RESULTADO POC 3 AO VIVO: %d verificações, %d falha(s) ==" % [_checks, _failures.size()])
    for failure in _failures:
        print("  FALHA: %s" % failure)
    get_tree().quit(1 if _failures.size() > 0 else 0)
