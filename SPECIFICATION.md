# SPECIFICATION.md — Laboratório 404

Especificação funcional e técnica, independente de implementação. Fonte de intenção para agentes de IA. Todo requisito aqui deve ser observável e testável.

> Versões exatas marcadas como `A CONFIRMAR` devem ser preenchidas antes do fechamento do POC correspondente.

## 1. Objetivo

Construir, de forma incremental (POC 1 → POC 6), um jogo 3D educacional/ficcional em que o jogador explora o **Laboratório 404** — instalação subterrânea administrada pela IA local **ARIA** — usando **Godot 4** para gameplay, **Blender** para assets e **Ollama** para a conversa com ARIA, com controle por **teclado e joystick USB de PlayStation 1**.

Cada POC deve terminar em uma versão **executável e demonstrável** (Regra de Ouro).

### Fora de escopo
- Multiplayer/online.
- Controle direto do jogo pela LLM (a LLM só devolve texto e intenções).
- Ramificação narrativa extensa (no POC 6 a escolha altera apenas o epílogo).
- Assets de produção final (placeholders são aceitáveis até o POC 6).

## 2. Atores

| Ator | Papel |
|---|---|
| Jogador (técnico de campo) | movimenta, interage, resolve a missão |
| ARIA (IA local) | conversa, dá dicas/lore, reage ao estado |
| ECO | registro de voz de um antigo operador (terminais/gravações) |
| NPCs (POC 4+) | reagem ao estado do laboratório |
| Desenvolvedor/agente | implementa e valida os POCs |

## 3. Estados e eventos

### Estados de equipamento (POC 2+)
`OFF`, `FAULT`, `READY`, `RUNNING` — serializáveis e independentes de interface.

### Estados globais (`GameState`)
`power_restored`, `communication_restored`, `plc_restarted`, `aria_trusted`.

### Eventos principais
- `INTERACT` (ação de proximidade/raycast).
- `ITEM_COLLECTED`, `EQUIPMENT_STATE_CHANGED`, `QUEST_STEP_COMPLETED`.
- `ARIA_REPLY` (resposta estruturada com intenção).
- `ARIA_TONE_CHANGED` (POC 4).

## 4. Requisitos funcionais

### POC 1 — Fundação jogável

| ID | Requisito |
|---|---|
| FR-001 | O projeto usa um **Input Map** com ações semânticas (`move_forward`, `move_backward`, `move_left`, `move_right`, `look_*`, `interact`, `cancel`, `run`, `flashlight`, `inventory`, `pause`, `dialog_next`). Proibido hardcode de botão/índice de joystick no gameplay. |
| FR-002 | O `Player` (`CharacterBody3D`) movimenta-se por WASD/setas e pelo analógico esquerdo do joystick. |
| FR-003 | A câmera é controlada por mouse e, quando o adaptador expõe os eixos, pelo analógico direito. |
| FR-004 | Gravidade e colisão impedem o personagem de atravessar paredes/piso. |
| FR-005 | Menu de pausa acionado por `Esc` (teclado) e `Start` (joystick). |
| FR-006 | HUD mínimo visível (objetivo e prompt de interação). |
| FR-007 | Tela de diagnóstico de input (`InputTest`) lista joysticks conectados, eixos e botões em tempo real, com deadzone configurável (padrão `0.15`). |
| FR-008 | O jogo trata hotplug: desconectar/reconectar o joystick sem quebrar a execução. |

### POC 2 — Laboratório funcional

| ID | Requisito |
|---|---|
| FR-009 | `Interactable` é um sistema desacoplado: detecção por raycast de proximidade + prompt contextual, emitindo o sinal `interacted`. |
| FR-010 | Inventário diegético (kit técnico) com itens coletáveis (fusível F-17, módulo RS-404, chave). |
| FR-011 | Portas abrem/fecham, podendo depender de permissões/estado. |
| FR-012 | Equipamentos (painel, CLP, bomba, tanque, sensor) possuem estados serializáveis (`OFF`, `FAULT`, `READY`, `RUNNING`). |
| FR-013 | Missão `RESTAURAR_COMUNICACAO`: encontrar fusível → encontrar módulo RS-404 → instalar ambos → reiniciar CLP → diagnosticar bomba → abrir porta do corredor. |
| FR-014 | Feedback visual e sonoro para interações e mudanças de estado. |
| FR-015 | Sala 3D modelada no Blender (portas, painel, tanque, bomba, sensor, itens) exportada como GLB/glTF. |
| FR-015a | Identidade visual da sala conforme `docs/Detalhamento do Ambiente 3D — Laboratório 404.md`: infraestrutura de teto (eletrocalhas, tubulações, vigas), faixas de segurança, mobiliário, luminárias visíveis e letreiros das estações (`Label3D`). |

