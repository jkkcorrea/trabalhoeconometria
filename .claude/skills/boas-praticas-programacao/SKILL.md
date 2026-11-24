---
name: boas-praticas-programacao
description: Use ao escrever ou revisar código R do projeto (extração, painel, modelos, gráficos): código completo, cache idempotente, validações, reprodutibilidade, estilo tidyverse, testes de consistência e como mudar resultado sem quebrar o envio.
---

# Boas práticas de programação (R) neste projeto

As regras de código estão em `CLAUDE.md` (seções 4 e 5). Este resumo é a lista de conferência.

## Código
1. **Completo.** Sem marcador de lacuna ("repita para os demais", reticências no lugar de lógica). Os 29 municípios aparecem explícitos onde a lista é usada.
2. **Cache idempotente.** Se o `.rds` existe em `dados_brutos/` ou `dados_processados/`, leia com `readRDS()`; se não, chame a API e grave com `saveRDS()`. Não repita requisição.
3. **Defensivo.** `tryCatch()` em API e leitura; no fim de cada bloco confira dimensão (linhas = n × T = 290), conte `NA`, `NaN`, `Inf` com `message()` e force numérico nas variáveis econômicas.
4. **Confira o dado em execução.** Compare nome e código devolvidos pela API com o esperado e pare com `stop()` em divergência.
5. **Estilo.** `tidyverse`, pipe consistente, `group_by`/`summarise`/`purrr::map` no lugar de `for`; nomes em snake_case e sem acento; funções pequenas com uma tarefa.
6. **Espacial.** Projete em EPSG 31982 antes de centroide ou distância em km.
7. **Reprodutível.** Caminhos relativos à raiz; semente fixa (`set.seed`) em tudo que é aleatório; versões em `ambiente_r.csv`; nenhum caminho absoluto, senha ou token.
8. **Marcas.** `[a confirmar]` para o que não foi conferido na fonte e `[presunção da modelagem]` para escolha sem fonte.

## Armadilhas já encontradas (não repetir)
- `tibble()`: coluna criada antes mascara objeto de mesmo nome.
- `confint.default(modelo, vcov. = V)` ignora `vcov.`; calcule estimativa ± t × erro.
- RESET com termos quadráticos: graus de liberdade pelo posto, não pela contagem de colunas.
- `gganimate` interpola texto como cor: rótulos de animação como fator.
- `sprintf` com % literal: escreva `%%`.

## Fluxo de mudança
1. Altere o script de `R/` (nunca `envio_professor/` à mão).
2. Rode `Rscript R/00_executar_tudo.R` e leia as mensagens.
3. Se resultado, documentação ou figura mudou: `bash _Trilha/ferramentas/reconstruir_envio.sh` e exija "N de N verificações aprovadas". Não afrouxe tolerância de verificação para passar.
4. Registre decisão em `_Trilha/DECISOES.md` (só com texto literal do pesquisador).
5. Atualize o catálogo (`Rscript _Trilha/ferramentas/gerar_catalogo.R`).

Ao terminar: lembre o colega de enviar o trabalho ao repositório (branch próprio, commit, `git push -u origin <branch>`, pull request; ver `CONTRIBUIR.md`). Não faça o push sozinho.
