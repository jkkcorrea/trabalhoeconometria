# HANDOFF — retomada no VS Code (21/11/2026)

Documento de passagem entre sessões. Leia junto com `CLAUDE.md`, `_Trilha/DECISOES.md` e `_Trilha/BACKLOG.md`. Não substitui essas regras.

## 1. Estado do código

Editado nesta data (conferido no disco: tamanhos batem com as versões gravadas):

| Arquivo | O que mudou | Ligação com a lista de alterações |
|---|---|---|
| `R/01_extracao_dados.R` | Biblioteca do usuário e cache da RAIS funcionam fora do Windows. No Windows o cache continua em `%LOCALAPPDATA%/trabalho_econometria_rais`; no Linux, `~/.cache/trabalho_econometria_rais`. Variável `TRABALHO_ECONOMETRIA_CACHE` tem prioridade. | A7 |
| `R/02_tratamento_painel.R` | Rótulo "ignorada" excluído do Shannon e de S. Aviso se S ≠ 87. Para se algum par município-ano ficar sem divisão válida. | A6, A8 |
| `R/04_modelagem_diagnosticos.R` | DW calculado por município (linha extra `d de Durbin-Watson médio por município`); DW empilhado rotulado como inválido. Nota do Newey-West como referência. t da simulação com G − 1 = 28. Retransformação com smearing de Duan (`fator_smear`). Biblioteca no Linux. | A1, A3, A4, A5, A7 |
| `R/05_robustez_mundlak.R` | **Novo.** Mundlak com médias por município (`media_prop`, `media_dom`, `media_shannon`), teste conjunto, bootstrap `fwildclusterboot` (B = 9999), teste de Breusch-Godfrey de painel (`plm::pbgtest`, modelo within) e duas figuras de conferência. | B1, B2, B3, C1 |
| `R/03_aede_visualizacoes.R` | Não alterado. | — |

**Resultados ainda não reconciliados:** antes desta edição, as tabelas e figuras em `resultados_econometricos/` e `figuras_graficos/` eram da versão anterior. O Antigravity foi instruído a copiar o estado anterior para `backup_antes_alteracoes/` e a rodar as etapas 2, 4 e 5. O relatório dele ainda não foi analisado.

## 2. Pendências de código (não feitas)

1. **Rotular o Breusch-Godfrey do `04`** (linha `bgtest(modelo, order = 1)`, em `diagnosticar_modelo_2`). Ainda usa o painel empilhado. A referência válida está no `05`. Aguardando autorização para editar.
2. **B4:** centralizar `dom_industrial` e `dist_curitiba_km` antes da interação do Modelo 3b (`04`, `FORMULA_M3B`). Reportar as duas versões.
3. **C2:** RESET no Mundlak e no 3b (`lmtest::resettest`).
4. **C3:** teste de quebra estrutural entre Curitiba e os demais municípios.
5. **C4:** p-valor conservador da Selic (G − 1 = 9 por ano) também no Mundlak.
6. **Infraestrutura:** `00_pacotes.R`, `rodar_tudo.R` (ordem 01 → 02 → 03 → 04 → 05, com opção de pular o 01) e README.
7. **Backlog 14:** acabamento de figuras (opcional, só se o pesquisador pedir).

## 3. Itens "a confirmar" — situação

| Item | Situação |
|---|---|
| Total de divisões CNAE 2.0 = 87 | **Confirmado** (IBGE: 21 seções, 87 divisões). Backlog 13 pode ser fechado. |
| S = 87 com os dados da RAIS | **Pendente de checagem.** Se "ignorada" for uma das 87, o valor válido é 86. Bloco de checagem está no prompt do Antigravity (seção 4). |
| Quantidade de vínculos "ignorada" por ano | **Pendente.** Mesmo bloco. |
| Argumentos do `fwildclusterboot::boottest` | **Pendente.** Versão CRAN 0.13.0 existe; argumentos mudaram entre versões. A chamada no `05` é a mais incerta e precisa ser conferida com `?boottest` no ambiente instalado. |
| `plm::pbgtest` | **Confirmado** como função de teste de Breusch-Godfrey de painel (Wooldridge). Conferir se o modelo within roda sem erro. |
| Ordem do painel (município, ano) | **Confirmado** no código. |

## 4. Decisões a registrar (não registradas ainda)

Não foram gravadas em `_Trilha/DECISOES.md`. Cabe ao pesquisador aprovar e numerar. Proposta, com numeração provisória:

- **D-prov-A (2026-11-21): especificação principal.** Pooled com erros agrupados por município (mantém D-2026-11-16-10). Mundlak como robustez. Efeitos fixos não adotados, porque eliminam `dist_curitiba_km` e `dummy_curitiba`.
- **D-prov-B: Shannon.** Vínculos com divisão "ignorada" excluídos de X4 e de S. Alternativa: tratar como categoria. Requer confirmação do pesquisador depois de ver a quantidade do Antigravity.
- **D-prov-C: DW e Newey-West.** Não usados como evidência de autocorrelação no painel empilhado. Evidência passa a ser o DW por município e o teste de painel.
- **D-prov-D: retransformação.** Smearing de Duan na simulação e nos intervalos; a variação percentual não muda.
- **D-prov-E: graus de liberdade.** G − 1 nos intervalos com erros agrupados por município (28).

## 5. Regras que valem nesta retomada

- Não editar `R/` sem autorização explícita, a não ser o que já foi pedido.
- Não rodar `R/01_extracao_dados.R` sem pedido: baixa cerca de 3,5 GB da RAIS.
- Não apagar `dados_brutos/`, `dados_processados/` nem `backup_antes_alteracoes/`.
- Não redigir texto acadêmico sem pedido expresso.
- Não usar `billing_id` nem `basedosdados` sem autorização expressa.
- Marcar `[a confirmar]` e `[presunção da modelagem]` onde couber.
- Não há git instalado; não fazer commit.

## 6. Próximo passo

1. Ler o relatório do Antigravity (comparação antes e depois, validação, figuras, avisos).
2. Responder às perguntas de validação da seção 3 com os números do relatório.
3. Autorizar ou recusar as pendências da seção 2 e as decisões da seção 4.
