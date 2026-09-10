# MONOGRAFIA_STATUS.md — Estado da monografia

Atualizado em 2026-09-10. Documento de continuidade: descreve o estado atual,
o que está pronto, o que falta e como reproduzir a compilação.

## Identificação

- **Título:** Laboratório 404: desenvolvimento de um jogo sério 3D com
  inteligência artificial local para apoio ao ensino de automação industrial
- **Autoria:** William da Silva Vianna — Instituto Federal Fluminense,
  Campus Meu laboratório pessoal, Campos dos Goytacazes; orientação: o próprio
  autor (curso exato e banca pendentes — P-01)
- **Compilação:** `./build.sh` (pdflatex → bibtex → pdflatex → pdflatex)

## Estado da compilação (execução de referência)

| Item | Valor |
|---|---|
| PDF gerado | `monografia/monografia-laboratorio-404.pdf` (cópia de distribuição; `main.pdf` é o artefato de compilação) — **69 páginas** (47 páginas de conteúdo, capítulos 1–8) |
| Erros fatais | 0 |
| Citações indefinidas | 0 |
| Referências indefinidas | 0 |
| Overfull hbox | 0 |
| Overfull vbox | 46 ocorrências de 0,85 pt (inerentes ao espaçamento 1,5; benignas) |
| Figuras | 27 (18 capturas do jogo, 9 diagramas Mermaid, 2 geradas em TikZ/pgfplots — contagem inclui reúso) |
| Quadros | 13 |
| Tabelas | 4 |
| Equações | 2 |
| Referências | `.bib` com 28 entradas verificadas, todas citadas no texto |

## Estrutura entregue

- Pré-textuais: capa, folha de rosto, resumo, abstract, listas (figuras,
  tabelas, quadros, abreviaturas e siglas) e sumário;
- Capítulos 1–8: introdução, fundamentação, trabalhos relacionados, materiais
  e métodos, desenvolvimento, experimentos e resultados, discussão, conclusão;
- Apêndices A–D: requisitos completos, suíte de testes, repositório e tela de
  diagnóstico de entrada;
- Documentos de controle: `MONOGRAFIA_PLANO.md`, `MONOGRAFIA_EVIDENCIAS.md`,
  `MONOGRAFIA_RASTREABILIDADE.md`, `MONOGRAFIA_PENDENCIAS.md`.

## Verificação do PDF (inspeção visual realizada)

Inspecionados: capa e folha de rosto (marcadores institucionais visíveis),
sumário e listas, quadros com código (prefixos, exportação, contrato da IA,
intenções, salvamento, gerador, áudio), tabelas (ambiente, verificações,
latências, critérios de aceitação), figuras (arquitetura, missão, estados,
fluxo de conversa, memória, gerador, mapa de level design, capturas do jogo,
gráfico de verificações), página de resultados com medições e o Apêndice D
com a captura do diagnóstico de entrada. Numeração de páginas e legendas
conferidas; sem texto cortado nas margens.

## Situação de integridade

- Nenhum dado, resultado ou referência inventados.
- Lacunas marcadas no texto: `[REFERÊNCIA NECESSÁRIA]` (6 pontos),
  `[VALIDAR COM O AUTOR]`, `[MEDIÇÃO DE FRAME TIME NÃO REALIZADA]`,
  `[ESTUDO DE USUÁRIO NÃO REALIZADO]`, `[ESTUDO COMPARATIVO NÃO REALIZADO]`,
  `[MODELO-ALVO NÃO EXECUTADO]`.
- Pendências consolidadas e priorizadas em `MONOGRAFIA_PENDENCIAS.md`.

## Extensão

O documento tem **47 páginas de conteúdo**, abaixo da meta de 65–100 páginas
da skill. A expansão deve seguir o plano registrado em
`MONOGRAFIA_PLANO.md` (§ Plano de expansão), com conteúdo academicamente
necessário — nunca por repetição ou subseções artificiais.

## Próximos passos (ordem sugerida)

1. **P-01** — obter o modelo institucional e preencher capa, folha de rosto,
   folha de aprovação e ficha catalográfica;
2. **P-02** — validar as edições vigentes das normas citadas;
3. **P-03** — localizar as referências marcadas como necessárias;
4. executar o plano de expansão da extensão (itens 1–6 do plano);
5. **P-07/P-08** — repetir medições (5 por contexto) e executar o modelo-alvo
   `llama3.2:3b` quando instalado;
6. **P-05/P-06** — validações manuais de hardware e empacotamento do
   executável, atualizando os capítulos 6 e 7 com os novos resultados;
7. **P-10** — versionar `monografia/` e `docs/videos/` no Git.

## Como retomar (continuidade entre agentes)

1. Ler, nesta ordem: este arquivo, `MONOGRAFIA_PLANO.md`,
   `MONOGRAFIA_EVIDENCIAS.md`, `MONOGRAFIA_RASTREABILIDADE.md` e
   `MONOGRAFIA_PENDENCIAS.md`;
2. executar `./build.sh` e conferir o resumo (0 overfull, 0 indefinidas);
3. identificar a última pendência concluída e continuar a partir dela, sem
   reiniciar conteúdo aprovado.
