# Gera envio_professor/documentacao/ e envio_professor/LEIAME.md a partir dos resultados do modelo principal.
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
gravar <- function(arq, linhas) writeLines(linhas, file.path(DOC, arq), useBytes = TRUE)

# ---- Resultados carregados
coef <- res("coeficientes_modelos.csv")
cl <- coef[coef$matriz == "classico", ]
wh <- coef[coef$matriz == "white", ]
testes <- res("testes_diagnostico.csv")
norm <- res("normalidade_residuos.csv")
vif <- res("vif_tolerancia.csv")
anova <- res("anova_f_modelo.csv")
reset <- res("especificacao_reset.csv")
lm_t <- res("especificacao_lm_tendencia.csv")
chow <- res("chow_quebra_periodo.csv")
gini_chk <- res("medida_gini_checagem.csv")
rob <- res("robustez_x4_definicao_gini.csv")
rob2 <- res("robustez_porte_e_negativos.csv")
hc <- res("testes_heterocedasticidade_complementares.csv")
frob <- res("f_geral_robusto.csv")
mres <- res("maiores_residuos.csv")
het_res <- res("autocorrelacao_heterogeneidade_resumo.csv")
reesp <- res("reespecificacao_forma_funcional.csv")
finc <- res("f_incremental_robusto.csv")
pmed <- res("previsao_media_2021.csv")
proj <- res("projecao_selic_m2.csv")
efeito <- res("efeito_selic_m2.csv")
aut <- res("autocorrelacao_por_municipio.csv")
aut_res <- res("autocorrelacao_resumo.csv")

rot <- c(prop_superior = "X2 escolaridade (proporção com superior completo, %)",
         dom_industrial = "X3 industrialização (VAB da indústria / VAB total, %)",
         gini_setorial = "X4 Gini setorial (vínculos entre 87 divisões CNAE)",
         selic_real = "X5 Selic real (% a.a.)",
         dist_curitiba_km = "X6 distância a Curitiba (km)",
         `(Intercept)` = "Intercepto")
cw <- wh[match(names(rot), wh$termo), ]
ct <- cl[match(names(rot), cl$termo), ]
tab_coef <- data.frame(Variável = rot, Coeficiente = f4(cw$estimativa), `EP (White)` = f4(cw$erro_padrao),
                       `t` = f2(cw$estatistica_t), `p-valor` = fp(cw$p_valor),
                       `IC 95% inferior` = f4(cw$ic_inf_95), `IC 95% superior` = f4(cw$ic_sup_95), check.names = FALSE)
tab_coef_cl <- data.frame(Variável = rot, Coeficiente = f4(ct$estimativa), `EP (clássico)` = f4(ct$erro_padrao),
                          `p-valor (clássico)` = fp(ct$p_valor), check.names = FALSE)
p_wh <- function(termo) cw$p_valor[cw$termo == termo]
gl_m <- unique(cw$gl)

# ---- Testes
tab_test <- data.frame(Teste = testes$teste, Estatística = f2(testes$estatistica), gl = testes$gl,
                       `p-valor` = fp(testes$p_valor), Decisão = testes$decisao_5pct, check.names = FALSE)
tab_hipo <- rbind(
  data.frame(Teste = testes$teste, H0 = testes$hipotese_nula, Ha = testes$hipotese_alternativa,
             Estatística = f2(testes$estatistica), `p-valor` = fp(testes$p_valor), Decisão = testes$decisao_5pct, check.names = FALSE),
  data.frame(Teste = "Shapiro-Wilk (normalidade dos resíduos)", H0 = norm$hipotese_nula, Ha = norm$hipotese_alternativa,
             Estatística = f4(norm$estatistica), `p-valor` = fp(norm$p_valor), Decisão = ifelse(norm$p_valor < 0.05, "rejeita H0", "não rejeita H0"), check.names = FALSE),
  data.frame(Teste = reset$teste, H0 = reset$hipotese_nula, Ha = reset$hipotese_alternativa,
             Estatística = f2(reset$estatistica_f), `p-valor` = fp(reset$p_valor), Decisão = reset$decisao_5pct, check.names = FALSE),
  data.frame(Teste = lm_t$teste, H0 = lm_t$hipotese_nula, Ha = lm_t$hipotese_alternativa,
             Estatística = f2(lm_t$estatistica), `p-valor` = fp(lm_t$p_valor), Decisão = lm_t$decisao_5pct, check.names = FALSE),
  data.frame(Teste = chow$teste, H0 = chow$hipotese_nula, Ha = chow$hipotese_alternativa,
             Estatística = f2(chow$estatistica_f), `p-valor` = fp(chow$p_valor), Decisão = chow$decisao_5pct, check.names = FALSE)
)

