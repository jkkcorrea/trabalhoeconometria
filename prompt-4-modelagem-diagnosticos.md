# PROMPT 4: MODELAGEM ECONOMÉTRICA, BATERIA DE DIAGNÓSTICOS DO MCRL E INFERÊNCIA ROBUSTA (UFPR)

# DIRETRIZES GERAIS E PAPEL
Você é um Cientista de Dados Sênior especializado em Econometria Teórica e Aplicada em R.
Estamos desenvolvendo a etapa crucial de modelagem econométrica e testes de hipótese para a disciplina de Econometria I da Universidade Federal do Paraná (UFPR).
Seu objetivo é gerar um script em R autônomo, modular, robusto, defensivo e auditável para:
1. Carregar o painel mestre de dados tratados (`./dados_processados/dados_painel_rmc.rds`).
2. Estimar as especificações econométricas (Modelo Base, Modelo Log-Linear Múltiplo Principal e Modelos Alternativos com Controles Espaciais/Temporais).
3. Executar a bateria completa e rigorosa de testes de diagnóstico das violações do Modelo Clássico de Regressão Linear (MCRL) cobrada pela UFPR (Multicolinearidade, Heterocedasticidade, Autocorrelação Serial, Normalidade e Erro de Especificação RESET).
4. Implementar correções econométricas de variância-covariância robusta (White e Newey-West/HAC) quando detectadas violações.
5. Estruturar tabelas comparativas de regressão (padrão publicação / `stargazer` ou `modelsummary`) e rotinas de simulação contrafactual.

NÃO gere redações acadêmicas, relatórios em texto corrido ou ensaios teóricos.
Seu foco é EXCLUSIVAMENTE em código R executável, sem placeholders, sem omissões e 100% pronto para o RStudio.

---

# 1. ESPECIFICAÇÃO DOS MODELOS A SEREM ESTIMADOS

A partir do dataframe `./dados_processados/dados_painel_rmc.rds`, estruture e estime as seguintes equações via `stats::lm()`:

### Modelo 1: Modelo Base Linear Simples (Benchmark)
Relação bivariada simples entre remuneração real e capital humano:
$$\text{salario\_real}_{it} = \beta_1 + \beta_2 (\text{escolaridade\_sup}_{it}) + u_{it}$$

### Modelo 2: Modelo Principal Log-Linear Múltiplo (Nossa Hipótese Teórica)
Transformação semi-logarítmica com a composição estrutural e controles espaciais e macroeconômicos:
$$\ln(\text{salario\_real}_{it}) = \beta_1 + \beta_2 (\text{escolaridade\_sup}_{it}) + \beta_3 (\text{dom\_industria}_{it}) + \beta_4 (\text{shannon\_div}_{it}) + \beta_5 (\text{selic\_real}_t) + \beta_6 (\text{dist\_curitiba}_i) + u_{it}$$

### Modelo 3: Modelo Expandido com Dummy do Polo Central (Curitiba) e Interação Espacial
Para isolar o efeito específico da capital e verificar se a proximidade industrial compensa o isolamento geográfico:
$$\ln(\text{salario\_real}_{it}) = \beta_1 + \beta_2 (\text{escolaridade\_sup}_{it}) + \beta_3 (\text{dom\_industria}_{it}) + \beta_4 (\text{shannon\_div}_{it}) + \beta_5 (\text{selic\_real}_t) + \beta_6 (\text{dist\_curitiba}_i) + \beta_7 (\text{dummy\_curitiba}_i) + u_{it}$$

---

# 2. BATERIA OBRIGATÓRIA DE DIAGNÓSTICOS DO MCRL (PADRÃO UFPR)

Para o Modelo Principal (Modelo 2), o script deve implementar formalmente todos os testes exigidos na disciplina, extraindo estatísticas de teste, graus de liberdade e p-valores em um dataframe consolidado de auditoria:

### A. Diagnóstico de Multicolinearidade
1. Cálculo da Tolerância ($TOL_j = 1 - R_j^2$) e do Fator de Inflação da Variância ($FIV_j = 1 / TOL_j$) via `car::vif(modelo_2)`.
2. Verificação automatizada da regra de bolso de Gujarati ($FIV > 10$ ou $TOL < 0.10$).
3. Mensagem no console indicando explicitamente se há ou não evidência de multicolinearidade severa entre os regressores.

### B. Diagnóstico de Heterocedasticidade
1. Teste de Breusch-Pagan-Godfrey ($H_0$: Homocedasticidade) via `lmtest::bptest(modelo_2, studentize = TRUE)`.
2. Teste de White com termos cruzados e quadráticos: `lmtest::bptest(modelo_2, ~ . + I(escolaridade_sup^2) + I(dom_industria^2) + I(shannon_div^2), data = dados)`.
3. Gráfico de dispersão diagnóstico: Resíduos Padronizados vs. Valores Ajustados ($\hat{Y}$), incluindo linha horizontal no zero e curva suave LOESS.

