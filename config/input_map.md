# Configuração de Input Map

Criar no Godot:

```text
move_forward
move_backward
move_left
move_right
look_left
look_right
look_up
look_down
interact
cancel
run
flashlight
inventory
pause
dialog_next
```

## Recomendação

Use ações semânticas no código:

```gdscript
var axis := Input.get_vector("move_left", "move_right",
                             "move_forward", "move_backward")
```

Nunca faça:

```gdscript
if Input.is_joy_button_pressed(0, 1):
```

O número do botão varia conforme o adaptador.

## Diagnóstico

A cena `scenes/input_test.tscn` (`scripts/input_diagnostic.gd`) mostra em tempo real:

```text
DISPOSITIVOS   #0  USB Gamepad
EIXOS          eixo 0: -0.73   eixo 1: +0.01 ...
BOTÕES         pressionados: [0, 9]
ZONA MORTA     0.15 (slider — aplica em todas as ações)
```

Ela também trata hotplug (`Input.joy_connection_changed`) sem travar a execução.

## Mapeamento implementado (POC 1)

| Ação | Teclado | Joystick (padrão — **A CONFIRMAR** no hardware) |
|---|---|---|
| `move_forward/backward/left/right` | WASD + setas | eixos 0/1 (analógico esquerdo) |
| `look_left/right/up/down` | — (mouse) | eixos 2/3 (analógico direito, se existir) |
| `interact` | E | botão 0 (X) |
| `cancel` | Q | botão 1 (O) |
| `run` | Shift | botão 5 (R1) |
| `flashlight` | F | botão 4 (L1) |
| `inventory` | Tab | botão 8 (Select) |
| `pause` | Esc | botão 9 (Start) |
| `dialog_next` | Enter/Espaço | botão 0 (X) |
| `save_game` | F5 | — |
| `load_game` | F9 | — |

Os índices de botão **só** aparecem em `project.godot` e na tela de diagnóstico — o gameplay
usa exclusivamente as ações (FR-001/NFR-005).