### POC 3 — ARIA + Ollama

| ID | Requisito |
|---|---|
| FR-016 | Adapter local (`POST /chat`, FastAPI) valida entrada, injeta contexto, chama o Ollama e valida a saída. |
| FR-017 | O contrato de saída devolve `text` e `intent` estruturada; o jogo aceita apenas intenções cadastradas (`HINT`, `DIAGNOSE`, `LORE`, `STATUS`, `NONE`). |
| FR-018 | Cliente HTTP assíncrono em Godot com timeout, tratamento de erro e fallback para mensagens pré-definidas. |
| FR-019 | Terminal de ARIA na UI (entrada de texto, histórico e resposta). |
| FR-020 | A personalidade de ARIA fica em arquivo de configuração versionado, não espalhada nos scripts. |
| FR-021 | A LLM não controla física nem executa comandos; apenas retorna texto e intenções que o jogo valida. |

### POC 4 — Mundo inteligente

| ID | Requisito |
|---|---|
| FR-022 | NPCs reagem ao estado do laboratório (ex.: técnico comenta a bomba). |
| FR-023 | Memória separada em: sessão, estado persistente do jogo, conhecimento narrativo e histórico conversacional. |
| FR-024 | Eventos alteram o mundo: luzes conforme energia, portas conforme permissão, tom da ARIA muda se o jogador ignora um alerta. |
| FR-024a | A iluminação é em camadas: luz geral (estado claro/emergência) **alinhada às luminárias visíveis** + acentos por zona (emergência, ARIA, painel, bomba, sala de controle) que preservam a identidade cromática. |
| FR-024b | A câmera de segurança da sala acompanha o jogador depois que a energia é restabelecida. |

### POC 5 — Laboratório procedural

| ID | Requisito |
|---|---|
| FR-025 | Módulos (corredor, controle, bombas, baterias, sensores, arquivo, contenção) com entradas, saídas, pontos de interesse, iluminação e sockets para props. |
| FR-026 | Geração determinística por `seed`. |
| FR-027 | Garantia de conectividade: nenhuma sala inacessível e pontos de interesse alcançáveis. |

### POC 6 — Vertical slice

| ID | Requisito |
|---|---|
| FR-028 | Experiência jogável de 10–20 minutos com começo, meio e fim (chegada → tutorial → diagnóstico → conversa → exploração → recuperação → falha → redirecionamento de energia → revelação → reinicialização → porta final → epílogo). |
| FR-029 | Tutorial de controles dentro do jogo. |
| FR-030 | Save/load de progresso. |
| FR-031 | Áudio ambiente, alarmes e efeitos. |
| FR-032 | Epílogo variável conforme escolha (seguir instruções, questionar ARIA ou reiniciar o núcleo). |
| FR-033 | Empacotamento/export executável e demonstração sem intervenção do desenvolvedor. |

## 5. Requisitos não funcionais

| ID | Requisito | Métrica/condição |
|---|---|---|
| NFR-001 | Executa em PC sem GPU dedicada | **Medido: 60 FPS** (limitado por vsync) na cena POC 1 — iGPU AMD Radeon Graphics, 1280×720, renderer `gl_compatibility` (2026-09-10) |
| NFR-002 | Escala Blender→Godot | 1 unidade Blender = 1 metro |
| NFR-003 | LLM local pequena | Alvo `llama3.2:3b` (`A CONFIRMAR` instalação); conversa real validada com `llama3.1:8b` local em 2026-09-10 (22 s no 1º turno, dentro do timeout de 30 s) |
| NFR-004 | Timeout do adapter | 30 s na chamada ao Ollama |
| NFR-005 | Robustez de input | nenhum número de botão de joystick hardcoded |
| NFR-006 | Segurança da IA | apenas intents cadastradas; resposta inválida → fallback |
| NFR-007 | Assets neutros | cores/materiais ajustáveis por pós-processamento |
| NFR-008 | Determinismo (POC 5) | mesma `seed` → mesma disposição de módulos |

