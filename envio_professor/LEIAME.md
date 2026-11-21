# Salário médio real formal nos municípios da Região Metropolitana de Curitiba, 2012 a 2021

Trabalho de Econometria I. Regressão linear múltipla sobre um painel de 29 municípios em 10 anos (290 observações). Variável dependente: logaritmo do salário médio real formal (R$ de 2021). Variáveis explicativas: proporção de vínculos com ensino superior (X2), dominância industrial (X3), diversificação setorial pela entropia de Shannon (X4), Selic real (X5) e distância a Curitiba (X6).

## Conteúdo da pasta

| Pasta | Conteúdo |
|---|---|
| `R/` | Scripts numerados na ordem de execução. |
| `dados_brutos/` | Dados de entrada já coletados (PIB municipal, Selic e IPCA, RAIS agregada, malha municipal, distâncias). |
| `dados_processados/` | Painel final (`dados_painel_rmc.csv` e `.rds`), estatísticas descritivas e matriz de correlação. |
| `resultados_econometricos/` | Tabelas de regressão, testes, memorial de cálculo, simulação e calibração. |
| `figuras_graficos/` | Gráficos dos dados, dos resíduos e das estimativas. |
| `documentacao/` | Dados e variáveis, métodos, resultados, calibração, fragilidades, limitações, critérios da disciplina e registro de verificação. |

## Scripts

| Script | Função | Grava em |
|---|---|---|
| `00_executar_tudo.R` | Executa os scripts 02 a 08 em ordem, cada um em processo separado (`Rscript R/00_executar_tudo.R`). | todas as pastas de saída |
| `01_extracao_dados.R` | Coleta dos dados públicos (SIDRA, Banco Central, IBGE, RAIS). Opcional: os dados já acompanham a pasta, e a RAIS exige o download de cerca de 3,5 GB. | `dados_brutos/` |
| `02_tratamento_painel.R` | Constrói o painel e as variáveis do modelo. | `dados_processados/` |
| `03_aede_visualizacoes.R` | Gráficos exploratórios, mapas numerados e animações. | `figuras_graficos/` |
| `04_modelagem_diagnosticos.R` | Modelos 1, 2, 3 e 3b, diagnósticos do modelo clássico, erros-padrão robustos, simulação. | `resultados_econometricos/`, `figuras_graficos/` |
| `05_robustez_mundlak.R` | Modelo de Mundlak, teste de autocorrelação em painel, Modelos 3c e 4. | `resultados_econometricos/`, `figuras_graficos/` |
| `06_calibracao_modelo.R` | Testes de efeito de município, estimadores com efeito de município, bootstrap wild cluster, influência. | `resultados_econometricos/`, `figuras_graficos/` |
| `07_memorial_modelo_2.R` | Memorial de cálculo matricial do Modelo 2 com quatro casas decimais. | `resultados_econometricos/` |
| `08_fragilidades_modelo.R` | Forma funcional (efeitos fixos com quadráticos e RESET), sensibilidade da Selic real (bootstrap exato por ano), exogeneidade estrita e regressores defasados. | `resultados_econometricos/`, `figuras_graficos/` |

## Como reproduzir

1. Instalar o R e os pacotes listados em `documentacao/ambiente_r.csv` (versões usadas na geração dos resultados).
2. Definir esta pasta como diretório de trabalho.
3. Executar, nesta ordem: `R/02_tratamento_painel.R`, `R/04_modelagem_diagnosticos.R`, `R/05_robustez_mundlak.R`, `R/06_calibracao_modelo.R`, `R/07_memorial_modelo_2.R`, `R/08_fragilidades_modelo.R` e, para os gráficos, `R/03_aede_visualizacoes.R`.

   ```
   Rscript R/02_tratamento_painel.R
   ```

   Ou, de uma vez: `Rscript R/00_executar_tudo.R`.

Os scripts usam caminhos relativos e param com mensagem se o diretório de trabalho não for a raiz desta pasta. Os resultados aleatórios (bootstrap) usam semente fixa. Os textos "Etapa N" nas mensagens dos scripts referem-se ao script de mesmo número.

O script `03_aede_visualizacoes.R` carrega o pacote `gifski` para renderizar as duas animações (`.gif`); sem ele o script para antes de gerar as figuras. O `gifski` exige o compilador Rust (`cargo`) para ser instalado no Linux.

## Onde ler cada resultado

- Resumo dos resultados validados: `documentacao/00_resumo.md`.
- Dados, variáveis e fontes: `documentacao/01_dados_e_variaveis.md`.
- Equações, estimadores e testes: `documentacao/02_especificacao_e_metodos.md`.
- Modelos 1, 2, 3 e 3b, diagnósticos, simulação: `documentacao/03_resultados_modelos_classicos.md`.
- Calibração e comparação de estimadores: `documentacao/04_calibracao.md`.
- Forma funcional, Selic real e exogeneidade: `documentacao/05_fragilidades.md`.
- Limitações: `documentacao/06_limitacoes.md`.
- Cálculo matricial do Modelo 2 (X'X, inversa, variância e covariância, ANOVA, testes t e F, FIV, previsão): `resultados_econometricos/memorial_modelo_2.txt`.
- Verificações realizadas: `documentacao/08_verificacao.md`.
