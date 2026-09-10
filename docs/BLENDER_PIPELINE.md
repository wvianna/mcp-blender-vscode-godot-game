# Pipeline Blender → Godot

## Convenções

- 1 unidade Blender = 1 metro.
- Aplicar transform antes de exportar.
- Origem do objeto deve ser útil para interação.
- Nomear objetos com prefixos.
- Evitar materiais excessivamente complexos.
- Preferir GLB/glTF.

## Prefixos

| Prefixo | Uso |
|---|---|
| `ENV_` | arquitetura |
| `PROP_` | objeto |
| `INT_` | objeto interativo |
| `COL_` | collider auxiliar |
| `FX_` | efeito |
| `NPC_` | personagem |
| `DEC_` | decoração |

## Template de sala

```text
          8 m
┌────────────────────────────┐
│ [VENT]       [LUZ]         │
│                            │
│   ┌──────┐    ┌────────┐   │
│   │TANQUE│    │  PLC   │   │
│   └──────┘    └────────┘   │
│                            │
│          ●                 │
│       jogador              │
│                            │
│ ┌──────────┐   ┌────────┐  │
│ │  PAINEL  │   │ PORTA  │  │
│ └──────────┘   └────────┘  │
└────────────────────────────┘
          6 m
```

## Template de corredor

```text
┌────────────────────────────────────┐
│ ▣    ▣       ▣       ▣       ▣    │
│                                    │
│  ═══════════════════════════════   │
│                 ●                  │
│  ═══════════════════════════════   │
│                                    │
│ ▣       ▣       ▣       ▣      ▣   │
└────────────────────────────────────┘
```

## Template de sala de controle

```text
┌───────────────────────────────────────┐
│       ███████████████████████         │
│       │      WALL SCREEN    │         │
│       ███████████████████████         │
│                                       │
│   ┌─────┐  ┌─────┐  ┌─────┐           │
│   │HMI  │  │HMI  │  │HMI  │           │
│   └─────┘  └─────┘  └─────┘           │
│                                       │
│             ● jogador                 │
│                                       │
│  [ARIA TERMINAL]             [DOOR]   │
└───────────────────────────────────────┘
```

## Kit modular

Modele primeiro:
- parede 2 m;
- parede 4 m;
- canto;
- porta;
- piso 2×2 m;
- teto;
- painel;
- luminária;
- tubulação;
- suporte;
- console.

Com isso, a maioria das salas do POC 5 pode ser montada por composição.

## Luzes e materiais emissivos

Regras aprendidas na reconstrução da sala (2026-09-10, referência `docs/images/laboratorio-exemplo.png`):

1. **Luminária visível = fonte de luz no Godot.** Modele o corpo da luminária e registre a posição; a
   `OmniLight3D` correspondente em `scenes/level_poc2.tscn` usa a mesma coordenada (atenção à troca de eixos
   Blender → Godot: `(x, y, z)_blender → (x, z, -y)_godot`).
2. **Emissão dosada.** Com `gl_compatibility` não há *bloom*: emissão acima de ~1,6 satura em branco puro e
   apaga a cor. Valores usados: luzes `MAT_Luz_*` 1,5–1,6; telas `MAT_Tela_*` 1,1–1,3.
3. **Perfis de cor por função:** branco = iluminação geral, ciano = ARIA/interfaces, âmbar = máquinas, 
   vermelho = emergência/travas. O Godot reforça esses perfis com as luzes do nó `Accents`.
4. **Letreiro é `Label3D` no Godot**, não texto no Blender (mantém tradução/ajuste baratos e evita 
   dependência de fonte no GLB).
5. **Não exporte câmeras nem luzes do Blender** no GLB (`export_cameras=False`, `export_lights=False`).

Exportação de referência:

```python
bpy.ops.export_scene.gltf(
    filepath="assets/lab404/lab_sala_poc2.glb", export_format='GLB',
    export_apply=True, export_yup=True, export_cameras=False, export_lights=False,
)
```

Depois de reexportar: `godot4 --headless --path . --import` e `tests/run_all.sh`.