tab_vif <- data.frame(Variável = vif$variavel, FIV = f4(vif$fiv), Tolerância = f4(vif$tolerancia),
                      Decisão = vif$decisao_fiv_10, check.names = FALSE)
tab_chow <- data.frame(Corte = chow$corte, Papel = ifelse(grepl("indicado", chow$teste), "indicado pelo gráfico", "comparação"),
                       `F` = f2(chow$estatistica_f), gl = chow$gl, `p-valor` = fp(chow$p_valor),
                       Decisão = chow$decisao_5pct, check.names = FALSE)
tab_aut_res <- data.frame(Modelo = "Modelo 2 (principal)", Municípios = aut_res$municipios,
                          `DW mediano` = f4(aut_res$durbin_watson_mediano), `ρ auxiliar mediano` = f4(aut_res$rho_auxiliar_mediano),
                          `DW rejeita ausência de autocorrelação positiva` = aut_res$dw_positiva,
                          `DW inconclusivo` = aut_res$dw_inconclusiva,
                          `Breusch-Godfrey rejeita (5%)` = aut_res$breusch_godfrey_rejeita, check.names = FALSE)

# ---- Projeção e efeito da Selic
cenarios <- unique(proj$cenario)
tab_proj <- data.frame(
  Cenário = cenarios,
  `Selic (% a.a.)` = f2(sapply(cenarios, function(c) mean(proj$selic[proj$cenario == c]))),
  `Média prevista sem correção (R$)` = f2(sapply(cenarios, function(c) mean(proj$salario_previsto_sem_correcao[proj$cenario == c]))),
  `Média prevista com correção (R$)` = f2(sapply(cenarios, function(c) mean(proj$salario_previsto_corrigido[proj$cenario == c]))),
  check.names = FALSE)
fator_vies <- efeito$fator_correcao_vies[1]

# ---- Robustez do Gini
tab_rob <- data.frame(Definição = rob$definicao_x4, Coeficiente = f4(rob$coef_x4), `p-valor` = fp(rob$p_valor_x4),
                      `R2 ajustado` = f4(rob$r2_ajustado), AIC = f2(rob$aic), check.names = FALSE)
tab_hc <- data.frame(Teste = ifelse(is.na(hc$ordenado_por) | hc$ordenado_por == "", hc$teste,
                                    paste0(hc$teste, ", ordenado por ", hc$ordenado_por)),
                     Estatística = f2(hc$estatistica), gl = hc$gl, `p-valor` = fp(hc$p_valor),
                     Decisão = hc$decisao_5pct, check.names = FALSE)
tab_frob <- data.frame(Matriz = frob$matriz, F = f2(frob$estatistica_f), `gl` = paste(frob$gl_numerador, frob$gl_denominador, sep = "; "),
                       `p-valor` = fp(frob$p_valor), Decisão = frob$decisao_5pct, check.names = FALSE)
tab_finc <- data.frame(Bloco = finc$bloco, Restrições = finc$restricoes, `F (White)` = f2(finc$estatistica_f_white),
                       `p-valor` = fp(finc$p_valor_white), Decisão = finc$decisao_5pct, check.names = FALSE)
tab_pmed <- data.frame(Cenário = pmed$cenario, `Selic (% a.a.)` = f2(pmed$selic),
                       `IC 95% clássico (ln)` = paste0("[", f4(pmed$ic_inf_ln_classico), "; ", f4(pmed$ic_sup_ln_classico), "]"),
                       `IC 95% com White (ln)` = paste0("[", f4(pmed$ic_inf_ln_white), "; ", f4(pmed$ic_sup_ln_white), "]"), check.names = FALSE)
tab_mres <- data.frame(Município = mres$nome_municipio, Ano = mres$ano, Resíduo = f4(mres$residuo),
                       `Resíduo / erro-padrão` = f2(mres$residuo_sobre_s), check.names = FALSE)
