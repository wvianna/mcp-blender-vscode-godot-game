# MONOGRAFIA_PLANO.md — Plano da monografia

Atualizado em 2026-09-10. Este arquivo descreve o plano, a estrutura e o
estado de cada parte do documento.

## Objetivo do documento

Monografia de graduação em Engenharia (IFF) sobre o desenvolvimento e a
validação técnica do Laboratório 404: jogo sério 3D com IA local (LLM)
integrada por diálogo, sem controle do jogo.

## Pipeline executado

```text
AUDITORIA → COMPREENSÃO DO PROJETO → PROBLEMA → OBJETIVOS
→ MAPA DE EVIDÊNCIAS → ESTRUTURA → PLANO DOS CAPÍTULOS
→ FUNDAMENTAÇÃO → METODOLOGIA → DESENVOLVIMENTO
→ EXPERIMENTOS → RESULTADOS → DISCUSSÃO → CONCLUSÃO
→ REVISÃO → COMPILAÇÃO → VALIDAÇÃO
```

## Estrutura e estado

| Parte | Arquivo | Estado |
|---|---|---|
| Pré-textuais (capa, folha de rosto, resumo, abstract, listas, sumário) | `pretextual.tex` | Concluído (com marcadores de validação) |
| 1 Introdução | `chapters/01_introducao.tex` | Concluído |
| 2 Fundamentação teórica | `chapters/02_fundamentacao.tex` | Concluído (2 marcadores de referência) |
| 3 Trabalhos relacionados | `chapters/03_trabalhos_relacionados.tex` | Concluído (1 marcador) |
| 4 Materiais e métodos | `chapters/04_materiais_metodos.tex` | Concluído |
| 5 Desenvolvimento | `chapters/05_desenvolvimento.tex` | Concluído |
| 6 Experimentos e resultados | `chapters/06_experimentos_resultados.tex` | Concluído |
| 7 Discussão | `chapters/07_discussao.tex` | Concluído |
| 8 Conclusão | `chapters/08_conclusao.tex` | Concluído |
| Apêndice A — Requisitos | `appendices/apendice_a_requisitos.tex` | Concluído |
| Apêndice B — Testes | `appendices/apendice_b_testes.tex` | Concluído |
| Apêndice C — Repositório | `appendices/apendice_c_repositorio.tex` | Concluído |
| Apêndice D — Diagnóstico de entrada | `appendices/apendice_d_diagnostico.tex` | Concluído |

## Plano de expansão (em aberto)

A meta da skill é de 65--100 páginas de conteúdo; o documento está abaixo
disso (ver `MONOGRAFIA_STATUS.md`). Expansões previstas, por ordem de valor —
todas com conteúdo academicamente necessário, nunca com repetição:

1. **Fundamentação (cap. 2):** aprofundar avaliação de jogos sérios
   (instrumentos e métricas) e fundamentos de segurança de IA em sistemas
   interativos; incluir figuras didáticas (pipeline de um LLM,
   orçamento de quadro).
2. **Trabalhos relacionados (cap. 3):** incorporar revisão sistemática de
   jogos sérios para ensino de CLP/automação (depende de referências a
   validar) e expandir a comparação com métricas comuns.
3. **Métodos (cap. 4):** detalhar o protocolo de medição (formulário,
   repetições, critérios de descarte) e o plano de análise.
4. **Desenvolvimento (cap. 5):** aprofundar algoritmos (gerador procedural
   com parâmetros; máquina de estados com tabela de transições) e o
   subsistema de interface (fluxos de tela).
5. **Resultados (cap. 6):** adicionar repetições das medições de latência
   (5 por contexto) e métricas de tempo de quadro por percentil.
6. **Discussão (cap. 7):** seção sobre implicações educacionais com
   fundamentação específica (depende de referências a validar).

## Regras de produção

- Nunca inventar dados, resultados ou referências; usar marcadores explícitos.
- Distinguir planejado de executado (implementado no capítulo 4).
- Toda afirmação técnica com evidência (matriz em `MONOGRAFIA_EVIDENCIAS.md`).
- Manter rastreabilidade em `MONOGRAFIA_RASTREABILIDADE.md`.
