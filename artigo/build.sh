#!/usr/bin/env bash
# Compila o artigo: pdflatex -> bibtex -> pdflatex -> pdflatex.
#
# Ambiente verificado (2026-09-10): TeX Live 2023/Debian com pdflatex + bibtex
# (sem latexmk, sem biber/biblatex). Citações autor-ano via natbib + plainnat.
#
# Uso:  ./build.sh          # compila e mostra o resumo
#       ./build.sh clean    # remove os temporários (mantém o PDF)

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if [ "${1:-}" = "clean" ]; then
    rm -f main.aux main.bbl main.blg main.log main.out main.toc main.synctex.gz
    echo "Temporários removidos."
    exit 0
fi

if ! command -v pdflatex >/dev/null 2>&1; then
    echo "pdflatex não encontrado (TeX Live)." >&2
    exit 127
fi

echo "== pdflatex (1/3) =="
pdflatex -interaction=nonstopmode -halt-on-error main.tex >/dev/null
echo "== bibtex =="
bibtex main >/dev/null 2>&1 || echo "  (aviso: bibtex retornou erro — ver main.blg)"
echo "== pdflatex (2/3) =="
pdflatex -interaction=nonstopmode -halt-on-error main.tex >/dev/null
echo "== pdflatex (3/3) =="
pdflatex -interaction=nonstopmode -halt-on-error main.tex >/dev/null

echo
echo "--- resumo ---"
grep -c "Overfull \\\\hbox" main.log 2>/dev/null | sed 's/^/Overfull hbox: /' || true
grep -c "LaTeX Warning: Citation" main.log 2>/dev/null | sed 's/^/Citações indefinidas: /' || true
grep -c "LaTeX Warning: Reference" main.log 2>/dev/null | sed 's/^/Referências indefinidas: /' || true
if [ -f main.pdf ]; then
    cp -f main.pdf artigo-laboratorio-404.pdf
    pages=$(pdfinfo main.pdf 2>/dev/null | awk '/^Pages/{print $2}')
    echo "PDF: main.pdf (${pages:-?} páginas)"
    echo "Cópia de distribuição: artigo-laboratorio-404.pdf"
else
    echo "PDF não gerado — ver main.log" >&2
    exit 1
fi