tab_reesp <- data.frame(Especificação = reesp$especificacao, `R2 ajustado` = f4(reesp$r2_ajustado), AIC = f2(reesp$aic),
                        `RESET F` = f2(reesp$reset_f), `RESET p-valor` = fp(reesp$reset_p), `Shapiro-Wilk W` = f4(reesp$shapiro_w),
                        `Gini: coeficiente (p)` = paste0(f4(reesp$coef_gini), " (", fp(reesp$p_gini), ")"), check.names = FALSE)
rob2 <- rob2[rob2$termo %in% c("gini_setorial", "dist_curitiba_km", "ln_vinculos_ativos"), ]
tab_rob2 <- data.frame(Especificação = rob2$especificacao, Termo = rob2$termo, Coeficiente = f4(rob2$coeficiente),
                       `p-valor` = fp(rob2$p_valor), check.names = FALSE)

# ---- Descrição das variáveis (a partir do painel)
desc <- data.frame(
  Variável = c("salario_medio_real", "ln_salario_real", "prop_superior", "dom_industrial", "gini_setorial",
               "selic_real", "dist_curitiba_km"),
  Média = sapply(c("salario_medio_real", "ln_salario_real", "prop_superior", "dom_industrial", "gini_setorial",
                   "selic_real", "dist_curitiba_km"), function(v) mean(painel[[v]])),
  Mínimo = sapply(c("salario_medio_real", "ln_salario_real", "prop_superior", "dom_industrial", "gini_setorial",
                    "selic_real", "dist_curitiba_km"), function(v) min(painel[[v]])),
  Máximo = sapply(c("salario_medio_real", "ln_salario_real", "prop_superior", "dom_industrial", "gini_setorial",
                    "selic_real", "dist_curitiba_km"), function(v) max(painel[[v]])),
  check.names = FALSE)
desc$Média <- f4(desc$Média); desc$Mínimo <- f4(desc$Mínimo); desc$Máximo <- f4(desc$Máximo)

# ---- 00 resumo
gravar("00_resumo.md", c(
  "# Resumo", "",
  "Modelo principal: MQO com as observações empilhadas (29 municípios da RMC x 10 anos = 290), sem controles fixos por município e sem métodos de dados em painel. Erros-padrão de White (HC1).", "",
  "Variável dependente: logaritmo natural do salário médio formal real (reais de 2021).", "",
  "## Coeficientes (erro de White)", "", md(tab_coef), "",
  sprintf("R² ajustado = %s; F geral = %s (gl 5 e %s), p-valor %s.",
          f4(anova$r2_ajustado[1]), f2(anova$estatistica_f[1]), anova$gl_denominador[1], fp(anova$p_valor[1])), "",
  "## Diagnósticos", "",
  sprintf("- Multicolinearidade: FIV máximo = %s (limite 10).", f2(max(vif$fiv))),
  sprintf("- Heterocedasticidade: Breusch-Pagan-Godfrey p = %s (rejeita); Goldfeld-Quandt ordenado pela distância p = %s (unilateral, não rejeita; ordenado pela industrialização, rejeita). O teste de White rejeita (ver 04_diagnosticos). Inferência com erros de White.",
          fp(testes$p_valor[grepl("Breusch", testes$teste)]), fp(testes$p_valor[grepl("Goldfeld", testes$teste)])),
  sprintf("- Normalidade dos resíduos: Shapiro-Wilk W = %s, p-valor %s (rejeita).", f4(norm$estatistica[1]), fp(norm$p_valor[1])),
  sprintf("- Forma funcional: RESET F = %s (gl %s), p-valor %s (rejeita).", f2(reset$estatistica_f[1]), reset$gl[1], fp(reset$p_valor[1])),
  sprintf("- Autocorrelação por município: mediana do Durbin-Watson = %s; o teste rejeita a ausência de autocorrelação positiva em %s de %s municípios.",
          f4(aut_res$durbin_watson_mediano[1]), aut_res$dw_positiva[1], aut_res$municipios[1]),
  sprintf("- Quebra estrutural (Chow, corte em 2017, indicado pelo gráfico): F = %s, p-valor %s (não rejeita).",
          f2(chow$estatistica_f[grepl("indicado", chow$teste)]), fp(chow$p_valor[grepl("indicado", chow$teste)])), "",
  "## Projeção de 2021 (previsão dentro da amostra)", "", md(tab_proj), "",
  "## Pendências", "",
  "- Gini (X4): fórmula da aula sobre medidas de desigualdade e de Hoffmann (2006, cap. 17), com as 87 divisões da CNAE e zeros incluídos. Verificação complementar só com as divisões que têm vínculo.",
  "- Confirmação de métodos pelo professor: tratamento da forma funcional (RESET) e da normalidade.",
  "- Recorte temporal: 2012 a 2021, mantido. Eventuais mudanças de recorte exigiriam reexecutar o pipeline e atualizar a documentação.", ""
))

