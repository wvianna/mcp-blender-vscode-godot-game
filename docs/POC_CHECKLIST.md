# Checklist executivo

## POC 1
- [x] projeto criado
- [x] player
- [x] câmera
- [x] teclado
- [x] joystick (código e calibração prontos; **validação física pendente** no adaptador PS1→USB)
- [x] input diagnostic
- [x] colisões
- [x] HUD
- [x] build (teste headless 77/77 PASS; 60 FPS em iGPU)

## POC 2
- [x] Blender (5.2.1 LTS, sala com painel/CLP/bomba/tanque/sensor/porta/itens)
- [x] GLB (`assets/lab404/lab_sala_poc2.glb`, 248 objetos, colisão por sufixo `-col`)
- [x] identidade visual (infraestrutura de teto, faixas, bancada, tanque TK-01, bomba, sala de controle, passarela e escada)
- [x] iluminação em camadas (luz geral claro/emergência + acentos por zona, alinhados às luminárias visíveis)
- [x] letreiros `Label3D` das estações e câmera de segurança que acompanha o jogador (`FR-015a`/`FR-024a`/`FR-024b`)
- [x] porta com trava (folha, moldura e detalhes andam juntos ao abrir — `FR-011`)
- [x] interação (`Lab404Interactable` + raycast + prompt)
- [x] inventário (kit técnico no HUD)
- [x] missão (`RESTAURAR_COMUNICACAO`, 6 passos)
- [x] equipamentos (OFF/FAULT/READY/RUNNING serializáveis)
- [x] áudio (efeitos originais em `audio/`, gerados por `tools/gen_audio.py`)
- [x] build (POC 2: 23/23 PASS)

## POC 3
- [x] adapter (`scripts/aria_adapter.py`, FastAPI + pydantic)
- [x] terminal (`Lab404AriaTerminal`)
- [x] contexto (objetivo, flags, tom, inventário)
- [x] timeout (30 s no adapter; 35 s no cliente, para esperar LLM local)
- [x] fallback (texto pré-definido + intent NONE)
- [x] build (POC 3: 26/26 PASS + 16 testes Python; Ollama real validado em 2026-09-10 com `llama3.1:8b` — `llama3.2:3b` ainda `A CONFIRMAR`)

## POC 4
- [x] NPC (`Lab404Npc`, fala por estado)
- [x] eventos (`Lab404WorldEvents`: luzes por energia, tom por alerta ignorado)
- [x] memória (4 camadas: sessão, persistente, narrativa, histórico)
- [x] estados (flags + equipamentos refletidos no mundo)
- [x] narrativa adaptativa (tom da ARIA + falas contextuais)
- [x] build (POC 4: 21/21 PASS)

## POC 5
- [x] módulos (7 tipos com POIs)
- [x] sockets (entradas/saídas recíprocas)
- [x] seed (`RandomNumberGenerator` local)
- [x] geração (`Lab404LabGenerator`)
- [x] navegação (aberturas nas paredes conforme conexões)
- [x] testes de conectividade (BFS em 6 seeds)

## POC 6
- [x] missão completa + tutorial (`Lab404Tutorial`)
- [x] save/load (`Lab404Save`, F5/F9)
- [x] áudio (ambiência em loop + efeitos)
- [x] narrativa (revelação + epílogo com 3 escolhas)
- [x] menu (pausa + diagnóstico)
- [x] teclado (validado por teste)
- [ ] PS1 USB (**MANUAL** — hardware real)
- [ ] empacotamento (bloqueado: *export templates* ausentes — `T-033`)
- [ ] demonstração (playthrough humano pendente)
