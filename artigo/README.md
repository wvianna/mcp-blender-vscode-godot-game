# Artigo — Laboratório 404

Artigo científico/tecnológico sobre o projeto Laboratório 404 (Godot + Blender +
LLM local), produzido conforme a skill `artigo-cientifico-latex`
(integridade: nenhum dado, resultado ou referência inventados).

- **Título (escolhido):** *Laboratório 404: um jogo 3D educacional com uma IA
  local restrita ao mundo — arquitetura, processo incremental e validação
  automatizada*
- **Autor:** William da Silva Vianna — Instituto Federal Fluminense
- **Agradecimentos:** registrados conforme solicitado (o autor agradece a si mesmo).

## Alternativas de título consideradas

1. *Integração segura de um grande modelo de linguagem local em um jogo 3D
   educacional: o caso do Laboratório 404*
2. *Laboratório 404: arquitetura e validação de um jogo educacional com IA
   diegética de intenções restritas*
3. *Do POC ao vertical slice: um processo incremental e assistido por IA para um
   jogo 3D com LLM local*
4. *Laboratório 404: um jogo educacional em que a IA conversa, mas não controla*

## Estrutura

```text
artigo/
├── main.tex            # preâmbulo, título, resumo, palavras-chave
├── references.bib      # referências verificadas (ver seção abaixo)
├── build.sh            # pdflatex -> bibtex -> pdflatex -> pdflatex
├── sections/
│   ├── introduction.tex
│   ├── literature.tex
│   ├── methodology.tex
│   ├── results.tex
│   ├── discussion.tex
│   └── conclusion.tex
├── figures/
│   ├── sala-energizada.png        # captura do jogo (docs/images/poc2-sala-energizada.png)
│   └── aria-terminal.png          # captura do jogo (docs/images/poc3-aria-terminal-resposta.png)
└── main.pdf            # gerado pela compilação
```

O `build.sh` gera ainda a cópia de distribuição `artigo-laboratorio-404.pdf`.

## Compilação

```bash
./build.sh          # compila e mostra o resumo (overfull, citações, páginas)
./build.sh clean    # remove temporários (mantém o PDF)
```

Ambiente verificado em 2026-09-10: TeX Live 2023/Debian com `pdflatex` + `bibtex`
(sem `latexmk`, sem `biber`/`biblatex`). Citações autor--ano via `natbib`
(`round`) + `plainnat`. Última compilação: **12 páginas, 0 overfull hbox,
0 citações/referências indefinidas**.

## Dados usados (todos verificáveis no repositório)

| Número no artigo | Fonte |
|---|---|
| 211 verificações Godot + 16 Python (25--26 no POC 3) | `STATUS.md`, `docs/TESTES.md` |
| 342 nós, 37 materiais, 1.018,7 KB, 35 colisões `-col` | GLB medido (`assets/lab404/lab_sala_poc2.glb`) |
| 60 FPS (vsync) em iGPU a 1280x720 | `STATUS.md` / NFR-001 |
| Latências 22,0 s / 16,1 s / 12,9 s (`llama3.1:8b`) | `STATUS.md`, `docs/images/poc3-*` |
| ~2.400 linhas GDScript e ~1.300 de testes | contagem bruta (`wc -l`) em `scripts/` e `tests/` |
| Vídeo de demonstração (1 min 08 s, 1280x768 @30 fps) | `docs/videos/poc-laboratorio-404_1.mp4` |

## Pendências declaradas no texto (marcadores)

- `[A CONFIRMAR]` — e-mail de contato, campus/cidade e ORCID do autor
  (comentário no `main.tex`).
- `[REFERÊNCIA NECESSÁRIA]` — avaliação de jogos sérios em contextos escolares;
  latência comparada de LLMs locais em hardware sem GPU dedicada; fontes
  canônicas sobre desenvolvimento orientado a especificação.
- `[MEDIÇÃO DE FRAME TIME NÃO REALIZADA]` — percentis de tempo de quadro.
- `[ESTUDO COMPARATIVO NÃO REALIZADO]` / `[ESTUDO DE USUÁRIO NÃO REALIZADO]`.
- Empacotamento (FR-033) e playthrough humano (CA-013) seguem pendentes no
  projeto do jogo e assim são tratados no artigo.

## Referências — verificação (2026-09-10)

| Chave | Verificação |
|---|---|
| `abt1970serious` | clássico (Abt, *Serious Games*, Viking Press, 1970) |
| `gee2003what` | clássico (Gee, Palgrave Macmillan, 2003 — edição/ano conferidos) |
| `zyda2005from` | metadados conferidos (Computer 38(9), DOI 10.1109/MC.2005.297) |
| `laamarti2014overview` | metadados conferidos (IJCGT, DOI 10.1155/2014/358152) |
| `park2023generative` | página oficial do arXiv (arXiv:2304.03442) |
| `wang2023voyager` | página oficial do arXiv (arXiv:2305.16291) |
| `gallotta2024largelanguage` | página oficial do arXiv (arXiv:2402.18659; IEEE ToG, DOI 10.1109/TG.2024.3461510) |
| `godot2026`, `blender2026`, `ollama2026`, `fastapi2026`, `pydantic2026`, `uvicorn2026`, `khronos2026gltf` | documentação oficial dos projetos |
| `lab404repo`, `lab404video` | artefatos do próprio trabalho |

> O vídeo está referenciado pela URL do repositório; ele precisa ser
> versionado (`git add docs/videos/`) e enviado para o link funcionar.