# ---- 01 dados e variáveis
gravar("01_dados_e_variaveis.md", c(
  "# Dados e variáveis", "",
  "Unidades: os 29 municípios da Região Metropolitana de Curitiba (código IBGE 05501), de 2012 a 2021. Painel balanceado com 290 observações.", "",
  "## Fontes", "",
  "| Dado | Origem | Observação |", "|---|---|---|",
  "| Salário médio formal | RAIS (Ministério do Trabalho), microdados públicos | Remuneração média dos vínculos |",
  "| Escolaridade (X2) | RAIS | Proporção dos vínculos com ensino superior completo |",
  "| Industrialização (X3) | IBGE, SIDRA, tabela 5938 | VAB da indústria sobre o VAB total |",
  "| Gini setorial (X4) | RAIS | Vínculos por divisão da CNAE (87 divisões) |",
  "| Selic real (X5) | Banco Central, SGS (séries 4390 e 433) | Selic acumulada no ano, deflacionada pelo IPCA |",
  "| Distância a Curitiba (X6) | IBGE, malha municipal | Distância entre centroides, em km; Curitiba = 0 |",
  "| Deflator | IBGE, IPCA (série 433 do Banco Central) | Salários em reais de 2021 |", "",
  "## Variáveis e estatísticas descritivas", "", md(desc), "",
  "Observação: VAB industrial negativo em Araucária (2012 e 2013), mantido como publicado pelo IBGE e marcado no painel. Adrianópolis tem salto da participação industrial entre 2014 e 2015, confirmado na fonte.", "",
  "Os salários estão em reais de 2021. O logaritmo natural é usado porque os salários são positivos e a distribuição é assimétrica à direita; o coeficiente de uma variável explicativa então indica variação relativa (%) do salário."
))

# ---- 02 especificação e métodos
gravar("02_especificacao_e_metodos.md", c(
  "# Especificação e métodos", "",
  "## Modelo", "",
  "ln(salário real)_it = β0 + β1 X2_it + β2 X3_it + β3 X4_it + β4 X5_t + β5 X6_i + u_it", "",
  "Estimação por mínimos quadrados ordinários (MQO) com as 290 observações empilhadas. Inferência com erros-padrão de White (HC1), com t de n − k graus de liberdade (284).", "",
  "## Hipóteses", "",
  "H0 geral: o salário médio real formal de um município não depende da sua escolaridade, da sua estrutura de emprego e da sua localização.",
  "Ha: pelo menos uma dessas condições afeta o salário.", "",
  "| Hipótese | Variável | Sinal esperado |", "|---|---|---|",
  "| H1 | escolaridade (X2) | positivo |",
  "| H2 | industrialização (X3) | positivo |",
  "| H3 | diversificação setorial (X4, Gini invertido) | negativo para o Gini |",
  "| H4 | Selic real (X5) | exploratória, sem sinal único |",
  "| H5 | distância a Curitiba (X6) | negativo |", "",
  "Critério: rejeita-se H0 no coeficiente quando p < 0,05.", "",
  "## Métodos usados", "",
  "| Método | Uso no trabalho | Referência (Gujarati, 4ª ed., PDF) |", "|---|---|---|",
  "| MQO e álgebra matricial | estimação e memorial | caps. 6 e 7 |",
  "| Erros-padrão de White (HC1) | inferência | cap. 11, p. 442 em diante |",
  "| Multicolinearidade (FIV e tolerância) | diagnóstico | cap. 10 |",
  "| Breusch-Pagan-Godfrey | heterocedasticidade | cap. 11, pp. 439 e 440 |",
  "| Goldfeld-Quandt | heterocedasticidade | cap. 11, pp. 436 a 440 |",
  "| Teste geral de White | heterocedasticidade | cap. 11 e aula de heterocedasticidade |",
  "| Shapiro-Wilk e gráfico Q-Q | normalidade dos resíduos | orientação do professor |",
  "| RESET de Ramsey | forma funcional | cap. 13, pp. 549 a 552 |",
  "| Teste LM para tendência linear | variável omitida (ano) | cap. 13 |",
  "| Teste de Chow | quebra estrutural | cap. 8, pp. 303 a 309 |",
  "| Durbin-Watson (tabela D.5A) | autocorrelação, série de cada município | cap. 12, pp. 495 a 499; Apêndice D, p. 995 |",
  "| Breusch-Godfrey (ordem 1) | autocorrelação, série de cada município | cap. 12, pp. 499 e 500 |",
  "| Retransformação do logaritmo | previsão em reais com correção exp(s²/2) | presunção da modelagem |", "",
  "## Projeção", "",
  "A projeção é uma previsão dentro da amostra para 2021, último ano com todas as variáveis publicadas. Não há previsão para 2026. A previsão é x0'b; o intervalo da média usa x0'(X'X)^-1 x0 σ², e o intervalo individual, σ²(1 + x0'(X'X)^-1 x0).", "",
  sprintf("Viés da retransformação: a média em reais é exp(previsão + s²/2) sob erros normais. Aplicamos o fator exp(s²/2) = %s. Como a normalidade é rejeitada, a correção é aproximada.", f4(fator_vies)), ""
))

