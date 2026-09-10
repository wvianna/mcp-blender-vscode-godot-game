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

## Detalhamento de elementos (decoração e telas)

Receitas usadas no refino dos props (`docs/Detalhamento-elementos.txt`):

1. **Decalque = caixa fina colada na face.** Zebra de perigo, triângulo de alerta, esquema de fiação e
   rótulos de slot são caixas de 1–2 cm de espessura, posicionadas 1–2 cm **à frente** da face do painel
   (nunca na mesma profundidade: a face opaca esconde o decalque).
2. **Texto de tela vai para o Godot** (`Label3D` no nó `Screens`), seguindo a regra dos letreiros:
   sobre tela emissiva o texto deve ser **escuro e sem contorno** (contorno claro só em texto sobre fundo escuro).
3. **LED que pisca não é animação de glTF.** O glTF anima apenas TRS (posição/rotação/escala), não emissão
   de material: os LEDs são nós separados no GLB e quem pisca é `scripts/status_leds.gd`.
4. **Peça solta precisa de apoio visível.** Tubulações horizontais ganham poste + braçadeira ancorando ao
   piso/base, e parafusos sextavados (`primitive_cylinder_add(vertices=6)`) evidenciam a fixação.
5. **Desgaste metálico** = anéis/placas com material próprio (`MAT_Desgaste`, marrom escuro, rugosidade alta)
   aplicados sobre tubos e conexões.
6. **Easter eggs** (ex.: pato de borracha) entram como objeto único unido (`bpy.ops.object.join()`),
   com o prefixo `DEC_`.
