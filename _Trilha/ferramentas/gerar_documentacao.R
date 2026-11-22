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
lm_t <- res("especificacao_lm_tendencia.csv")
chow <- res("chow_quebra_periodo.csv")
mem_fiv <- res("memorial_modelo_2_fiv.csv")

nomes_termo <- c("(Intercept)" = "Constante", prop_superior = "X2 ensino superior (%)",
                 dom_industrial = "X3 dominância industrial (%)", gini_setorial = "X4 concentração setorial (Gini)",
                 selic_real = "X5 Selic real (% a.a.)", dist_curitiba_km = "X6 distância a Curitiba (km)",
                 dummy_curitiba = "Dummy de Curitiba", `dom_industrial:dist_curitiba_km` = "X3 x X6 (interação)")
coef_m <- function(modelo, matriz) {
  d <- coef[coef$modelo == modelo & coef$matriz == matriz, ]
  data.frame(Termo = nomes_termo[d$termo], Estimativa = f4(d$estimativa), `Erro-padrão` = f4(d$erro_padrao),
             t = f2(d$estatistica_t), `p-valor` = fp(d$p_valor), check.names = FALSE)
}

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
  "Estatísticas descritivas: `dados_processados/estatisticas_descritivas.csv`. Correlações: `dados_processados/matriz_correlacao_explicativas.csv`."))

# ---- 02 especificação e métodos
gravar("02_especificacao_e_metodos.md", c(
  "# Especificação e métodos", "",
  "Modelo principal (Modelo 2), estimado por MQO sobre o painel empilhado:", "",
  "ln(Y_it) = b1 + b2 X2_it + b3 X3_it + b4 X4_it + b5 X5_t + b6 X6_i + u_it", "",
  "Modelo 3 acrescenta a dummy de Curitiba; Modelo 3b acrescenta a interação X3 x X6.", "",
  "## Métodos usados (todos ensinados na disciplina)", "",
  "| Método | Uso no projeto | Fonte oficial |", "|---|---|---|",
  "| MQO e álgebra matricial | estimação e memorial | notas de regressão múltipla |",
  "| t, F, ANOVA, R2 | inferência | notas de regressão múltipla |",
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
  "Efeitos fixos e aleatórios, Mundlak, Hausman, erros agrupados por município, bootstrap, Newey-West e Prais-Winsten aplicados ao painel empilhado, Box-Cox, Jarque-Bera, smearing de Duan e a entropia de Shannon.", "",
  "Fontes oficiais e IDs no Drive: `documentacao/06_fontes.md`."))

# ---- 03 resultados
gravar("03_resultados_modelos.md", c(
  "# Resultados dos modelos", "",
  "Coeficientes com erro clássico (MQO) e com erro de White (HC1). O t tem n - k = 284 graus de liberdade.", "",
  "## Modelo 2 (principal), erro clássico", "", md(coef_m("Modelo 2", "classico")), "",
  "## Modelo 2, erro de White (HC1)", "", md(coef_m("Modelo 2", "white")), "",
  "## Modelo 3, erro de White (HC1)", "", md(coef_m("Modelo 3", "white")), "",
  "## Modelo 3b, erro de White (HC1)", "", md(coef_m("Modelo 3b", "white")), "",
  "## Significância conjunta (F da ANOVA)", "",
  md(data.frame(Modelo = anova$modelo, F = f2(anova$estatistica_f),
                `gl` = paste(anova$gl_numerador, anova$gl_denominador, sep = "; "),
                `p-valor` = fp(anova$p_valor), `R2` = f4(anova$r2), `R2 ajustado` = f4(anova$r2_ajustado),
                check.names = FALSE)), ""))

# ---- 04 diagnósticos
tab_test <- data.frame(Modelo = testes$modelo, Teste = testes$teste, Estatística = f2(testes$estatistica),
                       gl = testes$gl, `p-valor` = fp(testes$p_valor), Decisão = testes$decisao_5pct, check.names = FALSE)
tab_aut <- data.frame(Município = aut$nome_municipio, `Durbin-Watson` = f4(aut$durbin_watson),
                      `Decisão pela tabela` = aut$decisao_dw_tabela, `ρ auxiliar` = f4(aut$rho_auxiliar),
                      `Breusch-Godfrey p` = fp(aut$breusch_godfrey_p), check.names = FALSE)
