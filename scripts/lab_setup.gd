extends Node3D
class_name Lab404LabSetup

## Lógica da sala do POC 2 (FR-009…FR-015).
## O GLB vem do Blender com nomes convencionados; aqui procuramos os nós, instalamos
## `Lab404Interactable`/`Lab404Equipment`/`Lab404Door` e ligamos tudo à missão.
## Nenhuma geometria é criada aqui — só comportamento.

signal feedback(text: String)
signal terminal_requested
signal npc_requested
signal npc_line(speaker: String, text: String)

const ITEM_FUSE := "fusivel_f17"
const ITEM_MODULE := "modulo_rs404"

var door: Lab404Door = null

var _npc: Lab404Npc = null
var _interactables: Dictionary = {}  # chave -> Lab404Interactable
var _slots: Dictionary = {}          # "A"/"B" -> MeshInstance3D
var _items: Dictionary = {}          # item_id -> Node3D

func _ready() -> void:
    _setup()
    Lab404Game.inventory.changed.connect(_refresh_prompts)
    Lab404Game.quest.advanced.connect(_on_quest_advanced)
    _apply_flags()
    _refresh_prompts()

func _setup() -> void:
    _register_equipment("PROP_CLP", "clp", "CLP", Lab404Equipment.State.FAULT, 2.4)
    _register_equipment("PROP_Bomba", "bomba", "Bomba hidráulica", Lab404Equipment.State.FAULT, 1.5)

    door = _attach_door("ENV_Porta_Corredor", "pump_ok")

    _interactables["painel"] = _add_interactable("PROP_Painel", "EXAMINAR PAINEL", _on_panel)
    _interactables["clp"] = _add_interactable("PROP_CLP", "REINICIAR CLP", _on_clp)
    _interactables["bomba"] = _add_interactable("PROP_Bomba", "INSPECIONAR BOMBA", _on_pump)
    _interactables["terminal"] = _add_interactable("PROP_Terminal_ARIA", "FALAR COM ARIA", _on_terminal)
    _interactables["npc"] = _add_interactable("NPC_Tecnico_Corpo", "FALAR COM O TÉCNICO", _on_npc)
    _interactables["porta"] = _add_interactable("ENV_Porta_Corredor", "ABRIR PORTA", _on_door)

    _add_pickup("INT_Fusivel_F17", ITEM_FUSE, "Fusível F-17", "encontrar_fusivel")
    _add_pickup("INT_Modulo_RS404", ITEM_MODULE, "Módulo RS-404", "encontrar_modulo")

    _npc = _setup_npc()

    _slots["A"] = _find_mesh("PROP_Painel_Slot_A")
    _slots["B"] = _find_mesh("PROP_Painel_Slot_B")

# --- handlers da missão (FR-013) -------------------------------------------

func _on_panel(_actor: Node) -> void:
    var instalados: PackedStringArray = []

    if not Lab404Game.state.get_flag("fuse_installed") and Lab404Game.inventory.has_item(ITEM_FUSE):
        Lab404Game.inventory.remove_item(ITEM_FUSE)
        Lab404Game.state.set_flag("fuse_installed", true)
        _light_slot("A", true)
        instalados.append("fusível F-17")

    if not Lab404Game.state.get_flag("module_installed") and Lab404Game.inventory.has_item(ITEM_MODULE):
        Lab404Game.inventory.remove_item(ITEM_MODULE)
        Lab404Game.state.set_flag("module_installed", true)
        _light_slot("B", true)
        instalados.append("módulo RS-404")

    if not instalados.is_empty():
        Lab404Sfx.play("install")
        Lab404Game.memory.learn("painel", "Fusível F-17 e módulo RS-404 instalados no painel.")
        feedback.emit("INSTALADO — %s" % ", ".join(instalados))

    if Lab404Game.state.get_flag("fuse_installed") and Lab404Game.state.get_flag("module_installed"):
        Lab404Game.quest.complete("instalar_componentes")
    else:
        Lab404Sfx.play("error")
        var faltando: PackedStringArray = []
        if not Lab404Game.state.get_flag("fuse_installed"):
            faltando.append("fusível F-17")
        if not Lab404Game.state.get_flag("module_installed"):
            faltando.append("módulo RS-404")
        feedback.emit("FALTA INSTALAR — %s" % ", ".join(faltando))

    _refresh_prompts()

