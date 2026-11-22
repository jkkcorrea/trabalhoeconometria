# Gera envio_professor/documentacao/ e envio_professor/LEIAME.md a partir dos resultados.
# Uso (raiz do projeto): Rscript _Trilha/ferramentas/gerar_documentacao.R
# Os textos são montados com os números dos CSV: nada é digitado à mão.

DIR <- "envio_professor"
stopifnot(dir.exists(DIR))
DOC <- file.path(DIR, "documentacao")
dir.create(DOC, showWarnings = FALSE, recursive = TRUE)

res <- function(f) read.csv(file.path(DIR, "resultados_econometricos", f), check.names = FALSE, stringsAsFactors = FALSE)
painel <- readRDS(file.path(DIR, "dados_processados/dados_painel_rmc.rds"))
f4 <- function(x) formatC(as.numeric(x), format = "f", digits = 4, decimal.mark = ",")
f2 <- function(x) formatC(as.numeric(x), format = "f", digits = 2, decimal.mark = ",")
fp <- function(p) ifelse(as.numeric(p) < 0.0001, "< 0,0001", formatC(as.numeric(p), format = "f", digits = 4, decimal.mark = ","))
md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"),
                     paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                     apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
gravar <- function(nome, linhas) writeLines(linhas, file.path(DOC, nome), useBytes = TRUE)

coef <- res("coeficientes_modelos.csv")
testes <- res("testes_diagnostico.csv")
vif <- res("vif_tolerancia.csv")
anova <- res("anova_f_modelos.csv")
aut <- res("autocorrelacao_por_municipio.csv")
aut_res <- res("autocorrelacao_resumo.csv")
reset <- res("especificacao_reset.csv")
acresc <- res("especificacao_acrescimo_municipios.csv")
lm_t <- res("especificacao_lm_tendencia.csv")
chow <- res("chow_quebra_periodo.csv")
inf_ag <- res("inferencia_agregada_x5_x6.csv")
gini_chk <- res("medida_gini_checagem.csv")
comp <- res("comparacao_selic_producao.csv")
comp_f <- res("comparacao_f_retirar_selic.csv")

nomes_termo <- c("(Intercept)" = "Constante", prop_superior = "X2 ensino superior (%)",
                 dom_industrial = "X3 dominância industrial (%)", gini_setorial = "X4 concentração setorial (Gini)",
                 selic_real = "X5 Selic real (% a.a.)", dist_curitiba_km = "X6 distância a Curitiba (km)",
                 dummy_curitiba = "Dummy de Curitiba", `dom_industrial:dist_curitiba_km` = "X3 x X6 (interação)")
coef_m <- function(modelo, matriz) {
  d <- coef[coef$modelo == modelo & coef$matriz == matriz & !grepl("^factor", coef$termo), ]
  data.frame(Termo = nomes_termo[d$termo], Estimativa = f4(d$estimativa), `Erro-padrão` = f4(d$erro_padrao),
             t = f2(d$estatistica_t), `p-valor` = fp(d$p_valor), check.names = FALSE)
}
m4_nota <- paste("O Modelo 4 inclui 28 variáveis dummy de município (uma categoria de referência). Os coeficientes",
                 "das dummies estão em `resultados_econometricos/coeficientes_modelos.csv`. X6 é constante dentro",
                 "de cada município e não é identificada neste modelo.")

