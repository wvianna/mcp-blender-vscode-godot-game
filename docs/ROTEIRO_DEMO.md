# Roteiro de demonstração — Laboratório 404

Objetivo: fechar **CA-013** (playthrough completo por uma pessoa) e registrar o resultado.
Duração esperada: 15–20 min. O que já é coberto por teste automatizado está em `docs/TESTES.md`.

## Antes de começar

```bash
./start.sh                  # jogo + adapter de ARIA (PIDs/logs em .run/)
curl -s localhost:8000/health   # deve responder {"status":"ok", ...}
```

- Sem modelo Ollama instalado, o terminal de ARIA mostra o **fallback** — o jogo continua funcionando.
- Modelos disponíveis nesta máquina (2026-09-10): `llama3.1:8b` (testado, ~22 s frio), além de
  `deepseek-r1:8b`, `gemma4:12b`, `ornith:9b`, `qwen2.5-coder:1.5b`. O alvo é `llama3.2:3b` (mais rápido).
- Para trocar o modelo: `LAB404_MODEL=llama3.1:8b ./start.sh`

## Roteiro

| # | Passo | O que deve acontecer |
|---|---|---|
| 1 | Chegada (0–1 min) | Tutorial com 5 dicas no HUD; avance com `Enter`/`Espaço`/X. Objetivo "Localizar o fusível F-17" no painel esquerdo. Luz de emergência avermelhada. |
| 2 | Diagnóstico inicial (1–3 min) | No painel (E): "FALTA INSTALAR — fusível F-17, módulo RS-404". No CLP: "sem energia". Na porta leste: "travada". |
| 3 | Coleta (3–6 min) | Pegue o fusível na bancada (canto noroeste) e o módulo na caixa de carga (canto sudeste). Os dois aparecem no **KIT TÉCNICO**. |
| 4 | Conversa com ARIA (6–8 min) | Terminal na parede sul: pergunte "o que aconteceu aqui?" e "como reinicio o CLP?". Resposta em português; a linha de status mostra a intent (`HINT`/`DIAGNOSE`/`LORE`/`STATUS`/`NONE`). |
| 5 | Recuperação (8–11 min) | Instale no painel (os slots ficam verdes) → reinicie o CLP ("EM OPERAÇÃO") → inspecione a bomba ("EM OPERAÇÃO"). As luzes passam a branco forte e a ARIA avisa para não ficar no corredor. |
| 6 | Alerta ignorado (11–12 min) | Fique >90 s sem falar com a ARIA: o tom muda para "impaciente" (a próxima resposta fica mais curta/seca). Abrir o terminal reconhece o alerta e o tom volta a "neutra". |
| 7 | Porta final (12–14 min) | Abra a porta do corredor (E) → "MISSÃO CONCLUÍDA". O NPC muda a fala (reage ao estado). |
| 8 | Ala procedural (14–16 min) | Entre no corredor: ARIA revela o contexto e uma ala é gerada (mesma `seed` = mesma planta; `FR-026`). |
| 9 | Epílogo (16–18 min) | Interaja com o **NÚCLEO DE ARIA** e escolha uma das três opções; o texto final muda conforme a escolha. |
| 10 | Save/load (18–19 min) | `F5` salva; feche o jogo (`./stop.sh`), reabra (`./start.sh`) e pressione `F9`: missão, kit e estados dos equipamentos voltam. |

## Checklist de hardware (manual)

- [ ] teclado (WASD/setas) e mouse (câmera)
- [ ] joystick PS1: calibrar no menu (`Esc`/Start → Diagnóstico de input) e anotar eixo/botão de cada tecla
- [ ] hotplug: desconectar/reconectar com o jogo aberto (a calibração reage; o jogo não trava)
- [ ] conforto: sensibilidade do mouse e zona morta (`0.15` padrão)

## Registro do resultado

Anote no final e cole em `STATUS.md` (o nível de evidência passa a **LOCAL + MANUAL validado**):

```text
Data: ____  Tempo total: ____ min  Modelo ARIA: ____
Completou do início ao fim sem ajuda? ( ) sim ( ) não
Falhas/estranhezas: ____
```