func _on_clp(_actor: Node) -> void:
    if not (Lab404Game.state.get_flag("fuse_installed") and Lab404Game.state.get_flag("module_installed")):
        Lab404Sfx.play("error")
        feedback.emit("O CLP está sem energia: instale os componentes no painel.")
        return

    var clp := Lab404Game.get_equipment("clp")
    if clp != null and clp.state == Lab404Equipment.State.RUNNING:
        feedback.emit("O CLP já está em operação.")
        return

    Lab404Game.set_equipment_state("clp", Lab404Equipment.State.RUNNING)
    Lab404Game.state.set_flag("plc_restarted", true)
    Lab404Sfx.play("install")
    Lab404Game.memory.learn("clp", "CLP reiniciado; a bomba hidráulica segue em FALHA.")
    Lab404Game.quest.complete("reiniciar_clp")
    feedback.emit("CLP reiniciado. A bomba hidráulica reporta FALHA.")
    _refresh_prompts()

func _on_pump(_actor: Node) -> void:
    var clp := Lab404Game.get_equipment("clp")
    if clp == null or clp.state != Lab404Equipment.State.RUNNING:
        Lab404Sfx.play("error")
        feedback.emit("A bomba não responde: reinicie o CLP primeiro.")
        return

    Lab404Game.set_equipment_state("bomba", Lab404Equipment.State.RUNNING)
    Lab404Game.state.set_flag("pump_ok", true)
    Lab404Game.state.set_flag("power_restored", true)
    Lab404Sfx.play("alarm")
    Lab404Game.memory.learn("bomba", "Bomba diagnosticada e em operação; porta do corredor liberada.")
    Lab404Game.quest.complete("diagnosticar_bomba")
    feedback.emit("Bomba em operação. A porta do corredor foi liberada.")
    _refresh_prompts()

func _on_door(_actor: Node) -> void:
    if door == null:
        return
    if door.try_open():
        Lab404Sfx.play("door")
        Lab404Game.state.set_flag("communication_restored", true)
        Lab404Game.quest.complete("abrir_porta")
        feedback.emit("Porta do corredor aberta — comunicação restaurada.")
    else:
        Lab404Sfx.play("error")
        feedback.emit("Porta travada: conclua o diagnóstico da bomba.")
    _refresh_prompts()

func _on_terminal(_actor: Node) -> void:
    # Falar com a ARIA reconhece os alertas pendentes (FR-024).
    var events := get_node_or_null("WorldEvents")
    if events != null:
        events.acknowledge_alert()
    terminal_requested.emit()

func _on_npc(_actor: Node) -> void:
    npc_requested.emit()
    if _npc != null:
        npc_line.emit(_npc.speaker, _npc.current_line())

# --- montagem dos nós ------------------------------------------------------

func _add_interactable(node_name: String, prompt: String, handler: Callable) -> Lab404Interactable:
    var node := _find(node_name)
    if node == null:
        push_warning("Lab404: nó '%s' não encontrado no GLB." % node_name)
        return null

    var aabb := AABB(Vector3(-0.5, -0.5, -0.5), Vector3(1.0, 1.0, 1.0))
    var mesh := node as MeshInstance3D
    if mesh != null and mesh.mesh != null:
        aabb = mesh.get_aabb()

    var area := Lab404Interactable.new()
    area.name = "InteractionArea"
    area.prompt = prompt
    area.collision_layer = 2
    area.collision_mask = 0

    var caixa := _area_para_mira(aabb)
    area.position = caixa.get_center()

    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = caixa.size
    shape.shape = box
    area.add_child(shape)

    area.interacted.connect(handler)
    node.add_child(area)
    return area

## A mira do jogador fica a ~1,4 m do piso: a área precisa cobrir essa faixa mesmo
## para alvos baixos (ex.: bomba a 0,45 m). Vale porque as origens dos props estão no piso.
func _area_para_mira(aabb: AABB) -> AABB:
    const ALTURA_MIRA := 1.45
    const MARGEM := 0.6
    var tamanho := aabb.size + Vector3(MARGEM, MARGEM, MARGEM)
    var centro := aabb.get_center()
    var topo_local := centro.y + tamanho.y * 0.5
    if topo_local < ALTURA_MIRA:
        var extra := ALTURA_MIRA - topo_local
        centro.y += extra * 0.5
        tamanho.y += extra
    return AABB(centro - tamanho * 0.5, tamanho)

func _add_pickup(node_name: String, item_id: String, display_name: String, quest_step: String) -> void:
    var node := _find(node_name)
    if node == null:
        push_warning("Lab404: item '%s' não encontrado no GLB." % node_name)
        return
    _items[item_id] = node
    var handler := Callable(self, "_collect").bind(item_id, display_name, quest_step)
    _add_interactable(node_name, "PEGAR %s" % display_name, handler)

func _collect(_actor: Node, item_id: String, display_name: String, quest_step: String) -> void:
    Lab404Game.inventory.add_item(item_id, display_name)
    Lab404Game.state.set_flag("collected_%s" % item_id, true)
    _hide_item(item_id)
    Lab404Sfx.play("pickup")
    Lab404Game.memory.learn(item_id, "Item coletado: %s." % display_name)
    Lab404Game.quest.complete(quest_step)
    feedback.emit("ITEM COLETADO — %s" % display_name)