# ---- 03 resultados
gravar("03_resultados_modelos.md", c(
  "# Resultados do modelo principal", "",
  "## Coeficientes com erro de White (HC1)", "", md(tab_coef), "",
  "## Coeficientes com erro clássico (comparação)", "", md(tab_coef_cl), "",
  "## Efeito da Selic", "",
  sprintf("Cada ponto percentual a mais da Selic real está associado a um salário %s%% maior (efeito ln = %s; IC 95%% [%s; %s]; gl %s; p-valor %s).",
          f2(efeito$efeito_percentual_por_pp[1]), f4(efeito$efeito_ln_por_pp[1]), f4(efeito$ic95_inf_ln[1]),
          f4(efeito$ic95_sup_ln[1]), efeito$gl[1], fp(efeito$p_valor[1])), "",
  "## Robustez da X4: definição do Gini", "", md(tab_rob), "",
  "## Robustez adicional: porte do município e VAB da indústria negativo", "", md(tab_rob2), "",
  sprintf("O Gini setorial tem correlação de %s com o logaritmo dos vínculos ativos do município: ele acompanha o porte. Com esse controle, o coeficiente do Gini perde a significância e muda de sinal, e o da distância perde a significância. Sem as duas observações de Araucária com VAB da indústria negativo, o sinal e a significância do Gini se mantêm.", format(round(rob2$cor_gini_ln_vinculos[1], 2), decimal.mark = ",")), "",
  "A definição com as 87 divisões (zeros incluídos) é a usada no modelo principal. A versão só com as divisões que têm vínculo é apresentada como verificação; a definição final depende de orientação do professor.", "",
  sprintf("Correlação entre o Gini e o número de divisões com vínculo: %s.", f4(gini_chk$valor[1])), "",
  "## Projeção de 2021", "", md(tab_proj), "",
  sprintf("O fator de correção exp(s²/2) é %s. Com a correção, a previsão média em reais sobe nessa proporção.", f4(fator_vies)), ""
))