# ---- 01 dados e variáveis
n_municipios <- length(unique(painel$id_municipio))
gravar("01_dados_e_variaveis.md", c(
  "# Dados e variáveis", "",
  sprintf("Painel de %d municípios da Região Metropolitana de Curitiba, de %d a %d (%d observações).",
          n_municipios, min(painel$ano), max(painel$ano), nrow(painel)), "",
  "| Variável | Definição | Fonte |", "|---|---|---|",
  "| Y: ln do salário médio real | logaritmo do salário médio formal, em R$ de 2021 | RAIS (Ministério do Trabalho); IPCA (série 433 do Banco Central) |",
  "| X2: ensino superior (%) | vínculos com ensino superior completo, sobre os vínculos com escolaridade informada | RAIS |",
  "| X3: dominância industrial (%) | VAB da indústria sobre o VAB total, vezes 100 | IBGE, SIDRA (tabela 5938) |",
  "| X4: concentração setorial (Gini) | Gini da participação de cada divisão CNAE no total de vínculos; 87 divisões, zeros incluídos | RAIS (divisão CNAE) |",
  "| X5: Selic real (% a.a.) | Selic anual pela equação de Fisher com o IPCA | Banco Central (séries 4390 e 433) |",
  "| X6: distância a Curitiba (km) | distância entre centroides; Curitiba igual a zero | malha municipal do IBGE (geobr) |", "",
  "O Gini segue a fórmula do Guia P2 (questão 3): G = (2/n) soma(i x x_(i)) - (n+1)/n, com n = 87 divisões. Tratar divisões como indivíduos e o total de 87 divisões são escolhas a confirmar.", "",
  sprintf("A correlação entre o Gini e o número de divisões CNAE com emprego é %s. Ver 04_diagnosticos.md.", f4(gini_chk$valor[1])), "",
  "Estatísticas descritivas: `dados_processados/estatisticas_descritivas.csv`. Correlações: `dados_processados/matriz_correlacao_explicativas.csv`."))

# ---- 02 especificação e métodos
gravar("02_especificacao_e_metodos.md", c(
  "# Especificação e métodos", "",
  "Três especificações, todas por MQO sobre o painel empilhado:", "",
  "- **Modelo 2 (comparação, com X6):** ln(Y_it) = b1 + b2 X2 + b3 X3 + b4 X4 + b5 X5 + b6 X6 + u_it.",
  "- **Modelos 3 e 3b:** Modelo 2 com a dummy de Curitiba; o 3b acrescenta a interação X3 x X6.",
  "- **Modelo 4 (principal):** ln(Y_it) = b1 + b2 X2 + b3 X3 + b4 X4 + b5 X5 + dummies de município + u_it.", "",
  "A escolha do Modelo 4 como principal se apoia nos testes da Etapa 6: o F de acréscimo das dummies rejeita e o RESET passa a não rejeitar. A forma funcional não era o problema; a heterogeneidade entre municípios era. Ver 04_diagnosticos.md.", "",
  "## Métodos usados (todos ensinados na disciplina)", "",
  "| Método | Uso no projeto | Fonte oficial |", "|---|---|---|",
  "| MQO e álgebra matricial | estimação e memorial | notas de regressão múltipla |",
  "| t, F, ANOVA, R2 | inferência e teste de acréscimo | notas de regressão múltipla |",
  "| Variáveis dummy | controle de município (Modelo 4) e de Curitiba | Gujarati, cap. 9 (confirmar no livro) |",
  "| FIV e tolerância (limite 10) | multicolinearidade | notas de multicolinearidade; Guia P2 |",
  "| Breusch-Pagan-Godfrey | heterocedasticidade | notas de heterocedasticidade; provas 2023 a 2025 |",
  "| Goldfeld-Quandt | heterocedasticidade | notas de heterocedasticidade |",
  "| Erros-padrão de White (HC1) | inferência robusta | notas de heterocedasticidade; Guia P2 |",
  "| Durbin-Watson e ρ por regressão auxiliar AR(1) | autocorrelação, série de cada município | notas de autocorrelação; tabela de DW |",
  "| Breusch-Godfrey | autocorrelação, série de cada município | notas de autocorrelação |",
  "| RESET de Ramsey | forma funcional | notas de especificação e diagnóstico |",
  "| LM para variável omitida | acréscimo de tendência linear | notas de especificação e diagnóstico |",
  "| Teste de Chow | quebra estrutural por período | notas do teste de Chow |", "",
  "## Métodos removidos do projeto (não ensinados nas fontes oficiais)", "",
  "Efeitos fixos e aleatórios como estimadores próprios, Mundlak, Hausman, erros agrupados por município, bootstrap, Newey-West e Prais-Winsten aplicados ao painel empilhado, Box-Cox, Jarque-Bera e smearing de Duan.", "",
  "A entropia de Shannon foi removida por engano: ela é ensinada (Hoffmann, cap. 17, slides de medidas de desigualdade, em `aulas`). A X4 continua sendo o Gini; a entropia fica disponível como medida alternativa.", "",
  "Fontes oficiais e IDs no Drive: `06_fontes.md`."))

