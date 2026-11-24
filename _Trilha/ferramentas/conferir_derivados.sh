#!/usr/bin/env bash
# Confere os números dos textos derivados (artigo, slides e roteiros) contra as saídas do código.
# Uso (raiz do projeto):  bash _Trilha/ferramentas/conferir_derivados.sh
set -uo pipefail
[ -f CLAUDE.md ] || { echo "rode a partir da raiz do projeto"; exit 1; }
T="$(mktemp -d)"
python3 - "$T" <<'PY'
import re, sys, json, os, html
t = sys.argv[1]
d = json.load(open('apresentacao/deck_fonte/project/deck.json', encoding='utf-8'))
partes = []
for i in d['order']:
    s = open(f'apresentacao/deck_fonte/project/slides/{i}.html', encoding='utf-8').read()
    s = re.sub(r'<aside>.*?</aside>', ' ', s, flags=re.S)          # notas do orador ficam de fora
    s = re.sub(r'<(td|th)\b[^>]*>', ' | ', s)
    s = re.sub(r'<[^>]+>', '\n', s)
    partes.append(f'## {i}\n' + html.unescape(s))
open(os.path.join(t, 'slides.txt'), 'w', encoding='utf-8').write('\n'.join(partes))
PY
for arq in artigo/ARTIGO_rascunho_v2.md "$T/slides.txt" apresentacao/ROTEIRO_SLIDES.md apresentacao/CONTEXTO_PARA_O_TIME.md; do
  echo "=== $arq"
  Rscript --vanilla _Trilha/ferramentas/conferir_numeros.R "$arq" 2>&1 | grep -E "Números verificáveis|linha|Resultado" | cut -c1-120
done
