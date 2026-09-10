# Preparação do ambiente

## Linux/Ubuntu

Instale:
- Blender;
- Godot 4.x;
- VS Code;
- Git;
- Python 3;
- Ollama, a partir da documentação oficial correspondente à sua distribuição.

## Ordem

1. Criar repositório Git.
2. Criar projeto Godot.
3. Criar estrutura de diretórios.
4. Fazer POC 1 antes de instalar modelos.
5. Configurar Blender.
6. Só instalar/baixar modelo Ollama no POC 3, caso já não esteja instalado.

## Execução do jogo

```bash
./start.sh          # jogo + adapter de ARIA (PIDs e logs em .run/)
./stop.sh           # encerra jogo e adapter
godot4 --path .                               # jogo completo (POC 1–6), sem os scripts
tests/run_all.sh                              # suíte automatizada
godot4 --path . res://scenes/input_test.tscn  # calibração de input isolada
```

Dentro do jogo: `Esc`/Start → menu de pausa → **Diagnóstico de input**; `F5` salva, `F9` carrega.

## ARIA (POC 3)

```bash
python3 -m venv .venv
.venv/bin/pip install fastapi uvicorn requests pydantic
.venv/bin/uvicorn scripts.aria_adapter:app --reload --port 8000
ollama run llama3.2:3b   # em outro terminal
```

Sem adapter/Ollama o terminal de ARIA mostra o fallback — o jogo não trava.

## Empacotamento (FR-033)

```bash
godot4 --headless --path . --export-release "Linux/X11" build/lab404.x86_64
```

Requer os *export templates* da mesma versão em `~/.local/share/godot/export_templates/4.5.stable/`
(neste ambiente eles não estão instalados — `T-033` segue bloqueada).

## Adaptador PS1

Conecte o joystick USB e abra a tela de calibração de input.

Não assuma que:
- X é botão 0;
- O é botão 1;
- Start é botão 9.

Anote os índices reais exibidos e ajuste o Input Map (ver `config/input_map.md`) se necessário.

## Desempenho

O alvo inicial é PC sem GPU dedicada. Portanto:
- geometria simples;
- texturas moderadas;
- iluminação controlada;
- poucos efeitos;
- LLM local pequena para o POC.