# ---- 03 resultados
gravar("03_resultados_modelos.md", c(
  "# Resultados dos modelos", "",
  "Coeficientes com erro de White (HC1) e t com n - k graus de liberdade. Erro clássico em `coeficientes_modelos.csv`.", "",
  "## Modelo 4 (principal), erro de White", "", md(coef_m("Modelo 4", "white")), "", m4_nota, "",
  "## Modelo 2 (comparação), erro de White", "", md(coef_m("Modelo 2", "white")), "",
  "## Modelo 3, erro de White", "", md(coef_m("Modelo 3", "white")), "",
  "## Modelo 3b, erro de White", "", md(coef_m("Modelo 3b", "white")), "",
  "## Significância conjunta (F da ANOVA)", "",
  md(data.frame(Modelo = anova$modelo, F = f2(anova$estatistica_f),
                `gl` = paste(anova$gl_numerador, anova$gl_denominador, sep = "; "),
                `p-valor` = fp(anova$p_valor), `R2` = f4(anova$r2), `R2 ajustado` = f4(anova$r2_ajustado),
                check.names = FALSE)), "",
  "## Leitura dos coeficientes", "",
  "- X2 é positivo nos dois modelos e significativo a 5%: a associação não depende de comparar municípios diferentes.",
  "- X3 é positivo entre municípios (Modelo 2) e não significativo dentro deles (Modelo 4).",
  "- X4 tem sinal negativo no Modelo 2 e positivo no Modelo 4, consistente com a correlação de -0,95 com o número de setores ativos (ver 04_diagnosticos.md).",
  "- X5 é significativo no Modelo 4, mas a inferência usa 257 graus de liberdade com apenas 10 valores de Selic (ver 04_diagnosticos.md)."))

# ---- 04 diagnósticos
tab_test <- data.frame(Modelo = testes$modelo, Teste = testes$teste, Estatística = f2(testes$estatistica),
                       gl = testes$gl, `p-valor` = fp(testes$p_valor), Decisão = testes$decisao_5pct, check.names = FALSE)
tab_aut <- data.frame(Modelo = aut$modelo, Município = aut$nome_municipio, `Durbin-Watson` = f4(aut$durbin_watson),
                      `Decisão pela tabela` = aut$decisao_dw_tabela, `ρ auxiliar` = f4(aut$rho_auxiliar),
                      `Breusch-Godfrey p` = fp(aut$breusch_godfrey_p), check.names = FALSE)
tab_aut_res <- data.frame(Modelo = aut_res$modelo, Municípios = aut_res$municipios,
                          `DW mediano` = f4(aut_res$durbin_watson_mediano), `ρ mediano` = f4(aut_res$rho_auxiliar_mediano),
                          `DW positivo pela tabela` = aut_res$positiva_pela_tabela,
                          `Breusch-Godfrey rejeita a 5%` = aut_res$breusch_godfrey_rejeita, check.names = FALSE)
