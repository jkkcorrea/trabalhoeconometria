# =============================================================================
# Execução de todo o pipeline, na ordem, cada script em um processo separado
#
# Uso, a partir da raiz do projeto:  Rscript R/00_executar_tudo.R
# O script 01 (coleta, cerca de 3,5 GB de download da RAIS) só roda se a variável
# de ambiente INCLUIR_EXTRACAO for "sim".
# =============================================================================

if (!dir.exists("R") || !dir.exists("dados_brutos")) {
  stop("O diretório de trabalho atual (", getwd(), ") não é a raiz do projeto.", call. = FALSE)
}

scripts <- c(
  "02_tratamento_painel.R", "03_aede_visualizacoes.R", "04_modelagem_diagnosticos.R",
  "05_robustez_mundlak.R", "06_calibracao_modelo.R", "07_memorial_modelo_2.R", "08_fragilidades_modelo.R"
)
if (identical(Sys.getenv("INCLUIR_EXTRACAO"), "sim")) scripts <- c("01_extracao_dados.R", scripts)

executavel <- file.path(R.home("bin"), "Rscript")
resultado <- data.frame(script = scripts, situacao = NA_character_, segundos = NA_real_)
for (i in seq_along(scripts)) {
  inicio <- Sys.time()
  status <- system2(executavel, c("--vanilla", file.path("R", scripts[i])), stdout = FALSE, stderr = FALSE)
  resultado$situacao[i] <- if (status == 0) "ok" else paste("erro (status", status, ")")
  resultado$segundos[i] <- round(as.numeric(difftime(Sys.time(), inicio, units = "secs")), 1)
  message(sprintf("%-32s %s (%.1f s)", scripts[i], resultado$situacao[i], resultado$segundos[i]))
  if (status != 0) stop("O script ", scripts[i], " terminou com erro; veja a mensagem rodando-o isoladamente.", call. = FALSE)
}
print(resultado, row.names = FALSE)