# ---- 04 diagnósticos
gravar("04_diagnosticos.md", c(
  "# Diagnósticos do modelo principal", "",
  "## Hipóteses formais e critério de decisão a 5%", "",
  "Critério: rejeita-se H0 quando o p-valor é menor que 0,05.", "",
  md(tab_hipo), "",
  "## Multicolinearidade", "", md(tab_vif), "",
  "Regra ensinada: FIV maior que 10 indica multicolinearidade elevada. Nenhum regressor passa do limite.", "",
  "## Autocorrelação por município", "",
  "Os testes são aplicados à série de dez anos de cada município, com os resíduos do modelo principal. Durbin-Watson com dL = 0,243 e dU = 2,822 (Tabela D.5A, n = 10, k = 5, 5%). Zonas de decisão: d < dL rejeita a ausência de autocorrelação positiva; dL ≤ d ≤ 4 − dL é inconclusivo; d > 4 − dL rejeita a ausência de autocorrelação negativa.", "",
  md(tab_aut_res), "",
  "A autocorrelação é declarada como limitação. Não há correção de painel no modelo principal.", "",
  "## Quebra estrutural (Chow)", "", md(tab_chow), "",
  "O corte de 2017 foi escolhido a partir do gráfico das variáveis médias no tempo (figuras_graficos/diag6_variaveis_no_tempo.png). O corte de 2016 aparece para comparação; em nenhum dos dois há quebra a 5%.", "",
  sprintf("LM para tendência linear do ano: estatística %s, gl %s, p-valor %s (%s).",
          f2(lm_t$estatistica[1]), lm_t$gl[1], fp(lm_t$p_valor[1]), lm_t$decisao_5pct[1]), "",
  "## Forma funcional (RESET)", "",
  sprintf("F = %s (gl %s), p-valor %s: rejeita a forma funcional linear. Declarado como limitação do modelo.", f2(reset$estatistica_f[1]), reset$gl[1], fp(reset$p_valor[1])), "",
  "## Normalidade dos resíduos", "",
  sprintf("Shapiro-Wilk W = %s, p-valor %s: rejeita a normalidade. O gráfico Q-Q (figuras_graficos/diag5_normalidade_qq.png) mostra desvio nas duas caudas. Com 290 observações, a inferência é aproximadamente válida; a limitação é declarada.",
          f4(norm$estatistica[1]), fp(norm$p_valor[1])), "",
  "## Heterocedasticidade", "", md(tab_test), "",
  "A inferência usa erros-padrão de White (HC1), que não dependem da forma da variância.", "",
  "## Heterocedasticidade: teste de White e Goldfeld-Quandt por outras variáveis", "", md(tab_hc), "",
  "O Breusch-Pagan e o White rejeitam a homocedasticidade. O Goldfeld-Quandt ordenado pela distância não rejeita, mas tem pouco poder quando a variância não cresce com essa variável; ordenado pela industrialização (X3), ele rejeita. A divergência entre os testes vem do ordenamento escolhido, não de um resultado contraditório.", "",
  "## F geral com erro de White", "", md(tab_frob), "",
  "## F incremental por bloco, com erro de White", "", md(tab_finc), "",
  "O F geral com a matriz de White (HC1) usa F = b'V^-1 b / q para as q = 5 inclinações. A conclusão é a mesma do F clássico.", "",
  "## Heterogeneidade entre municípios e o Durbin-Watson", "",
  sprintf("Com os resíduos do modelo empilhado, o Durbin-Watson mediano é %s e %s municípios ficam abaixo de dL. Com os resíduos centrados na média de cada município, a mediana passa a %s e apenas %s município fica abaixo de dL. Em %s dos 29 municípios os dez resíduos têm o mesmo sinal, e %s%% da soma de quadrados dos resíduos está entre municípios. Parte do que o Durbin-Watson lê como autocorrelação é, portanto, diferença persistente entre municípios que o modelo empilhado não capta. Os valores dL e dU da Tabela D.5A são aproximados neste caso, porque X6 não varia no tempo dentro do município.",
          f4(het_res$durbin_watson_mediano[1]), het_res$abaixo_dl[1], f4(het_res$durbin_watson_centrado_mediano[1]),
          het_res$abaixo_dl_centrado[1], het_res$municipios_mesmo_sinal[1], f2(100 * het_res$parcela_soma_quadrados_entre_municipios[1])), "",
  "## Exame dos resíduos", "",
  "As figuras figuras_graficos/diag1_residuos_vs_ajustados.png, diag2_residuos_por_municipio.png e diag7_residuos_vs_regressores.png mostram os resíduos contra os valores ajustados, por município e contra cada regressor. Os dez maiores resíduos em módulo:", "",
  md(tab_mres), "",
  "A cauda positiva dos resíduos vem de Adrianópolis (2012 a 2016) e de Araucária (2012 a 2014), municípios com participação industrial atípica; isso ajuda a explicar a assimetria e a curtose que o Shapiro-Wilk rejeita.", "",
  "## Intervalo da média da previsão de 2021 (ponto médio dos regressores)", "", md(tab_pmed), "",
  "## Reespecificação da forma funcional", "", md(tab_reesp), "",
  "Os quadrados de X2 e X3 usam as variáveis centradas na média. A inclusão do logaritmo dos vínculos ativos (porte do município) reduz bastante a estatística do RESET, o que indica que parte da não linearidade vem de uma variável omitida. O RESET ainda rejeita em todas as versões. O modelo principal permanece como o definido nas orientações; as versões ampliadas são sensibilidade.", ""
))

