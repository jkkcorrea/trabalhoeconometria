# Prompt para construir o artigo, seção por seção

Como usar: abra a IA nesta pasta, cole este arquivo (ou peça "leia `instrucoes_ia/PROMPT_ARTIGO.md` e siga"). No Claude Code, use o agente `construtor-artigo`. Trabalhe **uma seção por vez** e só avance depois da conferência da seção.

Este arquivo não traz texto do artigo. Ele diz o que cada seção precisa conter, de onde vêm os dados e o que fica para o pesquisador decidir.

---

## Papel da IA

Você ajuda a redigir o artigo do trabalho de Econometria I (UFPR) sobre o salário médio real formal nos 29 municípios da Região Metropolitana de Curitiba, 2012 a 2021. Você organiza, redige e confere. O pesquisador decide teoria, sinais esperados e interpretação.

Antes de escrever, leia, nesta ordem:
1. `instrucoes_ia/LEIA_PRIMEIRO.md`
2. `SUMARIO_DO_PROJETO.md`
3. `envio_professor/documentacao/00_resumo.md` até `06_limitacoes.md`
4. `.claude/skills/estrutura-artigo-ufpr/SKILL.md`, `.claude/skills/formatacao-abnt/SKILL.md` e `.claude/skills/escrita-cientifica/SKILL.md`

## Regras de redação

- Linguagem clara e objetiva: frases curtas, voz ativa, um tema por parágrafo, termos técnicos definidos na primeira vez.
- Todo número vem de `envio_professor/` e leva a origem anotada num comentário HTML ao lado (`<!-- fonte: coeficientes_cinco_matrizes.csv -->`). Esses comentários saem na versão final.
- Onde faltar decisão do pesquisador: `[PESQUISADOR: definir]`. Onde faltar fonte: `[a confirmar]`.
- Nunca invente referência bibliográfica, sinal esperado, hipótese ou conclusão. Se o pesquisador não deu a obra, peça.
- Resultado frágil é dito como frágil. Não use "prova" nem linguagem causal.
- Formatação segundo as skills `formatacao-abnt` e `estrutura-artigo-ufpr`.

## Fluxo de cada seção

1. **Plano.** Liste em tópicos o que a seção vai dizer, com a fonte de cada afirmação. Mostre ao pesquisador.
2. **Rascunho.** Escreva só o que o plano cobre.
3. **Conferência.** Aplique `instrucoes_ia/VERIFICACAO_CONTEUDO.md` e rode `Rscript _Trilha/ferramentas/conferir_numeros.R <arquivo>`. Entregue o relatório com o rascunho.
4. **Aprovação.** O pesquisador aprova ou pede ajuste. Só então passe à próxima seção.
5. **Registro.** Decisão do pesquisador vai para `_Trilha/DECISOES.md` (literal).

Grave os rascunhos em `artigo/` (por exemplo `artigo/01_introducao.md`). Essa pasta é do pesquisador e dos colegas; o pipeline não a toca.

## Roteiro das seções

A ordem segue a estrutura de artigo da UFPR (ver a skill `estrutura-artigo-ufpr`). Os títulos de seção são sugestão; o pesquisador pode ajustar.

### Resumo (100 a 250 palavras) e palavras-chave
Escreva por último. Conteúdo: objetivo, método, principais resultados (com números da fonte), conclusão. Uma frase por elemento, em parágrafo único. Fonte dos números: `documentacao/00_resumo.md`. Palavras-chave: três a cinco, definidas pelo pesquisador `[PESQUISADOR: definir]`.

### 1 Introdução
- Problema: por que o salário médio formal varia entre os municípios da RMC `[PESQUISADOR: definir motivação e contexto]`.
- Pergunta e objetivo: `[PESQUISADOR: definir]`.
- Dados e recorte em uma frase: 29 municípios, 2012 a 2021 (`01_dados_e_variaveis.md`).
- Resumo da abordagem e do achado principal, sem detalhar números.
- Roteiro do artigo (uma frase por seção).

### 2 Revisão de literatura
- Teoria do capital humano, aglomeração e especialização industrial, diversificação setorial, política monetária e salário real, distância ao centro `[PESQUISADOR: definir obras e argumentos]`.
- A IA pode propor a estrutura de parágrafos e perguntas a responder, mas as obras e as citações vêm do pesquisador. Obras da pasta `Trabalhos Referencias/` servem de referência de estrutura; não copie texto.
- Para cada variável, deixe a lacuna do sinal esperado marcada: `[PESQUISADOR: definir sinal esperado de X2]` e assim por diante.

