# TASKS.md — Laboratório 404

Estados: `[ ]` pendente · `[-]` em andamento · `[x]` concluída · `[!]` bloqueada.
Requisitos e critérios referenciam `SPECIFICATION.md`.

## POC 1 — Fundação jogável

- [x] **T-001** Criar projeto Godot 4 e cenas base (`project.godot`, `Main.tscn`, `Player.tscn`) — FR-001…FR-005
- [x] **T-002** Configurar Input Map com ações semânticas (`config/input_map.md`) — FR-001
- [x] **T-003** Implementar movimentação (teclado + analógico esquerdo) — FR-002
- [x] **T-004** Implementar câmera (mouse + analógico direito, quando exposto) — FR-003
- [x] **T-005** Implementar gravidade/colisão — FR-004
- [x] **T-006** Implementar HUD mínimo — FR-006
- [x] **T-007** Implementar menu de pausa (`Esc`/`Start`) — FR-005
- [x] **T-008** Implementar `InputTest`/calibração (dispositivos, eixos, botões, deadzone 0.15) — FR-007, FR-008
- [x] **T-009** Validar build executável sem assets externos — CA-005

**Evidência POC 1 (2026-09-10):** `tests/run_poc1.sh` → 75 verificações, 0 falhas (CA-001…CA-005 automatizados); smoke da cena principal sem erros; 60 FPS (vsync) em iGPU AMD Radeon Graphics @1280×720. Pendentes MANUAIS: mouse capturado, joystick PS1 físico, hotplug físico.

## POC 2 — Laboratório funcional

- [x] **T-010** Modelar sala base no Blender e exportar GLB — FR-015
- [x] **T-011** Implementar `Interactable` desacoplado (raycast + prompt + sinal) — FR-009
- [x] **T-012** Implementar inventário diegético — FR-010
- [x] **T-013** Implementar coleta de itens — FR-010
- [x] **T-014** Implementar portas (com permissões) — FR-011
- [x] **T-015** Implementar estados de equipamento serializáveis — FR-012
- [x] **T-016** Implementar missão `RESTAURAR_COMUNICACAO` (`quest_manager.gd`) — FR-013
- [x] **T-017** Feedback visual/sonoro — FR-014

## POC 3 — ARIA + Ollama

- [x] **T-018** Completar adapter FastAPI (validação de intents, fallback) — FR-016, FR-017, FR-021
- [x] **T-019** Cliente HTTP assíncrono em Godot (timeout/erro/fallback) — FR-018
- [x] **T-020** Terminal ARIA na UI — FR-019
- [x] **T-021** Externalizar personalidade da ARIA em config — FR-020
- [x] **T-022** Testes de falha (Ollama off, timeout, JSON inválido, modelo inexistente) — CA-009, CA-010

## POC 4 — Mundo inteligente

- [x] **T-023** NPCs com diálogo contextual — FR-022
- [x] **T-024** Memória: sessão / estado persistente / narrativa / histórico — FR-023
- [x] **T-025** Eventos de mundo (luzes, portas, tom da ARIA) — FR-024

## POC 5 — Laboratório procedural

- [x] **T-026** Kit modular de arquitetura (paredes, canto, porta, piso, teto, painel, luminária) — FR-025
- [x] **T-027** Geração determinística por `seed` — FR-026
- [x] **T-028** Testes de conectividade (nenhuma sala inacessível) — FR-027

## POC 6 — Vertical slice

- [x] **T-029** Missão completa + tutorial de controles — FR-028, FR-029
- [x] **T-030** Save/load — FR-030
- [x] **T-031** Áudio ambiente, alarmes e efeitos — FR-031
- [x] **T-032** Epílogo com escolha (seguir/questionar/reiniciar núcleo) — FR-032
- [!] **T-033** Empacotamento e demonstração sem intervenção — FR-033 (bloqueada: export templates ausentes; `export_presets.cfg` pronto)

**Evidência POC 2–6 (2026-09-10):** `tests/run_all.sh` → POC 2 (34, inclui iluminação em camadas/letreiros/câmera de segurança/porta com folha), POC 3 (26), POC 4 (21), POC 5 (23), POC 6 (30) verificações + 16 testes Python do adapter, todas PASS. ARIA real validada com Ollama local (`llama3.1:8b`, intent `DIAGNOSE`, 22 s). Pendências MANUAIS: hardware real (joystick/mouse), `llama3.2:3b` e playthrough humano (`docs/ROTEIRO_DEMO.md`).

## Entregáveis e aceite

- **Código:** `scripts/` (GDScript + adapter), cenas `.tscn`, assets GLB.
- **Build:** projeto Godot sem erros de script; adapter sobe com `uvicorn scripts.aria_adapter:app --port 8000`.
- **Testes:** conforme `docs/TESTES.md` e `.specs/codebase/CODEBASE.md` (nível **LOCAL** até haver CI).
- **Critérios rastreados:** CA-001…CA-013 em `SPECIFICATION.md`.
- **Pendências/riscos:** versões exatas marcadas `A CONFIRMAR`; mapeamento do joystick depende de hardware.
- **Responsável pela validação:** agente implementador + desenvolvedor (playthrough do POC 6).
