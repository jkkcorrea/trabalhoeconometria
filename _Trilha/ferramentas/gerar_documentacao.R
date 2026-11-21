# Gera a documentação da pasta de envio a partir dos arquivos de resultado.
# Uso (a partir da raiz do projeto): Rscript _Trilha/ferramentas/gerar_documentacao.R
# Todo número vem de dados_processados/ ou resultados_econometricos/ da pasta de envio.

DIR <- "envio_professor"
if (!dir.exists(DIR)) stop("Pasta de envio não encontrada: ", DIR)
DOC <- file.path(DIR, "documentacao")
dir.create(DOC, showWarnings = FALSE)
suppressPackageStartupMessages({library(dplyr); library(sandwich); library(lmtest)})

# ----------------------------------------------------------------- utilitários
f4 <- function(x) ifelse(is.na(x), "", ifelse(x != 0 & abs(x) < 5e-5, formatC(x, format = "e", digits = 3, decimal.mark = ","),
                                            formatC(x, format = "f", digits = 4, decimal.mark = ",", big.mark = ".")))
f2 <- function(x) ifelse(is.na(x), "", formatC(x, format = "f", digits = 2, decimal.mark = ",", big.mark = "."))
f0 <- function(x) formatC(x, format = "d", big.mark = ".", decimal.mark = ",")
fpv <- function(p) ifelse(p < 1e-4, "p-valor < 0,0001", paste0("p-valor = ", formatC(p, format = "f", digits = 4, decimal.mark = ",")))
fp <- function(p) ifelse(is.na(p), "", ifelse(p < 1e-4, "< 0,0001", formatC(p, format = "f", digits = 4, decimal.mark = ",")))
pct <- function(b) f2(100 * (exp(b) - 1))
md <- function(df) {
  df[] <- lapply(df, as.character)
  cab <- paste0("| ", paste(names(df), collapse = " | "), " |")
  sep <- paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|")
  linhas <- apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |"))
  c(cab, sep, linhas, "")
}
ler <- function(pasta, arq) read.csv(file.path(DIR, pasta, arq), check.names = FALSE, stringsAsFactors = FALSE, encoding = "UTF-8")
res <- function(arq) ler("resultados_econometricos", arq)
dp  <- function(arq) ler("dados_processados", arq)
gravar <- function(nome, linhas) writeLines(linhas, file.path(DOC, nome), useBytes = TRUE)

painel <- readRDS(file.path(DIR, "dados_processados", "dados_painel_rmc.rds")) |> as.data.frame()
painel <- painel[order(painel$id_municipio, painel$ano), ]
stopifnot(nrow(painel) == 290L)

# ------------------------------------------------------------ modelos ajustados
f_m2  <- ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao + selic_real + dist_curitiba_km
m1  <- lm(salario_medio_real ~ prop_superior, painel)
m2  <- lm(f_m2, painel)
m3  <- update(m2, . ~ . + dummy_curitiba)
m3b <- update(m3, . ~ . + dom_industrial:dist_curitiba_km)
min_eig_3b <- tryCatch(min(eigen(sandwich::vcovCL(m3b, cluster = painel[, c("id_municipio", "ano")], type = "HC1", multi0 = FALSE), symmetric = TRUE, only.values = TRUE)$values), error = function(e) NA_real_)
resumo_modelo <- function(m) {
  s <- summary(m)
  c(n = nobs(m), k = length(coef(m)), r2 = s$r.squared, r2aj = s$adj.r.squared,
    F = unname(s$fstatistic[1]), gl1 = unname(s$fstatistic[2]), gl2 = unname(s$fstatistic[3]),
    pF = unname(pf(s$fstatistic[1], s$fstatistic[2], s$fstatistic[3], lower.tail = FALSE)), s = s$sigma)
}
rotulo_termo <- c(`(Intercept)` = "Intercepto", prop_superior = "X2 ensino superior (%)", dom_industrial = "X3 dominância industrial (%)",
                  shannon_diversificacao = "X4 diversificação (Shannon)", selic_real = "X5 Selic real (% a.a.)",
                  dist_curitiba_km = "X6 distância a Curitiba (km)", dummy_curitiba = "Indicadora de Curitiba",
                  `dom_industrial:dist_curitiba_km` = "X3 x X6 (interação)", media_prop = "Média por município de X2",
                  media_dom = "Média por município de X3", media_shannon = "Média por município de X4",
                  dom_c = "X3 centrada", dist_c = "X6 centrada", `dom_c:dist_c` = "X3 x X6 centradas", tendencia = "Tendência (ano - 2012)")
rot <- function(x) ifelse(x %in% names(rotulo_termo), rotulo_termo[x], x)

# =============================================================================
# 01. Dados e variáveis
# =============================================================================
mun <- painel |> distinct(id_municipio, nome_municipio) |> arrange(nome_municipio) |> mutate(numero = row_number())
tab_mun <- data.frame(Número = mun$numero, `Código IBGE` = mun$id_municipio, Município = mun$nome_municipio, check.names = FALSE)

dic <- data.frame(
  Símbolo = c("Y", "ln Y", "X2", "X3", "X4", "X5", "X6", "Indicadora", "x3_negativo", "shannon_normalizado"),
  `Nome no painel` = c("salario_medio_real", "ln_salario_real", "prop_superior", "dom_industrial", "shannon_diversificacao",
                       "selic_real", "dist_curitiba_km", "dummy_curitiba", "x3_negativo", "shannon_normalizado"),
  Definição = c(
    "Remuneração média nominal dos vínculos ativos em 31/12, multiplicada pelo fator de deflação (índice acumulado do IPCA, média anual, base 2021). Reais de 2021.",
    "Logaritmo natural de Y.",
    "Vínculos ativos com superior completo, mestrado ou doutorado, divididos pelos vínculos ativos com escolaridade informada, em %.",
    "Valor adicionado bruto da indústria dividido pelo valor adicionado bruto total (soma dos quatro setores), em %.",
    "Entropia de Shannon, -soma(p ln p), da distribuição dos vínculos ativos pelas divisões da CNAE 2.0 (87 divisões).",
    "Selic real anual pela equação de Fisher: ((1 + Selic)/(1 + IPCA) - 1) x 100, com Selic e IPCA do ano compostos a partir dos 12 valores mensais.",
    "Distância em km entre o centroide do município e o centroide de Curitiba, em SIRGAS 2000 / UTM 22S (EPSG 31982).",
    "1 para Curitiba, 0 para os demais.",
    "Verdadeiro quando X3 < 0 (valor adicionado da indústria negativo na fonte).",
    "X4 dividido por ln(87); varia entre 0 e 1."),
  Fonte = c("RAIS (Ministério do Trabalho); IPCA, SGS/Banco Central, série 433", "derivada", "RAIS (Ministério do Trabalho)",
            "PIB dos Municípios, IBGE (SIDRA, tabela 5938)", "RAIS (Ministério do Trabalho)",
            "Banco Central, SGS, séries 4390 (Selic) e 433 (IPCA)", "Malha municipal do IBGE", "derivada", "derivada", "derivada"),
  `Varia em` = c("município e ano", "município e ano", "município e ano", "município e ano", "município e ano",
                 "ano (igual para todos os municípios)", "município (constante no tempo)", "município", "município e ano", "município e ano"),
  check.names = FALSE)

desc <- dp("estatisticas_descritivas.csv")
rot_var <- c(salario_medio_real = "Y salário médio real (R$ de 2021)", ln_salario_real = "ln Y", prop_superior = "X2 ensino superior (%)",
             dom_industrial = "X3 dominância industrial (%)", shannon_diversificacao = "X4 diversificação (Shannon)",
             shannon_normalizado = "X4 normalizado (0 a 1)", selic_real = "X5 Selic real (% a.a.)", dist_curitiba_km = "X6 distância (km)")
t_desc <- data.frame(Variável = rot_var[desc$variavel], N = desc$n, Média = f4(desc$media), `Desvio-padrão` = f4(desc$desvio_padrao),
                     Mediana = f4(desc$mediana), Mínimo = f4(desc$minimo), Máximo = f4(desc$maximo), check.names = FALSE)

vars6 <- c("ln_salario_real", "prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real", "dist_curitiba_km")
cm <- cor(painel[, vars6])
t_cor <- data.frame(Variável = c("ln Y", "X2", "X3", "X4", "X5", "X6"), f4(cm), check.names = FALSE)
names(t_cor)[-1] <- c("ln Y", "X2", "X3", "X4", "X5", "X6")
t_cor[-1] <- lapply(t_cor[-1], as.character)
neg <- painel[painel$x3_negativo, c("nome_municipio", "ano", "dom_industrial")]
t_neg <- data.frame(Município = neg$nome_municipio, Ano = neg$ano, `X3 (%)` = f4(neg$dom_industrial), check.names = FALSE)
n_selic <- length(unique(round(painel$selic_real, 8)))
sel_ano <- painel |> distinct(ano, selic_real) |> arrange(ano)
t_selic <- data.frame(Ano = sel_ano$ano, `Selic real (% a.a.)` = f4(sel_ano$selic_real), check.names = FALSE)

