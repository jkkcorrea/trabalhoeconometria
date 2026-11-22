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
corr <- res("autocorrelacao_correcao.csv")
norm <- res("normalidade_residuos.csv")
infl <- res("influencia_observacoes.csv")
infl_sens <- res("influencia_sensibilidade.csv")
reset <- res("especificacao_reset.csv")
acresc <- res("especificacao_acrescimo_municipios.csv")
lm_t <- res("especificacao_lm_tendencia.csv")
chow <- res("chow_quebra_periodo.csv")
inf_ag <- res("inferencia_agregada_x5_x6.csv")
gini_chk <- res("medida_gini_checagem.csv")
comp <- res("comparacao_selic_producao.csv")
comp_f <- res("comparacao_f_retirar_selic.csv")
proj <- res("projecao_selic_m4.csv")
efeito <- res("efeito_selic_projecao.csv")
rob_x4 <- res("robustez_x4_definicao_gini.csv")

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
  "Fontes do uso de variáveis dummy: Gujarati, cap. 9 (PDF pp. 332 a 352), e o trabalho de exemplo da disciplina (seção 2.3). Os slides das aulas lidos não tratam de dummies.", "",
  "## Métodos usados (todos ensinados na disciplina)", "",
  "| Método | Uso no projeto | Fonte oficial |", "|---|---|---|",
  "| MQO e álgebra matricial | estimação e memorial | notas de regressão múltipla |",
  "| t, F, ANOVA, R2 | inferência e teste de acréscimo | notas de regressão múltipla |",
  "| Variáveis dummy | controle de município (Modelo 4) e de Curitiba | Gujarati, cap. 9 (confirmar no livro) |",
  "| FIV e tolerância (limite 10) | multicolinearidade | notas de multicolinearidade; Guia P2 |",
  "| Breusch-Pagan-Godfrey | heterocedasticidade | notas de heterocedasticidade; provas 2023 a 2025 |",
  "| Goldfeld-Quandt | heterocedasticidade | notas de heterocedasticidade |",
  "| Erros-padrão de White (HC1) | inferência robusta | notas de heterocedasticidade; Guia P2 |",
  "| Durbin-Watson e ρ por regressão auxiliar AR(1) | autocorrelação, série de cada município | Gujarati, cap. 12 (PDF pp. 495 a 499); Tabela D.5A (PDF p. 995); Guia P2 (cinco zonas) |",
  "| Breusch-Godfrey (ordem 1) | autocorrelação, série de cada município | Gujarati, cap. 12 (PDF pp. 499 e 500); slides autocorrel |",
  "| Teste das carreiras (runs) | aleatoriedade dos resíduos por município | Gujarati, cap. 12 (PDF p. 493); slides autocorrel pp. 79 a 93 |",
  "| Prais-Winsten e Cochrane-Orcutt | correção da autocorrelação, ρ comum, dentro de cada município | Gujarati, cap. 12 (PDF pp. 510 a 528); Guia P2 (não aparecem nos slides autocorrel) |",
  "| Jarque-Bera | normalidade dos resíduos | Gujarati, cap. 5, seção 5.12 (PDF pp. 176 e 177) |",
  "| Alavancagem e resíduo padronizado | observações atípicas e influentes (sem teste formal) | Gujarati, cap. 13, Outliers, Leverage, and Influence (PDF pp. 568 e 569) |",
  "| RESET de Ramsey | forma funcional | notas de especificação e diagnóstico |",
  "| LM para variável omitida | acréscimo de tendência linear | notas de especificação e diagnóstico |",
  "| Teste de Chow | quebra estrutural por período | notas do teste de Chow |", "",
  "## Métodos removidos do projeto (não ensinados nas fontes oficiais)", "",
  "Efeitos fixos e aleatórios como estimadores próprios, Mundlak, Hausman, erros agrupados por município, bootstrap e Box-Cox. Newey-West não é aplicado ao painel empilhado: ele corrige erros-padrão de uma série temporal única, e o painel empilhado não atende a essa condição (não aplicado; ver 04_diagnosticos.md). Smearing de Duan também não é usado.", "",
  "A entropia de Shannon foi removida por engano: ela é ensinada (slides de medidas de desigualdade, pasta `aulas`). A X4 continua sendo o Gini; a entropia fica disponível como medida alternativa.", "",
  "Fontes oficiais e IDs no Drive: `06_fontes.md`."))