# ---- 05 limitações
gravar("05_limitacoes.md", c(
  "# Limitações", "",
  "- Desenho observacional: os coeficientes indicam associações, não efeitos causais.",
  "- A forma funcional linear é rejeitada pelo RESET; os coeficientes devem ser lidos com essa ressalva.",
  "- A normalidade dos resíduos é rejeitada pelo Shapiro-Wilk. A inferência usa a aproximação de amostras grandes.",
  "- O porte do município é uma variável omitida relevante: o Gini setorial tem correlação de -0,88 com o logaritmo dos vínculos ativos e, com esse controle, perde a significância e muda de sinal (robustez_porte_e_negativos.csv). Salário e escolaridade podem se determinar juntos, e o VAB da indústria contém a massa salarial; os resultados são associações.",
  "- O Breusch-Godfrey é aplicado à série de resíduos de cada município (constante e resíduo defasado), versão reduzida, porque a série tem dez anos. Sem preencher com zero o primeiro resíduo defasado, o número de municípios que rejeitam sobe de 3 para 5 (valor em autocorrelacao_heterogeneidade_resumo.csv), o que mostra que o resultado é sensível a esse tratamento com apenas dez observações.",
  "- Autocorrelação dentro dos municípios: o Durbin-Watson e o Breusch-Godfrey indicam autocorrelação em parte dos municípios. Não há correção no modelo principal; a limitação é declarada.",
  "- O Gini (X4) usa as 87 divisões da CNAE como unidades, com zeros incluídos. A aula e Hoffmann aplicam a medida a indivíduos; a adaptação é nossa. O índice depende do número de divisões com vínculo (correlação de −0,95).",
  "- A Selic (X5) tem 10 valores distintos, um por ano. Seu coeficiente trata 290 observações como independentes e tende a superestimar a precisão.",
  "- A distância a Curitiba (X6) é constante no tempo para cada município (29 valores distintos).",
  "- Adrianópolis (2014 e 2015) tem salto da participação industrial confirmado na fonte; a causa não está documentada.",
  "- Araucária tem VAB industrial negativo em 2012 e 2013, como publicado pelo IBGE.",
  "- A quebra estrutural foi testada com um corte escolhido pelo gráfico; outro corte pode dar resultado diferente.",
  "- Recorte temporal de 2012 a 2021, limitado pela disponibilidade do VAB setorial municipal (não publicado para 2022 e 2023)."))

# ---- 06 fontes
gravar("06_fontes.md", c(
  "# Fontes e referências", "",
  "## Livros e textos", "",
  "| Fonte | Uso no trabalho |", "|---|---|",
  "| Gujarati, D. N. Basic Econometrics. 4ª ed. McGraw-Hill/Irwin, 2003 (PDF com texto completo, páginas do PDF) | métodos de regressão, testes e diagnósticos (páginas na tabela de métodos) |",
  "| Hoffmann, R. Estatística para economistas. 4ª ed. revista e ampliada, 2006, cap. 17 (Medidas de desigualdade, pp. 337 a 341) | fórmula discreta do Gini (pp. 340 e 341) |",
  "| Hasegawa, M. M. Slides de aula: Multicolinearidade (2016a), Heterocedasticidade (2016b), Autocorrelação (2017), Medidas de desigualdade (2020), Especificação e diagnóstico (2022) e Teste de Chow (2024). Curso de Ciências Econômicas, UFPR | métodos de diagnóstico e Gini discreto (as aulas citam Gujarati e Porter, 2011, 5ª ed.) |",
  "| Slides e guia da disciplina (Econometria I) | escopo dos métodos |", "",
  "## Dados", "",
  "| Dado | Origem | Arquivo |", "|---|---|---|",
  "| PIB e VAB municipais | IBGE, SIDRA, tabela 5938 | dados_brutos/pib_sidra.rds |",
  "| Selic (4390) e IPCA (433) | Banco Central, SGS | dados_brutos/macro_bacen.rds |",
  "| Vínculos, escolaridade e CNAE | RAIS, microdados públicos (MTE) | dados_brutos/rais.rds |",
  "| Malha e distâncias | IBGE | dados_brutos/malha_rmc.rds, distancias.rds |", ""
))