## 6. Interface pública — ARIA Adapter

| Campo | Valor |
|---|---|
| Endpoint / operação | `POST /chat` |
| Autenticação / autorização | nenhuma (localhost). Expor fora do localhost: `A CONFIRMAR` |
| Payload / schema | `{"message": str, "game_state": dict}` — `message` obrigatório, `game_state` opcional |
| Respostas | `200` → `{"text", "intent", "target"?, "confidence"}`; `422` validação pydantic; `5xx`/exceção → `{"text": fallback, "intent": "NONE", "confidence": 1.0, "error": ...}` |
| Idempotência / concorrência | N/A (chat é somente-leitura; não muta estado) |
| Limites | timeout 30 s; `message` string limitada (A CONFIRMAR tamanho máximo) |
| Falha / timeout | fallback textual pré-definido; intent `NONE`; sem retry automático no adapter |

## 7. Critérios de aceitação

Formato **DADO / QUANDO / ENTÃO**, incluindo casos de erro.

### POC 1
- **CA-001:** DADO um jogo executando, QUANDO o jogador pressiona WASD/setas ou move o analógico esquerdo, ENTÃO o personagem se move sem atravessar paredes.
- **CA-002:** DADO o joystick conectado, QUANDO o jogador move o analógico direito (quando exposto), ENTÃO a câmera gira.
- **CA-003:** DADO o jogo em execução, QUANDO o jogador pressiona `Esc`/`Start`, ENTÃO o jogo pausa e o menu aparece.
- **CA-004:** DADO a tela `InputTest`, QUANDO qualquer joystick é conectado/desconectado, ENTÃO a lista de dispositivos/eixos/botões é atualizada sem travar.
- **CA-005:** DADO o projeto, QUANDO aberto no Godot 4, ENTÃO executa sem assets externos obrigatórios.

### POC 2
- **CA-006:** DADO o jogador próximo a um objeto interativo, QUANDO o raycast o atinge, ENTÃO aparece o prompt contextual e a ação `interact` o aciona.
- **CA-007:** DADO os itens coletados, QUANDO instalados no painel, ENTÃO o passo da missão é concluído e o HUD avança.
- **CA-008:** DADO um equipamento, QUANDO seu estado muda, ENTÃO o estado é serializável e o feedback visual/sonoro é emitido.

### POC 3
- **CA-009:** DADO o Ollama indisponível ou lento, QUANDO o jogador envia uma mensagem, ENTÃO recebe fallback em até N segundos (timeout) sem travar o jogo.
- **CA-010:** DADO uma resposta da LLM, QUANDO a intent não está em `ALLOWED_INTENTS`, ENTÃO é rejeitada/convertida para `NONE`.

### POC 4–6
- **CA-011:** DADO um evento de mundo, QUANDO ocorre, ENTÃO NPCs/ambiente refletem o novo estado (luz, tom da ARIA, porta).
- **CA-012:** DADO a mesma `seed` (POC 5), QUANDO o laboratório é gerado, ENTÃO a disposição é idêntica e todas as salas são alcançáveis.
- **CA-013:** DADO uma pessoa sem conhecimento prévio, QUANDO joga o vertical slice, ENTÃO completa do início ao fim sem intervenção do desenvolvedor.

## 8. Matriz de rastreabilidade

| Requisito | Teste (ver `docs/TESTES.md`) | Evidência |
|---|---|---|
| FR-001…FR-008 | POC 1 (input, movimento, colisão, câmera, pausa, HUD) | build Godot + roteiro manual |
| FR-009…FR-015 | POC 2 (interação, inventário, porta, missão, identidade visual) | build + teste de script |
| FR-016…FR-021 | POC 3 (Ollama, timeout, JSON inválido, fallback) | teste de integração do adapter |
| FR-022…FR-024 | POC 4 (estado, NPC, evento, diálogo) | build + roteiro manual |
| FR-025…FR-027 | POC 5 (seed, conectividade) | teste determinístico |
| FR-028…FR-033 | POC 6 (início ao fim, save, áudio, build) | playthrough completo |

