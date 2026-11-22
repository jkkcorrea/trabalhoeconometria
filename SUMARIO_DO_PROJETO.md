# Sumário do projeto

Atualizado em 21/11/2026. Uma página para entender o projeto. Detalhes: `CATALOGO_DO_PROJETO.md`. Regras para IA: `instrucoes_ia/LEIA_PRIMEIRO.md`.

## Pergunta e dados

Salário médio real formal nos 29 municípios da Região Metropolitana de Curitiba (RMC), 2012 a 2021, painel de 290 observações. Trabalho de Econometria I, UFPR. A pergunta de pesquisa e a teoria são do pesquisador `[PESQUISADOR: definir]`.

Fontes: SIDRA/IBGE (PIB e valor adicionado), Banco Central (Selic, série 4390; IPCA, série 433), RAIS (microdados do Ministério do Trabalho), malha municipal do IBGE (`geobr`).

## Modelo

ln(Y) = β1 + β2·X2 + β3·X3 + β4·X4 + β5·X5 + β6·X6 + u

| Variável | O que mede | Unidade |
|---|---|---|
| Y | salário médio real formal | R$ de 2021 (modelo em logaritmo) |
| X2 | vínculos com ensino superior completo | % (0 a 100) |
| X3 | dominância industrial (VAB da indústria / VAB total) | % |
| X4 | diversificação setorial (entropia de Shannon na CNAE) | índice |
| X5 | Selic real anual (equação de Fisher) | % a.a. |
| X6 | distância do município ao centro de Curitiba | km |

Linha de base: MQO empilhado (Modelo 2). Referência para X2, X3 e X4: efeitos fixos/Mundlak, por presunção da sessão de 21/11/2026 (D-2026-11-21-20), **a confirmar pelo pesquisador**.

## Resultados-chave (fonte: `envio_professor/documentacao/00_resumo.md`)

- MQO empilhado, erro agrupado por município: X2 = 0,0159; X3 = 0,0054; X4 = 0,0762 (p = 0,1541); X5 = 0,0066; X6 = −0,0016 (p = 0,3394).
- Com efeitos de município: X2 = 0,0086; X3 deixa de ser significativo (−0,0005).
- O efeito de município é significativo (F = 75,8928) e o MQO empilhado é rejeitado nos testes de Hausman e Mundlak.
- Selic real: p-valor de 0,0005 a 0,0547, conforme o procedimento de inferência (resultado na fronteira de 5%).
- O Modelo 2 viola homocedasticidade, ausência de autocorrelação, normalidade e forma funcional; a inferência usa erros robustos e agrupados.
- Resultados são associações; limites em `envio_professor/documentacao/06_limitacoes.md`.

## Estrutura

| Pasta ou arquivo | Função |
|---|---|
| `R/` | scripts 00 a 08 (com comentários de processo) |
| `envio_professor/` | pasta de entrega, gerada; scripts sem comentários, dados, resultados, figuras, documentação |
| `envio_professor/documentacao/` | números, métodos e limitações validados (base para o artigo) |
| `instrucoes_ia/` | prompts do artigo e dos slides, regras e verificação de conteúdo |
| `.claude/skills/`, `.claude/agents/` | skills e agentes para IA |
| `_Trilha/` | decisões, pendências, handoffs e ferramentas |
| `artigo/`, `apresentacao/` | produção dos colegas (criadas quando necessário) |

## Como rodar

```
Rscript R/00_executar_tudo.R                       # scripts 02 a 08
bash _Trilha/ferramentas/reconstruir_envio.sh      # refaz envio_professor/ e verifica (49 verificações)
Rscript _Trilha/ferramentas/gerar_catalogo.R       # atualiza o catálogo
Rscript _Trilha/ferramentas/conferir_numeros.R rascunho.md   # confere números de um texto
```

Os dados brutos não vão para o repositório (`.gitignore`); veja `CONTRIBUIR.md`, seção 3.

## Regras em uma linha cada

1. Número só entra se estiver em `envio_professor/`.
2. O código manda; o texto se corrige.
3. Interpretação, sinais esperados e referências são do pesquisador; sem fonte, `[a confirmar]`.
4. `envio_professor/` não se edita à mão.
5. Ao terminar, envie ao repositório: branch próprio, `git push` e pull request (`CONTRIBUIR.md`). Nada de push direto na `main` nem de `--force`.

## Pendências abertas (ver `_Trilha/BACKLOG.md`)

Sinais esperados (cabe ao pesquisador); confirmação do modelo de referência (D-2026-11-21-20); texto do artigo e slides.