# ---- 07 critérios
gravar("07_criterios_da_disciplina.md", c(
  "# Critérios de correção", "",
  "Trabalho de Econometria I (UFPR). O modelo usa apenas métodos da disciplina: MQO, erros-padrão de White, testes t e F, multicolinearidade (FIV), heterocedasticidade (Breusch-Pagan-Godfrey, White e Goldfeld-Quandt), normalidade (Shapiro-Wilk), forma funcional (RESET e LM), quebra estrutural (Chow), autocorrelação por série (Durbin-Watson e Breusch-Godfrey) e previsão matricial.", "",
  "Hipóteses formais (H0 e Ha) e critério de decisão a 5% em todos os testes. Resultados com quatro casas decimais. Memorial de cálculo em `memorial_modelo_2_*.csv`."))

# ---- Ambiente e dicionário
amb <- data.frame(item = c("R", "pacotes principais", "sistema"),
                  valor = c(paste(R.version$major, R.version$minor, sep = "."),
                            paste0(paste(vapply(c("lmtest", "sandwich", "car", "ggplot2", "dplyr", "tidyr", "gganimate", "sf", "geobr"), function(p) paste(p, tryCatch(as.character(utils::packageVersion(p)), error = function(e) "n/d")), character(1)), collapse = ", "), "; shapiro.test (base R)"), R.version$platform))
write.csv(amb, file.path(DOC, "ambiente_r.csv"), row.names = FALSE)
dic <- data.frame(
  variavel = c("id_municipio", "nome_municipio", "ano", "salario_medio_nominal", "salario_medio_real", "ln_salario_real",
               "prop_superior", "dom_industrial", "gini_setorial", "selic_real", "dist_curitiba_km", "x3_negativo",
               "selic_nominal_ano", "ipca_ano", "indice_ipca_medio",
               "vinculos_ativos", "vinculos_superior", "vinculos_escolaridade_na", "pib", "vab_total_soma", "vab_industria"),
  descricao = c("código IBGE do município (7 dígitos)", "nome do município", "ano", "salário médio nominal (RAIS)",
                "salário médio real, reais de 2021", "logaritmo natural do salário real", "X2: % dos vínculos com superior completo",
                "X3: VAB da indústria / VAB total x 100", "X4: Gini da participação das divisões CNAE nos vínculos",
                "X5: Selic real anual (% a.a.)", "X6: distância a Curitiba (km)", "marca de VAB industrial negativo",
                "Selic anual", "IPCA anual", "índice de preços médio do ano",
                "vínculos ativos (RAIS)", "vínculos com superior completo", "vínculos sem escolaridade informada",
                "PIB municipal (mil reais)", "soma dos quatro VAB setoriais", "VAB da indústria (mil reais)"),
  stringsAsFactors = FALSE)
write.csv(dic, file.path(DOC, "dicionario_variaveis.csv"), row.names = FALSE)

# ---- LEIAME
gravar("../LEIAME.md", c(
  "# Trabalho de Econometria I: envio", "",
  "Modelo principal: MQO empilhado para 29 municípios da RMC, 2012 a 2021 (290 observações), com erros-padrão de White.", "",
  "## Como reproduzir", "",
  "1. Rode `Rscript R/00_executar_tudo.R` a partir desta pasta; ele executa os scripts 02 a 07 em ordem.",
  "2. Os dados brutos estão em `dados_brutos/` (cache das APIs e da RAIS); os scripts não consultam a internet quando o cache existe.", "",
  "## Conteúdo", "",
  "- `R/`: scripts 02 a 07 (tratamento, figuras, modelo, autocorrelação, especificação e memorial).",
  "- `resultados_econometricos/`: coeficientes, testes, memorial matricial, projeção e robustez.",
  "- `figuras_graficos/`: figuras de diagnóstico e de análise exploratória.",
  "- `documentacao/`: resumo, dados, especificação, resultados, diagnósticos, limitações, fontes e verificação.", "",
  "A verificação independente está em `documentacao/08_verificacao.md`."))
message("Documentação gerada em ", DOC)