gravar("04_diagnosticos.md", c(
  "# Diagnósticos do modelo", "",
  "## Multicolinearidade (FIV e tolerância)", "",
  md(data.frame(Modelo = vif$modelo, Variável = vif$variavel, FIV = f4(vif$fiv), Tolerância = f4(vif$tolerancia),
                Decisão = vif$decisao_fiv_10)), "",
  "Limite da regra ensinada: FIV > 10 indica multicolinearidade elevada.", "",
  "## Heterocedasticidade, forma funcional e quebra estrutural", "",
  md(tab_test), "",
  sprintf("RESET de Ramsey (potências 2 e 3 dos ajustados): estatística F = %s, p-valor %s. A forma log-linear é rejeitada e este é o principal achado de especificação.",
          f2(reset$estatistica_f), fp(reset$p_valor)), "",
  sprintf("LM para tendência linear do ano: estatística = %s, p-valor %s. Não há tendência omitida.",
          f4(lm_t$estatistica), fp(lm_t$p_valor)), "",
  sprintf("Teste de Chow (2012 a 2016 contra 2017 a 2021): F = %s, p-valor %s. Não há quebra estrutural a 5%%.",
          f4(chow$estatistica_f), fp(chow$p_valor)), "",
  "## Autocorrelação dentro de cada município", "",
  "Aplicado à série de dez anos de cada município, com os resíduos do Modelo 2. A tabela de Durbin-Watson para n = 10 e k' = 5 tem dL = 0,243 e dU = 2,822 (valores lidos do PDF por OCR, [a confirmar]). Com dU maior que 4 - dU não há zona de não rejeição: a tabela só permite conclusão para d < dL.", "",
  md(tab_aut), "",
  sprintf("Resumo: %s municípios com autocorrelação positiva pela tabela; %s na zona de inconclusão; %s com Breusch-Godfrey significativo a 5%%.",
          aut_res$valor[aut_res$indicador == "decisão pela tabela: autocorrelação positiva"],
          aut_res$valor[aut_res$indicador == "decisão pela tabela: zona de inconclusão"],
          aut_res$valor[aut_res$indicador == "Breusch-Godfrey rejeita H0 a 5%"]), "",
  "Essa autocorrelação positiva não é corrigida por nenhum método ensinado aplicável ao painel. Os erros-padrão, mesmo os de White, tendem a estar subestimados nesse caso. Isso é limitação do trabalho."))

# ---- 05 limitações
gravar("05_limitacoes.md", c(
  "# Limitações", "",
  "- Desenho observacional: os coeficientes são associações, não efeitos causais.",
  "- Autocorrelação positiva dentro dos municípios, sem correção ensinada aplicável ao painel (ver 04_diagnosticos).",
  "- Forma funcional rejeitada pelo RESET: a especificação log-linear com estas cinco variáveis não é completa.",
  "- Heterocedasticidade rejeitada pelo Breusch-Pagan-Godfrey no Modelo 2; a inferência usa erros de White.",
  "- O Gini setorial tem correlação de 0,73 com a distância a Curitiba. Os FIVs ficam abaixo de 10, mas a colinearidade entre X4 e X6 deve ser lida com cautela.",
  "- A divisão do Chow no ano de 2016 é uma escolha, e o tamanho das duas partes é igual (145 observações cada).",
  "- Dados da RAIS: vínculos com divisão CNAE 'ignorada' ficam fora do Gini."))

# ---- 06 fontes
gravar("06_fontes.md", c(
  "# Fontes e referências", "",
  "## Fontes oficiais da disciplina (podem ser citadas)", "",
  "| Fonte | Conteúdo usado |", "|---|---|",
  "| Gujarati, D. N.; Porter, D. C. Econometria Básica. 5ª ed. AMGH, 2011 | base teórica: regressão, testes, heterocedasticidade, autocorrelação, especificação |",
  "| Hoffmann, R.; Vieira, S. Análise de Regressão: Introdução à Econometria. 2ª ed. Hucitec, 1987 | regressão linear múltipla (bibliografia básica) |",
  "| Notas de aula de regressão linear múltipla (Hasegawa) | matriz X'X, ANOVA, t e F, R2 parcial |",
  "| Notas de multicolinearidade, heterocedasticidade, autocorrelação, especificação e teste de Chow (SE614) | métodos de diagnóstico |",
  "| Tabela de Durbin-Watson (Apêndice D) | valores de dL e dU |",
  "| Guia da P2 (professor) | regras de decisão de FIV, BPG, DW e Gini |", "",
  "## Dados", "",
  "| Dado | Origem | Arquivo |", "|---|---|---|",
  "| PIB e VAB municipais | IBGE, SIDRA, tabela 5938 | dados_brutos/pib_sidra.rds |",
  "| Selic (4390) e IPCA (433) | Banco Central, SGS | dados_brutos/macro_bacen.rds |",
  "| Vínculos, escolaridade, salário e divisão CNAE | RAIS, microdados públicos do Ministério do Trabalho | dados_brutos/rais.rds |",
  "| Malha municipal | IBGE, pacote geobr | dados_brutos/malha_rmc.rds |",
  "| Distâncias a Curitiba | cálculo a partir dos centroides | dados_brutos/distancias.rds |", "",
  "Os endereços e os códigos das APIs foram conferidos em 22/11/2026 (ver 08_verificacao.md).", "",
  "Referências de métodos removidos do projeto não são citadas no trabalho."))

