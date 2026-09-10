extends Node

## Gerador de evidência visual e de desempenho (requer display/GPU).
##
## Execução:
##   LAB404_SHOT_PATH=$HOME/lab404.png godot4 --path . --position 60,60 \
##       --resolution 1280x720 res://tests/screenshot.tscn
##
## Variáveis:
##   LAB404_SHOT_PATH  caminho do PNG (padrão: user://lab404_screenshot.png)
##   LAB404_SHOT_VIEW  vazio (jogo) | input_test | terminal
##   LAB404_SHOT_POSE  "x,y,z,yaw_graus[,pitch_graus]" → posiciona o jogador antes da captura
##   LAB404_SHOT_DUMP  "1" → imprime posições de Accents/Labels/CAM_Security
##   LAB404_SHOT_FINISH "1" → conclui a missão, restabelece a energia e abre a porta
##
## Salva o primeiro frame estável de `scenes/main.tscn`, mede FPS por 3 s e encerra.

func _ready() -> void:
    var main = load("res://scenes/main.tscn").instantiate()
    add_child(main)
    await get_tree().process_frame

    # O jogo captura o mouse; numa captura de tela isso giraria a vista sem controle.
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    match OS.get_environment("LAB404_SHOT_VIEW"):
        "input_test":
            main.get_node("UI/InputTest").visible = true
        "terminal":
            main.get_node("UI/ARIATerminal").open()
        "terminal_ask":
            # Evidência ponta a ponta: pergunta no terminal e espera a resposta da ARIA.
            var terminal = main.get_node("UI/ARIATerminal")
            terminal.open()
            await get_tree().process_frame
            terminal._on_submit("ARIA, qual é o estado do laboratório?")
            var limite := Time.get_ticks_msec() + 45000
            while terminal._client.is_busy() and Time.get_ticks_msec() < limite:
                await get_tree().process_frame
            print("LAB404-ASK: resposta em %.1fs" % ((45000 - (limite - Time.get_ticks_msec())) / 1000.0))

    _aplicar_pose(main)

    if OS.get_environment("LAB404_SHOT_FINISH") == "1":
        for passo in Lab404QuestManager.STEPS:
            Lab404Game.quest.complete(String(passo["id"]))
        Lab404Game.state.set_flag("pump_ok", true)
        var nivel = main.get_node_or_null("Level")
        if nivel != null and nivel.get("door") != null:
            nivel.door.open()
            print("LAB404-FINISH: missão concluída, porta aberta")
        else:
            push_warning("LAB404_SHOT_FINISH: porta não encontrada no nível")

    if OS.get_environment("LAB404_SHOT_DUMP") == "1":
        var jogador_atual = main.get_node_or_null("Player")
        if jogador_atual != null:
            print("LAB404-DUMP Player pos=%s yaw=%.1f°" % [
                str(jogador_atual.global_position), rad_to_deg(jogador_atual.rotation.y)
            ])
        var level = main.get_node_or_null("Level")
        var npc = level.find_child("NPC_Tecnico_Corpo", true, false) if level != null else null
        if npc == null:
            print("LAB404-DUMP NPC_Tecnico_Corpo -> AUSENTE")
        else:
            print("LAB404-DUMP NPC_Tecnico_Corpo -> %s | mesh=%s" % [
                npc.get_class(), str(npc.get("mesh")) if npc is MeshInstance3D else "n/a"
            ])
            for filho in npc.get_children():
                print("   filho: %s (%s)" % [filho.name, filho.get_class()])
            var pai = npc.get_parent()
            if pai != null:
                print("   pai: %s (%s)" % [pai.name, pai.get_class()])
                for irmao in pai.get_children():
                    if "NPC" in String(irmao.name):
                        print("   irmão: %s (%s)" % [irmao.name, irmao.get_class()])
        for grupo in ["Accents", "Labels", "CAM_Security", "Screens"]:
            var no = level.get_node_or_null(grupo) if level != null else null
            if no == null:
                print("LAB404-DUMP %s -> AUSENTE" % grupo)
                continue
            print("LAB404-DUMP %s -> %d filho(s)" % [grupo, no.get_child_count()])
            for filho in no.get_children():
                print("   %s %s" % [filho.name, str(filho.global_position)])
        for detalhe in ["DEC_Mesa_Pato", "RS404_Capacitor_0", "DEC_CLP_Ranhura_0",
                "DEC_Bomba_Suporte2_Poste", "DEC_Painel_Esquema_L1", "DEC_Painel_Alerta"]:
            var det = level.find_child(detalhe, true, false) if level != null else null
            print("LAB404-DUMP %s -> %s" % [detalhe, "AUSENTE" if det == null else str(det.global_position)])
        var rotulos: Array = []
        _coletar_labels(main, rotulos)
        print("LAB404-DUMP Label3D: %d" % rotulos.size())
        for info in rotulos:
            print("   %s pos=%s texto=%s" % [info["nome"], info["pos"], info["texto"].substr(0, 28)])

    # Aguarda o assentamento da física e a estabilização do frame.
    for _i in 60:
        await get_tree().process_frame

    # Reaplica a pose: garante que a captura saia exatamente do ponto de vista pedido.
    _aplicar_pose(main)

    # Medição honesta de desempenho (NFR-001) enquanto a janela está visível.
    var frames_start := Engine.get_frames_drawn()
    var start_ms := Time.get_ticks_msec()
    while Time.get_ticks_msec() - start_ms < 3000:
        await get_tree().process_frame
    var duration := (Time.get_ticks_msec() - start_ms) / 1000.0
    var frames := Engine.get_frames_drawn() - frames_start
    print("LAB404-FPS: %.1f FPS (%d frames em %.2fs)" % [frames / duration, frames, duration])
    await RenderingServer.frame_post_draw

    var image := get_viewport().get_texture().get_image()
    var out := OS.get_environment("LAB404_SHOT_PATH")
    if out.is_empty():
        out = "user://lab404_screenshot.png"
    var err := image.save_png(out)
    print("LAB404-SHOT: %s (erro=%d) %dx%d" % [out, err, image.get_width(), image.get_height()])
    get_tree().quit(0 if err == OK else 1)