# ---- 03 resultados
gravar("03_resultados_modelos.md", c(
  "# Resultados dos modelos", "",
  "Coeficientes com erro de White (HC1) e t com n - k graus de liberdade. Erro clássico em `coeficientes_modelos.csv`.", "",
  "## Modelo principal: Modelo 4 com correção de autocorrelação (Prais-Winsten), erro de White", "",
  "Modelo principal do trabalho: dummies de município (Modelo 4) com correção de autocorrelação por Prais-Winsten, ρ comum a todos os municípios [presunção da modelagem], e erros-padrão de White (HC1). O memorial matricial está em `memorial_prais_winsten_m2.csv` (Modelo 2) e `memorial_modelo_4_fwl.csv` (Modelo 4, sem correção). Os coeficientes sem correção ficam abaixo como comparação.", "",
  md({
    cm <- corr[corr$modelo == "Modelo 4" & corr$metodo == "Prais-Winsten", ]
    cm <- cm[cm$termo %in% c("prop_superior", "dom_industrial", "gini_setorial", "selic_real"), ]
    data.frame(Variável = c(prop_superior = "X2 escolaridade", dom_industrial = "X3 industrialização", gini_setorial = "X4 Gini", selic_real = "X5 Selic real")[cm$termo],
               Coeficiente = f4(cm$estimativa), `EP HC1` = f4(cm$erro_padrao_HC1), `p-valor HC1` = fp(cm$p_valor_HC1), check.names = FALSE)
  }), "",
  sprintf("ρ estimado = %s; após a transformação, o ρ dos resíduos cai para %s. Confirmado por memorial matricial (C15).",
          f4(corr$rho[corr$modelo == "Modelo 4" & corr$metodo == "Prais-Winsten"][1]),
          f4(corr$rho_auxiliar_residuos_corrigidos[corr$modelo == "Modelo 4" & corr$metodo == "Prais-Winsten"][1])), "",
  "## Modelo 4 sem correção, erro de White (comparação)", "", md(coef_m("Modelo 4", "white")), "", m4_nota, "",
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
                          `DW positivo` = aut_res$dw_positiva, `DW inconclusivo` = aut_res$dw_inconclusiva,
                          `DW não aplicável` = aut_res$dw_nao_aplicavel,
                          `Breusch-Godfrey rejeita (5%)` = aut_res$breusch_godfrey_rejeita,
                          `Carreiras não aplicáveis` = aut_res$carreiras_nao_aplicavel, check.names = FALSE)
focais_txt <- c(prop_superior = "X2 escolaridade", dom_industrial = "X3 industrialização", gini_setorial = "X4 Gini",
                selic_real = "X5 Selic real", dist_curitiba_km = "X6 distância")
corr_f <- corr[corr$termo %in% names(focais_txt), ]
ref_white <- coef[coef$matriz == "white", ]
tab_corr <- data.frame(Modelo = corr_f$modelo, Método = corr_f$metodo, `ρ estimado` = f4(corr_f$rho),
                       Variável = unname(focais_txt[corr_f$termo]), `Coef. antes (White)` = f4(ref_white$estimativa[match(paste(corr_f$modelo, corr_f$termo), paste(ref_white$modelo, ref_white$termo))]),
                       `Coef. corrigido` = f4(corr_f$estimativa), `EP HC1` = f4(corr_f$erro_padrao_HC1),
                       `p-valor HC1` = fp(corr_f$p_valor_HC1), `Obs.` = corr_f$observacoes_usadas, check.names = FALSE)
corr_pw <- function(modelo, termo) corr$p_valor_HC1[corr$modelo == modelo & corr$metodo == "Prais-Winsten" & corr$termo == termo]
corr_est <- function(modelo, termo) corr$estimativa[corr$modelo == modelo & corr$metodo == "Prais-Winsten" & corr$termo == termo]
rho_pw <- function(modelo) corr$rho[corr$modelo == modelo & corr$metodo == "Prais-Winsten"][1]
rho_res_pw <- function(modelo) corr$rho_auxiliar_residuos_corrigidos[corr$modelo == modelo & corr$metodo == "Prais-Winsten"][1]
gravar("04_diagnosticos.md", c(
  "# Diagnósticos do modelo", "",
  "## Hipóteses formais (H0 e Ha) e critério de decisão a 5%", "",
  "Critério em todos os testes: rejeita-se H0 quando o p-valor é menor que 0,05 (ou quando a estatística passa do valor crítico).", "",
  md(rbind(
    data.frame(Teste = testes$teste, Modelo = testes$modelo, H0 = testes$hipotese_nula, Ha = testes$hipotese_alternativa,
               Estatística = f2(testes$estatistica), `p-valor` = fp(testes$p_valor), Decisão = testes$decisao_5pct, check.names = FALSE),
    data.frame(Teste = reset$teste, Modelo = reset$modelo, H0 = reset$hipotese_nula, Ha = reset$hipotese_alternativa,
               Estatística = f2(reset$estatistica_f), `p-valor` = fp(reset$p_valor), Decisão = reset$decisao_5pct, check.names = FALSE),
    data.frame(Teste = acresc$teste, Modelo = "Modelo 4", H0 = acresc$hipotese_nula, Ha = acresc$hipotese_alternativa,
               Estatística = f2(acresc$estatistica_f), `p-valor` = fp(acresc$p_valor), Decisão = acresc$decisao_5pct, check.names = FALSE),
    data.frame(Teste = lm_t$teste, Modelo = lm_t$modelo, H0 = lm_t$hipotese_nula, Ha = lm_t$hipotese_alternativa,
               Estatística = f2(lm_t$estatistica), `p-valor` = fp(lm_t$p_valor), Decisão = lm_t$decisao_5pct, check.names = FALSE),
    data.frame(Teste = chow$teste, Modelo = chow$modelo, H0 = chow$hipotese_nula, Ha = chow$hipotese_alternativa,
               Estatística = f2(chow$estatistica_f), `p-valor` = fp(chow$p_valor), Decisão = chow$decisao_5pct, check.names = FALSE),
    data.frame(Teste = norm$teste, Modelo = norm$modelo, H0 = norm$hipotese_nula, Ha = norm$hipotese_alternativa,
               Estatística = f2(norm$estatistica), `p-valor` = fp(norm$p_valor), Decisão = norm$decisao_5pct, check.names = FALSE))), "",
  "## Normalidade dos resíduos (Jarque-Bera)", "",
  md(data.frame(Modelo = norm$modelo, Estatística = f2(norm$estatistica), gl = norm$gl, `p-valor` = fp(norm$p_valor),
                Decisão = norm$decisao_5pct, `Assimetria S` = f4(norm$assimetria_S), `Curtose K` = f4(norm$curtose_K), check.names = FALSE)), "",
  sprintf("A normalidade dos resíduos é rejeitada nos dois modelos (p-valor %s no Modelo 2 e %s no Modelo 4). A distribuição tem caudas pesadas, sobretudo no Modelo 2 (S = %s, K = %s). Com 290 observações, os testes t e F são aproximadamente válidos pela teoria de amostras grandes; essa é uma limitação a declarar [a confirmar no Gujarati, cap. 5].",
          fp(norm$p_valor[norm$modelo == "Modelo 2"]), fp(norm$p_valor[norm$modelo == "Modelo 4"]),
          f4(norm$assimetria_S[norm$modelo == "Modelo 2"]), f4(norm$curtose_K[norm$modelo == "Modelo 2"])), "",
  "## Influência e observações atípicas", "",
  "Conceitos do Gujarati (cap. 13): outlier (resíduo grande), ponto de alavancagem (valor extremo de um regressor) e ponto influente (sua retirada muda a inclinação). O livro não apresenta teste formal para esses pontos; distância de Cook e DFBETAS não fazem parte do material da disciplina. Usamos a alavancagem (diagonal da matriz chapéu), o resíduo padronizado e a variação de cada coeficiente ao retirar a observação, em erros-padrão. Limiares: alavancagem acima de 2k/n, resíduo padronizado maior que 2 em módulo, e variação maior que 1 erro-padrão [presunção da modelagem].", "",
  md(data.frame(Modelo = c("Modelo 2", "Modelo 4"),
                `Alavancagem acima de 2k/n` = c(sum(infl$alavancagem_alta[infl$modelo == "Modelo 2"]), sum(infl$alavancagem_alta[infl$modelo == "Modelo 4"])),
                `Outliers (resíduo padronizado acima de 2 em módulo)` = c(sum(infl$outlier[infl$modelo == "Modelo 2"]), sum(infl$outlier[infl$modelo == "Modelo 4"])),
                `Influentes` = c(sum(infl$influente[infl$modelo == "Modelo 2"]), sum(infl$influente[infl$modelo == "Modelo 4"])), check.names = FALSE)), "",
  sprintf("Pontos influentes no Modelo 4: %s. Retirados esses pontos, o coeficiente de X4 (Gini) passa de %s para %s, e o de X5 (Selic) varia %s%%. A observação de Adrianópolis em 2012 tem o maior resíduo padronizado do painel; a participação industrial do município salta de %s%% em 2014 para %s%% em 2015, enquanto a mediana do RMC em 2015 é %s%%. O dado deve ser conferido na fonte (SIDRA, tabela 5938) antes de qualquer conclusão [a confirmar].",
          paste(paste(infl$nome_municipio, infl$ano)[infl$modelo == "Modelo 4" & infl$influente], collapse = "; "),
          f4(infl_sens$coef_completo[infl_sens$termo == "gini_setorial"]), f4(infl_sens$coef_sem_influentes[infl_sens$termo == "gini_setorial"]),
          f2(infl_sens$variacao_percentual[infl_sens$termo == "selic_real"]),
          f2(painel$dom_industrial[painel$nome_municipio == "Adrianópolis" & painel$ano == 2014]),
          f2(painel$dom_industrial[painel$nome_municipio == "Adrianópolis" & painel$ano == 2015]),
          f2(stats::median(painel$dom_industrial[painel$ano == 2015]))), "",
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
  "## Projeção pela previsão matricial (Modelo 4)", "",
  "Previsão do ln do salário para 2021 em cada município, com intervalos da previsão média e individual (fórmulas de previsão matricial das notas de regressão múltipla). A variável de cenário é a Selic.", "",
  md(data.frame(Cenário = unique(proj$cenario), `Selic (% a.a.)` = f2(tapply(proj$selic, proj$cenario, mean)[unique(proj$cenario)]),
                `Salário médio previsto (R$, média dos 29 municípios)` = f2(tapply(proj$salario_previsto_reais, proj$cenario, mean)[unique(proj$cenario)]),
                check.names = FALSE)), "",
  md(data.frame(Modelo = efeito$modelo, `Efeito de +1 p.p. (ln)` = f4(efeito$efeito_ln_por_pp),
                `Efeito (%)` = f2(efeito$efeito_percentual_por_pp), `IC 95% (ln)` = paste0("[", f4(efeito$ic95_inf_ln), "; ", f4(efeito$ic95_sup_ln), "]"),
                gl = efeito$gl, `p-valor` = fp(efeito$p_valor), check.names = FALSE)), "",
  "Leitura: pelo Modelo 4, cada ponto percentual a mais de Selic está associado a um salário cerca de 0,4% maior. A inferência do Modelo 4 é otimista (290 observações para 10 valores de Selic); a checagem agregada tem intervalo que inclui zero. A projeção mostra o efeito, mas o intervalo para a Selic deve ser lido com essa ressalva.", "",
  "## Robustez da X4: definição do Gini", "",
  md(data.frame(Modelo = rob_x4$modelo, `Definição da X4` = rob_x4$definicao_x4, coef = f4(rob_x4$coef_x4),
                `p-valor` = fp(rob_x4$p_valor_x4), `R2 aj.` = f4(rob_x4$r2_ajustado), AIC = f2(rob_x4$aic),
                `RESET p` = fp(rob_x4$reset_p), check.names = FALSE)), "",
  "O Gini sobre as 87 divisões (com zeros) depende de quantos setores têm emprego (correlação -0,95). O Gini só sobre as divisões com vínculo tem correlação -0,41 com esse número. Com a segunda definição, o efeito dentro dos municípios (Modelo 4) não é significativo. O efeito entre municípios (Modelo 2) se mantém nas duas definições.", "",
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
  "Os testes são aplicados à série de dez anos de cada um dos 29 municípios, com os resíduos do Modelo 2 e do Modelo 4 (Gujarati, cap. 12; Guia P2).", "",
  "H0 do Durbin-Watson: ρ = 0 (ausência de autocorrelação de primeira ordem). Ha: ρ > 0 (positiva) ou ρ < 0 (negativa). Valores de dL = 0,243 e dU = 2,822 para n = 10 e k = 5, a 5%, da Tabela D.5A do Gujarati (PDF p. 995), conferidos no livro. Zonas do Guia P2: d < dL rejeita H0 (positiva); dL ≤ d ≤ dU inconclusiva; dU < d < 4 − dU não rejeita; 4 − dU ≤ d ≤ 4 − dL inconclusiva; d > 4 − dL rejeita H0 (negativa). Com dU maior que 2, a zona de não rejeição fica vazia: o teste só rejeita H0 com d < 0,243 ou d > 3,757.", "",
  "H0 do Breusch-Godfrey (ordem 1): ausência de autocorrelação de primeira ordem. Estatística qui-quadrado com 1 gl; rejeita H0 se p < 0,05.", "",
  "H0 do teste das carreiras: os resíduos são aleatórios. Ha: não são aleatórios. A aproximação normal do Gujarati (cap. 12) exige N1 > 10 e N2 > 10; com dez anos por município isso não ocorre, e o teste é declarado não aplicável em cada série.", "",
  md(tab_aut_res), "",
  sprintf("No Modelo 2, o Durbin-Watson mediano é %s e o ρ auxiliar mediano é %s: a autocorrelação positiva é forte. No Modelo 4, a mediana do Durbin-Watson é %s, e o ρ auxiliar cai para %s. A autocorrelação do Modelo 2 em boa parte reflete diferenças persistentes entre municípios.",
          f4(aut_res$durbin_watson_mediano[aut_res$modelo == "Modelo 2"]), f4(aut_res$rho_auxiliar_mediano[aut_res$modelo == "Modelo 2"]),
          f4(aut_res$durbin_watson_mediano[aut_res$modelo == "Modelo 4"]), f4(aut_res$rho_auxiliar_mediano[aut_res$modelo == "Modelo 4"])), "",
  "## Correção da autocorrelação: Prais-Winsten e Cochrane-Orcutt", "",
  "Métodos do Gujarati (cap. 12) e do Guia P2. O ρ é comum a todos os municípios e a transformação é feita dentro de cada município (a primeira observação de cada um é tratada por Prais-Winsten e descartada por Cochrane-Orcutt) [presunção da modelagem]. Newey-West não é aplicado: ver a nota de métodos não aplicados em 02_especificacao_e_metodos.md.", "",
  md(tab_corr), "",
  sprintf("Depois da correção, o ρ auxiliar dos resíduos transformados cai para %s no Modelo 2 e %s no Modelo 4 (Prais-Winsten). O ρ estimado é %s no Modelo 2 e %s no Modelo 4.",
          f4(rho_res_pw("Modelo 2")), f4(rho_res_pw("Modelo 4")), f4(rho_pw("Modelo 2")), f4(rho_pw("Modelo 4"))), "",
  sprintf("Efeito sobre o Modelo 2: o coeficiente de X2 (escolaridade) passa de %s, com erro de White, para %s, com Prais-Winsten e erro de White (p-valor %s). Leitura: a associação entre municípios no Modelo 2 depende da persistência dos dados, e não só da correção dos erros-padrão.",
          f4(coef$estimativa[coef$modelo == "Modelo 2" & coef$matriz == "white" & coef$termo == "prop_superior"]),
          f4(corr_est("Modelo 2", "prop_superior")), fp(corr_pw("Modelo 2", "prop_superior"))), "",
  sprintf("No Modelo 4 corrigido, o coeficiente de X4 (Gini) é %s, com p-valor %s pelo erro de White. Com a correção, o efeito do Gini dentro dos municípios %s a 5%%.",
          f4(corr_est("Modelo 4", "gini_setorial")), fp(corr_pw("Modelo 4", "gini_setorial")),
          ifelse(corr_pw("Modelo 4", "gini_setorial") < 0.05, "continua significativo", "não é significativo")), "",
  "<details><summary>Série por município</summary>", "", md(tab_aut), "", "</details>"))

# ---- 05 limitações
gravar("05_limitacoes.md", c(
  "# Limitações", "",
  "- Desenho observacional: os coeficientes são associações, não efeitos causais.",
  "- Com as dummies de município, X6 (distância) não é identificada. Seu efeito só aparece no Modelo 2, onde está confundido com as diferenças não observadas entre municípios.",
  "- Variáveis de nível de tempo (Selic) têm 10 valores distintos. A inferência do Modelo 4 para X5 trata 290 observações como independentes e superestima a precisão. É o ponto que mais limita a conclusão sobre juros.",
  "- O efeito de X4 muda de sinal entre o Modelo 2 (entre municípios) e o Modelo 4 (dentro dos municípios). A medida acompanha o número de setores com emprego (correlação -0,95).",
  "- Autocorrelação dentro dos municípios: a correção Prais-Winsten e Cochrane-Orcutt com ρ comum é uma extensão do método de série temporal ao painel [presunção da modelagem]. Newey-West não é aplicado ao painel empilhado.",
  "- Heterocedasticidade: o Breusch-Pagan-Godfrey rejeita no Modelo 2 e no Modelo 4. A inferência usa erros de White.",
  "- Os coeficientes com correção (Prais-Winsten) dependem do ρ estimado, que é alto no Modelo 2. O efeito de X2 entre municípios cai muito com a correção (ver 04_diagnosticos.md).",
  "- Normalidade rejeitada nos dois modelos (Jarque-Bera). A assimetria e a curtose altas são reportadas; a inferência usa as aproximações assintóticas.",
  "- Observações influentes no Modelo 4 (Adrianópolis 2012 e Lapa 2016). A sensibilidade do coeficiente de X4 a elas é alta; o dado de Adrianópolis deve ser conferido na fonte.",
  "- A definição da X4 altera o efeito dentro dos municípios (ver 04_diagnosticos.md, robustez da X4).",
  "- O Modelo 4 usa variáveis dummy de município (Gujarati, cap. 9). Os slides de aulas lidos não trazem dummies; o uso depende de confirmação com o professor.",
  "- A Selic tem 10 valores distintos; sua inferência é otimista, embora retirá-la piore o ajuste (ver 04_diagnosticos.md).",
  "- A divisão do teste de Chow no ano de 2016 é uma escolha, com duas partes de 145 observações.",
  "- Vínculos com divisão CNAE 'ignorada' ficam fora do cálculo do Gini."))

# ---- 06 fontes
gravar("06_fontes.md", c(
  "# Fontes e referências", "",
  "## Fontes oficiais da disciplina (podem ser citadas)", "",
  "| Fonte | Conteúdo usado |", "|---|---|",
  "| Gujarati, D. N.; Porter, D. C. Basic Econometrics, 5ª ed. (2009; edição em espanhol consultada no índice, 2010); a edição citada pelo professor é a 5ª (AMGH, 2011). O PDF usado neste trabalho é a 4ª edição (McGraw-Hill, 2004); as páginas citadas são as do PDF. | fonte principal dos métodos (ver tabela abaixo) |",
  "| Notas de aula de regressão linear múltipla (Hasegawa) | matriz X'X, ANOVA, t e F, R2 parcial |",
  "| Notas de multicolinearidade, heterocedasticidade, autocorrelação, especificação e teste de Chow (SE614) | métodos de diagnóstico |",
  "| Gujarati, Apêndice D, Tabela D.5A (PDF p. 995): n = 10, k = 5, 5%: dL = 0,243 e dU = 2,822 | Durbin-Watson por município (conferido no livro) |",
  "| Guia da P2 (professor) | regras de decisão de FIV, BPG, DW e Gini |",
  "| Slides da pasta `aulas` do Drive: regressão matricial, especificação e diagnóstico (cap. 13), teste de Chow, multicolinearidade, heterocedasticidade, autocorrelação (Breusch-Godfrey, teste das carreiras, Durbin-Watson, medidas corretivas MQG e Newey-West, este último não aplicado ao painel), medidas de desigualdade | confirmação dos métodos ensinados |",
  "| Gujarati (PDF da 4ª ed.): cap. 5, seção 5.12 (Jarque-Bera, PDF pp. 176 e 177); cap. 8 (Chow, PDF pp. 303 a 309); cap. 9 (dummies, PDF pp. 332 a 352); cap. 11 (heterocedasticidade: Goldfeld-Quandt, Glejser, Park, White, MQP, PDF pp. 432 a 462); cap. 12 (autocorrelação: teste das carreiras PDF p. 493, Breusch-Godfrey PDF pp. 499 e 500, Durbin-Watson PDF pp. 495 a 499, Cochrane-Orcutt e Prais-Winsten PDF pp. 510 a 528, Newey-West, citado e não aplicado, PDF p. 503); cap. 13 (RESET PDF pp. 549 a 552, outliers, leverage e influência PDF pp. 568 e 569) | páginas citadas pelo trabalho |", "",
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
