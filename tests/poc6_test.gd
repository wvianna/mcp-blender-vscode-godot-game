extends Node

## Teste automatizado do POC 6 (headless) — vertical slice.
## Roteiro: tutorial → missão completa → corredor → ala procedural → núcleo → epílogo → save/load.
## Evidência automatizada de CA-013; o playthrough humano ainda é pendência MANUAL.

const MAIN_SCENE := "res://scenes/main.tscn"
const SAVE_PATH := "user://poc6_test_save.json"

var _checks := 0
var _failures: PackedStringArray = []

func _ready() -> void:
    await get_tree().process_frame
    Lab404Game.reset()
    Lab404Save.delete_save(SAVE_PATH)

    var main = load(MAIN_SCENE).instantiate()
    get_tree().root.add_child(main)
    await _wait_physics(20)

    var player = main.get_node("Player")
    var level = main.get_node("Level")
    var hud = main.get_node("UI/HUD")
    var tutorial = main.get_node("Tutorial")
    var vertical = level.get_node("VerticalSlice")
    var epilogue_ui = main.get_node("UI/Epilogue")

    print("== FR-029: tutorial de controles ==")
    _check("tutorial ativo no início", tutorial.is_active())
    _check("dica inicial exibida no HUD", hud.get_node("FeedbackLabel").visible)
    var dicas := 0
    while tutorial.is_active() and dicas < 20:
        dicas += 1
        tutorial.advance()
    _check("tutorial concluído (%d dicas)" % dicas, not tutorial.is_active())
    _check("flag tutorial_done registrada", Lab404Game.state.get_flag("tutorial_done"))
    _check("marcado na memória de sessão", Lab404Game.memory.recall_session("tutorial_done", false))

    print("== FR-028/FR-013: missão completa por interação real ==")
    await _executar_missao(player, level)
    _check("missão concluída", Lab404Game.quest.is_complete())
    _check("comunicação restaurada", Lab404Game.state.get_flag("communication_restored"))

    print("== FR-031: áudio ==")
    _check("efeitos carregados (porta, coleta)", Lab404Sfx.has_sound("door") and Lab404Sfx.has_sound("pickup"))
    _check("ambiência disponível (hum)", Lab404Sfx.has_sound("hum"))

    print("== FR-030: save/load ==")
    var err := Lab404Save.save_game(SAVE_PATH)
    _check("save gravado (erro=%d)" % err, err == OK and Lab404Save.has_save(SAVE_PATH))
    var indice_salvo: int = Lab404Game.quest.current_index()
    Lab404Game.reset()
    _check("estado zerado antes do load", not Lab404Game.quest.is_complete())
    err = Lab404Save.load_game(SAVE_PATH)
    _check("load aplicado (erro=%d)" % err, err == OK)
    _check("missão restaurada", Lab404Game.quest.is_complete() and Lab404Game.quest.current_index() == indice_salvo)
    _check("flags restauradas", Lab404Game.state.get_flag("communication_restored"))
    _check(
        "equipamento restaurado (bomba RUNNING)",
        Lab404Game.get_equipment("bomba").state == Lab404Equipment.State.RUNNING
    )
    _check("memória narrativa restaurada", Lab404Game.memory.knows("bomba"))
    level.apply_state()
    _check("mundo reconciliado com o save", Lab404Game.state.get_flag("pump_ok"))

    print("== FR-028/FR-032: corredor → ala procedural → núcleo → epílogo ==")
    player.set_physics_process(true)
    player.global_position = Vector3(13.5, 0.3, 3.0)  # dentro do gatilho do corredor
    player.velocity = Vector3.ZERO
    await _wait_physics(20)

    _check("ala procedural gerada ao entrar no corredor", vertical.wing != null)
    if vertical.wing != null:
        _check("ala com módulos (%d)" % vertical.wing.modules.size(), vertical.wing.modules.size() >= 2)
        _check("ala conectada (FR-027)", vertical.wing.verify_connectivity())
    _check("núcleo de ARIA plantado", vertical.core_area != null)
    _check("revelação registrada na memória narrativa", Lab404Game.memory.knows("revelacao"))

    var interagiu := false
    if vertical.core_area != null:
        await _aproximar(player, vertical.core_area)
        interagiu = player.get_node("Interaction").try_interact()
    _check("interação com o núcleo de ARIA", interagiu)
    _check("UI do epílogo aberta", epilogue_ui.visible)
    _check("três escolhas disponíveis", epilogue_ui.buttons().size() == 3)

    var seguir: String = Lab404Epilogue.text_for(Lab404Epilogue.FOLLOW)
    var questionar: String = Lab404Epilogue.text_for(Lab404Epilogue.QUESTION)
    var reiniciar: String = Lab404Epilogue.text_for(Lab404Epilogue.REBOOT)
    _check(
        "textos do epílogo distintos por escolha",
        seguir != questionar and questionar != reiniciar and seguir != reiniciar
    )

    epilogue_ui.choose(Lab404Epilogue.QUESTION)
    _check("escolha registrada na flag de estado", String(Lab404Game.state.get_value("epilogue")) == "questionar")
    _check("escolha registrada na memória persistente", String(Lab404Game.memory.recall("epilogue", "")) == "questionar")
    _check("texto final do epílogo exibido", "hesita" in epilogue_ui.final_text())
    _check("encerramento liberado após a escolha", epilogue_ui.buttons().size() == 1)

    Lab404Save.delete_save(SAVE_PATH)
    _report()