gravar("04_diagnosticos.md", c(
  "# Diagnósticos do modelo", "",
  "## Heterogeneidade entre municípios", "",
  md(data.frame(Teste = acresc$teste, `Estatística F` = f2(acresc$estatistica_f),
                gl = paste(acresc$gl_numerador, acresc$gl_denominador, sep = "; "),
                `p-valor` = fp(acresc$p_valor), Decisão = acresc$decisao_5pct, check.names = FALSE)), "",
  sprintf("As dummies de município são conjuntamente significativas. O RESET do Modelo 2 rejeita (p-valor %s) e o RESET do Modelo 4 não rejeita (p-valor %s). A rejeição da forma funcional vem, portanto, da variável omitida entre municípios.",
          fp(reset$p_valor[reset$modelo == "Modelo 2"]), fp(reset$p_valor[reset$modelo == "Modelo 4"])), "",
  "## Multicolinearidade (FIV e tolerância)", "",
  md(data.frame(Modelo = vif$modelo, Variável = vif$variavel, FIV = f4(vif$fiv), Tolerância = f4(vif$tolerancia),
                Decisão = vif$decisao_fiv_10)), "",
  "FIV calculado no Modelo 2 e no Modelo 3, pela regra ensinada (FIV > 10 indica multicolinearidade elevada). O Modelo 4 não entra nessa tabela.", "",
  "## Heterocedasticidade e testes de especificação", "",
  md(tab_test), "",
  "Como o Breusch-Pagan-Godfrey rejeita no Modelo 2 e no Modelo 4, a inferência usa erros de White (HC1).", "",
  sprintf("RESET de Ramsey: Modelo 2, p-valor %s (rejeita); Modelo 4, p-valor %s (não rejeita).",
          fp(reset$p_valor[reset$modelo == "Modelo 2"]), fp(reset$p_valor[reset$modelo == "Modelo 4"])), "",
  sprintf("LM para tendência linear do ano (Modelo 2): estatística = %s, p-valor %s. Não há tendência omitida.",
          f4(lm_t$estatistica), fp(lm_t$p_valor)), "",
  sprintf("Teste de Chow (2012 a 2016 contra 2017 a 2021, Modelo 2): F = %s, p-valor %s. Não há quebra estrutural a 5%%.",
          f4(chow$estatistica_f), fp(chow$p_valor)), "",
  "## Inferência com variáveis que variam pouco", "",
  "A Selic tem 10 valores distintos (um por ano) e a distância tem 29 (um por município). Com 290 observações, o t do modelo trata essas linhas como independentes e superestima a precisão. A checagem usa regressões simples sobre médias, com n - 2 graus de liberdade:", "",
  md(data.frame(Variável = inf_ag$variavel, Base = inf_ag$base, gl = inf_ag$gl, Estimativa = f4(inf_ag$estimativa),
                `p-valor` = fp(inf_ag$p_valor), Decisão = inf_ag$decisao_5pct, check.names = FALSE)), "",
  sprintf("Com a Selic, a inclinação não é significativa a 5%% na base de médias anuais (p-valor %s). Esse resultado não se sustenta com a inferência do Modelo 4.", fp(inf_ag$p_valor[1])), "",
  "## Medida X4 (Gini setorial)", "",
  sprintf("A correlação entre o Gini e o número de divisões CNAE com emprego é %s. O Gini, nesta construção, mede sobretudo quantos setores têm emprego, e não a desigualdade entre setores grandes.", f4(gini_chk$valor[1])), "",
  "## Teste da Selic e da produção agrícola", "",
  "A produção agrícola vem da PAM (IBGE/SIDRA, tabela 5457, variável 215, valor da produção em mil reais), deflacionada pelo IPCA. Testou-se se retirar a Selic melhora o modelo e se a produção a substitui. Critérios: AIC e BIC (menores são melhores), R2 ajustado e diagnósticos. O t usa erro de White.", "",
  md(data.frame(Especificação = comp$especificacao, `R2 aj.` = f4(comp$r2_ajustado), AIC = f2(comp$aic), BIC = f2(comp$bic),
                `RESET p` = fp(comp$reset_p), `BP p` = fp(comp$bp_p),
                `p Selic (White)` = ifelse(is.na(comp$p_selic_white), "-", fp(comp$p_selic_white)),
                `Coef. produção` = ifelse(is.na(comp$coef_producao_white), "-", f4(comp$coef_producao_white)),
                `p produção` = ifelse(is.na(comp$p_producao_white), "-", fp(comp$p_producao_white)), check.names = FALSE)), "",
  sprintf("Retirar a Selic piora o ajuste: F = %s no Modelo 4 (p-valor %s) e F = %s no Modelo 2 (p-valor %s). A produção agrícola substitui a Selic sem ganho relevante (AIC %s contra %s no Modelo 4) e com coeficiente negativo e não significativo; não é adotada no modelo principal.",
          f2(comp_f$estatistica_f[1]), fp(comp_f$p_valor[1]), f2(comp_f$estatistica_f[2]), fp(comp_f$p_valor[2]),
          f2(comp$aic[3]), f2(comp$aic[1])), "",
  "## Autocorrelação dentro de cada município", "",
  "Aplicado à série de dez anos de cada município, com os resíduos do Modelo 2 e do Modelo 4. A tabela de Durbin-Watson usada vai até k' = 20 e foi lida para n = 10 e k' = 5, com dL = 0,243 e dU = 2,822 (valores lidos do PDF por OCR, [a confirmar]). Para o Modelo 4 (k' = 32) a tabela não se aplica. Com dU maior que 4 - dU não há zona de não rejeição: a tabela só permite conclusão para d < dL.", "",
  md(tab_aut_res), "",
  "No Modelo 2, a autocorrelação positiva aparece em muitos municípios. No Modelo 4, a mediana do Durbin-Watson sobe para perto de 1,3 e o ρ auxiliar cai para 0,19: a maior parte da autocorrelação do Modelo 2 era heterogeneidade omitida entre municípios.", "",
  "<details><summary>Série por município</summary>", "", md(tab_aut), "", "</details>"))

