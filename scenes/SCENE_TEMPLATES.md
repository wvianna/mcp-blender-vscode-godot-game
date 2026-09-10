# Templates de cenas Godot

## Main.tscn

```text
Main (Node3D)
├── WorldEnvironment
├── DirectionalLight3D
├── NavigationRegion3D
├── Level
├── Player
├── GameState
├── QuestManager
├── Audio
└── UI (CanvasLayer)
```

## Player.tscn

```text
Player (CharacterBody3D)
├── CollisionShape3D
├── MeshInstance3D
├── CameraPivot
│   └── Camera3D
├── InteractionRay
└── AudioListener3D
```

## Interactable.tscn

```text
Interactable (Area3D)
├── CollisionShape3D
├── MeshInstance3D
└── Label3D
```

## ARIA Terminal

```text
ARIATerminal (StaticBody3D)
├── CollisionShape3D
├── MeshInstance3D
├── InteractionArea
└── Screen
    └── SubViewport
```

## Detalhes visuais do nível (POC 2)

```text
Level (Node3D, lab_setup.gd)
├── LabGLB (GLB do Blender: geometria + colisões por sufixo -col)
├── Lights (OmniLight3D, world_events.gd controla energia/cor)
│   ├── ENV_Luz_Controle_A  (x=-8, z=-1.5)  ← índice 0: verificado no POC 4
│   ├── ENV_Luz_Controle_B  (x=-4, z=-1.5)  ← índice 1: é quem pisca em emergência
│   ├── ENV_Luz_Controle_C  (x=0,  z=-1.5)
│   ├── ENV_Luz_Processo    (x=4,  z=-1.5)
│   ├── ENV_Luz_Tanque      (x=8,  z=-1.5)
│   ├── ENV_Luz_Corredor    (x=14.2)
│   └── ENV_Luz_Entrada     (z=+7, ilumina a parede da ARIA)
├── Accents (OmniLight3D, cor fixa por zona)
│   ├── ENV_Luz_Emg_A/B  (vermelho, luminárias de emergência do GLB)
│   ├── ENV_Luz_Emg_C    (vermelho, leitor da porta B1)
│   ├── FX_Luz_ARIA      (ciano, terminal)
│   ├── FX_Luz_Painel    (verde, painel elétrico)
│   ├── FX_Luz_Bomba     (âmbar, bomba hidráulica)
│   └── FX_Luz_Controle  (ciano, sala de controle)
├── Labels (Label3D com billboard=1)
│   └── DEC_Lbl_TK01 / _Nivel / _PLC01 / _Bomba / _B1 / _ARIA / _Setor
├── CAM_Security (security_camera.gd)
│   ├── Body (MeshInstance3D, caixa)
│   └── Lens (MeshInstance3D, emissivo ciano)
├── WorldEvents (POC 4)
└── VerticalSlice (POC 6)
```

Regras: as posições das luzes **coincidem com as luminárias visíveis do GLB** (evita poças de luz
sem origem); `Lights` recebe energia/cor pelo estado de energia, `Accents` mantém a identidade cromática.

## Cenas implementadas

| Arquivo | Papel |
|---|---|
| `scenes/main.tscn` | Cena principal: ambiente, luz, `Level`, `Player`, `Tutorial` e `UI` |
| `scenes/player.tscn` | `Player` (CharacterBody3D) + `CameraPivot/Camera3D` + `InteractionRay` + nó `Interaction` |
| `scenes/level_poc2.tscn` | Nível: GLB do Blender, `Lights` (luminárias), `Accents` (emergência/ARIA/painel/bomba/controle), `Labels` (letreiros), `CAM_Security`, `WorldEvents` (POC 4) e `VerticalSlice` (POC 6) |
| `scenes/hud.tscn` | HUD: objetivo com passos, prompt, feedback, mira e kit técnico |
| `scenes/pause_menu.tscn` | Menu de pausa (`Esc`/Start) em `process_mode = ALWAYS` |
| `scenes/input_test.tscn` | Calibração de input (também executável sozinha) |
| `scenes/aria_terminal.tscn` | Terminal da ARIA (POC 3) |
| `scenes/epilogue.tscn` | Epílogo com escolha (POC 6) |

O laboratório procedural (POC 5) é construído em tempo de execução por `Lab404LabGenerator`
(ala além do corredor), não como cena.
