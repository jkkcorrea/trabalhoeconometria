#!/usr/bin/env bash
# Reconstrói envio_professor/ do zero: limpa comentários, copia os scripts, roda o pipeline
# de dentro da pasta, gera a documentação e roda a verificação. Uso (raiz do projeto):
#   bash _Trilha/ferramentas/reconstruir_envio.sh
set -euo pipefail
export PATH="$HOME/.cargo/bin:$PATH"
RAIZ="$(pwd)"; D="$RAIZ/envio_professor"; T="$(mktemp -d)"
[ -f "$RAIZ/CLAUDE.md" ] || { echo "rode a partir da raiz do projeto"; exit 1; }
Rscript --vanilla _Trilha/ferramentas/limpar_comentarios.R R "$T/limpo" "$T/relatorio.txt" | tail -1
rm -rf "$D/R"/* "$D/resultados_econometricos"/* "$D/figuras_graficos"/* "$D/dados_processados"/*
mkdir -p "$D"/{R,dados_brutos,dados_processados,resultados_econometricos,figuras_graficos,documentacao}
cp "$T"/limpo/0*.R "$D/R/"
for f in pib_sidra macro_bacen malha_rmc distancias rais; do cp "dados_brutos/$f.rds" "$D/dados_brutos/"; done
cd "$D"
for n in 02_tratamento_painel 03_aede_visualizacoes 04_modelagem_diagnosticos 05_robustez_mundlak 06_calibracao_modelo 07_memorial_modelo_2 08_fragilidades_modelo; do
  Rscript --vanilla "R/$n.R" > "$T/$n.log" 2>&1 && echo "ok   $n" || { echo "ERRO $n"; tail -5 "$T/$n.log"; exit 1; }
done
rm -f Rplots.pdf
cd "$RAIZ"
Rscript --vanilla _Trilha/ferramentas/gerar_documentacao.R 2>&1 | tail -1
Rscript --vanilla _Trilha/ferramentas/verificar_envio.R 2>&1 | grep -E "FALHOU|verificações aprovadas"
# Zip de envio, gerado só depois de a verificação passar (set -e + pipefail interrompem antes se ela falhar).
python3 - <<'PYZIP'
import os, zipfile
z = "envio_professor.zip"
if os.path.exists(z): os.remove(z)
with zipfile.ZipFile(z, "w", zipfile.ZIP_DEFLATED) as f:
    for raiz, _, arqs in os.walk("envio_professor"):
        for a in sorted(arqs): f.write(os.path.join(raiz, a))
print("zip regenerado:", z, round(os.path.getsize(z) / 1024 / 1024, 2), "MB")
PYZIP
