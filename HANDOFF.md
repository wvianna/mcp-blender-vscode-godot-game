# HANDOFF.md — Laboratório 404

Protocolo de continuidade entre agentes.

## Contexto

Projeto de jogo 3D (Blender + Godot 4 + Ollama) que será implementado em 6 POCs incrementais. A especificação (`SPECIFICATION.md`) foi criada consolidando a documentação já existente em `docs/`, `design/`, `config/`, `scenes/` e `assets/`.

## Estado atual

- **POC 1 a POC 6 implementados e testados** (2026-09-10): jogo jogável da chegada ao epílogo, com sala Blender (GLB), ARIA local (adapter + terminal), NPC/memória/eventos, laboratório procedural (asa final) e save/load.
- Suíte automatizada: 209 verificações Godot (POC 1–6, inclui iluminação/letreiros/câmera de segurança no POC 2) + 16 testes do adapter Python — todas PASS.
- Pendências reais: hardware (joystick PS1/mouse), Ollama com modelo real e empacotamento (templates).

## Alterações realizadas nesta sessão

- **POC 2:** modelagem da sala no Blender 5.2.1 (`assets/lab404/lab_sala_poc2.glb`, 31 objetos, colisão via sufixo `-col`); `interactable.gd`, `inventory.gd`, `equipment.gd`, `door.gd`, `lab_setup.gd`; HUD com passos + kit técnico; `level_poc2.tscn`.
- **POC 3:** `aria_adapter.py` (pydantic, intents, personalidade, timeout 30 s, fallback), `config/aria_personality.json`, `aria_client.gd`, `aria_terminal.gd` + cena.
- **POC 4:** `npc.gd`, `world_events.gd` (luzes + tom da ARIA), `memory_store.gd` (4 camadas).
- **POC 5:** `lab_generator.gd` (módulos, seed, conectividade BFS).
- **POC 6:** `tutorial.gd`, `vertical_slice.gd` (corredor → ala procedural → núcleo), `epilogue.gd` + UI, `save_system.gd`, `sfx.gd`, `tools/gen_audio.py` (WAV originais), `export_presets.cfg`.
- **Testes:** `tests/poc{1..6}_test.{gd,tscn}`, `tests/test_aria_adapter.py`, `tests/run_all.sh`, `tests/screenshot.gd` (evidência visual + FPS).
- **Docs:** `STATUS.md`, `TASKS.md`, `HANDOFF.md`, `README.md`, `SPECIFICATION.md` (matriz de validação), `docs/{TESTES,INSTALL,POC_CHECKLIST}.md`, `config/input_map.md`, `scenes/SCENE_TEMPLATES.md`, `.specs/`.

## Decisões

- SDD com artefatos consolidados: `codebase/` consolidado em um único `CODEBASE.md` (anti-bloat), registrado em `STATUS.md`.
- Licença **Apache License 2.0** (padrão da skill), `Copyright 2026 Laboratório 404`.
- Intents da ARIA restritas a `{HINT, DIAGNOSE, LORE, STATUS, NONE}`.
- Input sempre por ações semânticas; nunca índices de botão de joystick.

## Problemas / bloqueios

- **Export** bloqueado por ausência de *export templates* 4.5 (T-033/FR-033).
- Ollama `llama3.2:3b` não confirmado no ambiente; adapter responde fallback (testado).
- Joystick PS1→USB e mouse dependem de hardware real (calibração no menu de pausa).
- Playthrough humano de 10–20 min (CA-013) ainda não foi feito por uma pessoa.

## Próximo passo

1. Instalar *export templates* 4.5 e gerar `build/lab404.x86_64` (FR-033).
2. Rodar o Ollama com `llama3.2:3b` e conversar com ARIA de verdade; ajustar a personalidade em `config/aria_personality.json` conforme o tom desejado.
3. Validar joystick PS1 real e conforto de câmera; ajustar `config/input_map.md` e sensibilidade.
4. Pedir a uma pessoa o playthrough completo (CA-013) e registrar o resultado em `STATUS.md`.

## Cuidados

- Não implementar mais de um sistema por vez (Regra de Ouro).
- Preservar os esqueletos de `scripts/` e a convenção `class_name`/`@export`/sinais.
- Manter `STATUS.md` e `TASKS.md` atualizados a cada alteração significativa.

## Critério de conclusão

Vertical slice jogável de ponta a ponta (chegada → missão → ARIA → corredor → epílogo), com CA-001…CA-012 `PASS` automatizados e CA-013 dependendo de playthrough humano + empacotamento.
