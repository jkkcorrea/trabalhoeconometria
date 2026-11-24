# Trabalho de Econometria I: envio

Modelo principal: MQO empilhado para 29 municípios da RMC, 2012 a 2021 (290 observações), com erros-padrão de White.

## Como reproduzir

1. Rode `Rscript R/00_executar_tudo.R` a partir desta pasta; ele executa os scripts 02 a 07 em ordem.
2. Os dados brutos estão em `dados_brutos/` (cache das APIs e da RAIS); os scripts não consultam a internet quando o cache existe.

## Conteúdo

- `R/`: scripts 02 a 07 (tratamento, figuras, modelo, autocorrelação, especificação e memorial).
- `resultados_econometricos/`: coeficientes, testes, memorial matricial, projeção e robustez.
- `figuras_graficos/`: figuras de diagnóstico e de análise exploratória.
- `documentacao/`: resumo, dados, especificação, resultados, diagnósticos, limitações, fontes e verificação.

A verificação independente está em `documentacao/08_verificacao.md`.
