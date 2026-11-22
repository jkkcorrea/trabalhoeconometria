# Salário médio real formal nos municípios da Região Metropolitana de Curitiba, 2012 a 2021

Trabalho de Econometria I (UFPR). Painel de 29 municípios em 10 anos (290 observações). Variável dependente: logaritmo do salário médio real formal. Explicativas: X2 ensino superior, X3 dominância industrial, X4 concentração setorial (Gini), X5 Selic real e X6 distância a Curitiba.

## Como reproduzir

1. Instalar o R e os pacotes de `documentacao/ambiente_r.csv`.
2. Definir esta pasta como diretório de trabalho e rodar `Rscript R/00_executar_tudo.R`.

## Scripts

| Script | Função |
|---|---|
| 02_tratamento_painel.R | constrói o painel e as variáveis |
| 03_aede_visualizacoes.R | figuras e animações |
| 04_modelagem_diagnosticos.R | modelos, erro de White, VIF, Breusch-Pagan-Godfrey, Goldfeld-Quandt, ANOVA |
| 05_autocorrelacao_municipios.R | Durbin-Watson, ρ e Breusch-Godfrey por município |
| 06_especificacao_chow.R | RESET, LM de tendência e teste de Chow |
| 07_memorial_modelo_2.R | memorial matricial do Modelo 2 |

Onde ler: `documentacao/00_resumo.md`. Verificações: `documentacao/08_verificacao.md`.
