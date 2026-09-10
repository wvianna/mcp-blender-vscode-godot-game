# STATUS.md — Laboratório 404

Última atualização: 2026-09-10.

## Concluído

- **POC 6 — Vertical slice (2026-09-10):** tutorial de controles, corredor → ala procedural (POC 5) → núcleo de ARIA → epílogo com três escolhas, save/load (`Lab404Save`), ambiência e efeitos sonoros originais (`tools/gen_audio.py`).
- **POC 5 — Laboratório procedural (2026-09-10):** `Lab404LabGenerator` com módulos (entradas/saídas/POIs/luz), determinismo por `seed` e conectividade garantida por construção (árvore de expansão + BFS).
- **POC 4 — Mundo inteligente (2026-09-10):** NPC reativo ao estado (`Lab404Npc`), memória em 4 camadas (`Lab404MemoryStore`), luzes conforme energia e tom da ARIA alterado por alerta ignorado (`Lab404WorldEvents`).
- **POC 3 — ARIA + Ollama (2026-09-10):** adapter FastAPI com pydantic, intents restritas, personalidade versionada (`config/aria_personality.json`), timeout de 30 s e fallback; cliente Godot com timeout/fallback; terminal com histórico.
- **POC 2 — Laboratório funcional (2026-09-10):** sala modelada no Blender 5.2.1 e exportada como GLB (`assets/lab404/lab_sala_poc2.glb`, 248 objetos, 24 materiais, 35 malhas `-col`), interação desacoplada, inventário diegético, porta com trava, estados de equipamento serializáveis e missão `RESTAURAR_COMUNICACAO`.
- **Correção — porta do corredor (2026-09-10):** a folha da porta é composta por várias malhas no GLB; apenas a colisão deslizava, então o visual continuava fechando o vão. Agora `DEC_Porta_Reforco`, `DEC_Porta_Visor` e `DEC_Porta_Placa` são filhas do objeto da porta no Blender (andam junto) e `Lab404Door` embute a folha no batente ao final do curso (`scripts/door.gd`). Evidência: `docs/images/poc2-porta-b1-fechada.png` e `poc2-porta-b1-aberta.png`.
- **Visual da sala (2026-09-10):** sala reconstruída seguindo `docs/Detalhamento do Ambiente 3D — Laboratório 404.md` e a referência `docs/images/laboratorio-exemplo.png` (arco de tubulações, eletrocalhas, faixas de segurança, bancada, tanque TK-01, bomba, CLP, sala de controle com vidro, passarela e escada). No Godot: iluminação em camadas (`Lights` + `Accents`) com fontes **alinhadas às luminárias visíveis do GLB**, estados claro/emergência, letreiros `Label3D` (TK-01, NÍVEL 42%, PLC-01, BOMBA-01, B1, ARIA, SETOR B) e câmera de segurança que acompanha o jogador após a energia voltar (`scripts/security_camera.gd`). Emissivos dosados no Blender para não estourar em branco (sem bloom no `gl_compatibility`). Evidência visual: `docs/images/poc2-sala-*.png` e `docs/images/poc2-porta-b1-*.png` + FPS.
- **POC 1 — Fundação jogável (2026-09-10):** projeto Godot 4.5, Input Map semântico, player (movimento/gravidade/colisão), câmera, HUD, pausa, calibração de input.
- **Suíte automatizada:** POC 1–6 com 211 verificações Godot (210 quando o adapter está no ar e o POC 3 valida a resposta real em vez do fallback, ver `docs/TESTES.md`) + 16 testes do adapter Python — todas PASS (`tests/run_all.sh`).
- Documentação de projeto: `docs/`, `design/`, `config/`, `scenes/`, `assets/`, `.specs/`.
- Esqueletos de código em `scripts/`: `player_controller.gd`, `game_state.gd`, `interaction.gd`, `input_diagnostic.gd`, `quest_manager.gd`, `aria_client.gd`, `aria_adapter.py`.
- Especificação SDD: `SPECIFICATION.md`, `AGENTS.md`, `TASKS.md`, `HANDOFF.md`, `STATUS.md`, `.specs/`, `LICENSE`, `.gitignore` (Godot).

## Em andamento

- Nenhum.

## Pendente

- **Validação em hardware real:** joystick PS1→USB (calibração, hotplug, botões), mouse capturado e conforto de câmera — item MANUAL de `tests/poc1_test.gd`.
- **Empacotamento (FR-033):** o export falha por ausência de *export templates* do Godot 4.5 neste ambiente. Comando: `godot4 --headless --path . --export-release "Linux/X11" build/lab404.x86_64` (instalar templates em `~/.local/share/godot/export_templates/4.5.stable/`). `export_presets.cfg` já está no repositório.
- **Playthrough humano de 10–20 min (CA-013):** o roteiro automatizado cobre a cadeia completa, mas ninguém jogou de ponta a ponta.
- **ARIA com Ollama real:** conversa validada de ponta a ponta em 2026-09-10 com `llama3.1:8b` local. Chamada direta ao adapter: intent `DIAGNOSE`, confidence 0.9, 22 s (frio). **No jogo** (`tests/poc3_live_test.tscn`): resposta em 12,9 s, intent `HINT`, 5/5 verificações — o cliente Godot espera até 35 s (acima dos 30 s do adapter) para acomodar LLM local lento. O modelo especificado `llama3.2:3b` **não está instalado** (`A CONFIRMAR`).
- **Demonstração:** roteiro passo a passo (15–20 min) em `docs/ROTEIRO_DEMO.md` para fechar CA-013.

## Problemas e erros conhecidos

- Export de executável bloqueado por ausência de *export templates* (ver Pendente).
- Modelo `llama3.2:3b` não instalado; `llama3.1:8b` levou 22 s no primeiro turno (limite do adapter: 30 s). Com o 8B em máquina mais lenta, o timeout pode ser atingido — o alvo é o 3B.
- Mapeamento real do adaptador PS1→USB depende do hardware (usar a calibração no menu de pausa).
- Aviso cosmético ao encerrar os testes: "ObjectDB instances leaked at exit" (nós liberados no `quit`) — não afeta o jogo.

## Próximo passo recomendado

1. Instalar os *export templates* do Godot 4.5 e gerar o executável (`build/lab404.x86_64`) — fecha FR-033/CA-013.
2. Validar o joystick PS1 real e ajustar o Input Map com base na calibração.
3. Subir o Ollama com `llama3.2:3b` e conversar com ARIA de verdade (`docs/OLLAMA.md`).

## Nível de evidência

- **LOCAL** — suíte automatizada headless: POC 1 (77), POC 2 (34: inclui iluminação em camadas, letreiros, câmera de segurança e a porta que move a folha com o visual), POC 3 (25 com adapter no ar / 26 com adapter desligado), POC 4 (21), POC 5 (23) e POC 6 (30) verificações + 16 testes do adapter Python; todas PASS (`tests/run_all.sh`). Desempenho: 60 FPS (vsync) em iGPU AMD Radeon Graphics @1280×720, inclusive após o detalhamento da sala (248 objetos, 15 luzes). Pendências: hardware real, empacotamento e playthrough humano.
