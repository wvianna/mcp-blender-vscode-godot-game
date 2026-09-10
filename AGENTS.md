# AGENTS.md — Laboratório 404

Regras permanentes do projeto. **Leia antes de modificar qualquer arquivo.**

## Visão

Jogo 3D educacional/ficcional (Blender + Godot 4 + Ollama) ambientado no Laboratório 404, administrado pela IA ARIA. Progressão incremental em POCs; **cada POC termina em versão executável e demonstrável** (Regra de Ouro).

## Stack e versões

| Componente | Tecnologia | Versão |
|---|---|---|
| Motor | Godot | 4.x (`A CONFIRMAR` subversão) |
| Gameplay | GDScript | Godot 4 |
| Assets | Blender → GLB/glTF | `A CONFIRMAR` |
| Adapter ARIA | Python + FastAPI + uvicorn + requests + pydantic | Python 3 (`A CONFIRMAR`) |
| LLM local | Ollama | `llama3.2:3b` (`A CONFIRMAR`) |

## Regras de desenvolvimento (obrigatórias)

1. **Input Map sempre.** Use ações semânticas (`move_*`, `look_*`, `interact`, …). **Nunca** `is_joy_button_pressed(n, b)` — o número varia por adaptador.
2. **Regra de Ouro.** Um POC por vez; só avance com caminho de teste reproduzível.
3. **LLM é texto, não controle.** ARIA devolve texto + intenções; o jogo valida tudo; nunca executa comandos arbitrários nem controla física.
4. **Intents restritas** ao conjunto `ALLOWED_INTENTS = {HINT, DIAGNOSE, LORE, STATUS, NONE}`.
5. **Personalidade da ARIA** em arquivo de configuração versionado (não espalhada nos scripts).
6. **Blender:** 1 unidade = 1 m; aplicar transform antes de exportar; prefixos `ENV_`, `PROP_`, `INT_`, `COL_`, `FX_`, `NPC_`, `DEC_`; preferir GLB.
7. **Desempenho:** alvo PC sem GPU dedicada → geometria simples, texturas moderadas, LLM pequena.
8. **GDScript:** `class_name`, `@export`, sinais; preservar os esqueletos existentes em `scripts/`.
9. **Python:** tipagem, validação com pydantic, tratar exceções com fallback.
10. **Não invente dados.** Lacunas de versão/configuração → marcar `A CONFIRMAR`.

## Estrutura de diretórios

```text
lab404/
├── assets/            # assets e ASSET_LIST.md
├── config/            # input_map.md e configurações
├── design/            # conceito visual e level design
├── docs/              # arquitetura, controles, narrativa, testes, etc.
├── scenes/            # templates de cenas (.tscn) e SCENE_TEMPLATES.md
├── scripts/           # GDScript + adapter Python
├── .specs/            # especificação técnica (constituição, roadmap, codebase)
├── AGENTS.md          # este arquivo
├── SPECIFICATION.md   # requisitos FR/NFR e critérios de aceite
├── TASKS.md           # tarefas com estado
├── STATUS.md          # estado atual do desenvolvimento
└── HANDOFF.md         # transferência entre agentes
```

## Comandos importantes

- Jogo: `./start.sh` e `./stop.sh` (PIDs/logs em `.run/`); equivalente direto: `godot4 --path .`.
- Testes: `tests/run_all.sh` (Godot headless + adapter Python).
- Adapter ARIA: `.venv/bin/uvicorn scripts.aria_adapter:app --reload --port 8000`
- Dependências do adapter: `python3 -m venv .venv && .venv/bin/pip install fastapi uvicorn requests pydantic`
- LLM local: `ollama run llama3.2:3b`
- Áudio (regenerar WAVs): `python3 tools/gen_audio.py`

## Critérios para alterar arquivos

- `docs/**`, `design/**`, `config/**` são a **fonte de intenção**; qualquer mudança de comportamento observável atualiza `SPECIFICATION.md` e `STATUS.md`.
- `scripts/**` é implementação: **uma issue/sistema por vez**; implementar, rodar teste, só então avançar.
- Mudança em instalação/build/teste/execução atualiza `README.md` e `.specs/codebase/CODEBASE.md`.

## Referências obrigatórias

- `SPECIFICATION.md` (requisitos e aceites), `TASKS.md`, `STATUS.md`, `HANDOFF.md`.
- `.specs/project/constitution.md` (princípios inegociáveis) e `.specs/codebase/CODEBASE.md` (stack, arquitetura, convenções, testes, integrações).
