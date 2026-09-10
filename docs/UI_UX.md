# Interface e direção visual

## Conceito visual

Misturar:
- laboratório industrial;
- ficção científica de baixa escala;
- estética de equipamento dos anos 1990/2000;
- telas monocromáticas secundárias;
- iluminação de emergência;
- detalhes técnicos.

A interface principal deve parecer um **instrumento**, não um menu de jogo genérico.

## HUD

```text
┌────────────────────────────────────────────────┐
│  04:17:32        LAB 404       ███ POWER 62%  │
│                                                │
│                                                │
│                    +                           │
│                                                │
│                                                │
│                                                │
│  OBJETIVO                                      │
│  ▸ Restaurar comunicação                       │
│    □ Fusível F-17                              │
│    □ Módulo RS-404                             │
│    □ Reiniciar PLC                             │
│                                                │
│  [E] INTERAGIR                    [TAB] STATUS │
└────────────────────────────────────────────────┘
```

## Terminal ARIA

```text
╔══════════════════════════════════════════════╗
║ ARIA // AUTONOMOUS RESEARCH & INDUSTRIAL AI ║
╠══════════════════════════════════════════════╣
║ SISTEMA: ONLINE                              ║
║                                             ║
║ ARIA: Boa noite, técnico.                   ║
║      Você não deveria estar aqui.           ║
║                                             ║
║ VOCÊ: O que aconteceu?                      ║
║                                             ║
║ ARIA: Essa pergunta possui 17 respostas.    ║
║       Apenas 3 são seguras.                 ║
║                                             ║
║ > _                                         ║
╚══════════════════════════════════════════════╝
```

## Inventário diegético

Em vez de uma grade tradicional:

```text
┌─────────────────────────────┐
│ KIT TÉCNICO                 │
├─────────────────────────────┤
│ [F-17] Fusível              │
│ [RS4] Módulo RS-404         │
│ [KEY] Chave de manutenção   │
│                             │
│ PESO: 1.8 kg                │
└─────────────────────────────┘
```

## Cores

A implementação final pode usar uma paleta escura, mas os assets devem permanecer neutros para permitir ajustes de pós-processamento.