## Pose opcional do jogador: `LAB404_SHOT_POSE="x,y,z,yaw_graus[,pitch_graus]"`.
func _aplicar_pose(main: Node) -> void:
    var pose := OS.get_environment("LAB404_SHOT_POSE")
    if pose.is_empty():
        return
    var partes := pose.split(",")
    var jogador = main.get_node_or_null("Player")
    if partes.size() < 4 or jogador == null:
        push_warning("LAB404_SHOT_POSE inválida (use x,y,z,yaw[,pitch]) — ignorada")
        return
    jogador.global_position = Vector3(float(partes[0]), float(partes[1]), float(partes[2]))
    jogador.rotation.y = deg_to_rad(float(partes[3]))
    if partes.size() >= 5:
        # Pitch negativo = olhar para baixo (útil para props no piso/bancada).
        var pivot = jogador.get_node_or_null("CameraPivot")
        if pivot != null:
            pivot.rotation.x = deg_to_rad(clampf(float(partes[4]), -85.0, 85.0))
    if jogador is CharacterBody3D:
        jogador.velocity = Vector3.ZERO
    print("LAB404-POSE: %s" % pose)

## Coleta recursiva dos `Label3D` da cena (diagnóstico de rótulos sobrepostos).
func _coletar_labels(no: Node, saida: Array) -> void:
    if no is Label3D:
        saida.append({
            "nome": no.get_path(),
            "pos": str(no.global_position),
            "texto": String(no.text).replace("\n", " | "),
        })
    for filho in no.get_children():
        _coletar_labels(filho, saida)