func _register_equipment(
    node_name: String,
    equipment_id: String,
    display_name: String,
    initial: Lab404Equipment.State,
    indicator_height: float
) -> void:
    var node := _find(node_name)
    if node == null:
        push_warning("Lab404: equipamento '%s' não encontrado no GLB." % node_name)
        return
    var equipment := Lab404Equipment.new()
    equipment.name = "Equipment"
    equipment.id = equipment_id
    equipment.display_name = display_name
    equipment.initial_state = initial
    equipment.indicator_height = indicator_height
    node.add_child(equipment)

func _attach_door(node_name: String, unlocked_flag: String) -> Lab404Door:
    var node := _find(node_name)
    if node == null:
        push_warning("Lab404: porta '%s' não encontrada no GLB." % node_name)
        return null
    var door_node := Lab404Door.new()
    door_node.name = "DoorController"
    door_node.unlocked_by_flag = unlocked_flag
    node.add_child(door_node)
    return door_node

## NPC reativo ao estado do laboratório (FR-022). A ordem das chaves define a prioridade.
func _setup_npc() -> Lab404Npc:
    var node := _find("NPC_Tecnico_Corpo")
    if node == null:
        push_warning("Lab404: NPC não encontrado no GLB.")
        return null
    var npc := Lab404Npc.new()
    npc.name = "Npc"
    npc.speaker = "TÉCNICO"
    npc.default_line = "Não deveria haver mais ninguém aqui. E eu nem tenho certeza de mim mesmo."
    npc.lines = {
        "quest:abrir_porta": "Conseguiu. A porta abriu sozinha — e eu não pedi isso à ARIA.",
        "flag:pump_ok": "A bomba voltou. Não fique muito tempo no corredor.",
        "flag:plc_restarted": "Reiniciou o CLP? Então a bomba ainda vai reclamar.",
        "flag:module_installed": "Esse módulo não deveria estar numa caixa de carga.",
        "flag:fuse_installed": "Você achou o fusível. A ARIA estava te guiando — ou te testando.",
    }
    node.add_child(npc)
    return npc

# --- estado e apresentação -------------------------------------------------

func _apply_flags() -> void:
    if Lab404Game.state.get_flag("fuse_installed"):
        _light_slot("A", true)
    if Lab404Game.state.get_flag("module_installed"):
        _light_slot("B", true)
    for item_id in _items.keys():
        if Lab404Game.state.get_flag("collected_%s" % item_id):
            _hide_item(String(item_id))

func _hide_item(item_id: String) -> void:
    var node: Node3D = _items.get(item_id)
    if node == null:
        return
    node.visible = false
    var area := node.get_node_or_null("InteractionArea")
    if area != null:
        area.queue_free()

func _light_slot(slot_key: String, on: bool) -> void:
    var mesh: MeshInstance3D = _slots.get(slot_key)
    if mesh == null:
        return
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.25, 0.7, 0.35) if on else Color(0.55, 0.5, 0.22)
    material.metallic = 0.3
    material.roughness = 0.4
    material.emission_enabled = on
    material.emission = Color(0.35, 1.0, 0.55)
    material.emission_energy_multiplier = 1.4
    mesh.material_override = material

func _refresh_prompts() -> void:
    _set_prompt("painel", _panel_prompt())
    _set_prompt("clp", "REINICIAR CLP")
    _set_prompt("bomba", "INSPECIONAR BOMBA")
    var porta_livre := door != null and not door.is_locked()
    _set_prompt("porta", "ABRIR PORTA" if porta_livre else "PORTA TRAVADA")

func _panel_prompt() -> String:
    if Lab404Game.state.get_flag("fuse_installed") and Lab404Game.state.get_flag("module_installed"):
        return "PAINEL COMPLETO"
    if Lab404Game.inventory.has_item(ITEM_FUSE) or Lab404Game.inventory.has_item(ITEM_MODULE):
        return "INSTALAR COMPONENTES"
    return "EXAMINAR PAINEL"

func _set_prompt(key: String, text: String) -> void:
    var area: Lab404Interactable = _interactables.get(key)
    if area != null:
        area.prompt = text

func _on_quest_advanced(_step_id: String) -> void:
    _refresh_prompts()

## Reconcilia o mundo com o estado atual (usado depois de carregar um save).
func apply_state() -> void:
    _apply_flags()
    _refresh_prompts()

# --- utilidades ------------------------------------------------------------

func _find(node_name: String) -> Node3D:
    var found := find_child(node_name, true, false)
    return found as Node3D

func _find_mesh(node_name: String) -> MeshInstance3D:
    return _find(node_name) as MeshInstance3D