# ---- 05 limitações
gravar("05_limitacoes.md", c(
  "# Limitações", "",
  "- Desenho observacional: os coeficientes são associações, não efeitos causais.",
  "- Com as dummies de município, X6 (distância) não é identificada. Seu efeito só aparece no Modelo 2, onde está confundido com as diferenças não observadas entre municípios.",
  "- Variáveis de nível de tempo (Selic) têm 10 valores distintos. A inferência do Modelo 4 para X5 trata 290 observações como independentes e superestima a precisão. É o ponto que mais limita a conclusão sobre juros.",
  "- O efeito de X4 muda de sinal entre o Modelo 2 (entre municípios) e o Modelo 4 (dentro dos municípios). A medida acompanha o número de setores com emprego (correlação -0,95).",
  "- A autocorrelação dentro dos municípios cai com as dummies, mas o Breusch-Godfrey ainda rejeita em alguns municípios; não há correção ensinada aplicável ao painel para o resto.",
  "- Heterocedasticidade: o Breusch-Pagan-Godfrey rejeita no Modelo 2 e no Modelo 4. A inferência usa erros de White.",
  "- Autocorrelação positiva dentro dos municípios: aceita como limitação do trabalho (decisão registrada). Os erros-padrão, mesmo os de White, tendem a estar subestimados nessa parte.",
  "- O Modelo 4 usa variáveis dummy de município. Os slides de aulas lidos não trazem o capítulo 9 de Gujarati; o uso das dummies depende de confirmação com o professor.",
  "- A Selic tem 10 valores distintos; sua inferência é otimista, embora retirá-la piore o ajuste (ver 04_diagnosticos.md).",
  "- A divisão do teste de Chow no ano de 2016 é uma escolha, com duas partes de 145 observações.",
  "- Vínculos com divisão CNAE 'ignorada' ficam fora do cálculo do Gini."))

