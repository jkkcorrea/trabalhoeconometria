# Prompt para o Claude Code no VS Code — retomada do projeto "trabalho econometria"

Cole o bloco abaixo no Claude Code, com o workspace aberto na raiz `trabalho econometria/`.

---

Você está retomando o trabalho de Econometria I (UFPR), projeto em R, pasta raiz `trabalho econometria/`. Antes de qualquer ação, leia nesta ordem:

1. `CLAUDE.md` (regras do projeto, incluindo as restrições de não editar sem pedido, não apagar cache e não redigir texto acadêmico sem pedido expresso).
2. `_Trilha/_Handoffs/HANDOFF_vscode_20261121.md` (estado atual, pendências e decisões propostas).
3. `_Trilha/DECISOES.md` e `_Trilha/BACKLOG.md`.
4. `R/05_robustez_mundlak.R` (novo nesta data).

Não edite nenhum arquivo ainda. Primeiro faça o diagnóstico abaixo.

## Etapa 1: diagnóstico (somente leitura)

a) Verifique se existe `backup_antes_alteracoes/` na raiz. Se existir, liste o conteúdo.

b) Verifique se existem arquivos com prefixo `robustez_mundlak_` em `resultados_econometricos/` e se existem as duas figuras novas em `figuras_graficos/` (`robustez_mundlak_coeficientes.png` e `robustez_mundlak_dw_por_municipio.png`). Liste datas de modificação.

c) Procure por um relatório do Antigravity na raiz ou em `_Trilha/`. Se houver, leia: execução, validação dos itens a confirmar, comparação antes e depois, figuras e avisos do R.

d) Confirme que os quatro scripts editados contêm as alterações esperadas (use `grep`, não leitura integral):
   - `02_tratamento_painel.R`: texto "ignorada" e "cnae_validos".
   - `04_modelagem_diagnosticos.R`: "fator_smear", "GL_MUNICIPIOS_CONSERVADOR" e "d_municipios".
   - `01_extracao_dados.R`: "TRABALHO_ECONOMETRIA_CACHE".
   - `05_robustez_mundlak.R`: "executar_etapa_5".

Ao final, responda em uma tabela: item | situação | evidência (arquivo e linha ou data).

## Etapa 2: validação dos itens "a confirmar" (com base no relatório do Antigravity)

Para cada item, diga se ficou confirmado, refutado ou ainda pendente, com o número que o embasa:

1. S = 87 ou 86? (há "ignorada" entre as divisões?)
2. Quantos vínculos "ignorada" por ano e qual a fração do total?
3. A chamada de `fwildclusterboot::boottest` em `05` roda na versão instalada? Os argumentos são os aceitos pela versão? Se não, qual a correção, conforme `?boottest`?
4. O `plm::pbgtest` do modelo within rodou? Qual o p-valor?

Não altere o código para resolver esses itens. Só proponha a correção por escrito.

## Etapa 3: pendências (aguarde autorização)

Liste as pendências da seção 2 do handoff, com o arquivo e as linhas afetadas. Para cada uma, proponha a mudança em uma frase. Pergunte qual autorizar. Não execute nenhuma sem resposta.

## Regras durante toda a sessão

- Não rode `R/01_extracao_dados.R` (baixa cerca de 3,5 GB).
- Não apague `dados_brutos/`, `dados_processados/` nem `backup_antes_alteracoes/`.
- Não faça commit: não há git instalado.
- Não use `billing_id` nem `basedosdados`.
- Marque com `[a confirmar]` o que não foi verificado num R executado, e com `[presunção da modelagem]` a escolha metodológica sem fonte externa.
- Para registrar decisões em `_Trilha/DECISOES.md`, primeiro mostre o texto proposto e espere a aprovação. A numeração é a do pesquisador.
- Papel: atue como professor de Econometria I que valida o trabalho. Seja objetivo, sem elogios excessivos. Aponte o que está errado e o que falta.

Comece pelo diagnóstico da Etapa 1.

---
