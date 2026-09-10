extends Node

## Teste automatizado do POC 1 (headless) — evidência para CA-001…CA-005.
##
## Execução: `tests/run_poc1.sh`
## (ou `godot4 --headless --path . res://tests/poc1_test.tscn`).
##
## Cobre: Input Map (FR-001), movimento/gravidade/colisão (FR-002/FR-004), câmera (FR-003),
## HUD/prompt (FR-006), pausa (FR-005), diagnóstico de input/hotplug/deadzone (FR-007/FR-008)
## e carregamento sem assets externos (CA-005).
##
## Itens que dependem de hardware real (joystick PS1, mouse capturado, FPS) são listados como
## MANUAL — não contam como falha e devem ser verificados conforme `docs/TESTES.md`.

const REQUIRED_ACTIONS: PackedStringArray = [
    "move_forward", "move_backward", "move_left", "move_right",
    "look_left", "look_right", "look_up", "look_down",
    "interact", "cancel", "run", "flashlight", "inventory", "pause", "dialog_next",
]

const MAIN_SCENE := "res://scenes/main.tscn"
const INPUT_TEST_SCENE := "res://scenes/input_test.tscn"

var _checks := 0
var _failures: PackedStringArray = []
var _manual: PackedStringArray = []

func _ready() -> void:
    await get_tree().process_frame
    await _run_all()
    _report()

func _run_all() -> void:
    _check_input_map()

    var main := await _spawn_main()
    if main == null:
        return

    await _check_scene_and_gravity(main)
    await _check_movement(main)
    await _check_collision(main)
    await _check_camera(main)
    await _check_interaction(main)
    await _check_pause(main)
    await _check_input_test()

func _spawn_main() -> Node:
    print("== CA-005: carregamento da cena principal ==")
    var scene: PackedScene = load(MAIN_SCENE)
    _check("cena %s carrega" % MAIN_SCENE, scene != null)
    if scene == null:
        return null
    var main = scene.instantiate()
    get_tree().root.add_child(main)
    await _wait_physics(5)
    return main

func _check_input_map() -> void:
    print("== FR-001 / FR-007: Input Map semântico ==")
    for action in REQUIRED_ACTIONS:
        var exists := InputMap.has_action(action)
        _check("ação '%s' existe" % action, exists)
        if not exists:
            continue
        _check("ação '%s' tem eventos mapeados" % action, InputMap.action_get_events(action).size() > 0)
        _check(
            "ação '%s' usa deadzone 0.15" % action,
            is_equal_approx(InputMap.action_get_deadzone(action), 0.15)
        )

func _check_scene_and_gravity(main: Node) -> void:
    print("== CA-005 / FR-004: cena base e gravidade ==")
    _check("nó Player presente", main.has_node("Player"))
    _check("nó Level presente", main.has_node("Level"))
    _check("nó UI/HUD presente", main.has_node("UI/HUD"))
    _check("nó UI/PauseMenu presente", main.has_node("UI/PauseMenu"))
    _check("nó UI/InputTest presente", main.has_node("UI/InputTest"))
    _check("sala do Blender (GLB) instanciada", main.has_node("Level/LabGLB"))

    var player = main.get_node_or_null("Player")
    if player == null:
        return
    var camera = player.get_node_or_null("CameraPivot/Camera3D")
    _check("câmera ativa no viewport", camera != null and main.get_viewport().get_camera_3d() == camera)

    await _wait_physics(40)
    _check("FR-004: jogador assentou no piso (is_on_floor)", player.is_on_floor())
    _check("FR-004: altura final próxima do piso", absf(player.global_position.y) < 0.2)

func _check_movement(main: Node) -> void:
    print("== CA-001 / FR-002: movimentação por ação semântica ==")
    var player = main.get_node("Player")
    var start = player.global_position

    Input.action_press("move_forward")
    await _wait_physics(30)
    Input.action_release("move_forward")
    await _wait_physics(2)

    var delta = player.global_position - start
    _check("FR-002: 'move_forward' desloca o jogador em -Z", delta.z < -0.5)
    _check(
        "FR-002: deslocamento respeita o limite de velocidade",
        Vector2(delta.x, delta.z).length() <= player.run_speed * 0.6
    )

func _check_collision(main: Node) -> void:
    print("== FR-004: colisão com parede (sem atravessar) ==")
    var player = main.get_node("Player")

    Input.action_press("move_forward")
    await _wait_physics(200)
    var z_antes = player.global_position.z
    await _wait_physics(60)
    Input.action_release("move_forward")
    var z_depois = player.global_position.z

    _check("FR-004: jogador avançou até a parede norte", z_depois < -6.0)
    _check(
        "FR-004: jogador parou na parede (delta=%.3f)" % absf(z_depois - z_antes),
        absf(z_depois - z_antes) < 0.05
    )
    _check("FR-004: jogador continua apoiado no piso", player.is_on_floor())

