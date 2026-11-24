# Prompt para construir a apresentação de slides

Como usar: abra a IA nesta pasta, cole este arquivo (ou peça "leia `instrucoes_ia/PROMPT_SLIDES.md` e siga"). No Claude Code, use o agente `designer-storytelling-slides`. Este arquivo não traz os slides prontos: traz o roteiro, as regras de leitura e de cor, e as fontes.

---

## Objetivo

Apresentar o projeto (salário médio real formal nos 29 municípios da RMC, 2012 a 2021) em painéis de leitura rápida, usando as figuras e os GIFs já produzidos. A plateia conhece o tema, mas não o R.

## Antes de começar

Leia: `instrucoes_ia/LEIA_PRIMEIRO.md`, `SUMARIO_DO_PROJETO.md`, `envio_professor/documentacao/00_resumo.md`, `06_limitacoes.md` e `.claude/skills/storytelling-graficos/SKILL.md`. Todo número do slide vem de `envio_professor/` (regra 1 de `LEIA_PRIMEIRO.md`).

## Regras de leitura humana

1. **Uma mensagem por slide.** O título é a mensagem, em frase completa (por exemplo, "O ensino superior é a variável que mais se associa ao salário" só se o resultado sustentar; senão `[PESQUISADOR: definir mensagem]`).
2. **Pouco texto.** No máximo 40 palavras por slide, fora figura e tabela. Tópicos de até 12 palavras. Nada de parágrafo.
3. **Figura grande.** A figura ocupa pelo menos metade da área útil. Use as imagens existentes; não redesenhe sem pedido.
4. **Legenda e fonte em todo painel**: fonte dos dados em corpo menor, na base.
5. **Um destaque por slide**: um número ou um elemento colorido. Os demais ficam neutros.
6. **Notas do apresentador**: duas a quatro frases por slide com o que dizer e de onde vem cada número.
7. **Frágil é dito como frágil.** Resultado que muda com a matriz de variância tem slide próprio ou nota.
8. Tamanho mínimo de fonte: título 32 pt, corpo 20 pt, fonte dos dados 12 pt.

## Paleta (clara, limpa, calma, de baixa luminosidade)

Fundo suave, sem branco puro e sem preto puro. Contraste do texto sobre o fundo conferido (razão de luminância pela fórmula WCAG; texto comum pede pelo menos 4,5).

| Uso | Cor | Contraste sobre o fundo `#EDEAE3` |
|---|---|---|
| Fundo do slide | `#EDEAE3` | — |
| Cartão / painel | `#F6F4EF` | — |
| Texto principal | `#2F3A3F` | 9,7 |
| Texto secundário | `#55616A` | 5,3 |
| Destaque principal (verde-azulado) | `#3C6A6D` | 5,0 |
| Série 2 (azul acinzentado) | `#496785` | 4,9 |
| Série 3 (argila) | `#85583C` | 5,0 |
| Série 4 (verde-sálvia) | `#4C6C54` | maior que 4,5 sobre o cartão |
| Alerta, uso raro (vermelho apagado) | `#9A4F49` | 4,9 |
| Linhas e grades | `#C9C5BB` | só decoração |

Regras: no máximo quatro cores por painel; cor nunca é a única informação (use também rótulo ou forma); não use vermelho e verde juntos para distinguir categorias. As figuras PNG já existentes têm paleta própria: coloque-as em cartão `#F6F4EF` com margem, sem filtro nem recoloração.

## Roteiro sugerido (ajuste ao tempo disponível)

Duração-base: 12 a 15 minutos, 12 a 14 slides.

| # | Slide | Conteúdo | Fonte |
|---|---|---|---|
| 1 | Título | Título, autores, disciplina, UFPR, data `[PESQUISADOR: definir]` | — |
| 2 | Pergunta | A pergunta de pesquisa `[PESQUISADOR: definir]` | — |
| 3 | Onde e quando | 29 municípios da RMC, 2012 a 2021, 290 observações | `01_dados_e_variaveis.md`; `mapa1_painel_espacial_rmc.png`, `legenda_municipios_rmc.png` |
| 4 | Como o salário se move | Distribuição do salário por ano | `fig2_ridgeplot_salario_anos.png` |
| 5 | Onde está a renda | Animação do mapa de renda | `animacao1_mapa_renda_rmc.gif` |
| 6 | Quem lidera | Ranking dos municípios | `animacao2_ranking_salario_municipios.gif` |
| 7 | As variáveis | X2 a X6 em uma tabela de uma linha cada (nome, o que mede, unidade) | `dicionario_variaveis.csv` |
| 8 | As variáveis se misturam? | Correlação entre explicativas | `fig1_matriz_correlacao.png` |
| 9 | Capital humano e indústria | Dispersão | `fig3_dispersao_capital_humano_industria.png` |
| 10 | O modelo | Equação e estimador em uma tela | `02_especificacao_e_metodos.md` |
| 11 | Resultado principal | Tabela curta dos coeficientes com a matriz principal | `coeficientes_cinco_matrizes.csv`, `tabela_comparativa_modelos.html` |
| 12 | O modelo se sustenta? | Diagnósticos e robustez do Gini | `diag1`, `diag2`, `diag5`, `robustez_x4_definicao_gini.csv` |
| 13 | Onde é frágil | Selic real, forma funcional, exogeneidade, Curitiba | `05_fragilidades.md`, `fragilidades_efeito_marginal_superior.png` |
| 14 | Conclusão e limites | Três frases `[PESQUISADOR: definir]` e limites de `06_limitacoes.md` | — |

Os GIFs só tocam no PowerPoint ou no navegador. No PDF eles viram imagem estática: para o PDF, use um quadro representativo e diga isso na nota.

## Formatos de entrega

Pergunte ao colega qual formato ele quer e use a ferramenta disponível:
- **PowerPoint (.pptx)**, preferido para apresentar. No Claude Code, use a skill de pptx, se disponível.
- **HTML de slides** (um arquivo, navegável por setas), se o colega não tiver PowerPoint.
- **Roteiro em Markdown** (`apresentacao/roteiro_slides.md`), sempre gerado: um bloco por slide, com título, texto, figura, fonte e nota do apresentador. Serve de base para qualquer formato.

Grave os arquivos em `apresentacao/`. Essa pasta é dos colegas; o pipeline não a toca.

## Conferência antes de entregar

1. Aplique `instrucoes_ia/VERIFICACAO_CONTEUDO.md` ao roteiro. Rode `Rscript _Trilha/ferramentas/conferir_numeros.R apresentacao/roteiro_slides.md`.
2. Abra cada figura usada e confirme que o título do slide diz o que a figura mostra.
3. Confirme o contraste do texto (razão pelo menos 4,5) e o tamanho mínimo de fonte.
4. Liste os `[PESQUISADOR: definir]` e `[a confirmar]` pendentes.

## Ao terminar

Lembre o colega de enviar o trabalho ao repositório: branch próprio, `git add` por nome, `git commit`, `git push -u origin <branch>` e pull request, como em `CONTRIBUIR.md`. Arquivos `.pptx` pesados: avise o responsável antes de enviar. Não faça o push sozinho.