### 3 Metodologia
Fonte principal: `documentacao/01_dados_e_variaveis.md` e `02_especificacao_e_metodos.md`.
- Unidade, período, fontes dos dados (SIDRA/IBGE, Banco Central, RAIS) e construção das variáveis (Y, X2 a X6), com unidade de cada uma.
- Equação do modelo principal, igual à de `02_especificacao_e_metodos.md`.
- Modelo principal e por quê: o que está em `00_resumo.md` e em `_Trilha/DECISOES.md`. Confirmar com o pesquisador antes de escrever.
- Erros-padrão: clássico e de White (HC1). Diga qual é o principal.
- Testes de diagnóstico usados (multicolinearidade, heterocedasticidade, autocorrelação, forma funcional, quebra estrutural, efeito de município).
- Tratamento de observações atípicas (Araucária 2012 e 2013, VAB da indústria negativo).

### 4 Resultados
Fonte: `documentacao/03_resultados_modelos.md`, `04_diagnosticos.md`, `05_limitacoes.md`.
- Estatísticas descritivas: `dados_processados/estatisticas_descritivas.csv` e figuras `fig2` e `fig3`.
- Estimativas do Modelo 2 e comparação com os Modelos 3 e 3b: `coeficientes_cinco_matrizes.csv`, `tabela_comparativa_modelos.html`.
- Diagnósticos: `diagnosticos_modelo_2.csv`, figuras `diag1` a `diag4`.
- Robustez: definição do Gini (87 divisões e divisões com vínculo), Selic real, forma funcional (RESET), normalidade (Shapiro-Wilk).
- Para cada tabela e figura: título, fonte e uma frase com o que o leitor deve ver. A interpretação econômica dos coeficientes fica `[PESQUISADOR: definir]`.

### 5 Discussão (se o pesquisador quiser separar da conclusão)
- Resultados robustos e resultados frágeis, lado a lado (`05_fragilidades.md`).
- Limitações: `06_limitacoes.md`, com as palavras do próprio arquivo quando possível.
- Interpretação teórica: `[PESQUISADOR: definir]`.

### 6 Conclusão (ou Considerações finais)
- Responde à pergunta da Introdução, retoma os achados principais com números da fonte e aponta limites e próximos passos.
- Nada novo: não introduz resultado que não esteja em Resultados.

### Referências
- Apenas obras citadas no texto, em ABNT (NBR 6023). Dados públicos citados com fonte, endereço e data de acesso.
- Pacotes de R usados: `documentacao/ambiente_r.csv` traz as versões; as referências dos pacotes vêm de `citation("pacote")` conferido no R `[a confirmar]`.

### Apêndices e anexos (opcionais)
- Apêndice: tabelas completas, memorial matricial (`memorial_modelo_2.txt`), dicionário de variáveis.
- Anexo: só material não elaborado pelo autor.

## Mapa de figuras para o artigo

Nomes exatos em `envio_professor/figuras_graficos/`. Use no máximo as que a seção precisa.

| Figura | Seção sugerida | Mensagem |
|---|---|---|
| `mapa1_painel_espacial_rmc.png` e `legenda_municipios_rmc.png` | Metodologia ou Resultados (descritivas) | distribuição espacial das variáveis |
| `fig1_matriz_correlacao.png` | Resultados (descritivas) | correlação entre explicativas |
| `fig2_ridgeplot_salario_anos.png` | Resultados (descritivas) | distribuição do salário por ano |
| `fig3_dispersao_capital_humano_industria.png` | Resultados (descritivas) | relação entre ensino superior, indústria e salário |
| `diag1` a `diag4` | Resultados (diagnóstico) | resíduos, autocorrelação, normalidade |
| `fragilidades_efeito_marginal_superior.png` | Discussão | efeito marginal de X2 |
| GIFs `animacao1` e `animacao2` | não entram no artigo impresso; servem para os slides | |

Antes de citar uma figura, abra a imagem e confirme que ela mostra o que o texto diz.

## Ao terminar cada sessão

1. Entregue a lista de pendências (`[PESQUISADOR: definir]` e `[a confirmar]` ainda abertos).
2. Lembre o colega de enviar o trabalho ao repositório: branch próprio, `git add` por nome, `git commit`, `git push -u origin <branch>` e pull request, como em `CONTRIBUIR.md`. Não faça o push sozinho.