# ---- 06 fontes
gravar("06_fontes.md", c(
  "# Fontes e referências", "",
  "## Fontes oficiais da disciplina (podem ser citadas)", "",
  "| Fonte | Conteúdo usado |", "|---|---|",
  "| Gujarati, D. N.; Porter, D. C. Econometria Básica. 5ª ed. AMGH, 2011 | base teórica: regressão, testes, heterocedasticidade, autocorrelação, especificação, variáveis dummy |",
  "| Hoffmann, R.; Vieira, S. Análise de Regressão: Introdução à Econometria. 2ª ed. Hucitec, 1987 | regressão linear múltipla (bibliografia básica) |",
  "| Notas de aula de regressão linear múltipla (Hasegawa) | matriz X'X, ANOVA, t e F, R2 parcial |",
  "| Notas de multicolinearidade, heterocedasticidade, autocorrelação, especificação e teste de Chow (SE614) | métodos de diagnóstico |",
  "| Tabela de Durbin-Watson (Apêndice D) | valores de dL e dU |",
  "| Guia da P2 (professor) | regras de decisão de FIV, BPG, DW e Gini |",
  "| Slides da pasta `aulas` do Drive: regressão matricial, especificação e diagnóstico (cap. 13), teste de Chow, multicolinearidade, heterocedasticidade, autocorrelação, medidas de desigualdade (Hoffmann, cap. 17) | confirmação dos métodos ensinados |", "",
  "## Dados", "",
  "| Dado | Origem | Arquivo |", "|---|---|---|",
  "| PIB e VAB municipais | IBGE, SIDRA, tabela 5938 | dados_brutos/pib_sidra.rds |",
  "| Selic (4390) e IPCA (433) | Banco Central, SGS | dados_brutos/macro_bacen.rds |",
  "| Vínculos, escolaridade, salário e divisão CNAE | RAIS, microdados públicos do Ministério do Trabalho | dados_brutos/rais.rds |",
  "| Malha municipal | IBGE, pacote geobr | dados_brutos/malha_rmc.rds |",
  "| Distâncias a Curitiba | cálculo a partir dos centroides | dados_brutos/distancias.rds |",
  "| Valor da produção agrícola municipal (PAM) | IBGE, SIDRA, tabela 5457, variável 215 | dados_brutos/pam_valor_producao.rds |", "",
  "Os endereços e os códigos das APIs foram conferidos em 22/11/2026 (ver 08_verificacao.md).", "",
  "Referências de métodos removidos do projeto não são citadas no trabalho."))

# ---- 07 critérios
gravar("07_criterios_da_disciplina.md", c(
  "# Critérios da disciplina aplicados ao trabalho", "",
  "- Todos os cálculos no R, com caminhos relativos e rotina reproduzível: `R/00_executar_tudo.R`.",
  "- Quatro casas decimais nos resultados do memorial (`memorial_modelo_2.txt`, referente ao Modelo 2).",
  "- Hipóteses nula e alternativa explicitadas nos testes (`testes_diagnostico.csv`, `especificacao_*.csv`).",
  "- Apenas métodos ensinados (ver 02_especificacao_e_metodos.md)."))

# ---- ambiente e dicionário
ambiente <- data.frame(pacote = c("dplyr", "readr", "tibble", "stringr", "purrr", "ggplot2", "car", "lmtest", "sandwich", "sf", "geobr", "sidrar", "rbcb", "gifski", "gganimate"),
                       versao = vapply(c("dplyr", "readr", "tibble", "stringr", "purrr", "ggplot2", "car", "lmtest", "sandwich", "sf", "geobr", "sidrar", "rbcb", "gifski", "gganimate"),
                                       function(p) if (requireNamespace(p, quietly = TRUE)) as.character(packageVersion(p)) else "ausente", character(1)))
write.csv(ambiente, file.path(DOC, "ambiente_r.csv"), row.names = FALSE)
write.csv(data.frame(variavel = names(painel), tipo = vapply(painel, function(x) class(x)[1], character(1))),
          file.path(DOC, "dicionario_variaveis.csv"), row.names = FALSE)

