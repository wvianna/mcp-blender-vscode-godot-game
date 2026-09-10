# Plano de testes

## Suíte completa (automatizada)

```bash
tests/run_all.sh    # POC 1–6 (Godot headless) + adapter Python (venv)
```

Resultado de referência (2026-09-10): POC 1 (77), POC 2 (34), POC 3 (25 com adapter no ar / 26 com
adapter desligado), POC 4 (21), POC 5 (23) e POC 6 (30) verificações + 16 testes Python — **todas PASS**.

> O POC 3 adapta-se ao ambiente: com o adapter/Ollama **desligado** valida o caminho de fallback (2 verificações);
> com o adapter **no ar** valida a resposta real e a intent em `ALLOWED_INTENTS` (1 verificação) e imprime uma nota.

## POC 1

### Automatizado (headless)

```bash
tests/run_poc1.sh
```

Cobre: Input Map (ações e deadzone 0.15), carregamento sem assets externos, gravidade/piso,
movimento por ação (`move_forward`), limite de velocidade, colisão com parede, câmera
(`look_right` + limites de pitch), prompt/feedback do HUD, interação com a área de teste,
pausa/retomada e hotplug/deadzone da tela de diagnóstico.
Resultado de referência (2026-09-10): **75 verificações, 0 falhas**.

Evidência visual + FPS (requer GPU/display):

```bash
POC1_SHOT_PATH=/tmp/poc1.png godot4 --path . res://tests/poc1_screenshot.tscn
# POC1_SHOT_VIEW=input_test captura a tela de calibração
```

### Manual (hardware real)
- [ ] teclado WASD
- [ ] setas
- [ ] joystick PS1 (calibração: anote eixo/botão de cada tecla)
- [ ] deadzone (ajuste o slider e avalie o conforto)
- [ ] botão X (interagir)
- [ ] botão O (fechar diagnóstico)
- [ ] Start (pausa)
- [ ] desconectar/reconectar joystick com o jogo aberto
- [ ] mouse capturado (girar câmera)
- [ ] colisão (paredes/pilares)
- [ ] gravidade
- [ ] limite de velocidade (andar × correr)

## POC 2 — automatizado (`tests/poc2_test.gd`)

Cobre: GLB carregado, equipamentos registrados, interação por raycast com prompt contextual,
coleta de itens, kit técnico no HUD, instalação no painel, reinício do CLP, diagnóstico da bomba,
abertura da porta, conclusão da missão, serialização de estado — e a camada visual: luminárias
gerais alinhadas à fileira central do GLB, acentos por zona com cores distintas, letreiros
`Label3D` das estações (TK-01, NÍVEL 42%, PLC-01, BOMBA-01, B1, ARIA) e câmera de segurança que
gira na direção do jogador após a energia voltar (FR-015a/FR-024a/FR-024b).

Cobre também a porta do corredor: as três malhas da folha são filhas do nó da porta e sobem
junto com ela quando abre (FR-011) — regressão do defeito "a porta abre, mas o visual fica no vão".

Evidência visual (fora da suíte headless):

```bash
LAB404_SHOT_PATH=$HOME/sala.png LAB404_SHOT_POSE="0,0.05,2,0" \
    godot4 --path . res://tests/screenshot.tscn
```

- [ ] conferir no hardware: conforto da retícula e do alcance de interação (1,7 m)

## POC 3 — automatizado (`tests/poc3_test.gd` + `tests/test_aria_adapter.py`)

Cobre: intents restritas, timeout, fallback com adapter/Ollama fora, terminal abrindo/fechando,
contexto enviado e personalidade versionada.

- [x] Ollama disponível (resposta real em português) — 2026-09-10, `llama3.1:8b`: intent `DIAGNOSE`, confidence 0.9, 22 s (directo no adapter) e **12,9 s dentro do jogo**, intent `HINT` (`tests/poc3_live_test.tscn`, 5/5 PASS)
- [ ] `llama3.2:3b`: instalar e repetir (esperado: mais rápido que os ~20 s do modelo 8B)
- [x] modelo inexistente / JSON malformado / resposta inválida (fallback) — cobertos por `tests/test_aria_adapter.py`
- [x] modelo lento (o cliente Godot espera 35 s — acima do timeout de 30 s do adapter — e só então mostra fallback) — coberto por `tests/poc3_test.gd`

### Integração ao vivo (opcional)

Com o adapter e um modelo local rodando:

```bash
LAB404_MODEL=llama3.1:8b .venv/bin/uvicorn scripts.aria_adapter:app --port 8000 &
godot4 --headless --path . res://tests/poc3_live_test.tscn
```

## POC 4 — automatizado (`tests/poc4_test.gd`)

Cobre: fala do NPC por estado, luzes conforme energia, tom da ARIA após alerta ignorado,
quatro camadas de memória e limite do histórico.

- [ ] diálogo contextual no hardware (loop completo com terminal)

## POC 5 — automatizado (`tests/poc5_test.gd`)

Cobre: módulos/POIs/iluminação, determinismo por seed, conectividade BFS em 6 seeds e reciprocidade de portas.

- [ ] navegação manual da ala gerada (caminhabilidade real)

## POC 6 — automatizado (`tests/poc6_test.gd`)

Cobre: tutorial, missão completa por interação real, áudio disponível, save/load, geração da ala
procedural no corredor, núcleo de ARIA, escolhas do epílogo.

- [ ] início ao fim por uma pessoa (10–20 min) — CA-013
- [ ] joystick e teclado no hardware
- [ ] build limpa (após instalar export templates)