gravar("01_dados_e_variaveis.md", c(
"# Dados e variáveis",
"",
"## Escopo",
"",
sprintf("- Unidades: %d municípios da Região Metropolitana de Curitiba (composição oficial, código 05501 da API de localidades do IBGE).", n_distinct(painel$id_municipio)),
sprintf("- Período: %d a %d (%d anos).", min(painel$ano), max(painel$ano), n_distinct(painel$ano)),
sprintf("- Observações: %d (painel balanceado, %d municípios x %d anos), sem valores ausentes nas variáveis do modelo.", nrow(painel), n_distinct(painel$id_municipio), n_distinct(painel$ano)),
"- Unidade de análise: município-ano.",
"",
"## Municípios (numeração usada nos mapas)",
"",
md(tab_mun),
"## Dicionário de variáveis",
"",
md(dic),
"Variação das variáveis explicativas:",
"",
sprintf("- X5 assume %d valores distintos, um por ano, iguais para todos os municípios.", n_selic),
"- X6 é constante no tempo dentro de cada município; Curitiba tem distância zero.",
"- X2, X3 e X4 variam entre municípios e no tempo.",
"",
"Selic real por ano:",
"",
md(t_selic),
"## Estatísticas descritivas",
"",
md(t_desc),
"## Correlação de Pearson entre as variáveis do modelo",
"",
md(t_cor),
sprintf("A correlação de X4 com X6 é %s, a maior em módulo entre as variáveis explicativas. X5 varia só no tempo e X6 só entre municípios, por isso a correlação entre elas é %s.",
        f4(cm["shannon_diversificacao", "dist_curitiba_km"]), f4(cm["selic_real", "dist_curitiba_km"])),
"",
"## Observações com valor adicionado da indústria negativo",
"",
"O valor publicado pelo IBGE para o valor adicionado bruto da indústria é negativo nas duas observações abaixo. O painel mantém o valor da fonte e as marca em `x3_negativo`; o Modelo 2 é reestimado sem elas como teste de robustez.",
"",
md(t_neg),
"## Construção do painel",
"",
"1. Remuneração média: média da remuneração média nominal entre os vínculos ativos em 31/12 com remuneração maior que zero, por município e ano (média simples, sem ponderar pelos meses trabalhados).",
"2. Escolaridade: vínculos com superior completo, mestrado ou doutorado (códigos 9, 10 e 11 da RAIS).",
"3. Divisão da CNAE 2.0: dois primeiros dígitos da classe de cinco dígitos. Todos os vínculos têm divisão válida (nenhum vínculo sem divisão) e o conjunto de divisões distintas observadas no período é 87.",
"4. Deflator: índice de preços com base 100 no primeiro mês da amostra, acumulando a variação mensal do IPCA (série 433); o valor anual é a média dos 12 meses; fator de deflação = índice de 2021 dividido pelo índice do ano.",
"5. Verificações do painel: 290 linhas, 29 municípios, 10 anos, sem duplicidade de município e ano, sem NA, NaN ou Inf nas variáveis do modelo, X5 constante entre municípios em cada ano, X6 constante no tempo em cada município, Curitiba com distância zero.",
"",
"Os arquivos `dados_processados/dados_painel_rmc.csv` e `.rds` contêm o painel completo, com as colunas auxiliares (`selic_nominal_ano`, `ipca_ano`, `indice_ipca_medio`, `vinculos_ativos`, `vinculos_superior`, `vinculos_escolaridade_na`, `pib`, `vab_total_soma`, `vab_industria`)."
))
write.csv(dic, file.path(DOC, "dicionario_variaveis.csv"), row.names = FALSE, fileEncoding = "UTF-8")

# =============================================================================
# 02. Especificação e métodos
# =============================================================================
ha_testes <- c("multicolinearidade severa", "heterocedasticidade", "heterocedasticidade", "variância crescente com a variável de ordenação (unilateral)",
               "autocorrelação de ordem 1 (bilateral)", "autocorrelação até a ordem 1", "resíduos não normais", "resíduos não normais",
               "forma funcional incorreta", "existem efeitos individuais", "existem efeitos individuais",
               "efeitos aleatórios inconsistentes", "alguma média por município com coeficiente não nulo",
               "autocorrelação de primeira ordem (modelo within)", "alguma defasagem futura com coeficiente não nulo", "algum quadrático com coeficiente não nulo",
               "forma de Y em nível ou em logaritmo rejeitada (razão de verossimilhança)", "coeficientes diferentes em Curitiba")
testes <- data.frame(
  Teste = c("Fator de inflação da variância (FIV)", "Breusch-Pagan-Godfrey (studentizado)", "White", "Goldfeld-Quandt",
            "Durbin-Watson", "Breusch-Godfrey", "Jarque-Bera", "Shapiro-Wilk", "RESET de Ramsey",
            "Teste F de efeitos individuais", "Breusch-Pagan de multiplicadores de Lagrange", "Hausman",
            "Mundlak", "Wooldridge e Breusch-Godfrey de painel", "Exogeneidade estrita", "Termos quadráticos conjuntos", "Box-Cox", "Chow (Curitiba)"),
  `H0` = c("sem multicolinearidade severa", "homocedasticidade", "homocedasticidade", "homocedasticidade",
           "sem autocorrelação de ordem 1", "sem autocorrelação até a ordem 1", "resíduos normais", "resíduos normais",
           "forma funcional correta", "sem efeitos individuais", "sem efeitos individuais",
           "efeitos aleatórios consistentes", "médias por município com coeficientes nulos (efeito do município não correlacionado com X)",
           "sem autocorrelação de primeira ordem (modelo within)", "valores futuros de X2, X3 e X4 com coeficientes nulos", "quadráticos de X2, X3 e X4 com coeficientes nulos", "lambda igual a 0 (logaritmo) ou a 1 (nível)", "coeficientes de X2 a X5 iguais em Curitiba e nos demais"),
  Ha = ha_testes,
  `Critério a 5%` = c("FIV > 10 indica multicolinearidade severa (TOL < 0,10)", "rejeita H0 se p-valor < 0,05", "rejeita H0 se p-valor < 0,05",
                      "rejeita H0 se p-valor < 0,05", "rejeita H0 se p-valor < 0,05 (no painel empilhado o teste cruza fronteiras entre municípios)",
                      "rejeita H0 se p-valor < 0,05", "rejeita H0 se p-valor < 0,05", "rejeita H0 se p-valor < 0,05", "rejeita H0 se p-valor < 0,05",
                      "rejeita H0 se p-valor < 0,05", "rejeita H0 se p-valor < 0,05", "rejeita H0 se p-valor < 0,05; rejeição favorece efeitos fixos",
                      "rejeita H0 se p-valor < 0,05; rejeição indica que o MQO empilhado é viesado nas variáveis que variam no tempo",
                      "rejeita H0 se p-valor < 0,05", "rejeita H0 se p-valor < 0,05; rejeição indica retroalimentação ou antecipação", "rejeita H0 se p-valor < 0,05 (F com 3 e 28 gl)", "rejeita H0 se a razão de verossimilhança excede o qui-quadrado de 1 gl (3,8415)", "rejeita H0 se p-valor < 0,05 (F com 5 e 280 gl, teste clássico)"),
  check.names = FALSE)

gravar("02_especificacao_e_metodos.md", c(
"# Especificação e métodos",
"",
"## Modelos estimados",
"",
"Notação: i indexa o município (i = 1, ..., 29), t o ano (2012 a 2021). X2 a X6 são definidas em `01_dados_e_variaveis.md`.",
"",
"| Modelo | Equação | Script |",
"|---|---|---|",
"| 1 | Y_it = b1 + b2 X2_it + u_it (nível) | 04 |",
"| 2 | ln Y_it = b1 + b2 X2_it + b3 X3_it + b4 X4_it + b5 X5_t + b6 X6_i + u_it | 04 |",
"| 3 | Modelo 2 + b7 D_Curitiba_i | 04 |",
"| 3b | Modelo 3 + b8 (X3_it x X6_i) | 04 |",
"| 3c | Modelo 3b com X3 e X6 centradas nas médias amostrais | 05 |",
"| 4 | Modelo 2 + b7 Tendência_t (ano - 2012) | 05 |",
"| Mundlak | Modelo 2 + g2 mean_i(X2) + g3 mean_i(X3) + g4 mean_i(X4) | 05 e 06 |",
"| Efeitos fixos (within) | ln Y_it = a_i + b2 X2_it + b3 X3_it + b4 X4_it + b5 X5_t + u_it | 06 |",
"| Efeitos fixos de município e ano | ln Y_it = a_i + l_t + b2 X2_it + b3 X3_it + b4 X4_it + u_it | 06 |",
"| Prais-Winsten | Modelo 2 transformado por (y_t - r y_t-1) dentro de cada município, com a primeira observação multiplicada por raiz(1 - r^2); r comum, iterado até convergir | 06 |",
"| Primeiras diferenças | d ln Y_it = c + b2 d X2_it + b3 d X3_it + b4 d X4_it + b5 d X5_t + e_it | 06 |",
"| Efeitos fixos com quadráticos | ln Y_it = a_i + b2 X2_it + b3 X3_it + b4 X4_it + b5 X5_t + c2 X2_it^2 + c3 X3_it^2 + c4 X4_it^2 + u_it | 08 |",
"| Efeitos fixos com valores futuros | Efeitos fixos linear + d2 X2_i,t+1 + d3 X3_i,t+1 + d4 X4_i,t+1 (teste de exogeneidade estrita) | 08 |",
"| Efeitos fixos com regressores defasados | ln Y_it = a_i + b2 X2_i,t-1 + b3 X3_i,t-1 + b4 X4_i,t-1 + b5 X5_t + u_it | 08 |",
"",
"No modelo de efeitos fixos, X6 e a indicadora de Curitiba são absorvidas pelo efeito de município; no modelo com efeitos de ano, X5 também é absorvida. O modelo de Mundlak preserva X5 e X6 e estima, para X2, X3 e X4, os mesmos coeficientes do modelo de efeitos fixos.",
"",
"## Estimação por mínimos quadrados ordinários",
"",
"Estimador b = (X'X)^-1 X'y; soma dos quadrados dos resíduos SQR = y'y - b'X'y; variância estimada s^2 = SQR/(n - k); matriz de variância e covariância clássica s^2 (X'X)^-1. O cálculo matricial completo do Modelo 2 está em `resultados_econometricos/memorial_modelo_2.txt`, conferido contra `lm()`.",
"",
"## Matrizes de covariância dos estimadores",
"",
"- Clássica: s^2 (X'X)^-1.",
"- White (HC1): corrige heterocedasticidade de forma desconhecida.",
"- Newey-West: corrige heterocedasticidade e autocorrelação de uma única série temporal; no painel empilhado serve apenas como referência, porque cruza fronteiras entre municípios (28 pares de observações vizinhas pertencem a municípios diferentes).",
"- Agrupada por município (HC1): robusta a heterocedasticidade e a correlação arbitrária dentro de cada município. Fórmula: G/(G-1) x (n-1)/(n-k) x (X'X)^-1 [soma dos X_g' e_g e_g' X_g] (X'X)^-1, com G = 29. Os testes t usam G - 1 = 28 graus de liberdade nas tabelas de calibração (script 06) e os graus de liberdade residuais nas tabelas do script 04.",
"- Agrupada por município e ano: dois eixos, tipo HC1.",
"- Agrupada por ano (G = 10, t com 9 graus de liberdade): usada apenas para X5, porque X5 varia só entre anos e a dependência entre municípios no mesmo ano não é captada pelo agrupamento por município.",
"",
"## Testes e regras de decisão (nível de significância de 5%)",
"",
md(testes),
"## Bootstrap wild cluster",
"",
"Procedimento restrito de Cameron, Gelbach e Miller (2008) com pesos de Rademacher: para H0: b_j = 0, estima o modelo sem a variável j, gera y* = ajustado_restrito + w_g x resíduo_restrito, com w_g igual a -1 ou +1 por município, reestima o modelo completo e compara a estatística t agrupada de cada réplica com a observada. 9.999 réplicas, 29 clusters, semente fixa. Implementação própria em `R/06_calibracao_modelo.R`. Com 10 grupos (Selic por ano) usam-se também o bootstrap exato, com as 2^10 combinações de sinais, e o bootstrap com pesos de Webb (seis pontos, 9.999 réplicas), que é o padrão com poucos grupos; em cada réplica de um modelo within a variável dependente é transformada de novo por município.",
"",
"## Convenções",
"",
"- Nível de significância: 5%.",
"- Valores em quatro casas decimais nas tabelas desta documentação; os arquivos CSV trazem a precisão completa.",
"- Coeficientes de modelos em ln Y: a variação percentual aproximada de Y associada a uma unidade de X é 100 x (exp(b) - 1)."
))