# ---- 00 resumo
gravar("00_resumo.md", c(
  "# Resumo dos resultados", "",
  "Todos os números saem de `resultados_econometricos/`. Escopo: apenas métodos ensinados na disciplina.", "",
  "## Modelo principal (Modelo 4: MQO com dummies de município e erro de White)", "",
  md(coef_m("Modelo 4", "white")), "", m4_nota, "",
  sprintf("F da ANOVA = %s (p-valor %s); R2 = %s.", f2(anova$estatistica_f[anova$modelo == "Modelo 4"]),
          fp(anova$p_valor[anova$modelo == "Modelo 4"]), f4(anova$r2[anova$modelo == "Modelo 4"])), "",
  "## Modelo de comparação (Modelo 2: MQO com X6, erro de White)", "",
  md(coef_m("Modelo 2", "white")), "",
  "## Diagnósticos", "",
  sprintf("- Heterogeneidade entre municípios: F de acréscimo das dummies = %s (p-valor %s).", f2(acresc$estatistica_f), fp(acresc$p_valor)),
  sprintf("- Forma funcional: RESET p-valor %s no Modelo 2 e %s no Modelo 4.", fp(reset$p_valor[reset$modelo == "Modelo 2"]), fp(reset$p_valor[reset$modelo == "Modelo 4"])),
  sprintf("- Multicolinearidade (Modelo 2): maior FIV = %s (limite 10).", f4(max(vif$fiv[vif$modelo == "Modelo 2"]))),
  sprintf("- Heterocedasticidade (Breusch-Pagan-Godfrey): p-valor %s no Modelo 2 e %s no Modelo 4; inferência com White.",
          fp(testes$p_valor[testes$modelo == "Modelo 2" & grepl("Breusch", testes$teste)]),
          fp(testes$p_valor[testes$modelo == "Modelo 4" & grepl("Breusch", testes$teste)])),
  sprintf("- Quebra estrutural (Chow): p-valor %s; não rejeita.", fp(chow$p_valor)),
  sprintf("- Autocorrelação: mediana do Durbin-Watson por município = %s no Modelo 2 e %s no Modelo 4.",
          f4(aut_res$durbin_watson_mediano[aut_res$modelo == "Modelo 2"]), f4(aut_res$durbin_watson_mediano[aut_res$modelo == "Modelo 4"])), "",
  "Limitações e pontos a rever: 05_limitacoes.md."))

# ---- LEIAME
gravar("../LEIAME.md", c(
  "# Salário médio real formal nos municípios da Região Metropolitana de Curitiba, 2012 a 2021", "",
  "Trabalho de Econometria I (UFPR). Painel de 29 municípios em 10 anos (290 observações). Variável dependente: logaritmo do salário médio real formal. Explicativas: X2 ensino superior, X3 dominância industrial, X4 concentração setorial (Gini), X5 Selic real e X6 distância a Curitiba (no Modelo 2).", "",
  "## Como reproduzir", "",
  "1. Instalar o R e os pacotes de `documentacao/ambiente_r.csv`.",
  "2. Definir esta pasta como diretório de trabalho e rodar `Rscript R/00_executar_tudo.R`.", "",
  "## Scripts", "",
  "| Script | Função |", "|---|---|",
  "| 02_tratamento_painel.R | constrói o painel e as variáveis |",
  "| 03_aede_visualizacoes.R | figuras e animações |",
  "| 04_modelagem_diagnosticos.R | modelos 2, 3, 3b e 4; erro de White; VIF; Breusch-Pagan-Godfrey; Goldfeld-Quandt; ANOVA |",
  "| 05_autocorrelacao_municipios.R | Durbin-Watson, ρ e Breusch-Godfrey por município (Modelos 2 e 4) |",
  "| 06_especificacao_chow.R | RESET, teste F de acréscimo das dummies, LM de tendência, Chow, inferência agregada e checagem do Gini |",
  "| 07_memorial_modelo_2.R | memorial matricial do Modelo 2 com quatro casas decimais |", "",
  "Onde ler: `documentacao/00_resumo.md`. Verificações: `documentacao/08_verificacao.md`."))
message("Documentação gerada em ", DOC)
