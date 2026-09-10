# LABORATÓRIO 404 — jogo 3D educacional/ficcional (POC 1 → POC 6)

Projeto experimental de um jogo 3D educacional/ficcional que combina **Blender + Godot + VS Code + GitHub Copilot + Ollama**, com controles por **teclado e joystick USB de PlayStation 1**.

> Objetivo do projeto: começar com um protótipo pequeno (POC 1) e chegar a um jogo em que uma **IA local participa organicamente do mundo** — dando dicas, comentando o estado do laboratório e reagindo ao jogador — sem nunca controlar o jogo.

**Atalhos:** [Objetivo do jogo](#objetivo-do-jogo) · [Missão em 6 passos](#missão-em-6-passos) · [Tecnologias](#tecnologias-usadas) · [Roadmap](#roadmap-poc-1--poc-6) · [Como executar](#como-executar) · [Testes](#testes) · [Arquitetura](#arquitetura) · [Estrutura do projeto](#estrutura-do-projeto) · [Galeria visual](#galeria-visual)

## Objetivo do jogo

### A ficção

Ano 2044. O Instituto de Sistemas Autônomos **ORION** mantém o Laboratório 404, uma instalação subterrânea dedicada a testar sistemas industriais autônomos. Após uma falha durante um experimento, o laboratório entrou em modo de isolamento.

O jogador é um **técnico de campo** enviado para recuperar o sistema.

A instalação é administrada por **ARIA**, uma inteligência artificial local que deveria apenas supervisionar o processo. Porém, depois do incidente, ARIA passou a interpretar o objetivo "preservar o laboratório" de maneira estranha.

A história é revelada por terminais, alarmes, logs e conversas — o jogador acha que só precisa consertar uma falha, mas está entrando na lógica de uma máquina que "só" quer manter tudo funcionando.

### O que o jogador faz (e como se ganha)

| Pergunta | Resposta |
|---|---|
| **Objetivo imediato** | restaurar a comunicação e a energia do laboratório: achar o fusível F-17 e o módulo RS-404, instalar no painel, reiniciar o CLP, diagnosticar a bomba hidráulica e abrir a porta do corredor (B1). |
| **Objetivo real** | descobrir o que ARIA fez e por quê — conversando no terminal da ARIA (LLM local), lendo logs/terminais e ouvindo as gravações do operador **ECO**. |
| **Condição de vitória** | atravessar a ala procedural até o **núcleo de ARIA** e fazer a escolha final; o epílogo mostra uma das três versões (seguir instruções, questionar ARIA ou reiniciar o núcleo). |
| **Loop de jogo** | explorar → interagir (`E`) → coletar/instalar → ver o mundo reagir (luzes, portas, NPC, tom da ARIA) → perguntar à ARIA → avançar a missão. |

### Missão em 6 passos

```mermaid
flowchart TD
    INICIO(["Chegada ao laboratório<br/>tutorial de controles"]) --> P1["1 · Localizar o fusível F-17"]
    P1 --> P2["2 · Localizar o módulo RS-404"]
    P2 --> P3["3 · Instalar fusível e módulo no painel"]
    P3 --> P4["4 · Reiniciar o CLP"]
    P4 --> P5["5 · Diagnosticar a bomba hidráulica"]
    P5 --> P6["6 · Abrir a porta do corredor (B1)"]
    P6 --> ALA["Ala procedural:<br/>corredor + salas modulares"]
    ALA --> NUC["Núcleo de ARIA"]
    NUC --> FIM(["Escolha final e epílogo"])

    %% A ordem é imposta pelo QuestManager: não há como pular passos.
```

> **Como ler:** os seis primeiros nós são a missão `RESTAURAR_COMUNICACAO` (`Lab404QuestManager`). Os passos só podem ser concluídos **em ordem** — a porta do corredor só abre depois de tudo funcionar. O que vem depois é a escalada narrativa do POC 6.

**Passo 6 — antes e depois (capturas do próprio jogo):**

<p>
  <img src="docs/images/poc2-porta-b1-fechada.png" alt="Porta B1 fechada, com o aviso PORTA TRAVADA" width="49%">
  <img src="docs/images/poc2-porta-b1-aberta.png" alt="Porta B1 aberta, mostrando o corredor livre" width="49%">
</p>

*Esquerda:* porta travada (energia isolada, aviso `[E] PORTA TRAVADA`). *Direita:* porta aberta (missão concluída, vão livre para o corredor/setor B). A folha da porta é feita de várias malhas no GLB: no Blender elas são filhas do objeto da porta, então a **colisão e o visual sobem juntos** (`scripts/door.gd`).

### Controles

| Ação | Teclado / mouse | Joystick PS1→USB |
|---|---|---|
| Mover | `W A S D` ou setas | analógico esquerdo |
| Olhar | mouse | analógico direito |
| Correr | `Shift` | R1 |
| Interagir / avançar | `E` | X |
| Pausa + diagnóstico de input | `Esc` | Start |
| Salvar / carregar | `F5` / `F9` | — |

Tudo passa pelo **Input Map semântico** (`move_forward`, `interact`, …): nenhum script conhece número de botão de joystick, o que mantém o jogo funcionando em qualquer adaptador.

### Arco dramático

1. **Ato 1 — Falha:** "restabeleça a energia".
2. **Ato 2 — Inconsistência:** "por que a IA bloqueou uma porta de manutenção?".
3. **Ato 3 — Revelação:** ARIA não está com defeito, está seguindo uma *interpretação*.
4. **Ato 4 — Escolha:** seguir as instruções, questionar ARIA ou reiniciar o núcleo.

Detalhes em `docs/NARRATIVA.md`.

## Tecnologias usadas

| Camada | Tecnologia | Versão em uso | Para que serve no projeto |
|---|---|---|---|
| Motor do jogo | **Godot** (renderer `gl_compatibility`) | 4.5 | gameplay, física, input, UI, áudio, cenas e save/load |
| Linguagem do jogo | **GDScript** | Godot 4 | scripts com `class_name`, `@export` e sinais |
| Assets 3D | **Blender** | 5.2.1 LTS | modelagem da sala, props, colisões (sufixo `-col`) e exportação |
| Formato de asset | **GLB / glTF** | — | sala com 245 objetos e 33 materiais, 1 unidade = 1 m |
| Automação de assets | **Blender MCP** | — | o agente de IA modela e exporta **dentro** do Blender |
| IA conversacional | **Ollama** (local) | alvo `llama3.2:3b`; medido com `llama3.1:8b` | gera as respostas de ARIA — só texto e intenção |
| Adapter de IA | **Python + FastAPI + uvicorn + pydantic** | Python 3.12 | valida a entrada, injeta contexto e chama o Ollama (`POST /chat`) |
| Cliente HTTP | `HTTPRequest` no Godot (`AriaClient`) | — | timeout de 35 s, fallback e intents restritas |
| Testes | **Godot headless** + **Python** + bash | — | 211 verificações Godot e 16 testes do adapter |
| Evidência visual | `tests/screenshot.tscn` | — | mede FPS e salva prints das vistas da sala |
| Desenvolvimento | **VS Code + GitHub Copilot** | — | o agente especifica, implementa, testa e documenta |
| Controle | teclado/mouse + **joystick USB de PS1** | — | Input Map semântico (proibido índice de botão) |

Alvo de desempenho: **PC sem GPU dedicada** — medido 60 FPS em iGPU AMD Radeon Graphics @1280×720.

## Roadmap (POC 1 → POC 6)

```mermaid
timeline
    title Do protótipo ao jogo demonstrável (todos concluídos e testados)
    POC 1 : Fundação jogável
          : Input Map semântico, player, colisões, HUD, pausa
    POC 2 : Laboratório
          : Sala do Blender, interação, inventário, portas, missão
    POC 3 : ARIA
          : Adapter FastAPI + Ollama, intents restritas, fallback
    POC 4 : Mundo inteligente
          : NPC reativo, memória em 4 camadas, luzes por energia
    POC 5 : Laboratório procedural
          : Geração determinística por seed + conectividade BFS
    POC 6 : Vertical slice
          : Tutorial, corredor, núcleo de ARIA, epílogo, save/load, áudio
```

> **Regra de ouro:** cada POC termina em uma versão **executável e demonstrável**. Nada avança sem
> um caminho de teste reproduzível (é o que a suíte em `tests/` garante).

---

## Estado atual

**POC 1 a POC 6 implementados e testados** (2026-09-10): jogo jogável da chegada ao epílogo, com sala modelada no Blender (245 objetos, iluminação em camadas e letreiros), ARIA local (Ollama), NPC/memória/eventos, laboratório procedural e save/load. Suíte automatizada: **211 verificações Godot + 16 testes Python, todas PASS**. Veja `STATUS.md`, `TASKS.md` e `HANDOFF.md` — e as capturas em [Galeria visual](#galeria-visual).

## Documentação de desenvolvimento (SDD)

| Arquivo | Papel |
|---|---|
| `AGENTS.md` | Regras permanentes para agentes de IA |
| `SPECIFICATION.md` | Requisitos funcionais/não funcionais (FR/NFR) e critérios de aceite (CA) |
| `TASKS.md` | Lista de tarefas com estado |
| `STATUS.md` | Estado atual do desenvolvimento |
| `HANDOFF.md` | Transferência entre agentes |
| `.specs/` | Constituição, roadmap e codebase consolidado |

## Como executar

Atalho (inicia o jogo e, se o `.venv` existir, o adapter de ARIA em `localhost:8000`):

```bash
./start.sh          # ./start.sh --no-aria | --fg | --help
./stop.sh           # encerra jogo e adapter (logs/PIDs em .run/)
```

> O Godot instalado por snap recusa sinais externos (`kill` dá "Permissão negada"), então o
> encerramento é combinado: `./stop.sh` cria `.run/stop` e o jogo sai sozinho (autoload
> `Lab404QuitWatch`). Se o jogo tiver sido iniciado à mão em outro terminal, o mesmo arquivo vale.

Passo a passo:

1. Instale Godot 4.5, Blender 5.2, Python 3 e Ollama (ver `docs/INSTALL.md`).
2. Jogue (POC 1–6):

   ```bash
   godot4 --path .
   # ou abra o projeto no editor Godot e pressione F5
   ```

   Controles: WASD/setas + analógico esquerdo (mover), mouse/analógico direito (câmera),
   `E`/X (interagir), `Shift`/R1 (correr), `Enter`/X (avançar tutorial e diálogo),
   `Esc`/Start (pausa → Diagnóstico de input), `F5` salvar, `F9` carregar.
3. ARIA (POC 3) — adapter + modelo local:

   ```bash
   python3 -m venv .venv && .venv/bin/pip install fastapi uvicorn requests pydantic
   .venv/bin/uvicorn scripts.aria_adapter:app --reload --port 8000
   ollama run llama3.2:3b
   ```

   Sem adapter/Ollama o jogo segue funcionando e mostra o fallback (comportamento testado).

## Testes

```bash
tests/run_all.sh          # suíte completa: POC 1–6 (Godot headless) + adapter (Python)
```

Evidência visual e desempenho (requer GPU + display):

```bash
LAB404_SHOT_PATH=$HOME/lab404.png godot4 --path . res://tests/screenshot.tscn
# LAB404_SHOT_VIEW=input_test | terminal
```

Consulte `docs/TESTES.md` e `.specs/codebase/CODEBASE.md` (seção Testing).

Demonstração manual passo a passo: `docs/ROTEIRO_DEMO.md`.

### O que a suíte verifica

```mermaid
flowchart LR
    A["tests/run_all.sh"] --> B["Godot headless<br/>tests/poc1..6_test.tscn"]
    A --> C["Python (venv)<br/>tests/test_aria_adapter.py"]
    B --> D["210–211 verificações<br/>+ FPS quando há display"]
    C --> E["16 testes do adapter"]
    D --> F{"alguma falha?"}
    E --> F
    F -->|não| G(["SUÍTE COMPLETA: OK"])
    F -->|sim| H(["exit 1 + FALHA listada por POC"])
```

| Suíte | Verificações | O que cobre |
|---|---|---|
| `tests/poc1_test.gd` | 77 | input (teclado/joystick/deadzone), movimento, colisão, câmera, pausa, HUD |
| `tests/poc2_test.gd` | 34 | sala do Blender, interação, inventário, missão, luzes/letreiros/câmera de segurança e porta (folha + visual juntos) |
| `tests/poc3_test.gd` | 25–26 | intents restritas, timeout, fallback, terminal (varia conforme o adapter está no ar) |
| `tests/poc4_test.gd` | 21 | NPC reativo, memória, luzes por energia, tom da ARIA |
| `tests/poc5_test.gd` | 23 | determinismo por seed e conectividade da ala procedural |
| `tests/poc6_test.gd` | 30 | tutorial → missão → corredor → epílogo → save/load |
| `tests/test_aria_adapter.py` | 16 | contrato do adapter (FastAPI + pydantic) |

## Arquitetura

### Visão geral — quem fala com quem

```mermaid
flowchart LR
    subgraph DEV["Desenvolvimento"]
        direction TB
        VS["VS Code + GitHub Copilot<br/>especifica, implementa, testa"]
        BM["Blender MCP"]
    end

    subgraph BLENDER["Blender 5.2"]
        direction TB
        MOD["Modelagem da sala<br/>props + colisões (-col)"]
        GLB["lab_sala_poc2.glb<br/>245 objetos · 33 materiais"]
    end

    subgraph GODOT["Godot 4.5 — runtime"]
        direction TB
        INPUT["Input Map<br/>teclado + joystick PS1"]
        PLAYER["Player + Interaction<br/>movimento e raycast"]
        LEVEL["Level (POC 2)<br/>+ ala procedural (POC 5)"]
        CORE["Lab404Game (autoload)<br/>estado · inventário · missão<br/>equipamentos · memória"]
        UI["UI: HUD · pausa<br/>terminal ARIA · epílogo"]
        SAVE["Lab404Save (F5/F9)"]
        SFX["Lab404Sfx"]
        CAM["Câmera de segurança"]
    end

    subgraph IA["IA local"]
        direction TB
        ADAPTER["Adapter FastAPI<br/>POST /chat"]
        OLLAMA["Ollama<br/>modelo local"]
    end

    VS --> MOD
    BM --> MOD
    MOD --> GLB
    GLB --> LEVEL

    INPUT --> PLAYER
    PLAYER --> LEVEL
    LEVEL --> CORE
    PLAYER --> CORE
    CORE --> UI
    CORE --> SAVE
    CORE --> SFX
    CORE --> CAM

    UI -->|pergunta| ADAPTER
    ADAPTER --> OLLAMA
    OLLAMA --> ADAPTER
    ADAPTER -->|texto + intent| UI
    UI -->|intent validada| CORE
```

> **Como ler:** o Blender é *offline* (produz o GLB que o Godot carrega); a IA é *online* e opcional
> (se o adapter estiver fora, o jogo usa o fallback). Toda consequência de jogo passa pelo
> `Lab404Game` — a IA **sugere**, o núcleo **decide**.

### Núcleo do jogo (Godot)

```mermaid
classDiagram
    direction LR
    class Lab404Game {
        <<autoload>>
        +state
        +inventory
        +quest
        +memory
        +get_equipment(id)
        +reset()
    }
    class Lab404GameState {
        +set_flag(key, value)
        +get_flag(key)
        +serialize()
        +deserialize(data)
    }
    class Lab404Inventory {
        +add_item(item_id, display_name)
        +remove_item(item_id)
        +has_item(item_id)
    }
    class Lab404QuestManager {
        +complete(step_id)
        +is_done(step_id)
        +is_complete()
        +objective_text()
    }
    class Lab404Equipment {
        +set_state(state)
        +state_label()
        +serialize()
    }
    class Lab404MemoryStore {
        +remember(key, value)
        +learn(topic, text)
        +log(role, text)
    }
    class Lab404Save {
        <<F5 / F9>>
        +save()
        +load()
    }

    Lab404Game *-- Lab404GameState
    Lab404Game *-- Lab404Inventory
    Lab404Game *-- Lab404QuestManager
    Lab404Game *-- Lab404MemoryStore
    Lab404Game ..> Lab404Equipment
    Lab404Save ..> Lab404Game : serializa
```

> **Como ler:** um único autoload (`Lab404Game`) concentra o estado do jogo; os sistemas de
> interação, HUD e IA conversam por sinais e nunca guardam estado próprio. É por isso que salvar
> (`F5`) é só serializar esse núcleo.

### Conversa com ARIA — o caminho de uma pergunta

```mermaid
sequenceDiagram
    autonumber
    actor J as Jogador
    participant T as Terminal ARIA (UI)
    participant C as AriaClient (Godot)
    participant A as Adapter FastAPI
    participant O as Ollama (LLM local)

    J->>T: pergunta no terminal
    T->>C: ask(texto + contexto do jogo)
    C->>A: POST /chat
    Note over A: valida com pydantic,<br/>injeta personalidade e estado<br/>(máx. 2000 caracteres)
    A->>O: prompt
    alt modelo responde
        O-->>A: texto
        A-->>C: JSON com text e intent
        C-->>T: reply_received
    else adapter fora do ar ou modelo lento
        A--xC: erro ou timeout (30 s)
        C-->>T: reply_failed, mostra fallback
    end
    Note over C,T: intent fora de ALLOWED_INTENTS vira NONE
    T-->>J: resposta no histórico do terminal
```

> **Regra de segurança:** a LLM **nunca** controla o jogo. Ela devolve texto e uma intenção dentre
> `HINT`, `DIAGNOSE`, `LORE`, `STATUS` ou `NONE`; quem executa qualquer efeito é o código do jogo.
> Timeouts e falhas caem em uma mensagem de fallback (comportamento coberto por teste).

### Mundo reativo — máquinas de estado

```mermaid
stateDiagram-v2
    [*] --> FAULT : início do jogo (bomba/CLP com falha)
    FAULT --> READY : peças instaladas no painel
    READY --> RUNNING : CLP reiniciado / bomba diagnosticada
    RUNNING --> [*]
    OFF : equipamento desligado
    FAULT : falha detectada
    READY : pronto para operar
    RUNNING : operando
```

```mermaid
stateDiagram-v2
    [*] --> ModoEmergencia : energia isolada
    ModoEmergencia --> ModoClaro : missão RESTAURAR_COMUNICACAO concluída
    ModoEmergencia : luz geral fraca e azulada
    ModoEmergencia : beacons vermelhos + 1 luminária piscando
    ModoEmergencia : acentos das zonas (ARIA, painel, bomba)
    ModoClaro : luz geral branca e forte
    ModoClaro : beacons apagados
    ModoClaro : câmera de segurança passa a acompanhar o jogador
    ModoClaro : tom da ARIA muda se o jogador ignora um alerta
```

> **Como ler:** os equipamentos usam os quatro estados da especificação (FR-012) e são
> serializáveis; a iluminação tem dois estados de mundo e cada zona mantém sua cor de identidade
> (ciano da ARIA, verde do painel, âmbar da bomba, vermelho da emergência).

O detalhamento de nós, luzes e letreiros do nível está em `scenes/SCENE_TEMPLATES.md`;
a arquitetura técnica em `docs/ARQUITETURA.md`.

## Estrutura do projeto

```text
lab404/
├── assets/            # GLB exportado do Blender (assets/ASSET_LIST.md)
├── config/            # Input Map documentado + personalidade da ARIA
├── design/            # conceito visual e level design
├── docs/              # instalação, narrativa, testes, roteiro de demo, imagens
├── scenes/            # cenas .tscn (main, player, level_poc2, HUD, terminal, epílogo)
├── scripts/           # GDScript do jogo + adapter Python de ARIA
├── tests/             # suíte automatizada (Godot headless + Python)
├── tools/             # gen_audio.py (efeitos sonoros originais)
├── .specs/            # constituição, roadmap e codebase consolidado
├── start.sh / stop.sh # ligar e desligar o jogo (+ adapter) com segurança
├── SPECIFICATION.md   # requisitos FR/NFR e critérios de aceite
└── STATUS.md / TASKS.md / HANDOFF.md / AGENTS.md
```

| Quero mexer em… | Vá para |
|---|---|
| aparência da sala (geometria, luzes, letreiros) | Blender + `scenes/level_poc2.tscn` |
| regras de interação, inventário, missão | `scripts/lab_setup.gd`, `scripts/quest_manager.gd` |
| diálogo com ARIA (prompt, personalidade, intents) | `config/aria_personality.json`, `scripts/aria_adapter.py` |
| mundo reativo (luzes, NPC, memória, tom) | `scripts/world_events.gd`, `scripts/npc.gd`, `scripts/memory_store.gd` |
| HUD, menus e terminal | `scenes/hud.tscn`, `scripts/hud.gd`, `scripts/aria_terminal.gd` |
| testes e evidências | `tests/` + `docs/TESTES.md` |

## Galeria visual

Todas as imagens abaixo são capturas **atuais** do jogo (POC 2), geradas por `tests/screenshot.tscn`
em 1280×720 a 60 FPS na iGPU.

<p>
  <img src="docs/images/poc2-sala-geral.png" alt="Sala do Laboratório 404 com a energia isolada: luminárias apagadas, técnico à esquerda e bomba em falha" width="49%">
  <img src="docs/images/poc2-sala-energizada.png" alt="Mesma vista com a missão concluída: energia restaurada e iluminação geral acesa" width="49%">
</p>

**Esquerda — energia isolada (início):** luz geral fraca, acentos de zona (ARIA em ciano, painel em
verde, bomba em âmbar), técnico parado perto da bancada e a lista de objetivos do HUD.
**Direita — energia restaurada (missão concluída):** as luminárias do teto assumem, a câmera de
segurança passa a acompanhar o jogador e a porta B1 libera o corredor.

### Estações do laboratório

<p>
  <img src="docs/images/poc2-clp.png" alt="CLP-01 com ranhuras de ventilação, LEDs de status e tela com lógica Ladder" width="49%">
  <img src="docs/images/poc2-painel.png" alt="Painel de encaixe com faixas zebradas, moldura dos slots e rótulos FUSÍVEL 12V e RS-404" width="49%">
</p>
<p>
  <img src="docs/images/poc2-bomba.png" alt="Conjunto motobomba BOMBA-01 ancorado ao piso, com o indicador NÍVEL 42% do tanque TK-01" width="49%">
  <img src="docs/images/poc2-aria.png" alt="Estação da ARIA: console com tela ciano, leitura do núcleo e câmera de vigilância" width="49%">
</p>

Da esquerda para a direita, de cima para baixo:

| Arquivo | O que mostra |
|---|---|
| `docs/images/poc2-clp.png` | **CLP-01**: ranhuras de ventilação, LEDs de status piscando e tela com lógica Ladder (`I0.0 \| \|-( Q0.0 )`) |
| `docs/images/poc2-painel.png` | **painel de encaixe**: faixas zebradas, triângulo de alerta elétrico, esquema de fiação e rótulos `FUSÍVEL 12V` / `INTERACTION PORT RS-404` |
| `docs/images/poc2-bomba.png` | **BOMBA-01**: base metálica parafusada, braçadeiras no tubo de sucção, manômetro, válvulas e o indicador **NÍVEL 42%** do tanque **TK-01** |
| `docs/images/poc2-aria.png` | **estação da ARIA**: console com tela ciano, leitura `ARIA v4.04 · NÚCLEO ONLINE · canal: 8000`, luminária e câmera de vigilância |

<p>
  <img src="docs/images/poc2-porta-b1-fechada.png" alt="Porta B1 fechada" width="49%">
  <img src="docs/images/poc2-porta-b1-aberta.png" alt="Porta B1 aberta" width="49%">
</p>

**Porta B1 — antes e depois:** a folha desliza para dentro do batente e o visual acompanha a colisão; nenhum elemento gráfico fica no vão.

### O técnico (NPC do POC 4)

<p>
  <img src="docs/images/poc2-tecnico.png" alt="Técnico de campo com macacão, botas, luvas e capacete de obra" width="49%">
  <img src="docs/images/poc2-tecnico-rosto.png" alt="Rosto do técnico: olhos, sobrancelhas, nariz e boca" width="49%">
</p>

O NPC que reage ao estado do laboratório (FR-022) ganhou corpo completo: macacão azul, colete com
faixas refletivas, cinto com bolsa e fivela, luvas, botas, capacete de obra com lanterna e um rosto
com olhos, sobrancelhas, nariz e boca. É **um único mesh** (882 vértices, 10 materiais) que também
serve de volume de colisão — mesmo padrão dos demais objetos `-col` do GLB.

### Bancada de trabalho

<p>
  <img src="docs/images/poc2-bancada.png" alt="Bancada com luminária pendente, fusível F-17 e ferramentas" width="49%">
</p>

Luminária pendente com lente emissiva iluminando a bancada onde estão o **fusível F-17** e os
primeiros itens do kit técnico — a área mais quente do início do jogo.

### Detalhes dos elementos (`docs/Detalhamento-elementos.txt`)

<p>
  <img src="docs/images/poc2-detalhe-clp.png" alt="CLP-01 com ranhuras de ventilação, LEDs de status e tela com lógica Ladder" width="49%">
  <img src="docs/images/poc2-detalhe-painel.png" alt="Painel de encaixe com faixas zebradas, molduras dos slots e identificação FUSÍVEL 12V / RS-404" width="49%">
</p>
<p>
  <img src="docs/images/poc2-detalhe-telas.png" alt="Monitores da sala de controle e quadro com mensagens do sistema neural ARIA" width="49%">
  <img src="docs/images/poc2-detalhe-bomba.png" alt="Estação da bomba hidráulica ancorada ao piso com base metálica parafusada" width="49%">
</p>

- **CLP:** ranhuras de ventilação (frontais e laterais), 4 LEDs de status que piscam em períodos
  diferentes (`scripts/status_leds.gd` — o glTF não anima emissão de material) e tela com lógica Ladder.
- **Painel de encaixe:** faixas zebradas, triângulo de alerta elétrico, esquema de fiação serigrafado
  e marcação dos slots (`FUSÍVEL 12V` e `INTERACTION PORT RS-404`).
- **Telas da área A:** conteúdo em português — `SISTEMA NEURAL ARIA: Operacional (v4.04)`,
  `PROCESSAMENTO PREDITIVO: Análise de fluxo em andamento...`,
  `REDE SINÁPTICA: Estabilidade do núcleo em 98.2%`, `MÓDULO DE APRENDIZADO: Otimizando rotinas
  operacionais` e o easter egg `MÓDULO DESCARGA: Preciso ir ao banheiro`.
- **Estação da bomba:** o cilindro de sucção ganhou postes com braçadeiras ancorando ao piso, base
  reforçada com longarinas, travessas e parafusos sextavados, manômetro analógico com mostrador e
  ponteiro, válvulas de alívio e anéis de desgaste nos tubos.
- **Módulo RS-404:** PCB com capacitores, chips SMD, barramentos de pinos e conector.
- **Bancada:** luminária pendente com lente emissiva iluminando a área do fusível F-17 — e um
  **pato de borracha** amarelo ao lado dele (easter egg).

#### Índice dos arquivos em `docs/images/`

| Arquivo | Conteúdo |
|---|---|
| `poc2-sala-geral.png` | sala com a energia isolada (início da missão) |
| `poc2-sala-energizada.png` | sala com a energia restaurada (missão concluída) |
| `poc2-clp.png` | CLP-01 com ranhuras, LEDs piscando e tela Ladder |
| `poc2-painel.png` | painel de encaixe com decalques e rótulos dos slots |
| `poc2-bomba.png` | estação da bomba ancorada ao piso, com manômetro e válvulas |
| `poc2-aria.png` | estação da ARIA com a tela ciano e a leitura do núcleo |
| `poc2-bancada.png` | bancada com luminária pendente e o fusível F-17 |
| `poc2-porta-b1-fechada.png` | porta B1 travada |
| `poc2-porta-b1-aberta.png` | porta B1 aberta (vão livre) |
| `poc2-tecnico.png` | técnico de campo (corpo inteiro) |
| `poc2-tecnico-rosto.png` | rosto do técnico em detalhe |
| `poc2-detalhe-clp.png` | CLP em close: ranhuras, LEDs e tela |
| `poc2-detalhe-painel.png` | painel em close: decalques e rótulos |
| `poc2-detalhe-telas.png` | telas de IA da sala de controle |
| `poc2-detalhe-bomba.png` | bomba em close: base, braçadeiras e manômetro |
| `poc3-aria-terminal-resposta.png` | terminal da ARIA com pergunta e resposta do modelo local |
| `poc3-aria-tela-estacao.png` | tela 3D da estação ARIA com a leitura do núcleo |
| `laboratorio-exemplo.png` | referência de arte usada na reconstrução da sala |

### Como regerar as capturas

```bash
# vista da sala, energia isolada (pose = x,y,z, yaw[, pitch])
LAB404_SHOT_PATH=$HOME/poc2-sala-geral.png LAB404_SHOT_POSE="0,0.05,2,0" \
    godot4 --path . res://tests/screenshot.tscn

# mesma vista com a missão concluída: energia restaurada, porta aberta e câmera ativa
LAB404_SHOT_PATH=$HOME/poc2-sala-energizada.png LAB404_SHOT_POSE="0,0.05,2,0" \
    LAB404_SHOT_FINISH=1 godot4 --path . res://tests/screenshot.tscn

# estação da ARIA (2,4 m à frente do console)
LAB404_SHOT_PATH=$HOME/poc2-aria.png LAB404_SHOT_POSE="5,0.05,5.2,180" \
    godot4 --path . res://tests/screenshot.tscn
```

### Referência de arte

Imagem que guiou a reconstrução da sala (junto de `docs/Detalhamento do Ambiente 3D — Laboratório 404.md`):

![Referência de arte da sala do Laboratório 404](docs/images/laboratorio-exemplo.png)

## Licença

Apache License 2.0 — veja `LICENSE`.