func _check_camera(main: Node) -> void:
    print("== CA-002 / FR-003: câmera ==")
    var player = main.get_node("Player")
    var pivot = player.get_node("CameraPivot")

    var yaw_before = player.rotation.y
    Input.action_press("look_right")
    await _wait_physics(30)
    Input.action_release("look_right")
    await _wait_physics(2)
    _check("CA-002: analógico direito (ação 'look_right') gira a câmera", player.rotation.y < yaw_before - 0.05)

    var limit = deg_to_rad(player.pitch_limit_deg)
    player._apply_look(0.0, 10.0)
    _check("FR-003: pitch limitado para cima", pivot.rotation.x <= limit + 0.001)
    player._apply_look(0.0, -20.0)
    _check("FR-003: pitch limitado para baixo", pivot.rotation.x >= -limit - 0.001)

    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        var yaw_mouse_before = player.rotation.y
        var event := InputEventMouseMotion.new()
        event.relative = Vector2(150.0, -80.0)
        player._unhandled_input(event)
        _check("FR-003: mouse gira a câmera", player.rotation.y < yaw_mouse_before - 0.05)
    else:
        _manual.append("FR-003: rotação por mouse (headless não captura o mouse)")

func _check_interaction(main: Node) -> void:
    print("== FR-006/FR-009: prompt e interação (área de teste substituída pelo painel) ==")
    var player = main.get_node("Player")
    var hud = main.get_node("UI/HUD")
    var painel = main.get_node("Level").find_child("PROP_Painel", true, false)
    _check("interactable do painel encontrado", painel != null)
    if painel == null:
        return
    var area = painel.get_node_or_null("InteractionArea")
    _check("área de interação instalada no painel", area != null)
    if area == null:
        return

    # Reposiciona o jogador de frente para o painel, olhando para -Z.
    player.rotation = Vector3.ZERO
    player.get_node("CameraPivot").rotation = Vector3.ZERO
    player.global_position = Vector3(0.0, 0.05, area.global_position.z + 1.6)
    player.velocity = Vector3.ZERO
    await _wait_physics(30)

    _check("FR-006: prompt de interação visível com alvo na mira", hud.get_node("PromptLabel").visible)

    var activated := [false]
    area.interacted.connect(func(_actor: Node) -> void: activated[0] = true)
    var interacted = player.get_node("Interaction").try_interact()
    _check("FR-009: interação acionada pelo raycast", interacted and activated[0])
    _check("FR-006: feedback exibido no HUD", hud.get_node("FeedbackLabel").visible)

func _check_pause(main: Node) -> void:
    print("== CA-003 / FR-005: menu de pausa ==")
    var pause_menu = main.get_node("UI/PauseMenu")

    _send_action("pause")
    await _wait_process(3)
    _check("CA-003: árvore de cena pausada", get_tree().paused)
    _check("CA-003: menu de pausa visível", pause_menu.visible)

    _send_action("pause")
    await _wait_process(3)
    _check("CA-003: árvore de cena retomada", not get_tree().paused)
    _check("CA-003: menu de pausa oculto", not pause_menu.visible)

func _check_input_test() -> void:
    print("== FR-007 / FR-008: diagnóstico de input ==")
    var scene: PackedScene = load(INPUT_TEST_SCENE)
    _check("cena %s carrega" % INPUT_TEST_SCENE, scene != null)
    if scene == null:
        return
    var diag = scene.instantiate()
    get_tree().root.add_child(diag)
    await _wait_process(2)

    _check("FR-007: deadzone padrão 0.15", is_equal_approx(diag.deadzone, 0.15))

    diag._on_joy_connection_changed(0, true)
    await _wait_process(2)
    var status: String = diag.get_node("Margin/VBox/StatusLabel").text
    _check("FR-008: hotplug atualiza o status sem travar execução", "CONECTADO" in status)

    diag._on_deadzone_changed(0.25)
    _check(
        "FR-007: zona morta configurável propaga ao Input Map",
        is_equal_approx(InputMap.action_get_deadzone("move_forward"), 0.25)
    )
    diag._on_deadzone_changed(0.15)
    _check(
        "FR-007: zona morta restaurada para 0.15",
        is_equal_approx(InputMap.action_get_deadzone("move_forward"), 0.15)
    )

    diag.queue_free()
    await _wait_process(1)

# --- utilidades -------------------------------------------------------------

func _check(label: String, condition: bool) -> void:
    _checks += 1
    if condition:
        print("  [PASS] %s" % label)
    else:
        _failures.append(label)
        print("  [FALHA] %s" % label)

func _send_action(action: String) -> void:
    var pressed := InputEventAction.new()
    pressed.action = action
    pressed.pressed = true
    Input.parse_input_event(pressed)

    var released := InputEventAction.new()
    released.action = action
    released.pressed = false
    Input.parse_input_event(released)

func _wait_physics(frames: int) -> void:
    for _i in frames:
        await get_tree().physics_frame

func _wait_process(frames: int) -> void:
    for _i in frames:
        await get_tree().process_frame

func _report() -> void:
    print("")
    print("== RESULTADO POC 1: %d verificações, %d falha(s) ==" % [_checks, _failures.size()])
    for failure in _failures:
        print("  FALHA: %s" % failure)
    for item in _manual:
        print("  MANUAL (hardware real): %s" % item)
    get_tree().quit(1 if _failures.size() > 0 else 0)
