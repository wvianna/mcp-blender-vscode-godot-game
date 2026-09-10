# MONOGRAFIA_EVIDENCIAS.md — Matriz de evidências

Atualizado em 2026-09-10. Formato: `Afirmação | Evidência | Arquivo/Fonte | Seção`.

| # | Afirmação | Evidência | Arquivo/Fonte | Seção |
|---|---|---|---|---|
| 1 | 211 verificações do motor + 16 testes do adaptador, todas aprovadas | Execução da suíte completa (10/09/2026) | `tests/run_all.sh`, `tests/poc*_test.gd`, `tests/test_aria_adapter.py`, `STATUS.md` | 6.1; Apêndice B |
| 2 | Etapas 1--6 entregues e demonstráveis (Regra de Ouro) | Suíte verde por etapa + execução do jogo | `tests/`, `SPECIFICATION.md`, `STATUS.md` | 5.2; 6.1 |
| 3 | 60 FPS (vsync) em 1280x720 na GPU integrada | Leitura do motor em execução na cena completa | Máquina de referência (Tab. 4.1); `STATUS.md` | 6.3 |
| 4 | Asset 3D: 342 nós, 37 materiais, 35 colisões, 1.018,7 KB | Inspeção programática do GLB | `assets/lab404/lab_sala_poc2.glb` (medido em 10/09/2026) | 5.4.1; 6.4 |
| 5 | Latências da IA: 22,0 s / 16,1 s / 12,9 s | Três execuções cronometradas (3 contextos) | `STATUS.md`; captura `docs/images/poc3-aria-terminal-resposta.png` | 6.5 |
| 6 | IA responde de ponta a ponta com modelo local | Teste ao vivo (5/5 verificações; intent HINT) | `tests/poc3_live_test.tscn`; `STATUS.md` | 6.5 |
| 7 | Degradação segura: serviço fora do ar não trava o jogo | Testes de contrato e de integração | `tests/test_aria_adapter.py`; CA-009/CA-010 | 5.5.4; 6.5 |
| 8 | Intenção inválida converte para NONE em duas camadas | Testes automatizados | `scripts/aria_adapter.py` (`sanitize_intent`); cliente GDScript; CA-010 | 5.5.2 |
| 9 | Missão completa do início ao fim (automatizado) | Cena de teste da etapa final | `tests/poc6_test.gd` | 6.2 |
| 10 | Geração procedural determinística e conectada | Teste com 6 sementes + BFS | `tests/poc5_test.gd`; CA-012 | 5.7 |
| 11 | Porta B1 abre com a folha visual (defeito corrigido) | Testes de regressão + capturas antes/depois | `tests/poc2_test.gd`; `docs/images/poc2-porta-b1-*.png` | 5.4.5 |
| 12 | Ambiência em laço correto (defeito QOA corrigido) | Verificação de regressão na suíte | `scripts/sfx.gd`; `tests/poc6_test.gd` | 5.8.3 |
| 13 | Joystick invisível ao jogo por confinamento do pacote | Diagnóstico no log do jogo + udev do sistema | `scripts/main.gd` (log de joysticks); `docs/INSTALL.md` | 7.6 |
| 14 | Áudio silencioso por estado de mudo do aplicativo | Diagnóstico do servidor de áudio | `docs/INSTALL.md` (solução de problemas) | 7.6 |
| 15 | Vídeo de demonstração de 1 min 08 s | Arquivo de vídeo + link no repositório | `docs/videos/poc-laboratorio-404_1.mp4` | 6.6 |
| 16 | Tela de diagnóstico de entrada (FR-007/FR-008) | Captura da tela em execução | `figures/input_test.png` | Apêndice D |

## Evidências negativas / lacunas declaradas

| # | Lacuna | Motivo | Marcador no texto |
|---|---|---|---|
| N1 | Estudo com usuários (aprendizagem/usabilidade) | Fora do escopo | `[ESTUDO DE USUÁRIO NÃO REALIZADO]` — caps. 7 |
| N2 | Comparação quantitativa com sistemas correlatos | Objetivos distintos | `[ESTUDO COMPARATIVO NÃO REALIZADO]` — cap. 3/7 |
| N3 | Tempo de quadro por percentil | Não instrumentado | `[MEDIÇÃO DE FRAME TIME NÃO REALIZADA]` — cap. 6 |
| N4 | Modelo-alvo llama3.2:3b | Não instalado no ambiente | `[MODELO-ALVO NÃO EXECUTADO]` — cap. 6 |
| N5 | Validação manual (mouse, joystick físico, percurso humano) | Depende de hardware/pessoa | caps. 4/6/7 |
| N6 | Empacotamento (FR-033) | Export templates ausentes | caps. 6/7 |
