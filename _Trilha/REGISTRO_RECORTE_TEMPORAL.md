# Registro do recorte temporal: onde mudar, se o recorte for alterado

Recorte atual: **2012 a 2021**, 29 municípios, 290 observações. Mantido em 23/11/2026 (decisão D-2026-11-23-02). Este arquivo lista onde as alterações deveriam ser feitas. Nenhuma alteração foi feita nesta data além da manutenção do recorte.

## 1. Parâmetros de código (alterar primeiro)

| Arquivo | Trecho | O que muda |
|---|---|---|
| `R/01_extracao_dados.R` | `ANOS_PADRAO <- 2012:2021` (linha ~131) | anos padrão da extração |
| `R/01_extracao_dados.R` | `validar_anos(anos, 2012, 2022, "RAIS")` (linha ~851) | limites aceitos para a RAIS |
| `R/01_extracao_dados.R` | tabela de tamanhos esperados da RAIS, por ano (linha ~215) | incluir os anos novos (tamanhos da listagem do FTP) |
| `R/01_extracao_dados.R` | `caminho_api` com `p/` dos anos (linha ~351) | anos pedidos ao SIDRA (PIB) |
| `R/01b_extracao_pam.R` | `ANOS <- 2012:2021` (linha ~37), `nrow(pam) != 290L` (linha ~74) | anos e tamanho da PAM |
| `R/02_tratamento_painel.R` | período e constantes de anos (cabeçalho, item 6) | período do painel e validações |
| `R/04_modelagem_diagnosticos.R` | `N_ANOS <- 10L` (linha ~50) | número de anos (usado na validação do painel) |
| `R/03_aede_visualizacoes.R` | `N_ANOS <- 10L` (linha ~106) e títulos com "2012 a 2021" | número de anos e rótulos das figuras |
| `R/05_autocorrelacao_municipios.R` | `DW_DL` e `DW_DU` (linhas ~38 e ~39) | valores de dL e dU da Tabela D.5A **só valem para n = 10 e k = 5**. Com outro número de anos, buscar outra linha da tabela |
| `R/06_especificacao_chow.R` | `ANO_CORTE <- 2017L` (linha ~49) | corte do Chow. Deve ser reescolhido a partir do gráfico `diag6` do novo recorte |
| `R/06_especificacao_chow.R` | projeção (`ano_ref <- max(painel$ano)`) | ano da projeção é o último ano do painel; se o recorte encurtar ou estender, muda automaticamente |
| `R/07_memorial_modelo_2.R` | `nrow(dados) != 290L`; Curitiba em 2021 (linhas ~63 e ~176) | tamanho do painel e ano da previsão de Curitiba |

## 2. Validações que assumem 290 observações e 10 anos

- `R/01b_extracao_pam.R`, `R/02_tratamento_painel.R`, `R/04_modelagem_diagnosticos.R` (função `carregar_painel`), `R/07_memorial_modelo_2.R`.
- `_Trilha/ferramentas/verificar_envio.R`: B1 (290 linhas, 29 x 10), C7 (decisões de Durbin-Watson com dL e dU fixos), C8 (Chow com corte de 2017), C10 (projeção de 2021).

## 3. Cache de dados brutos

- `dados_brutos/rais_YYYY.rds`: um arquivo por ano. Anos novos exigem baixar e processar a RAIS do FTP do Ministério do Trabalho (existem até 2025).
- `dados_brutos/pib_sidra.rds`, `pam_valor_producao.rds`, `macro_bacen.rds`: cache das APIs. Anos novos exigem nova consulta.
- Pastas `dados_brutos/_periodo_2012_2021` e `_periodo_2012_2022`: cache por período. Não apagar sem pedido.

## 4. Restrições que limitam o recorte

- **VAB setorial municipal (X3):** a SIDRA (tabela 5938, variáveis 498 e 517) não publica o VAB total nem o da indústria para 2022 e 2023. Sem X3, não há modelo para esses anos. Consulta feita em 23/11/2026.
- **PIB total:** disponível em 2022 e 2023 (variável 37), mas não usado no modelo.
- **RAIS:** disponível até 2025 no FTP do Ministério do Trabalho. Não há 2026.
- **Selic e IPCA:** Banco Central (SGS) disponível até 2026. Não é o fator limitante.
- **Opções já levantadas (23/11/2026):**
  1. Manter 2012 a 2021 (adotado).
  2. 2012 a 2025, trocando X3 por participação do emprego industrial (RAIS). Muda a definição de X3 em `CLAUDE.md` seção 6 e nas hipóteses aprovadas (H2). Impacto: alto.
  3. 2016 a 2021, mantendo X3. Reduz para 174 observações. Impacto: médio.

## 5. Documentação e registros

- `envio_professor/documentacao/*.md`, `envio_professor/LEIAME.md`: são gerados por `_Trilha/ferramentas/gerar_documentacao.R`. Os textos com "2012 a 2021", "290" e "dez anos" estão no próprio gerador. Após mudar o recorte, rodar `_Trilha/ferramentas/reconstruir_envio.sh`.
- `README.md`, `SUMARIO_DO_PROJETO.md`, `CATALOGO_DO_PROJETO.md` (gerado por `_Trilha/ferramentas/gerar_catalogo.R`), `_Trilha/ferramentas/gerar_catalogo.R` (título do projeto).
- `RESPOSTA_AO_PROFESSOR.txt`: cita 2012 a 2021, 290 observações, Chow de 2017, projeção de 2021 e Adrianópolis. Atualizar antes de qualquer envio.
- `CLAUDE.md`: seção 6 (recorte, unidades e decisão D-2026-11-16-07) e seção 2. Não editar sem pedido do pesquisador.
- `_Trilha/DECISOES.md`: registrar a nova decisão de recorte, sem apagar a anterior (D-2026-11-16-07 e D-2026-11-23-02).

## 6. Ordem sugerida, se o recorte mudar

1. Decidir o recorte e registrar em `DECISOES.md`.
2. Ajustar os parâmetros da seção 1 e baixar os anos novos (seção 3).
3. Refazer o painel (`R/02`), as figuras (`R/03`), o modelo e os diagnósticos (`R/04` a `R/07`).
4. Reescolher o corte do Chow a partir de `diag6` e atualizar `ANO_CORTE`.
5. Refazer a Tabela D.5A para o novo n e k, se o recorte mudar o número de anos.
6. Atualizar o gerador de documentação e o verificador (seção 2).
7. Rodar `reconstruir_envio.sh` e conferir a verificação.
8. Atualizar `RESPOSTA_AO_PROFESSOR.txt`, README, SUMARIO e CATALOGO.