# --- roteiro da missão -------------------------------------------------------

func _executar_missao(player: Node, level: Node) -> void:
    var interaction = player.get_node("Interaction")
    var passos := [
        "INT_Fusivel_F17", "INT_Modulo_RS404", "PROP_Painel",
        "PROP_CLP", "PROP_Bomba", "ENV_Porta_Corredor",
    ]
    for nome in passos:
        var alvo = _interactable_of(level, nome)
        await _aproximar(player, alvo)
        interaction.try_interact()

# --- utilidades --------------------------------------------------------------

func _interactable_of(level: Node, node_name: String) -> Node:
    var node := level.find_child(node_name, true, false)
    if node == null:
        return null
    return node.get_node_or_null("InteractionArea")

func _aproximar(player: Node, interactable: Node) -> void:
    if interactable == null:
        return
    var alvo: Vector3 = interactable.global_position
    var space: PhysicsDirectSpaceState3D = player.get_world_3d().direct_space_state
    var interaction = player.get_node("Interaction")
    for candidato in _candidatos(alvo):
        if not _posicao_livre(space, player, candidato):
            continue
        _teleportar(player, candidato, alvo)
        await _wait_physics(8)
        if interaction.get_focus_target() == interactable:
            return
    push_warning("POC6: não foi possível mirar %s" % interactable.get_parent().name)

func _candidatos(alvo: Vector3) -> Array:
    return [
        Vector3(alvo.x, 0.1, alvo.z + 1.7),
        Vector3(alvo.x, 0.1, alvo.z - 1.7),
        Vector3(alvo.x + 1.7, 0.1, alvo.z),
        Vector3(alvo.x - 1.7, 0.1, alvo.z),
        Vector3(alvo.x + 1.2, 0.1, alvo.z + 1.2),
        Vector3(alvo.x - 1.2, 0.1, alvo.z + 1.2),
        Vector3(alvo.x + 1.2, 0.1, alvo.z - 1.2),
        Vector3(alvo.x - 1.2, 0.1, alvo.z - 1.2),
    ]

func _teleportar(player: Node, posicao: Vector3, alvo: Vector3) -> void:
    player.global_position = posicao
    player.rotation = Vector3.ZERO
    player.get_node("CameraPivot").rotation = Vector3.ZERO
    player.velocity = Vector3.ZERO
    player.look_at(Vector3(alvo.x, posicao.y, alvo.z), Vector3.UP)

func _posicao_livre(space: PhysicsDirectSpaceState3D, player: Node, ponto: Vector3) -> bool:
    var params := PhysicsPointQueryParameters3D.new()
    params.position = ponto + Vector3(0.0, 0.9, 0.0)
    params.collision_mask = 1
    params.exclude = [player.get_rid()]
    return space.intersect_point(params, 1).is_empty()

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
    print("== RESULTADO POC 6: %d verificações, %d falha(s) ==" % [_checks, _failures.size()])
    for failure in _failures:
        print("  FALHA: %s" % failure)
    get_tree().quit(1 if _failures.size() > 0 else 0)
