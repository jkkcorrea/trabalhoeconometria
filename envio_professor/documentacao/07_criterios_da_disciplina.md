# Critérios da disciplina e onde estão atendidos

| Critério | Onde |
|---|---|
| Resultados com quatro casas decimais | `documentacao/` e `memorial_modelo_2.txt` |
| Memorial de cálculo explícito (passo a passo matricial) | `resultados_econometricos/memorial_modelo_2.txt` |
| Hipóteses H0 e Ha explicitadas, decisão a 5% | `documentacao/02_especificacao_e_metodos.md` e `diagnosticos_modelo_2.csv` |
| Multicolinearidade: FIV, tolerância e relação com o determinante de X'X | `memorial_modelo_2.txt` (seção 10) e `fiv_modelos_2_3_3b.csv` |
| Heterocedasticidade: Breusch-Pagan, White, Goldfeld-Quandt | `diagnosticos_modelo_2.csv`, `calibracao_goldfeld_quandt.csv` e `memorial_modelo_2.txt` (seção 14, Breusch-Pagan passo a passo) |
| Autocorrelação: Durbin-Watson, rho, Breusch-Godfrey | `diagnosticos_modelo_2.csv`, `calibracao_autocorrelacao.csv`, `calibracao_testes_painel.csv` e `memorial_modelo_2.txt` (seção 15, Durbin-Watson passo a passo) |
| Medidas corretivas: erros robustos de White, Newey-West, Prais-Winsten | `coeficientes_cinco_matrizes.csv` e `calibracao_coeficientes.csv` |
| Quadro ANOVA, teste F global, testes t, intervalos de confiança | `memorial_modelo_2.txt` (seções 7 a 9) |
| Contribuição incremental (teste F) e coeficientes de determinação parcial | `memorial_modelo_2.txt` (seções 11 e 12) |
| Previsão pontual e intervalos (média e individual) | `memorial_modelo_2.txt` (seção 13) |
| Normalidade dos resíduos | `diagnosticos_modelo_2.csv` e `figuras_graficos/diag3` e `diag4` |
| Forma funcional | `diagnosticos_modelo_2.csv` (RESET), `calibracao_reset.csv`, `fragilidades_forma_funcional.csv` e `fragilidades_box_cox.csv` (forma de Y) |
| Painel, endogeneidade e sensibilidade da Selic | `calibracao_testes_painel.csv`, `fragilidades_exogeneidade_*.csv` e `fragilidades_selic_*.csv` |