### C. Diagnóstico de Autocorrelação Serial dos Resíduos
1. Estatística $d$ de Durbin-Watson via `lmtest::dwtest(modelo_2, alternative = "two.sided")`.
2. Teste de Breusch-Godfrey de correlação serial de ordem superior via `lmtest::bgtest(modelo_2, order = 1)`.
3. Cálculo do coeficiente de autocorrelação residual aproximado: $\hat{\rho} \approx 1 - d/2$.
4. Gráfico da Função de Autocorrelação (ACF) dos resíduos com limites de significância a 95%.

### D. Diagnóstico de Normalidade dos Resíduos
1. Teste de Jarque-Bera assintótico ($H_0$: Resíduos normalmente distribuídos) via `tseries::jarque.bera.test(residuals(modelo_2))`.
2. Teste de Shapiro-Wilk: `stats::shapiro.test(residuals(modelo_2))`.
3. Gráfico de Densidade dos Resíduos contraposta à curva normal teórica e Gráfico Q-Q Normal com envelopes de confiança (`car::qqPlot()`).

### E. Diagnóstico de Especificação e Forma Funcional
1. Teste RESET de Ramsey ($H_0$: Modelo corretamente especificado quanto à forma funcional) via `lmtest::resettest(modelo_2, power = 2:3, type = "regressor")`.

---

# 3. TRATAMENTO DE VIOLAÇÕES E INFERÊNCIA ROBUSTA (NEWEY-WEST / WHITE)

Como dados de painel regional frequentemente apresentam heterocedasticidade espacial e autocorrelação temporal:
1. Obtenha a Matriz de Variância-Covariância Robusta à Heterocedasticidade de White ($HC_1$ ou $HC_3$) via `sandwich::vcovHC(modelo_2, type = "HC1")`.
2. Obtenha a Matriz de Variância-Covariância Robusta à Heterocedasticidade e Autocorrelação de Newey-West ($HAC$) via `sandwich::NeweyWest(modelo_2)`.
3. Recalcule os testes $t$ e p-valores de todos os coeficientes com erros padrão corrigidos:
   - `lmtest::coeftest(modelo_2, vcov = vcov_white)`
   - `lmtest::coeftest(modelo_2, vcov = vcov_newey_west)`
4. Teste $F$ Robusto de significância global via `car::linearHypothesis()` ou Wald test sob matriz HAC.

---

# 4. TABELAS DE PUBLICAÇÃO E SIMULAÇÃO CONTRAFACTUAL

### A. Tabela Comparativa de Modelos
Gere uma tabela unificada comparando:
- Modelo 1 (MQO Padrão)
- Modelo 2 (MQO Padrão)
- Modelo 2 (Erros Padrão Robustos de Newey-West)
- Modelo 3 (Com Dummy Curitiba e Erros Robustos)
A tabela deve conter: coeficientes estimados, erros padrão entre parênteses, estrelas de significância ($*** p < 0.01, ** p < 0.05, * p < 0.1$), $R^2$, $R^2$ Ajustado, Estatística $F$, Erro Padrão Residual ($s$) e número de observações ($N$).
Utilize `modelsummary::modelsummary()` ou `stargazer::stargazer()` e salve em HTML e texto formatado.

### B. Simulação de Previsão Contrafactual (Análise de Cenários)
Implemente uma função pura `simular_cenarios_renda(modelo, base_dados, delta_industria, delta_escolaridade)` que calcule:
1. **Cenário 1 (Choque de Industrialização):** O que ocorre com a remuneração média de municípios de baixa renda (ex: Fazenda Rio Grande ou Almirante Tamandaré) se a dominância industrial aumentar em $+10$ pontos percentuais?
2. **Cenário 2 (Choque de Capital Humano):** Qual o impacto previsto no salário médio municipal se a proporção de graduados no ensino superior aumentar em $+5$ pontos percentuais?
3. O script deve calcular o valor pontual previsto e o respectivo Intervalo de Confiança de 95% da previsão.

---

# 5. REQUISITOS TÉCNICOS E PERSISTÊNCIA DOS RESULTADOS
1. Dependências automatizadas: verificar, instalar e carregar `tidyverse`, `car`, `lmtest`, `sandwich`, `tseries`, `modelsummary`, `stargazer`, `broom`, `ggplot2`, `patchwork`.
2. Crie o diretório local `./resultados_econometricos/`.
3. Salve:
   - Objeto R com todos os modelos e testes: `saveRDS(lista_resultados, "./resultados_econometricos/modelos_e_testes.rds")`.
   - Tabela de resumo dos testes de diagnóstico em formato tabular `.csv`.
   - Gráficos diagnósticos de resíduos em alta resolução (`.png`, 300 dpi) no diretório `./figuras_graficos/`.
4. Sintaxe moderna em R, código 100% comentado e sem qualquer placeholder. O script deve rodar diretamente no RStudio.