# ---- 07 critérios (regras de correção da P2 sobre o modelo)
gravar("07_criterios_da_disciplina.md", c(
  "# Critérios da disciplina aplicados ao trabalho", "",
  "- Todos os cálculos no R, com caminhos relativos e rotina reproduzível: `R/00_executar_tudo.R`.",
  "- Quatro casas decimais nos resultados do memorial (`resultados_econometricos/memorial_modelo_2.txt`).",
  "- Hipóteses nula e alternativa explicitadas nos testes (`testes_diagnostico.csv`, `especificacao_*.csv`).",
  "- Apenas métodos ensinados (ver 02_especificacao_e_metodos.md)."))

# ---- 08 ambiente
ambiente <- data.frame(pacote = c("dplyr", "readr", "tibble", "stringr", "purrr", "ggplot2", "car", "lmtest", "sandwich", "sf", "geobr", "sidrar", "rbcb", "gifski", "gganimate"),
                       versao = vapply(c("dplyr", "readr", "tibble", "stringr", "purrr", "ggplot2", "car", "lmtest", "sandwich", "sf", "geobr", "sidrar", "rbcb", "gifski", "gganimate"),
                                       function(p) if (requireNamespace(p, quietly = TRUE)) as.character(packageVersion(p)) else "ausente", character(1)))
write.csv(ambiente, file.path(DOC, "ambiente_r.csv"), row.names = FALSE)
write.csv(data.frame(variavel = names(painel), tipo = vapply(painel, function(x) class(x)[1], character(1))),
          file.path(DOC, "dicionario_variaveis.csv"), row.names = FALSE)

# ---- 00 resumo (fecha a documentação)
gravar("00_resumo.md", c(
  "# Resumo dos resultados", "",
  "Todos os números abaixo saem de `resultados_econometricos/`. Escopo: apenas métodos ensinados na disciplina.", "",
  "## Modelo principal (MQO empilhado, erro de White)", "",
  md(coef_m("Modelo 2", "white")), "",
  sprintf("F da ANOVA = %s (p-valor %s); R2 = %s.", f2(anova$estatistica_f[1]), fp(anova$p_valor[1]), f4(anova$r2[1])), "",
  "## Diagnósticos", "",
  sprintf("- Multicolinearidade: maior FIV = %s (limite 10).", f4(max(vif$fiv[vif$modelo == "Modelo 2"]))),
  sprintf("- Heterocedasticidade (Breusch-Pagan-Godfrey): p-valor %s.", fp(testes$p_valor[testes$modelo == "Modelo 2" & grepl("Breusch", testes$teste)])),
  sprintf("- Forma funcional (RESET): p-valor %s; rejeita.", fp(reset$p_valor)),
  sprintf("- Quebra estrutural (Chow): p-valor %s; não rejeita.", fp(chow$p_valor)),
  sprintf("- Autocorrelação positiva dentro dos municípios: %s de 29 municípios pela tabela de Durbin-Watson.",
          aut_res$valor[aut_res$indicador == "decisão pela tabela: autocorrelação positiva"]), "",
  "Detalhes: 03_resultados_modelos.md, 04_diagnosticos.md, 05_limitacoes.md."))

# ---- LEIAME
gravar("../LEIAME.md", c(
  "# Salário médio real formal nos municípios da Região Metropolitana de Curitiba, 2012 a 2021", "",
  "Trabalho de Econometria I (UFPR). Painel de 29 municípios em 10 anos (290 observações). Variável dependente: logaritmo do salário médio real formal. Explicativas: X2 ensino superior, X3 dominância industrial, X4 concentração setorial (Gini), X5 Selic real e X6 distância a Curitiba.", "",
  "## Como reproduzir", "",
  "1. Instalar o R e os pacotes de `documentacao/ambiente_r.csv`.",
  "2. Definir esta pasta como diretório de trabalho e rodar `Rscript R/00_executar_tudo.R`.", "",
  "## Scripts", "",
  "| Script | Função |", "|---|---|",
  "| 02_tratamento_painel.R | constrói o painel e as variáveis |",
  "| 03_aede_visualizacoes.R | figuras e animações |",
  "| 04_modelagem_diagnosticos.R | modelos, erro de White, VIF, Breusch-Pagan-Godfrey, Goldfeld-Quandt, ANOVA |",
  "| 05_autocorrelacao_municipios.R | Durbin-Watson, ρ e Breusch-Godfrey por município |",
  "| 06_especificacao_chow.R | RESET, LM de tendência e teste de Chow |",
  "| 07_memorial_modelo_2.R | memorial matricial do Modelo 2 |", "",
  "Onde ler: `documentacao/00_resumo.md`. Verificações: `documentacao/08_verificacao.md`."))
message("Documentação gerada em ", DOC)