## 9. Premissas, riscos e perguntas bloqueadoras

### Premissas
- Godot 4.x com GDScript; Python 3 com FastAPI/uvicorn/requests/pydantic; Ollama com `llama3.2:3b`.
- O adaptador USB de PS1 pode mapear botões/eixos de forma imprevisível → nunca codificar índices.

### Riscos
- Mapeamento do joystick varia por hardware (mitigado por FR-007/FR-008).
- LLM lenta/indisponível (mitigado por NFR-004, FR-018).
- Alvo sem GPU dedicada exige geometria/texturas simples (NFR-001, NFR-007).

### Perguntas bloqueadoras (não bloqueiam o POC 1)
- Versão do Godot: **4.5** (`4.5.stable.official.876b29033`), confirmada em 2026-09-10; renderer `gl_compatibility` (alvo sem GPU dedicada).
- Blender: **5.2.1 LTS** (confirmado em 2026-09-10); Python: **3.12.3** (sistema) — venv do projeto com fastapi/pydantic/requests/uvicorn.
- Necessidade de autenticação no adapter se exposto fora do localhost: `A CONFIRMAR`.
- Tamanho máximo da mensagem no `/chat`: implementado limite de **2000 caracteres** (validado por teste).

## 10. Estado de validação (2026-09-10)

Suíte: `tests/run_all.sh` (Godot headless + Python). **209 verificações Godot + 16 testes Python, todas PASS.**

| Critério | Evidência | Status |
|---|---|---|
| CA-001 | `tests/poc1_test.gd` — movimento por ação semântica, parada verificada contra a parede, piso | PASS (automático) |
| CA-002 | `tests/poc1_test.gd` — ação `look_right` gira a câmera; limites de pitch; mouse | PASS (automático; mouse = MANUAL) |
| CA-003 | `tests/poc1_test.gd` — ação `pause` pausa/retoma e exibe o menu | PASS (automático) |
| CA-004 | `tests/poc1_test.gd` — deadzone configurável + handler de hotplug | PASS (parcial; joystick físico = MANUAL) |
| CA-005 | `tests/poc1_test.gd` — `main.tscn` carrega e roda sem assets externos | PASS (automático) |
| CA-006 | `tests/poc2_test.gd` — prompt contextual + interação por raycast | PASS (automático) |
| FR-015a / FR-024a | `tests/poc2_test.gd` — luminárias alinhadas, acentos com cores distintas, letreiros billboard das estações; evidência visual em `docs/images/poc2-sala-*.png` | PASS (automático) |
| FR-024b | `tests/poc2_test.gd` — câmera de segurança ativa após a energia voltar e girando na direção do jogador | PASS (automático) |
| CA-007 | `tests/poc2_test.gd` — coleta, instalação no painel e avanço da missão no HUD | PASS (automático) |
| CA-008 | `tests/poc2_test.gd` — estados OFF/FAULT/READY/RUNNING serializáveis | PASS (automático) |
| CA-009 | `tests/poc3_test.gd` + `tests/test_aria_adapter.py` — fallback com adapter/Ollama fora | PASS (automático) |
| CA-010 | `sanitize_intent` (cliente e adapter) — intent inválida vira `NONE` | PASS (automático) |
| CA-011 | `tests/poc4_test.gd` — NPC, luzes por energia e tom da ARIA após alerta ignorado | PASS (automático) |
| CA-012 | `tests/poc5_test.gd` — mesma `seed` → mesmo layout; conectividade por BFS em 6 seeds | PASS (automático) |
| CA-013 | `tests/poc6_test.gd` — tutorial → missão → ala procedural → epílogo → save/load | PARCIAL (playthrough humano = MANUAL) |
| FR-033 | Export do executável | A CONFIRMAR (sem *export templates* no ambiente) |