# =============================================================================
# 03. Resultados dos modelos clássicos
# =============================================================================
cinco <- res("coeficientes_cinco_matrizes.csv")
tab_modelo <- function(nome, m) {
  cl <- cinco |> filter(modelo == nome, matriz == "Clássico (MQO)")
  ag <- cinco |> filter(modelo == nome, matriz == "Agrupado por município")
  data.frame(Termo = rot(cl$termo), Estimativa = f4(cl$estimativa), `EP clássico` = f4(cl$erro_padrao), `t clássico` = f4(cl$estatistica_t),
             `p clássico` = fp(cl$p_valor), `EP agrupado` = f4(ag$erro_padrao), `t agrupado` = f4(ag$estatistica_t),
             `p agrupado` = fp(ag$p_valor),
             `Variação % de Y` = ifelse(cl$termo %in% c("(Intercept)", "dom_industrial:dist_curitiba_km"), "", pct(cl$estimativa)), check.names = FALSE)
}
tab1 <- {
  s <- summary(m1)$coefficients
  data.frame(Termo = c("Intercepto", "X2 ensino superior (%)"), Estimativa = f4(s[, 1]), `EP clássico` = f4(s[, 2]),
             `t clássico` = f4(s[, 3]), `p clássico` = fp(s[, 4]), check.names = FALSE)
}
resumo_tab <- function(m, nome) {
  r <- resumo_modelo(m)
  data.frame(Modelo = nome, N = f0(r["n"]), Parâmetros = f0(r["k"]), `R²` = f4(r["r2"]), `R² ajustado` = f4(r["r2aj"]),
             `F (gl)` = paste0(f4(r["F"]), " (", r["gl1"], "; ", r["gl2"], ")"), `p do F` = fp(r["pF"]), `Erro-padrão residual` = f4(r["s"]), check.names = FALSE)
}
t_resumo <- bind_rows(resumo_tab(m1, "1 (Y em nível)"), resumo_tab(m2, "2"), resumo_tab(m3, "3"), resumo_tab(m3b, "3b"))
diag <- res("diagnosticos_modelo_2.csv")
ha_de <- function(teste) ifelse(grepl("Breusch-Pagan|White", teste), "heterocedasticidade",
  ifelse(grepl("Durbin-Watson empilhado|Durbin-Watson \\(", teste), "autocorrelação de ordem 1 (bilateral)",
  ifelse(grepl("Breusch-Godfrey", teste), "autocorrelação até a ordem 1",
  ifelse(grepl("Jarque|Shapiro", teste), "resíduos não normais",
  ifelse(grepl("RESET", teste), "forma funcional incorreta", "")))))
valor_critico <- function(gl_txt, nome_est) {
  v <- suppressWarnings(as.numeric(unlist(regmatches(gl_txt, gregexpr("[0-9]+", gl_txt)))))
  if (grepl("RESET", nome_est) && length(v) >= 2) return(qf(0.95, v[1], v[2]))
  if (grepl("^df = ", gl_txt) && length(v) == 1) return(qchisq(0.95, v[1]))
  NA_real_
}
vc <- mapply(valor_critico, as.character(diag$graus_liberdade), as.character(diag$nome_estatistica), USE.NAMES = FALSE)
t_diag <- data.frame(Bloco = diag$bloco, Teste = diag$teste, H0 = diag$hipotese_nula, Ha = ha_de(diag$teste), Estatística = f4(diag$estatistica),
                     `Valor crítico (5%)` = f4(vc), `Graus de liberdade` = diag$graus_liberdade,
                     `p-valor` = fp(diag$p_valor), `Decisão a 5%` = diag$decisao_5pct, check.names = FALSE)
fiv <- res("fiv_modelos_2_3_3b.csv")
t_fiv <- data.frame(Modelo = fiv$modelo, Termo = rot(fiv$termo), FIV = f4(fiv$fiv), Tolerância = f4(fiv$tolerancia),
                    `FIV > 10` = ifelse(fiv$severa, "sim", "não"), check.names = FALSE)
fr <- res("teste_f_global_robusto.csv")
t_fr <- data.frame(Modelo = fr$modelo, Matriz = fr$matriz, Hipótese = fr$hipotese, F = f4(fr$estatistica_f),
                   `gl` = paste0(fr$gl_numerador, "; ", fr$gl_denominador), `p-valor` = fp(fr$p_valor), check.names = FALSE)
sx <- res("robustez_modelo_2_sem_x3_negativo.csv")
t_sx <- data.frame(Termo = rot(sx$termo), `Coef. amostra completa` = f4(sx$coef_completo), `EP agrupado` = f4(sx$ep_agrupado_completo),
                   `Coef. sem x3_negativo` = f4(sx$coef_sem_x3neg), `EP agrupado` = f4(sx$ep_agrupado_sem_x3neg),
                   `Variação do coeficiente (%)` = f2(sx$variacao_coef_pct), check.names = FALSE)
sc <- res("selic_p_valor_conservador.csv")
sim <- res("simulacao_cenarios_renda.csv")
s1 <- sim |> filter(grepl("Cenário 1", cenario))
s2 <- sim |> filter(grepl("Cenário 2", cenario))
t_s1 <- data.frame(Município = s1$nome_municipio, `Salário previsto antes (R$)` = f2(s1$salario_prev_antes), `Salário previsto depois (R$)` = f2(s1$salario_prev_depois),
                   `Variação (%)` = f2(s1$variacao_pct), `IC 95% agrupado da variação (%)` = paste0("[", f2(s1$ic_inf_variacao_pct_agrupado), "; ", f2(s1$ic_sup_variacao_pct_agrupado), "]"), check.names = FALSE)
t_s2 <- data.frame(Medida = c("Municípios", "Variação média (%)", "Variação mínima (%)", "Variação máxima (%)"),
                   Valor = c(nrow(s2), f2(mean(s2$variacao_pct)), f2(min(s2$variacao_pct)), f2(max(s2$variacao_pct))))
mem_anova <- res("memorial_modelo_2_anova.csv")
mem_par <- res("memorial_modelo_2_determinacao_parcial.csv")
mem_inc <- res("memorial_modelo_2_f_incremental.csv")
mem_prev <- res("memorial_modelo_2_previsao.csv")
t_anova <- data.frame(Fonte = mem_anova$fonte, gl = mem_anova$graus_liberdade, `Soma de quadrados` = f4(mem_anova$soma_quadrados),
                      `Quadrado médio` = f4(mem_anova$quadrado_medio), F = f4(mem_anova$estatistica_f), `F crítico (5%)` = f4(mem_anova$F_critico_5pct),
                      `p-valor` = fp(mem_anova$p_valor), check.names = FALSE)
t_par <- data.frame(Variável = mem_par$variavel, t = f4(mem_par$estatistica_t), `r² parcial` = f4(mem_par$r2_parcial), check.names = FALSE)
t_inc <- data.frame(Bloco = mem_inc$bloco, m = mem_inc$restricoes, F = f4(mem_inc$estatistica_f), `F crítico (5%)` = f4(mem_inc$F_critico_5pct),
                    `p-valor` = fp(mem_inc$p_valor), Decisão = mem_inc$decisao, check.names = FALSE)
t_prev <- data.frame(Cenário = mem_prev$cenario, `ln previsto` = f4(mem_prev$ln_previsto),
                     `IC 95% da média` = paste0("[", f4(mem_prev$ic_media_inf), "; ", f4(mem_prev$ic_media_sup), "]"),
                     `IC 95% individual` = paste0("[", f4(mem_prev$ic_individual_inf), "; ", f4(mem_prev$ic_individual_sup), "]"), check.names = FALSE)

