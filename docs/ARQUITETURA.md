# Arquitetura técnica

```mermaid
flowchart LR
    K[Teclado] --> I[Godot Input Map]
    J[Joystick USB PS1] --> I
    I --> P[Player Controller]
    P --> W[World / Physics]

    W --> G[Game State]
    G --> UI[HUD / Menus]
    G --> Q[Quest System]
    G --> E[Equipment State]

    UI --> T[ARIA Terminal]
    T --> A[Local API Adapter]
    A --> O[Ollama]
    O --> A
    A --> T

    B[Blender] --> GLB[GLB/glTF]
    GLB --> W
```

## Separação de responsabilidades

### Blender
Modelagem, UV, materiais, rigging, animações e exportação.

### Godot
Gameplay, física, input, UI, áudio, cenas, estados, salvamento e validação.

### Ollama
Inferência local e geração de respostas de ARIA.

### Adaptador
Converte mensagens do jogo para o formato do modelo e restringe o retorno.

## Estrutura sugerida

```text
lab404/
├── assets/
├── scenes/
├── scripts/
│   ├── player/
│   ├── interaction/
│   ├── quests/
│   ├── equipment/
│   ├── ai/
│   └── ui/
├── data/
├── audio/
├── shaders/
└── tests/
```
