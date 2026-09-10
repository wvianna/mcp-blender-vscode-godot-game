# MONOGRAFIA_PENDENCIAS.md — Pendências da monografia

Atualizado em 2026-09-10. Cada pendência tem identificador, descrição, onde
aparece no documento e o que falta para resolver.

## P-01 — Modelo institucional (parcialmente resolvido em 2026-09-10)

**Fornecido pelo autor:** orientação ("o próprio autor"), campus
("Meu laboratório pessoal") e cidade ("Campos dos Goytacazes") — aplicados em
`pretextual.tex`.
**O que falta:** confirmação do curso exato; banca e natureza do trabalho
segundo o manual do IFF; folha de aprovação; ficha catalográfica; e, se
exigido, lista de símbolos.
**Onde:** `pretextual.tex` (marcador restante: curso).
**Impacto:** nenhuma exigência institucional específica foi afirmada no texto;
a formatação segue a ABNT em geral.

## P-02 — Edições vigentes de normas (crítico)

**O que falta:** conferir as edições vigentes de ABNT NBR 14724, NBR 10520 e
NBR 6023, e da IEC 61131-3, antes da versão final.
**Onde:** `references.bib`; texto dos capítulos 2 e 4.
**Observação:** as entradas no `.bib` trazem a nota "Validar edição vigente".

## P-03 — Referências marcadas como necessárias

**O que falta:** localizar e validar fontes acadêmicas para os pontos marcados
no texto com `[REFERÊNCIA NECESSÁRIA]`: (a) avaliação de jogos sérios em
contextos escolares; (b) revisão sistemática de jogos sérios para ensino de
CLP/automação; (c) emuladores de CLP para ensino; (d) laboratórios virtuais e
remotos na educação em engenharia; (e) fonte canônica de engenharia de
requisitos; (f) diretrizes de segurança de IA em sistemas interativos.
**Onde:** capítulos 2 e 3.

## P-04 — Estudo com usuários (escopo)

**O que falta:** estudo de usabilidade e/ou aprendizagem com participantes.
**Onde:** capítulos 1, 7 e 8 (marcado como fora do escopo / trabalho futuro).

## P-05 — Validação manual de hardware

**O que falta:** operar mouse com captura de cursor e joystick físico real;
calibrar e registrar; concluir o percurso humano de ponta a ponta (CA-013).
**Onde:** capítulos 4, 6 e 7 (status "Parcial (manual)").

## P-06 — Empacotamento (FR-033)

**O que falta:** instalar modelos de exportação do motor na mesma versão;
gerar o executável; testar em máquina limpa.
**Onde:** capítulos 6 e 7 ("Aberto").

## P-07 — Medições complementares

**O que falta:** repetições das latências (5 por contexto, com mediana e
dispersão) e métricas de tempo de quadro por percentil (1\% e 0,1\%).
**Onde:** capítulo 6 (marcado `[MEDIÇÃO DE FRAME TIME NÃO REALIZADA]`).

## P-08 — Modelo-alvo da IA

**O que falta:** instalar e executar `llama3.2:3b`; repetir as medições.
**Onde:** capítulos 4 e 6 (`[MODELO-ALVO NÃO EXECUTADO]`).

## P-09 — Extensão do documento

**Situação:** o documento tem 69 páginas totais e 47 páginas de conteúdo
(capítulos 1--8), abaixo da meta de 65--100 páginas de conteúdo da skill.
**O que falta:** executar o plano de expansão de `MONOGRAFIA_PLANO.md`
(aprofundar fundamentação, trabalhos relacionados, protocolo de medição e
resultados), sempre com conteúdo academicamente necessário.
**Regra:** não ampliar por repetição, subseção artificial ou texto genérico.

## P-10 — Versionamento

**O que falta:** versionar no Git os arquivos novos (`monografia/` e o vídeo
`docs/videos/`), para que os links do documento funcionem no GitHub.

## P-11 — Anexos

**Situação:** não há anexos (materiais de terceiros). Se a banca exigir, os
manuais/atas de validação em hardware podem virar anexos quando produzidos.
