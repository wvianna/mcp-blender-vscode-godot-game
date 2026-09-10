extends Node

## Teste automatizado do POC 2 (headless) — evidência para CA-006…CA-008.
## Execução: `tests/run_all.sh` (ou `godot4 --headless --path . res://tests/poc2_test.tscn`).

const MAIN_SCENE := "res://scenes/main.tscn"

var _checks := 0
var _failures: PackedStringArray = []

func _ready() -> void:
    await get_tree().process_frame
    Lab404Game.reset()

    var main = load(MAIN_SCENE).instantiate()
    get_tree().root.add_child(main)
    await _wait_physics(20)

    var level = main.get_node("Level")
    var player = main.get_node("Player")
    var hud = main.get_node("UI/HUD")

    print("== FR-015 / FR-012: sala do Blender e equipamentos ==")
    _check("GLB do Blender instanciado no nível", level.get_node_or_null("LabGLB") != null)
    _check(
        "equipamentos registrados (CLP e bomba)",
        Lab404Game.get_equipment("clp") != null and Lab404Game.get_equipment("bomba") != null
    )
    _check(
        "CA-008: CLP inicia em FAULT",
        Lab404Game.get_equipment("clp").state == Lab404Equipment.State.FAULT
    )
    _check(
        "FR-013: passo futuro não pode ser concluído fora de ordem",
        not Lab404Game.quest.complete("abrir_porta")
    )

    print("== CA-006: prompt contextual e interação por raycast ==")
    var fusivel = _interactable_of(level, "INT_Fusivel_F17")
    _check("interactable do fusível existe", fusivel != null)
    await _aproximar(player, fusivel)
    _check("prompt visível perto do item", hud.get_node("PromptLabel").visible)
    _check("prompt contextual do item (contém PEGAR)", "PEGAR" in String(hud.get_node("PromptLabel").text))
    var ok = player.get_node("Interaction").try_interact()
    _check("item coletado pelo raycast", ok and Lab404Game.inventory.has_item("fusivel_f17"))
    _check(
        "FR-010: kit técnico atualizado no HUD",
        hud.get_node("InventoryPanel/Margin/VBox/Items").get_child_count() > 0
    )
    _check("FR-013: passo 'encontrar_fusivel' concluído", Lab404Game.quest.is_done("encontrar_fusivel"))

    var modulo = _interactable_of(level, "INT_Modulo_RS404")
    await _aproximar(player, modulo)
    player.get_node("Interaction").try_interact()
    _check("FR-010: módulo RS-404 coletado", Lab404Game.inventory.has_item("modulo_rs404"))

    print("== CA-007: instalação no painel e progresso da missão ==")
    var painel = _interactable_of(level, "PROP_Painel")
    await _aproximar(player, painel)
    player.get_node("Interaction").try_interact()
    _check(
        "fusível e módulo instalados no painel",
        Lab404Game.state.get_flag("fuse_installed") and Lab404Game.state.get_flag("module_installed")
    )
    _check("passo 'instalar_componentes' concluído", Lab404Game.quest.is_done("instalar_componentes"))
    _check("itens consumidos saíram do inventário", not Lab404Game.inventory.has_item("fusivel_f17"))

    print("== CA-008: estados de equipamento serializáveis ==")
    var clp_area = _interactable_of(level, "PROP_CLP")
    await _aproximar(player, clp_area)
    player.get_node("Interaction").try_interact()
    _check(
        "CLP em RUNNING após reinício",
        Lab404Game.get_equipment("clp").state == Lab404Equipment.State.RUNNING
    )
    var dados = Lab404Game.get_equipment("clp").serialize()
    _check("estado serializável (state=RUNNING)", String(dados.get("state", "")) == "RUNNING")

    print("== FR-013: diagnóstico da bomba e porta do corredor ==")
    var bomba = _interactable_of(level, "PROP_Bomba")
    await _aproximar(player, bomba)
    player.get_node("Interaction").try_interact()
    _check(
        "bomba em RUNNING após diagnóstico",
        Lab404Game.get_equipment("bomba").state == Lab404Equipment.State.RUNNING
    )
    _check("porta destravada após o diagnóstico", not level.door.is_locked())

    var porta = _interactable_of(level, "ENV_Porta_Corredor")
    await _aproximar(player, porta)
    player.get_node("Interaction").try_interact()
    _check("FR-011: porta aberta", level.door.is_open)
    _check("FR-013: missão concluída", Lab404Game.quest.is_complete())
    _check(
        "objetivo final refletido no HUD",
        "restaurada" in String(hud.get_node("ObjectivePanel/Margin/VBox/ObjectiveLabel").text).to_lower()
    )

    print("== FR-015a / FR-024a: identidade visual e iluminação em camadas ==")
    var luzes = level.get_node_or_null("Lights")
    _check("FR-024a: luminárias gerais presentes", luzes != null and luzes.get_child_count() >= 6)
    var alinhadas := 0
    if luzes != null:
        for luz in luzes.get_children():
            if luz is OmniLight3D and absf(luz.position.z + 1.5) < 0.6:
                alinhadas += 1
    _check("FR-024a: %d luminárias sobre a fileira central do GLB" % alinhadas, alinhadas >= 5)

    var acentos = level.get_node_or_null("Accents")
    _check("FR-024a: acentos por zona presentes", acentos != null and acentos.get_child_count() >= 6)
    var cores := {}
    if acentos != null:
        for luz in acentos.get_children():
            if luz is OmniLight3D:
                cores[String(luz.light_color.to_html(false))] = true
    _check("FR-024a: acentos com cores distintas (%d)" % cores.size(), cores.size() >= 3)

    var rotulos = level.get_node_or_null("Labels")
    var textos: Array = []
    if rotulos != null:
        for rotulo in rotulos.get_children():
            if rotulo is Label3D and not String(rotulo.text).strip_edges().is_empty() \
                    and rotulo.billboard != BaseMaterial3D.BILLBOARD_DISABLED:
                textos.append(String(rotulo.text))
    _check("FR-015a: letreiros billboard legíveis (%d)" % textos.size(), textos.size() >= 6)
    var esperados: Array = ["TK-01", "NÍVEL 42%", "PLC-01", "BOMBA-01", "B1", "ARIA"]
    var faltando: Array = []
    for esperado in esperados:
        if not textos.has(esperado):
            faltando.append(esperado)
    _check(
        "FR-015a: letreiros das estações esperadas%s" % ("" if faltando.is_empty() else " (faltam: %s)" % ", ".join(faltando)),
        faltando.is_empty()
    )

    print("== FR-024b: câmera de segurança acompanha o jogador ==")
    var camera_seg = level.get_node_or_null("CAM_Security")
    _check("FR-024b: câmera de segurança presente no nível", camera_seg is Lab404SecurityCamera)
    _check("FR-024b: câmera ativa após a energia voltar", camera_seg != null and camera_seg.is_tracking())
    if camera_seg != null:
        player.global_position = Vector3(4.0, 0.05, 5.5)
        await _wait_physics(4)
        var antes := _desvio_da_camera(camera_seg, player)
        await _wait_physics(30)
        var depois := _desvio_da_camera(camera_seg, player)
        _check(
            "FR-024b: câmera gira na direção do jogador (%.0f° → %.0f°)" % [rad_to_deg(antes), rad_to_deg(depois)],
            depois < antes * 0.9
        )

    print("== Serialização (base para o save do POC 6) ==")
    var copia := Lab404GameState.new()
    copia.deserialize(Lab404Game.state.serialize())
    _check("state: flags ida e volta", copia.get_flag("communication_restored"))
    var inventario := Lab404Inventory.new()
    inventario.from_dict({"chave": "Chave de manutenção"})
    _check("inventory: ida e volta", inventario.has_item("chave"))

    _report()

# --- utilidades -------------------------------------------------------------

## Desvio angular (rad) entre a mira da câmera (-Z local) e o alvo.
func _desvio_da_camera(camera: Node3D, alvo: Node3D) -> float:
    var local := camera.to_local(alvo.global_position)
    return absf(atan2(-local.x, -local.z))

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
    var tentativa := 0
    for candidato in _candidatos(alvo):
        tentativa += 1
        if not _posicao_livre(space, player, candidato):
            continue
        _teleportar(player, candidato, alvo)
        await _wait_physics(8)
        if interaction.get_focus_target() == interactable:
            if tentativa > 1:
                print("  (aproximação: posição alternativa %d usada)" % tentativa)
            return
    push_warning("POC2: não foi possível mirar %s" % interactable.get_parent().name)

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
    print("== RESULTADO POC 2: %d verificações, %d falha(s) ==" % [_checks, _failures.size()])
    for failure in _failures:
        print("  FALHA: %s" % failure)
    get_tree().quit(1 if _failures.size() > 0 else 0)