gravar("03_resultados_modelos_classicos.md", c(
"# Resultados dos modelos clássicos (script 04 e memorial do script 07)",
"",
"Todas as tabelas foram geradas a partir dos arquivos de `resultados_econometricos/`. As colunas \"clássico\" usam s^2 (X'X)^-1; as \"agrupado\", a matriz agrupada por município (HC1). Nesta seção os p-valores agrupados usam os graus de liberdade residuais do `coeftest`; as tabelas de calibração (`04_calibracao.md`) usam 28 graus de liberdade.",
"",
"## Ajuste dos modelos",
"",
md(t_resumo),
"## Modelo 1 (nível)",
"",
md(tab1),
"## Modelo 2",
"",
md(tab_modelo("Modelo 2")),
"## Modelo 3 (com indicadora de Curitiba)",
"",
md(tab_modelo("Modelo 3")),
"Nos Modelos 3 e 3b a indicadora isola um único município e os resíduos de Curitiba somam zero; o erro-padrão robusto da indicadora não é confiável. Por isso o teste F sob matrizes robustas exclui a indicadora da hipótese (tabela de testes F abaixo); o F clássico mantém todas as inclinações.",
"",
"## Modelo 3b (com interação X3 x X6, sem centralizar)",
"",
md(tab_modelo("Modelo 3b")),
"## Diagnósticos do Modelo 2",
"",
md(t_diag),
"Observação: o Durbin-Watson e o Breusch-Godfrey do painel empilhado tratam as 290 linhas como uma única série e cruzam fronteiras entre municípios; a evidência válida de autocorrelação está em `04_calibracao.md` (autocorrelação dentro do município e testes de painel).",
"",
sprintf("Notas: (1) o White completo tem 20 graus de liberdade e inclui X5, que só varia no tempo, e X6, que só varia entre municípios; (2) a matriz de dois eixos (município e ano) do Modelo 3b não é semidefinida positiva (menor autovalor %s), de modo que o erro da interação e o F robusto dessa coluna são pouco confiáveis; além disso o agrupamento por ano tem só 10 grupos; (3) o Goldfeld-Quandt unilateral (variância crescente) ordenado por vínculos rejeita a 5%% (%s) e ordenado por X2 e X3 não rejeita; ele testa uma ordenação específica e tem menos poder contra outras formas de heterocedasticidade que o Breusch-Pagan e o White.", formatC(min_eig_3b, format = "e", digits = 2, decimal.mark = ","), fpv(res("calibracao_goldfeld_quandt.csv")$p_valor[1])),
"",
"## Multicolinearidade (FIV)",
"",
md(t_fiv),
"## Teste F de significância conjunta sob cada matriz",
"",
md(t_fr),
"## Robustez do Modelo 2 sem as observações com X3 negativo",
"",
md(t_sx),
"## P-valor da Selic real agrupado por ano (t com 9 graus de liberdade)",
"",
sprintf("Modelo 2: coeficiente %s, erro-padrão %s, t = %s, %s.", f4(sc$estimativa), f4(sc$erro_padrao), f4(sc$estatistica_t), fpv(sc$p_valor)),
"",
"## Memorial matricial do Modelo 2",
"",
"Quadro de análise de variância (Modelo 2):",
"",
md(t_anova),
"Coeficientes de determinação parcial (r² = t²/(t² + n - k)):",
"",
md(t_par),
"Teste F de contribuição incremental:",
"",
md(t_inc),
"Previsão de ln Y:",
"",
md(t_prev),
"## Simulação de cenários (Modelo 2, base 2021)",
"",
"Previsão da média na escala do log, retransformada por exp() com o fator de Duan (média de exp do resíduo). Intervalo de 95% pela matriz agrupada por município, t com 28 graus de liberdade.",
"",
"Cenário 1: aumento de 10 pontos percentuais em X3.",
"",
md(t_s1),
"Cenário 2: aumento de 5 pontos percentuais em X2 nos 29 municípios.",
"",
md(t_s2),
"A tabela completa está em `resultados_econometricos/simulacao_cenarios_renda.csv`."
))

# =============================================================================
# 04. Calibração
# =============================================================================
cal <- res("calibracao_coeficientes.csv")
t_cal <- cal |> filter(termo != "(Intercept)") |>
  transmute(Estimador = estimador, Termo = rot(termo), Estimativa = f4(estimativa), `EP agrupado` = f4(erro_padrao), t = f4(estatistica_t),
            `p-valor (t, 28 gl)` = fp(p_valor), `IC 95%` = paste0("[", f4(ic_inf_95), "; ", f4(ic_sup_95), "]"))
tp <- res("calibracao_testes_painel.csv")
ha_tp <- c("existem efeitos individuais", "existem efeitos individuais", "efeitos aleatórios inconsistentes", rep("alguma média por município com coeficiente não nulo", 2), "autocorrelação de primeira ordem", "autocorrelação de ordem 1")
t_tp <- data.frame(Teste = tp$teste, `H0` = tp$hipotese_nula, Ha = ha_tp, Estatística = f4(tp$estatistica), `gl` = tp$graus_liberdade, `p-valor` = fp(tp$p_valor), check.names = FALSE)
ac <- res("calibracao_autocorrelacao.csv")
t_ac <- data.frame(Modelo = ac$modelo, `rho dos resíduos no mesmo município` = f4(ac$rho_residuos_mesmo_municipio), `d aproximado = 2(1 - rho)` = f4(ac$d_aproximado), check.names = FALSE)
rs <- res("calibracao_reset.csv")
t_rs <- data.frame(Modelo = rs$modelo, F = f4(rs$estatistica_f), gl = paste0(rs$gl1, "; ", rs$gl2), `p-valor` = fp(rs$p_valor), `R² ajustado` = f4(rs$r2_ajustado), check.names = FALSE)
gq <- res("calibracao_goldfeld_quandt.csv")
t_gq <- data.frame(`Ordenado por` = gq$ordenado_por, F = f4(gq$estatistica_f), gl = paste0(gq$gl_numerador, "; ", gq$gl_denominador), `p-valor (unilateral)` = fp(gq$p_valor), `p-valor (bilateral)` = fp(gq$p_valor_bilateral), check.names = FALSE)
vt <- res("calibracao_variancia_tamanho.csv")
inf <- res("calibracao_influencia.csv")
t_inf <- head(inf, 8) |> transmute(Município = nome_municipio, Ano = ano, `Distância de Cook` = f4(cook), Alavancagem = f4(alavancagem), `Maior |DFBETAS|` = f4(max_dfbetas))
boot <- res("calibracao_bootstrap_wild_cluster.csv")
t_boot <- boot |> transmute(Estimador = estimador, Termo = rot(termo), t = f4(estatistica_t), `p-valor bootstrap` = fp(p_bootstrap))
sa <- res("calibracao_selic_agrupada_por_ano.csv")
t_sa <- data.frame(Estimador = sa$estimador, Estimativa = f4(sa$estimativa), `EP agrupado por ano` = f4(sa$erro_padrao), t = f4(sa$estatistica_t), `p-valor (t, 9 gl)` = fp(sa$p_valor), check.names = FALSE)
ra <- res("robustez_adicional_resumo.csv")
t_ra <- data.frame(Modelo = ra$modelo, N = ra$n, `R²` = f4(ra$r2), `p do RESET` = fp(ra$reset_p), check.names = FALSE)
rc <- res("robustez_adicional_coeficientes.csv")
t_rc <- rc |> filter(termo != "(Intercept)") |> transmute(Modelo = modelo, Termo = rot(termo), Estimativa = f4(estimativa), `EP agrupado` = f4(erro_padrao), `p-valor (t, 28 gl)` = fp(p_valor), `FIV ajustado` = f4(fiv_ajustado))
rm_ <- res("robustez_mundlak_teste_mundlak.csv")

