extends Node3D
class_name Lab404Main

## Coordenador do jogo (`scenes/main.tscn`):
## liga player, HUD, menus e level aos sistemas globais do autoload `Lab404Game`.
## Toda lógica de gameplay fica nos nós filhos (FR-001…FR-006).

const PROMPT_INTERACT := "[E] %s"

@onready var player: Lab404Player = $Player
@onready var hud: Lab404Hud = $UI/HUD
@onready var pause_menu: Lab404PauseMenu = $UI/PauseMenu
@onready var input_test: Lab404InputDiagnostic = $UI/InputTest
@onready var terminal: Lab404AriaTerminal = $UI/ARIATerminal
@onready var epilogue_ui: Lab404EpilogueUi = $UI/Epilogue
@onready var tutorial: Lab404Tutorial = $Tutorial
@onready var interaction: Lab404Interaction = $Player/Interaction
@onready var level: Lab404LabSetup = $Level
@onready var vertical: Lab404VerticalSlice = $Level/VerticalSlice

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

    terminal.setup_player(player)
    interaction.focus_changed.connect(_on_focus_changed)
    pause_menu.resume_requested.connect(_on_resume_requested)
    pause_menu.input_test_requested.connect(_on_input_test_requested)
    pause_menu.quit_requested.connect(_on_quit_requested)
    input_test.closed.connect(_on_input_test_closed)

    level.feedback.connect(hud.show_feedback)
    level.terminal_requested.connect(_on_terminal_requested)
    level.npc_requested.connect(_on_npc_requested)
    level.npc_line.connect(hud.show_dialogue)

    var events := level.get_node_or_null("WorldEvents")
    if events != null:
        events.alert_raised.connect(_on_alert_raised)

    tutorial.hint_shown.connect(hud.show_feedback)
    tutorial.finished.connect(_on_tutorial_finished)
    vertical.revelation.connect(_on_revelation)
    vertical.epilogue_requested.connect(_on_epilogue_requested)
    epilogue_ui.choice_made.connect(_on_epilogue_choice)
    epilogue_ui.restart_requested.connect(_on_epilogue_restart)

    Lab404Game.inventory.changed.connect(_refresh_inventory)
    Lab404Game.quest.advanced.connect(_on_quest_advanced)
    Lab404Game.quest.completed.connect(_on_quest_completed)
    Lab404Game.quest.step_completed.connect(_on_step_completed)

    _refresh_inventory()
    _refresh_quest()

    Lab404Sfx.set_ambience(true)  # FR-031
    tutorial.start()              # FR-029
    _report_joypads()
    Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _unhandled_input(event: InputEvent) -> void:
    # Overlays consomem o input enquanto abertos.
    if terminal.is_open() or epilogue_ui.visible:
        return

    # Tutorial de controles (FR-029): avança com Enter/Espaço/X.
    if tutorial.is_active() and event.is_action_pressed("dialog_next"):
        tutorial.advance()
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed("save_game"):
        save_game()
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed("load_game"):
        load_game()
        get_viewport().set_input_as_handled()
        return

    # Enquanto o jogo roda (não pausado), `pause` abre o menu (FR-005).
    if event.is_action_pressed("pause"):
        set_paused(true)
        get_viewport().set_input_as_handled()

## Pausa/retoma o jogo. Exposto para testes (`tests/poc1_test.gd`).
func set_paused(paused: bool) -> void:
    get_tree().paused = paused
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED
    if paused:
        pause_menu.open()
    else:
        pause_menu.close()
        input_test.visible = false

func _on_focus_changed(target: Node3D) -> void:
    if target == null:
        hud.clear_prompt()
        return
    var text := "INTERAGIR"
    if target.has_method("get_prompt"):
        text = String(target.get_prompt())
    if text.is_empty():
        hud.clear_prompt()
    else:
        hud.show_prompt(PROMPT_INTERACT % text)

func _refresh_inventory() -> void:
    hud.set_inventory(Lab404Game.inventory.entries())

func _refresh_quest() -> void:
    hud.set_objective(Lab404Game.quest.objective_text())
    hud.set_steps(Lab404Game.quest.status_lines())

func _on_step_completed(_step_id: String) -> void:
    _refresh_quest()

func _on_quest_advanced(_step_id: String) -> void:
    _refresh_quest()

func _on_quest_completed() -> void:
    _refresh_quest()
    hud.show_feedback("MISSÃO CONCLUÍDA — comunicação restaurada.")

## Terminal da ARIA (POC 3): aberto ao interagir com o console (FR-019).
func _on_terminal_requested() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    terminal.open()

## Diálogo com NPC (POC 4): a fala é exibida por `npc_line` → `hud.show_dialogue`.
func _on_npc_requested() -> void:
    pass

func _on_alert_raised(text: String) -> void:
    hud.show_feedback(text)

func _on_resume_requested() -> void:
    set_paused(false)

func _on_input_test_requested() -> void:
    # O jogo permanece pausado; o diagnóstico roda com `process_mode = ALWAYS` (FR-007).
    pause_menu.close()
    input_test.visible = true

func _on_input_test_closed() -> void:
    if get_tree().paused:
        pause_menu.open()

func _on_quit_requested() -> void:
    get_tree().quit()

# --- POC 6: tutorial, fase final, epílogo e save/load --------------------------

func _on_tutorial_finished() -> void:
    hud.show_feedback("Controles liberados. Siga o objetivo no painel.")

func _on_revelation(text: String) -> void:
    hud.show_feedback(text)
    Lab404Game.memory.learn("revelacao", text)

func _on_epilogue_requested() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    player.set_physics_process(false)
    epilogue_ui.open()

func _on_epilogue_choice(choice: String) -> void:
    hud.show_feedback("Decisão registrada: %s." % choice)

func _on_epilogue_restart() -> void:
    get_tree().paused = false
    epilogue_ui.visible = false
    Lab404Game.reset()
    get_tree().reload_current_scene()

## Salva o progresso (FR-030). Exposto para testes.
func save_game() -> Error:
    var err := Lab404Save.save_game()
    hud.show_feedback("JOGO SALVO." if err == OK else "Falha ao salvar (%d)." % err)
    return err

## Carrega o progresso e reconcilia o mundo com o estado salvo (FR-030).
func load_game() -> Error:
    var err := Lab404Save.load_game()
    if err != OK:
        hud.show_feedback("Nenhum save disponível (%d)." % err)
        return err
    _refresh_inventory()
    _refresh_quest()
    level.apply_state()
    hud.show_feedback("JOGO CARREGADO.")
    return err

# --- Diagnóstico de input ------------------------------------------------------

## Registra os joysticks no log (`.run/game.log`): o confinamento do snap pode esconder o
## adaptador sem nenhum erro visível (correção: `sudo snap connect godot4:joystick`).
func _report_joypads() -> void:
    var pads := Input.get_connected_joypads()
    if pads.is_empty():
        var hint := ""
        if OS.has_environment("SNAP"):
            hint = " — snap: rode `sudo snap connect godot4:joystick` (ver docs/INSTALL.md)"
        print("Lab404: nenhum joystick detectado%s." % hint)
        return
    var names: PackedStringArray = []
    for id in pads:
        names.append("#%d %s" % [id, Input.get_joy_name(id)])
    print("Lab404: joysticks detectados: %s." % ", ".join(names))

func _on_joy_connection_changed(device: int, connected: bool) -> void:
    print("Lab404: joystick %d %s." % [device, "conectado" if connected else "desconectado"])
