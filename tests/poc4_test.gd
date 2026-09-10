extends Node

## Teste automatizado do POC 4 (headless) — CA-011.
## Cobre: NPC reativo (FR-022), memória em quatro camadas (FR-023) e eventos de mundo (FR-024).

const MAIN_SCENE := "res://scenes/main.tscn"

var _checks := 0
var _failures: PackedStringArray = []

func _ready() -> void:
    await get_tree().process_frame
    Lab404Game.reset()

    var main = load(MAIN_SCENE).instantiate()
    get_tree().root.add_child(main)
    await _wait_physics(10)

    var level = main.get_node("Level")
    var hud = main.get_node("UI/HUD")
    var events = level.get_node_or_null("WorldEvents")
    _check("nó de eventos de mundo presente", events != null)

    print("== CA-011 / FR-022: NPC reage ao estado do laboratório ==")
    var npc = level.find_child("Npc", true, false)
    _check("NPC presente na sala", npc != null)
    if npc != null:
        var linha_inicial: String = npc.current_line()
        _check("NPC tem fala inicial", not linha_inicial.is_empty())
        Lab404Game.state.set_flag("fuse_installed", true)
        var linha_fusivel: String = npc.current_line()
        _check("fala muda após instalar o fusível", linha_fusivel != linha_inicial)
        Lab404Game.state.set_flag("plc_restarted", true)
        _check("fala prioriza o evento mais recente", "bomba" in npc.current_line().to_lower())
        _check("condição de flag avaliada corretamente", npc.condition_met("flag:plc_restarted"))
        _check("condição de missão ainda não satisfeita", not npc.condition_met("quest:abrir_porta"))

        for step in Lab404QuestManager.STEPS:
            Lab404Game.quest.complete(String(step["id"]))
        _check("fala final do NPC após a missão", "porta" in npc.current_line().to_lower())

    print("== CA-011 / FR-024: luzes conforme a energia ==")
    var light = level.get_node("Lights/ENV_Luz_Controle_A")
    Lab404Game.state.set_flag("power_restored", false)
    await _wait_process(2)
    var energia_emergencia: float = light.light_energy
    var cor_emergencia: Color = light.light_color
    _check("luz de emergência reduzida", energia_emergencia < 1.5)
    Lab404Game.state.set_flag("power_restored", true)
    await _wait_process(2)
    _check("luz forte com energia restaurada", light.light_energy > 2.0)
    _check("cor da luz muda com a energia", light.light_color != cor_emergencia)

    print("== CA-011 / FR-024: tom da ARIA após ignorar alerta ==")
    _check("alerta de energia avisado no HUD", hud.get_node("FeedbackLabel").visible)
    events.alert_timeout = 0.3
    Lab404Game.state.set_flag("aria_tone", "neutra")
    events.raise_alert("teste de alerta")
    _check("alerta registrado como ativo", events.is_alert_active())
    await _wait_seconds(0.7)
    _check(
        "tom muda para impaciente ao ignorar",
        String(Lab404Game.state.get_value("aria_tone")) == "impaciente"
    )
    _check(
        "alerta ignorado contabilizado na memória persistente",
        int(Lab404Game.memory.recall("ignored_alerts", 0)) >= 1
    )
    events.alert_timeout = 90.0
    events.raise_alert("segundo alerta")
    events.acknowledge_alert()
    _check("reconhecer o alerta devolve o tom neutro", String(Lab404Game.state.get_value("aria_tone")) == "neutra")
    _check("alerta deixa de estar ativo", not events.is_alert_active())

    print("== FR-023: memória em quatro camadas ==")
    var mem = Lab404Game.memory
    mem.clear()
    mem.remember_session("sessao", 1)
    mem.remember("persistente", 2)
    mem.learn("lore_bomba", "A bomba hidráulica alimenta o sistema de contenção.")
    mem.log("player", "teste")
    _check(
        "camadas independentes (sessão/persistente/narrativa/histórico)",
        mem.recall_session("sessao") == 1 and mem.recall("persistente") == 2
            and mem.knows("lore_bomba") and mem.history.size() == 1
    )
    var copia := Lab404MemoryStore.new()
    copia.from_dict(mem.to_dict())
    _check(
        "serialização preserva as quatro camadas",
        copia.recall_session("sessao") == 1 and copia.knows("lore_bomba") and copia.history.size() == 1
    )
    for i in 60:
        mem.log("aria", "linha %d" % i)
    _check(
        "histórico é limitado a %d entradas" % Lab404MemoryStore.HISTORY_LIMIT,
        mem.history.size() == Lab404MemoryStore.HISTORY_LIMIT
    )

    print("== FR-023: terminal alimenta a memória conversacional ==")
    var terminal = main.get_node("UI/ARIATerminal")
    terminal.open()
    terminal._on_submit("ARIA, qual é o estado do laboratório?")
    _check("mensagem do jogador registrada no histórico", Lab404Game.memory.recent().size() >= 1)
    terminal.close()

    _report()

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

func _wait_process(frames: int) -> void:
    for _i in frames:
        await get_tree().process_frame

func _wait_seconds(seconds: float) -> void:
    var fim := Time.get_ticks_msec() + int(seconds * 1000.0)
    while Time.get_ticks_msec() < fim:
        await get_tree().process_frame

func _report() -> void:
    print("")
    print("== RESULTADO POC 4: %d verificações, %d falha(s) ==" % [_checks, _failures.size()])
    for failure in _failures:
        print("  FALHA: %s" % failure)
    get_tree().quit(1 if _failures.size() > 0 else 0)
