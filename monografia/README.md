# Monografia — Laboratório 404

Monografia de graduação em Engenharia (Instituto Federal Fluminense),
produzida com a skill `skill-monografia-engenharia-latex`.

- **Título:** Laboratório 404: desenvolvimento de um jogo sério 3D com
  inteligência artificial local para apoio ao ensino de automação industrial
- **Autor:** William da Silva Vianna
- **Formato:** ABNT aplicada manualmente sobre a classe `memoir`
  (margens 3/2 cm, espaçamento 1,5, citações numéricas `unsrt`)

## Compilação

```bash
./build.sh          # pdflatex -> bibtex -> pdflatex -> pdflatex
./build.sh clean    # remove temporários (mantém o PDF)
```

Ambiente verificado em 2026-09-10: TeX Live 2023/Debian com `pdflatex` +
`bibtex` (sem `latexmk`, sem `biber`/`biblatex`, sem `abnTeX2`).

## Estrutura

```text
monografia/
├── main.tex                  # preâmbulo, metadados e inclusões
├── pretextual.tex            # capa, folha de rosto, resumos, listas, sumário
├── chapters/                 # 8 capítulos (01..08)
├── appendices/               # A: requisitos, B: testes, C: repositório, D: diagnóstico
├── tables/                   # tabelas isoladas (ambiente, testes, latência, aceitação)
├── figures/                  # capturas do jogo + diagramas renderizados
├── diagrams/                 # fontes Mermaid (.mmd) dos diagramas
├── pptr.json                 # configuração do puppeteer (Chrome do sistema) p/ mmdc
├── references.bib            # referências (verificadas, ver README)
├── build.sh                  # compilação
├── main.pdf                  # PDF gerado pela compilação
└── monografia-laboratorio-404.pdf  # cópia de distribuição (gerada pelo build.sh)
```

## Diagramas (Mermaid -> PNG)

As fontes ficam em `diagrams/*.mmd` e são renderizadas para `figures/*.png`
com o `mermaid-cli` (`mmdc`), apontando para o Chrome do sistema:

```bash
for f in diagrams/*.mmd; do b=$(basename "$f" .mmd); \
  mmdc -p pptr.json -i "$f" -o "figures/$b.png" -w 1600 -b white; done
```

## Figuras (capturas do jogo)

As capturas vêm do diretório de evidências do projeto do jogo
(`docs/images/`) e foram geradas pelo arnês de captura (cena de teste com
posicionamento programático do jogador). Arquivos de origem:

| Arquivo em `figures/` | Origem |
|---|---|
| `sala_geral.png`, `sala_energizada.png` | `docs/images/poc2-sala-*.png` |
| `clp.png`, `painel.png`, `bomba.png`, `bancada.png`, `aria_estacao.png` | `docs/images/poc2-*.png` |
| `porta_fechada.png`, `porta_aberta.png` | `docs/images/poc2-porta-b1-*.png` |
| `detalhe_*.png` | `docs/images/poc2-detalhe-*.png` |
| `tecnico.png`, `tecnico_rosto.png` | `docs/images/poc2-tecnico*.png` |
| `terminal_aria.png`, `tela_aria.png` | `docs/images/poc3-aria-*.png` |
| `referencia_arte.png` | `docs/images/laboratorio-exemplo.png` |
| `input_test.png` | captura gerada para o Apêndice D (cena de captura, modo diagnóstico) |

## Arquivos de controle (continuidade entre agentes)

Leia, nesta ordem: `MONOGRAFIA_STATUS.md`, `MONOGRAFIA_PLANO.md`,
`MONOGRAFIA_EVIDENCIAS.md`, `MONOGRAFIA_RASTREABILIDADE.md` e
`MONOGRAFIA_PENDENCIAS.md`.

## Integridade

Nenhum dado, resultado ou referência foi inventado. Informações ausentes estão
marcadas no texto com `[REFERÊNCIA NECESSÁRIA]`, `[VALIDAR COM O AUTOR]`,
`[MEDIÇÃO DE FRAME TIME NÃO REALIZADA]`, `[ESTUDO DE USUÁRIO NÃO REALIZADO]`,
`[ESTUDO COMPARATIVO NÃO REALIZADO]` e `[MODELO-ALVO NÃO EXECUTADO]`.
As pendências estão consolidadas em `MONOGRAFIA_PENDENCIAS.md`.
