# Controles

## Filosofia

O jogo deve ser confortável tanto para teclado quanto para joystick USB de PS1. O adaptador USB pode apresentar diferentes nomes e mapeamentos; portanto, **não codifique números de botões diretamente no gameplay**. Use o Input Map do Godot.

## Mapa recomendado

| Ação | Teclado | PS1 USB |
|---|---|---|
| mover | WASD / setas | analógico esquerdo |
| câmera | mouse | analógico direito |
| ação/interagir | E | X |
| cancelar | Q / Esc | O |
| correr | Shift | R1 |
| lanterna | F | L1 |
| inventário | Tab | Select |
| mapa | M | Select + direção, opcional |
| pausa | Esc | Start |
| diálogo avançar | Enter/Espaço | X |

## Analógicos

Faça uma tela de calibração no POC 1:

```text
┌───────────────────────────────┐
│       CALIBRAÇÃO DE INPUT     │
│                               │
│     ○ zona morta: 0.15       │
│                               │
│        ┌───────────┐          │
│        │     ●     │          │
│        └───────────┘          │
│                               │
│ Mova todos os eixos.          │
│ X: 0.02   Y: -0.91            │
│                               │
│ [X] Confirmar                 │
└───────────────────────────────┘
```

## Teste de compatibilidade

Alguns adaptadores USB de PS1 podem:
- apresentar D-pad como botões;
- apresentar D-pad como eixos;
- inverter eixo Y;
- não possuir analógico direito;
- enumerar botões em ordem diferente.

A tela `InputTest` deve mostrar em tempo real:
- nome do dispositivo;
- eixo;
- valor;
- botão pressionado.

Isso torna o POC útil também como laboratório de testes de HID.