b <- function(est, termo) cal$estimativa[cal$estimador == est & cal$termo == termo]
get_p <- function(est, termo) cal$p_valor[cal$estimador == est & cal$termo == termo]
E_P <- "MQO empilhado (Modelo 2)"; E_F <- "Efeitos fixos (within)"; E_M <- "Mundlak (efeitos aleatórios correlacionados)"; E_T <- "Efeitos fixos de município e ano"; E_D <- "Primeiras diferenças"; E_W <- "Prais-Winsten"
t_comp <- data.frame(
  Termo = rot(c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real")),
  `MQO empilhado` = f4(sapply(c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real"), \(t) b(E_P, t))),
  `Efeitos fixos` = f4(sapply(c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real"), \(t) b(E_F, t))),
  `Variação % de Y por unidade (MQO)` = pct(sapply(c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real"), \(t) b(E_P, t))),
  `Variação % de Y por unidade (efeitos fixos)` = pct(sapply(c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real"), \(t) b(E_F, t))),
  check.names = FALSE)
pw_obs <- cal$observacao[cal$estimador == E_W][1]
mund_g <- tp[grepl("Mundlak", tp$teste), ]

gravar("04_calibracao.md", c(
"# Calibração do modelo (scripts 05 e 06)",
"",
"O Modelo 2 (MQO empilhado) é a linha de base. Esta seção documenta os testes que verificam as hipóteses do modelo clássico sobre o Modelo 2 e as estimações que corrigem as violações encontradas. Todos os coeficientes desta seção usam erro-padrão agrupado por município (HC1) e t com 28 graus de liberdade, salvo indicação.",
"",
"## 1. Sequência lógica",
"",
"1. Diagnósticos do Modelo 2 (script 04): heterocedasticidade, autocorrelação, normalidade e forma funcional rejeitam H0 (ver `03_resultados_modelos_classicos.md`).",
"2. Verificação da origem da autocorrelação: o rho dos resíduos dentro do município é alto no MQO empilhado e só cai nos efeitos fixos, que retiram o efeito do município; no Mundlak, que o mantém no erro, o rho não cai (seção 5).",
"3. Testes de efeito de município (seção 4): todos rejeitam a ausência de efeito individual e a consistência do MQO empilhado.",
"4. Estimação com efeito de município (Mundlak, efeitos fixos) e comparação com o MQO empilhado (seções 2 e 3).",
"5. Inferência com poucos grupos: t com G - 1 graus de liberdade e bootstrap wild cluster (seção 8); X5 com agrupamento por ano (seção 9).",
"",
"## 2. Estimadores lado a lado",
"",
md(t_cal),
sprintf("Prais-Winsten: %s. Com rho próximo de 1 a transformação aproxima-se de primeiras diferenças e os coeficientes ficam muito abaixo dos do MQO empilhado; o resultado fica registrado, não é adotado como estimativa de referência. Com rho próximo de 1, a transformação deixa em X6 (constante no tempo) só a variação da primeira observação de cada município e do fator (1 - rho), então o coeficiente de X6 desse estimador é frágil. O rho é estimado em resíduos que contêm o efeito de município e reflete esse efeito, não um processo AR(1) puro.", pw_obs),
"",
"## 3. Comparação direta dos coeficientes (MQO empilhado e efeitos fixos)",
"",
md(t_comp),
"Figura: `figuras_graficos/calibracao_coeficientes_estimadores.png`.",
"",
"## 4. Testes de efeito de município e de autocorrelação em painel",
"",
md(t_tp),
"## 5. Autocorrelação dos resíduos dentro do município",
"",
md(t_ac),
sprintf("Há duas definições de rho nos arquivos, ambas sobre os resíduos do Modelo 2 e só entre linhas do mesmo município: (a) rho de regressão, soma(e_t e_t-1)/soma(e_t-1^2), usado nesta tabela (%s) e (b) correlação entre resíduos vizinhos, em `diagnosticos_modelo_2.csv` (%s). O d médio por município, média dos d de cada município, é %s e corresponde a um rho aproximado de %s. As três medidas indicam autocorrelação positiva forte e diferem por construção.",
        f4(ac$rho_residuos_mesmo_municipio[1]), f4(diag$estatistica[grepl("vizinhos", diag$teste)]), f4(diag$estatistica[grepl("médio por município", diag$teste)]), f4(1 - diag$estatistica[grepl("médio por município", diag$teste)] / 2)),
"",
"## 6. Forma funcional (RESET de Ramsey, potências 2 e 3)",
"",
md(t_rs),
"## 7. Heterocedasticidade e tamanho do município",
"",
md(t_gq),
sprintf("Regressão de ln(resíduo²) sobre ln(vínculos ativos), Modelo 2: correlação %s, inclinação %s, t = %s, %s. Uma inclinação próxima de -1 indicaria variância proporcional a 1/n e justificaria mínimos quadrados ponderados pelo número de vínculos. A inclinação estimada é positiva e significativa a 5%%: a variância dos resíduos cresce com o tamanho do município, o oposto do que essa ponderação supõe, e a correlação é baixa. O Goldfeld-Quandt unilateral (variância crescente), ordenado por vínculos, rejeita a 5%% (%s); o bilateral dá %s. A ponderação não foi adotada e a inferência usa erros-padrão robustos.",
        f4(vt$correlacao), f4(vt$inclinacao), f4(vt$estatistica_t), fpv(vt$p_valor), fpv(gq$p_valor[1]), fpv(gq$p_valor_bilateral[1])),
"",
"## 8. Bootstrap wild cluster (H0: coeficiente igual a zero; 9.999 réplicas)",
"",
md(t_boot),
"## 9. Selic real com erro agrupado por ano (10 grupos, t com 9 graus de liberdade)",
"",
md(t_sa),
"## 10. Observações influentes (Modelo 2)",
"",
sprintf("Referências: distância de Cook > 4/n = %s; |DFBETAS| > 2/raiz(n) = %s. Observações acima da distância de Cook de 4/n: %d de %d.",
        f4(4 / nrow(painel)), f4(2 / sqrt(nrow(painel))), sum(inf$cook_acima_4_sobre_n), nrow(inf)),
"",
md(t_inf),
"A tabela completa está em `resultados_econometricos/calibracao_influencia.csv`.",
"",
"## 11. Modelos adicionais (script 05)",
"",
md(t_ra),
md(t_rc),
sprintf("Modelo 3c: ajuste idêntico ao do Modelo 3b (mesmo R², mesmo RESET); o FIV por variável explicativa cai porque a interação passa a ser calculada sobre variáveis centradas. Modelo 4: coeficiente da tendência %s (%s); o coeficiente de X5 é %s (%s).",
        f4(rc$estimativa[grepl("Modelo 4", rc$modelo) & rc$termo == "tendencia"]), fpv(rc$p_valor[grepl("Modelo 4", rc$modelo) & rc$termo == "tendencia"]),
        f4(rc$estimativa[grepl("Modelo 4", rc$modelo) & rc$termo == "selic_real"]), fpv(rc$p_valor[grepl("Modelo 4", rc$modelo) & rc$termo == "selic_real"])),
"",
sprintf("Teste conjunto de Mundlak (script 05, matriz agrupada por município, denominador com graus de liberdade residuais): F = %s (gl %s; %s), %s.",
        f4(rm_$estatistica_f), rm_$gl_numerador, rm_$gl_denominador, fpv(rm_$p_valor)),
"",
"As tabelas completas estão em `resultados_econometricos/calibracao_*.csv` e `robustez_*.csv`."
))

# =============================================================================
# 05. Fragilidades (script 08) e 06. Limitações
# =============================================================================
ff   <- res("fragilidades_forma_funcional.csv")
fqc  <- res("fragilidades_fe_quadratico_coeficientes.csv")
fqm  <- res("fragilidades_fe_quadratico_efeitos_marginais.csv")
fqj  <- res("fragilidades_fe_quadratico_teste_conjunto.csv")
selt <- res("fragilidades_selic_sensibilidade.csv")
selb <- res("fragilidades_selic_bootstrap_exato_por_ano.csv")
exoc <- res("fragilidades_exogeneidade_coeficientes.csv")
exot <- res("fragilidades_exogeneidade_teste.csv")
fe <- function(p) fp(p)

t_ff <- data.frame(Especificação = ff$especificacao, `R² ajustado` = f4(ff$r2_ajustado), AIC = f4(ff$aic), BIC = f4(ff$bic),
                   `RESET regressores: F` = f4(ff$reset_regressores_f), `gl` = ff$reset_regressores_gl, `p-valor` = fe(ff$reset_regressores_p),
                   `RESET ajustados: F` = f4(ff$reset_ajustados_f), `gl ` = ff$reset_ajustados_gl, `p-valor ` = fe(ff$reset_ajustados_p), check.names = FALSE)
t_fqc <- data.frame(Termo = rot(c(fqc$termo)), Estimativa = f4(fqc$estimativa), `EP agrupado` = f4(fqc$erro_padrao), t = f4(fqc$estatistica_t), `p-valor (t, 28 gl)` = fp(fqc$p_valor), check.names = FALSE)
t_fqc$Termo <- ifelse(fqc$termo == "sup2", "X2 ao quadrado", ifelse(fqc$termo == "dom2", "X3 ao quadrado", ifelse(fqc$termo == "sha2", "X4 ao quadrado", t_fqc$Termo)))
t_fqm <- data.frame(Termo = fqm$termo, `Média do regressor` = f4(fqm$media_do_regressor), `Efeito marginal médio` = f4(fqm$efeito_marginal_medio), `EP agrupado` = f4(fqm$erro_padrao),
                    t = f4(fqm$estatistica_t), `p-valor (t, 28 gl)` = fp(fqm$p_valor), `Vértice da parábola` = f4(fqm$vertice_da_parabola), `Mínimo observado` = f4(fqm$minimo_observado), `Máximo observado` = f4(fqm$maximo_observado), `Vértice no suporte` = ifelse(fqm$vertice_dentro_do_suporte, "sim", "não"), check.names = FALSE)
t_selt <- data.frame(Cenário = selt$cenario, N = selt$n, Estimativa = f4(selt$estimativa), `EP agrupado` = f4(selt$erro_padrao), t = f4(selt$estatistica_t), `gl` = selt$graus_liberdade, `p-valor` = fp(selt$p_valor), check.names = FALSE)
t_selb <- data.frame(Modelo = selb$modelo, `t (agrupado por ano)` = f4(selb$estatistica_t_por_ano), `p-valor do bootstrap exato` = fp(selb$p_bootstrap_exato), `Combinações de sinais` = f0(selb$combinacoes), check.names = FALSE)
t_exoc <- data.frame(Modelo = exoc$modelo, Termo = ifelse(exoc$termo %in% names(rotulo_termo), rot(exoc$termo),
                     c(prop_superior = "X2", dom_industrial = "X3", shannon_diversificacao = "X4", selic_real = "X5", sup_futuro = "X2 do ano seguinte", dom_futuro = "X3 do ano seguinte",
                       sha_futuro = "X4 do ano seguinte", sup_defas = "X2 defasada", dom_defas = "X3 defasada", sha_defas = "X4 defasada")[exoc$termo]),
                     Estimativa = f4(exoc$estimativa), `EP agrupado` = f4(exoc$erro_padrao), t = f4(exoc$estatistica_t), `p-valor (t, 28 gl)` = fp(exoc$p_valor), N = exoc$n, check.names = FALSE)
sel_min <- selt[grepl("^Sem o ano", selt$cenario), ]
sem2021 <- selt[selt$cenario == "Sem 2020 e 2021", ]
com_t <- selt[selt$cenario == "Com tendência linear no ano", ]
nome_x2q <- fqc[fqc$termo == "sup2", ]
reset_fe <- ff$reset_regressores_p[ff$especificacao == "Efeitos fixos linear"]
reset_q  <- ff$reset_regressores_p[ff$especificacao == "Efeitos fixos com quadráticos de X2, X3 e X4"]
reset_q2 <- ff$reset_regressores_p[ff$especificacao == "Efeitos fixos de município e ano com quadráticos"]
fut_x2 <- exoc[exoc$termo == "sup_futuro", ]

sfe <- res("fragilidades_simulacao_efeitos_fixos.csv")
t_sfe <- data.frame(Cenário = sfe$cenario, Modelo = sfe$modelo, `Variação de Y (%)` = f4(sfe$variacao_pct),
                    `IC 95% (%)` = ifelse(is.na(sfe$ic_inf_pct), "", paste0("[", f4(sfe$ic_inf_pct), "; ", f4(sfe$ic_sup_pct), "]")), check.names = FALSE)
inf8 <- res("fragilidades_influencia_sensibilidade.csv")
t_inf8 <- inf8 |> filter(termo %in% c("prop_superior", "dom_industrial")) |>
  transmute(Cenário = cenario, Excluídas = observacoes_excluidas, Modelo = modelo, Termo = rot(termo), Estimativa = f4(estimativa), `p-valor (t, G - 1 gl)` = fp(p_valor))
bcx <- res("fragilidades_box_cox.csv")
t_bcx <- data.frame(Modelo = bcx$modelo, `Lambda estimado` = f4(bcx$lambda_estimado), `IC 95%` = paste0("[", f4(bcx$ic95_inf), "; ", f4(bcx$ic95_sup), "]"),
                    `LR contra logaritmo` = f4(bcx$lr_logaritmo), `p-valor` = fp(bcx$p_logaritmo), `LR contra nível` = f4(bcx$lr_nivel), `p-valor ` = fp(bcx$p_nivel), check.names = FALSE)
dom_def <- exoc[exoc$termo == "dom_defas", ]
dec8 <- res("fragilidades_selic_decomposicao.csv"); webb8 <- res("fragilidades_selic_bootstrap_webb.csv")
chow8 <- res("fragilidades_quebra_curitiba.csv"); rcl8 <- res("fragilidades_reset_modelos_3_3b.csv")
t_dec8 <- data.frame(Termo = c(prop_superior = "X2", dom_industrial = "X3", shannon_diversificacao = "X4", selic_nominal = "Selic nominal do ano", ipca = "IPCA do ano")[dec8$termo],
                     Estimativa = f4(dec8$estimativa), `EP agrupado` = f4(dec8$erro_padrao), t = f4(dec8$estatistica_t), `p-valor (t, 28 gl)` = fp(dec8$p_valor),
                     `EP agrupado por ano` = f4(dec8$erro_padrao_por_ano), `p-valor (por ano, t com 9 gl)` = fp(dec8$p_valor_por_ano), check.names = FALSE)
fish8 <- res("fragilidades_selic_decomposicao_teste_fisher.csv")
t_webb8 <- data.frame(Modelo = webb8$modelo, `t (agrupado por ano)` = f4(webb8$estatistica_t_por_ano), `p-valor (Webb)` = fp(webb8$p_bootstrap_webb), Réplicas = f0(webb8$replicas), check.names = FALSE)
t_rcl8 <- data.frame(Modelo = rcl8$modelo, `RESET regressores: F` = f4(rcl8$reset_regressores_f), gl = rcl8$reset_regressores_gl, `p-valor` = fp(rcl8$reset_regressores_p), `RESET ajustados: F` = f4(rcl8$reset_ajustados_f), `gl ` = rcl8$reset_ajustados_gl, `p-valor ` = fp(rcl8$reset_ajustados_p), check.names = FALSE)

gravar("05_fragilidades.md", c(
"# Tratamento das três fragilidades (script 08)",
"",
"Erros-padrão agrupados por município (HC1) e t com 28 graus de liberdade, salvo indicação.",
"",
"## 1. Forma funcional",
"",
"Ponto de partida: o RESET rejeita a forma linear no Modelo 2 e no modelo de efeitos fixos. Estimaram-se especificações alternativas dentro do modelo de efeitos fixos. O RESET aparece em duas versões: com potências 2 e 3 de cada regressor e com potências 2 e 3 dos valores ajustados. Os graus de liberdade usam o posto da matriz: com termos quadráticos, o quadrado de X2 é exatamente colinear com o regressor X2 ao quadrado e não acrescenta parâmetro (por isso 11 e não 14 graus de liberdade no numerador).",
"",
md(t_ff),
sprintf("Leitura numérica: o RESET de regressores passa de %s (linear) para %s com termos quadráticos de X2, X3 e X4 (valores ajustados: %s), ambos próximos do limite de 5%%, e o AIC cai de %s para %s. O ln dos vínculos como controle não melhora o ajuste. Com efeitos fixos de município e de ano e quadráticos o RESET de regressores rejeita (%s).",
        fe(reset_fe), fe(reset_q), fe(ff$reset_ajustados_p[3]), f2(ff$aic[1]), f2(ff$aic[3]), fe(reset_q2)),
"",
"Coeficientes do modelo de efeitos fixos com quadráticos:",
"",
md(t_fqc),
"Efeitos marginais médios (derivada em relação a cada variável, avaliada na média amostral; variância pelo método delta):",
"",
md(t_fqm),
sprintf("Teste conjunto dos três termos quadráticos: F = %s (gl %s; %s), p-valor = %s. O quadrático de X2 é significativo isoladamente (p-valor = %s), os de X3 e X4 não.", f4(fqj$estatistica_f), fqj$gl_numerador, fqj$gl_denominador, f4(fqj$p_valor), f4(nome_x2q$p_valor)),
"",
"Figura: `figuras_graficos/fragilidades_efeito_marginal_superior.png` (efeito marginal de X2 por nível de X2).",
"",
sprintf("Observação sobre o vértice: -b/(2c) é o ponto de máximo ou de mínimo da parábola, não ponto de inflexão. O vértice de X4 (%s) fica fora do intervalo observado (%s a %s), de modo que a curvatura de X4 não tem interpretação dentro dos dados.", f4(fqm$vertice_da_parabola[3]), f4(fqm$minimo_observado[3]), f4(fqm$maximo_observado[3])),
"",
"Escolha da forma de Y (Box-Cox, razão de verossimilhança; lambda = 0 é o logaritmo e lambda = 1 o nível):",
"",
md(t_bcx),
sprintf("Com efeitos fixos, o logaritmo não é rejeitado (%s) e o nível é rejeitado (%s); no MQO empilhado ambos são rejeitados, e o lambda estimado fica longe de 0 e de 1.", fpv(bcx$p_logaritmo[2]), fpv(bcx$p_nivel[2])),
"",
"## 2. Sensibilidade da Selic real (10 valores distintos)",
"",
md(t_selt),
"Bootstrap wild cluster por ano, restrito, com todas as 2^10 = 1.024 combinações de sinais (resultado exato, sem aleatoriedade):",
"",
md(t_selb),
sprintf("Bootstrap exato por ano: p-valor = %s no modelo linear e %s com quadráticos; esse procedimento não rejeita a 5%%, ao contrário do erro agrupado por município e do erro agrupado por ano com t de 9 graus de liberdade (%s). O bootstrap exato refaz a transformação within em cada réplica.", f4(selb$p_bootstrap_exato[1]), f4(selb$p_bootstrap_exato[2]), f4(selt$p_valor[selt$cenario == "Erro agrupado por ano (10 grupos, t com 9 gl)"])),
"",
sprintf("Leitura numérica: o coeficiente de X5 varia de %s a %s quando se retira cada ano (todos positivos, p-valores abaixo de 0,05), vale %s sem 2020 e 2021 (p-valor = %s) e %s com tendência linear.", f4(min(sel_min$estimativa)), f4(max(sel_min$estimativa)), f4(sem2021$estimativa), f4(sem2021$p_valor), f4(com_t$estimativa)),
"",
"## 3. Exogeneidade estrita e regressores defasados",
"",
"Com regressores estritamente exógenos, valores futuros de X2, X3 e X4 não devem afetar o salário corrente depois de controlar os valores correntes e o efeito de município (Wooldridge, 2010).",
"",
md(t_exoc),
sprintf("Teste conjunto dos valores futuros: F = %s (gl %s; %s), p-valor = %s. O coeficiente de X2 do ano seguinte é %s (p-valor = %s).", f4(exot$estatistica_f), exot$gl_numerador, exot$gl_denominador, f4(exot$p_valor), f4(fut_x2$estimativa), f4(fut_x2$p_valor)),
"",
"O teste conjunto não rejeita a exogeneidade estrita a 5%, mas o valor futuro de X2 é significativo isoladamente, o que é compatível com antecipação ou retroalimentação entre escolaridade e salário.",
"",
sprintf("Com regressores defasados em um ano, X2 e X4 mantêm o sinal dos valores contemporâneos; X3 defasada tem coeficiente %s (%s), diferente do coeficiente contemporâneo de efeitos fixos, que não difere de zero.", f4(dom_def$estimativa), fpv(dom_def$p_valor)),
"",
"## 4. Simulação de cenários com efeitos fixos",
"",
"Variação percentual de Y, 100 x (exp(delta x b) - 1), com os coeficientes de cada modelo. O intervalo usa o erro agrupado por município e t com 28 graus de liberdade.",
"",
md(t_sfe),
sprintf("Com quadráticos, a variação de +5 pontos em X2 vai de %s%% (%s) a %s%% (%s) entre os 29 municípios; os municípios com X2 acima do vértice da parábola têm efeito negativo.", f4(sfe$minimo_pct[6]), sfe$municipio_do_minimo[6], f4(sfe$maximo_pct[6]), sfe$municipio_do_maximo[6]),
"",
"## 5. Sensibilidade a observações influentes",
"",
"Reestimação do MQO empilhado e do modelo de efeitos fixos sem observações específicas: Araucária 2012 e 2013, as 15 observações com distância de Cook acima de 4/n, Lapa 2016 e o município de Adrianópolis (5 anos marcados).",
"",
md(t_inf8),
"Tabela completa: `resultados_econometricos/fragilidades_influencia_sensibilidade.csv`.",
"",
"## 6. Selic real e deflator",
"",
"X5 = ((1 + Selic)/(1 + IPCA) - 1) x 100, e Y é deflacionado pelo mesmo IPCA. Separando X5 em Selic nominal e IPCA do ano, em efeitos fixos:",
"",
md(t_dec8),
sprintf("Se X5 tivesse um efeito próprio, a equação de Fisher imporia coeficientes de sinais opostos e mesma magnitude na Selic nominal e no IPCA. O teste da restrição (soma dos dois coeficientes igual a zero) não rejeita: %s com agrupamento por município e %s com agrupamento por ano. Os dados não distinguem um efeito próprio de X5 de um canal de deflação. Com agrupamento por ano, o exigido para variáveis que só variam no tempo, o IPCA perde significância a 5%% (%s).", fpv(fish8$p_valor[1]), fpv(fish8$p_valor[2]), fpv(dec8$p_valor_por_ano[dec8$termo == "ipca"])),
"",
"Bootstrap wild cluster por ano com pesos de Webb:",
"",
md(t_webb8),
"## 7. Quebra estrutural em Curitiba",
"",
sprintf("Teste de Chow: Modelo 2 contra o modelo com a indicadora de Curitiba e suas interações com X2 a X5 (X6 não interage, por ser constante em Curitiba): F = %s (gl %s; %s), %s. Teste clássico, sem erro agrupado; Curitiba tem 10 observações.", f4(chow8$estatistica_f), chow8$gl_numerador, chow8$gl_denominador, fpv(chow8$p_valor)),
"",
"## 8. RESET dos Modelos 3 e 3b",
"",
md(t_rcl8)
))

gravar("06_limitacoes.md", c(
"# Limitações e ressalvas",
"",
"Cada ressalva está associada a um resultado verificável na pasta.",
"",
sprintf("1. **Forma funcional.** O Box-Cox não rejeita o logaritmo de Y com efeitos fixos (%s). O RESET de regressores rejeita a forma linear (Modelo 2: %s; efeitos fixos: %s), mas o RESET de valores ajustados do modelo de efeitos fixos linear não rejeita (%s). Com quadráticos, o RESET de regressores passa a %s e o de valores ajustados a %s, ambos no limite de 5%%; o teste conjunto dos quadráticos tem %s, e com efeitos fixos de município e ano o RESET de regressores rejeita (%s). A melhora vale para a versão por regressores, não para a por valores ajustados. A não linearidade é evidente para X2 (retornos decrescentes) e não conclusiva para X3 e X4 (`05_fragilidades.md`). Os Modelos 3 e 3b rejeitam o RESET nas duas versões.",
        fpv(bcx$p_logaritmo[2]), fe(rs$p_valor[1]), fe(reset_fe), fe(ff$reset_ajustados_p[1]), fe(reset_q), fe(ff$reset_ajustados_p[3]), fpv(fqj$p_valor), fe(reset_q2)),
"2. **Heterocedasticidade e normalidade.** O Breusch-Pagan e o White rejeitam homocedasticidade e o Jarque-Bera e o Shapiro-Wilk rejeitam normalidade no Modelo 2 (`03_resultados_modelos_classicos.md`). A inferência usa erros-padrão robustos e agrupados. Os testes t e F dependem de normalidade assintótica (290 observações) e o bootstrap wild cluster não exige normalidade dos erros. Mínimos quadrados ponderados por vínculos não foram adotados: a variância dos resíduos cresce com o tamanho do município (inclinação positiva e significativa), o oposto do que a ponderação supõe (`04_calibracao.md`, seção 7).",
"3. **Poucos grupos.** Há 29 municípios. Erros-padrão agrupados com poucos grupos tendem a ser otimistas; por isso as tabelas de calibração usam t com 28 graus de liberdade e bootstrap wild cluster. Os p-valores agrupados de `03_resultados_modelos_classicos.md` usam os graus de liberdade residuais e diferem um pouco dos de `04_calibracao.md`.",
sprintf("4. **Selic real.** X5 assume só %d valores distintos (um por ano) e se confunde com qualquer choque nacional anual: com efeitos fixos de ano ela não é estimável. A inferência depende do procedimento: p-valor de %s com erro agrupado por município (t com 28 gl), %s com erro agrupado por ano (t com 9 gl), %s no bootstrap exato por ano (pesos de Rademacher) e %s no bootstrap com pesos de Webb (modelo linear). O resultado fica na fronteira de 5%%. O coeficiente mantém o sinal à retirada de cada ano e cai para %s sem 2020 e 2021.", n_selic,
        f4(selt$p_valor[1]), f4(selt$p_valor[selt$cenario == "Erro agrupado por ano (10 grupos, t com 9 gl)"]), f4(selb$p_bootstrap_exato[1]), f4(webb8$p_bootstrap_webb[1]), f4(sem2021$estimativa)),
sprintf("5. **Selic real e deflator.** X5 = ((1 + Selic)/(1 + IPCA) - 1) x 100 e Y é deflacionado pelo mesmo IPCA. Separando X5 em Selic nominal e IPCA do ano, com efeitos fixos, os coeficientes são %s (Selic nominal, %s com agrupamento por município e %s por ano) e %s (IPCA, %s por município e %s por ano). A restrição de Fisher (soma igual a zero) não é rejeitada (%s e %s): os dados não distinguem um efeito próprio de X5 de um canal de deflação. O deflator é o IPCA nacional, não um índice da Região Metropolitana de Curitiba.",
        f4(dec8$estimativa[dec8$termo == "selic_nominal"]), fpv(dec8$p_valor[dec8$termo == "selic_nominal"]), fpv(dec8$p_valor_por_ano[dec8$termo == "selic_nominal"]), f4(dec8$estimativa[dec8$termo == "ipca"]), fpv(dec8$p_valor[dec8$termo == "ipca"]), fpv(dec8$p_valor_por_ano[dec8$termo == "ipca"]), fpv(fish8$p_valor[1]), fpv(fish8$p_valor[2])),
sprintf("6. **Associação, não causalidade.** O painel observacional não identifica efeitos causais. O teste de exogeneidade estrita não rejeita conjuntamente a 5%% (%s), mas o valor futuro de X2 é significativo isoladamente (%s) e X3 defasada tem coeficiente %s (%s); não há instrumento nem modelo dinâmico. Variáveis omitidas possíveis: participação da administração pública nos vínculos, composição por idade e sexo, porte das firmas e do mercado de trabalho.", fpv(exot$p_valor), fpv(fut_x2$p_valor), f4(dom_def$estimativa), fpv(dom_def$p_valor)),
sprintf("7. **Efeito de município.** O teste de Mundlak rejeita a ausência de correlação entre o efeito do município e X2, X3 e X4 (%s). As estimativas do MQO empilhado para essas variáveis misturam diferenças entre municípios e variação ao longo do tempo. A simulação do script 04 usa o Modelo 2; com efeitos fixos, +10 pontos em X3 dá variação de %s%% e +5 pontos em X2 dá %s%%; com quadráticos, a variação de X2 vai de %s%% (%s) a %s%% (%s) (`05_fragilidades.md`, seção 4).", fpv(rm_$p_valor), f4(sfe$variacao_pct[2]), f4(sfe$variacao_pct[5]), f4(sfe$minimo_pct[6]), sfe$municipio_do_minimo[6], f4(sfe$maximo_pct[6]), sfe$municipio_do_maximo[6]),
sprintf("8. **Robustez de X2.** O coeficiente de X2 perde significância a 5%% em três estimadores: efeitos fixos de município e ano (%s), primeiras diferenças (%s) e Prais-Winsten (%s) (`04_calibracao.md`, seção 2). Nos efeitos fixos simples ele é significativo.", fpv(cal$p_valor[cal$estimador == E_T & cal$termo == "prop_superior"]), fpv(cal$p_valor[cal$estimador == E_D & cal$termo == "prop_superior"]), fpv(cal$p_valor[cal$estimador == E_W & cal$termo == "prop_superior"])),
sprintf("9. **Observações influentes e Curitiba.** Araucária em 2012 e 2013 tem valor adicionado da indústria negativo na fonte, e Araucária 2012 é a observação de maior distância de Cook do Modelo 2 (%s). Curitiba difere do Modelo 2 no teste de Chow (F = %s, %s); a indicadora de Curitiba isola um município com 10 observações. Em Adrianópolis, X3 passa de %s%% em 2014 para %s%% em 2015, e sem o município o coeficiente de X3 com efeitos fixos é %s (%s). A sensibilidade a observações influentes está em `05_fragilidades.md`, seção 5.", f4(inf$cook[1]), f4(chow8$estatistica_f), fpv(chow8$p_valor), f2(painel$dom_industrial[painel$nome_municipio == "Adrianópolis" & painel$ano == 2014]), f2(painel$dom_industrial[painel$nome_municipio == "Adrianópolis" & painel$ano == 2015]), f4(inf8$estimativa[inf8$cenario == "Sem Adrianópolis (município inteiro)" & inf8$modelo == "Efeitos fixos" & inf8$termo == "dom_industrial"]), fpv(inf8$p_valor[inf8$cenario == "Sem Adrianópolis (município inteiro)" & inf8$modelo == "Efeitos fixos" & inf8$termo == "dom_industrial"])),
"10. **Construção de Y.** Y é a média simples da remuneração média dos vínculos ativos em 31/12, sem ponderar pelos meses trabalhados nem pelo tamanho do vínculo.",
"11. **Inferência clássica.** A previsão e o teste F incremental do memorial usam o s² clássico; os erros robustos e agrupados estão nas tabelas de coeficientes.",
"12. **Durbin-Watson.** A decisão usa o p-valor de `dwtest` (bilateral), porque n = 290 não consta nas linhas usuais das tabelas de dL e dU; não há decisão pelas cinco zonas numéricas. No painel empilhado o teste cruza fronteiras entre municípios (28 pares).",
"13. **Distância a Curitiba.** X6 mede a distância entre centroides, com Curitiba igual a zero; a coordenada oficial do marco zero de Curitiba não foi localizada em fonte oficial.",
"14. **Escolaridade.** X2 é calculada sobre vínculos formais com escolaridade informada; nenhum vínculo ativo tem escolaridade ignorada no período.",
"15. **Cobertura.** A RAIS cobre o emprego formal; o salário médio real não representa a renda de trabalhadores informais.",
"16. **Período.** 2012 a 2021: o valor adicionado municipal de 2022 não estava publicado pelo IBGE na data da coleta.",
sprintf("17. **Simulação fora do suporte.** No cenário de +5 pontos em X2, Curitiba vai de %s%% para %s%%, acima do máximo observado de X2 (%s%%); nesse ponto a simulação extrapola os dados.", f2(painel$prop_superior[painel$nome_municipio == "Curitiba" & painel$ano == 2021]), f2(painel$prop_superior[painel$nome_municipio == "Curitiba" & painel$ano == 2021] + 5), f2(max(painel$prop_superior))),
"18. **Prais-Winsten.** O rho desse estimador é estimado em resíduos que contêm o efeito de município; ele reflete esse efeito e não um processo AR(1) puro."
))
gravar("00_resumo.md", c(
"# Resumo dos resultados validados",
"",
"Todos os números abaixo vêm dos arquivos de `resultados_econometricos/` e foram recomputados de forma independente (`08_verificacao.md`).",
"",
"## Desenho",
"",
sprintf("- Painel de %d municípios da Região Metropolitana de Curitiba, %d a %d (%d observações). Variável dependente: ln do salário médio real formal (R$ de 2021).", n_distinct(painel$id_municipio), min(painel$ano), max(painel$ano), nrow(painel)),
"- Linha de base da disciplina: MQO empilhado (Modelo 2), com diagnósticos do modelo clássico.",
"- Estimativas de referência para X2, X3 e X4: efeitos fixos (equivalentes às do modelo de Mundlak, que preserva X5 e X6), porque o teste F de efeitos individuais, o Hausman e o Mundlak rejeitam o MQO empilhado.",
"",
"## Coeficientes principais (erro agrupado por município, t com 28 graus de liberdade)",
"",
md(data.frame(Termo = rot(c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real", "dist_curitiba_km")),
              `MQO empilhado` = f4(sapply(c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real", "dist_curitiba_km"), \(x) b(E_P, x))),
              `p-valor ` = fp(sapply(c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real", "dist_curitiba_km"), \(x) get_p(E_P, x))),
              Mundlak = f4(sapply(c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real", "dist_curitiba_km"), \(x) b(E_M, x))),
              `p-valor` = fp(sapply(c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real", "dist_curitiba_km"), \(x) get_p(E_M, x))), check.names = FALSE)),
"## Diagnósticos do Modelo 2",
"",
sprintf("- Multicolinearidade: maior FIV %s (limite 10).", f4(max(fiv$fiv[fiv$modelo == "Modelo 2"]))),
sprintf("- Breusch-Pagan: %s (%s); Durbin-Watson empilhado: %s; Jarque-Bera: %s; RESET: %s.", f4(diag$estatistica[grepl("Breusch-Pagan", diag$teste)][1]), fpv(diag$p_valor[grepl("Breusch-Pagan", diag$teste)][1]), f4(diag$estatistica[grepl("Durbin-Watson empilhado", diag$teste)]), f4(diag$estatistica[grepl("Jarque", diag$teste)]), f4(diag$estatistica[grepl("RESET", diag$teste)])),
"- O Modelo 2 viola homocedasticidade, ausência de autocorrelação, normalidade e forma funcional; o erro-padrão clássico não é válido, e a inferência usa erros robustos e agrupados.",
"",
"## O que a calibração mostrou",
"",
sprintf("- O efeito de município é significativo (F = %s) e correlacionado com X2, X3 e X4 (Mundlak: %s; Hausman: %s).", f4(tp$estatistica[1]), fpv(rm_$p_valor), fpv(tp$p_valor[3])),
sprintf("- Com efeitos fixos, X2 vale %s (MQO empilhado: %s) e X3 deixa de ser significativo (%s, %s).", f4(b(E_F, "prop_superior")), f4(b(E_P, "prop_superior")), f4(b(E_F, "dom_industrial")), fpv(get_p(E_F, "dom_industrial"))),
sprintf("- Selic real: p-valor de %s a %s conforme o procedimento de inferência; a Selic nominal e o IPCA entram com sinais opostos.", f4(min(c(selt$p_valor[1], selb$p_bootstrap_exato[1], webb8$p_bootstrap_webb[1]))), f4(max(c(selt$p_valor[1], selb$p_bootstrap_exato[1], webb8$p_bootstrap_webb[1])))),
sprintf("- Forma funcional: com quadráticos, o RESET de regressores passa a %s, mas o de valores ajustados piora para %s e, com efeitos de ano, o de regressores rejeita (%s); o quadrático de X2 sugere retornos decrescentes e o Box-Cox não rejeita o logaritmo de Y com efeitos fixos.", fp(ff$reset_regressores_p[3]), fp(ff$reset_ajustados_p[3]), fp(ff$reset_regressores_p[4])),
"- Os resultados são associações; ver `06_limitacoes.md`.",
"",
"## Onde ler",
"",
"`01_dados_e_variaveis.md`, `02_especificacao_e_metodos.md`, `03_resultados_modelos_classicos.md`, `04_calibracao.md`, `05_fragilidades.md`, `06_limitacoes.md`, `07_criterios_da_disciplina.md` e `08_verificacao.md`."
))
# remove os nomes antigos da numeração anterior
unlink(file.path(DOC, c("05_limitacoes.md", "06_criterios_da_disciplina.md", "07_verificacao.md")))

# =============================================================================
# 07. Critérios da disciplina
# =============================================================================
crit <- data.frame(
  Critério = c("Resultados com quatro casas decimais", "Memorial de cálculo explícito (passo a passo matricial)", "Hipóteses H0 e Ha explicitadas, decisão a 5%",
               "Multicolinearidade: FIV, tolerância e relação com o determinante de X'X", "Heterocedasticidade: Breusch-Pagan, White, Goldfeld-Quandt",
               "Autocorrelação: Durbin-Watson, rho, Breusch-Godfrey", "Medidas corretivas: erros robustos de White, Newey-West, Prais-Winsten",
               "Quadro ANOVA, teste F global, testes t, intervalos de confiança", "Contribuição incremental (teste F) e coeficientes de determinação parcial",
               "Previsão pontual e intervalos (média e individual)", "Normalidade dos resíduos", "Forma funcional", "Painel, endogeneidade e sensibilidade da Selic"),
  Onde = c("`documentacao/` e `memorial_modelo_2.txt`", "`resultados_econometricos/memorial_modelo_2.txt`", "`documentacao/02_especificacao_e_metodos.md` e `diagnosticos_modelo_2.csv`",
           "`memorial_modelo_2.txt` (seção 10) e `fiv_modelos_2_3_3b.csv`", "`diagnosticos_modelo_2.csv`, `calibracao_goldfeld_quandt.csv` e `memorial_modelo_2.txt` (seção 14, Breusch-Pagan passo a passo)",
           "`diagnosticos_modelo_2.csv`, `calibracao_autocorrelacao.csv`, `calibracao_testes_painel.csv` e `memorial_modelo_2.txt` (seção 15, Durbin-Watson passo a passo)", "`coeficientes_cinco_matrizes.csv` e `calibracao_coeficientes.csv`",
           "`memorial_modelo_2.txt` (seções 7 a 9)", "`memorial_modelo_2.txt` (seções 11 e 12)", "`memorial_modelo_2.txt` (seção 13)",
           "`diagnosticos_modelo_2.csv` e `figuras_graficos/diag3` e `diag4`", "`diagnosticos_modelo_2.csv` (RESET), `calibracao_reset.csv`, `fragilidades_forma_funcional.csv` e `fragilidades_box_cox.csv` (forma de Y)",
           "`calibracao_testes_painel.csv`, `fragilidades_exogeneidade_*.csv` e `fragilidades_selic_*.csv`"),
  check.names = FALSE)
gravar("07_criterios_da_disciplina.md", c(
"# Critérios da disciplina e onde estão atendidos",
"",
md(crit)))

# =============================================================================
# Ambiente de execução
# =============================================================================
pk <- c("dplyr", "tidyr", "purrr", "tibble", "stringr", "readr", "ggplot2", "scales", "car", "lmtest", "sandwich", "plm",
        "modelsummary", "broom", "tseries", "patchwork", "ggridges", "ggrepel", "ggspatial", "sf", "viridis", "gganimate", "gifski", "transformr")
amb <- data.frame(componente = c("R", pk),
                  versao = c(paste(R.version$major, R.version$minor, sep = "."),
                             vapply(pk, function(p) if (requireNamespace(p, quietly = TRUE)) as.character(packageVersion(p)) else "não instalado", character(1))))
write.csv(amb, file.path(DOC, "ambiente_r.csv"), row.names = FALSE, fileEncoding = "UTF-8")
cat("documentação gerada em", DOC, "\n")
