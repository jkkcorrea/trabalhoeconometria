# Registro de pendências aguardando a orientação do professor

Atualizado em 23/11/2026. Lista os trechos do artigo e dos slides que dependem da resposta do professor, onde estão, e o que mudar conforme a resposta. Para localizar as marcações: `grep -rn "aguardando orientação do professor" artigo/ apresentacao/`, e nos slides, `grep -rn "Aguardando orientação" apresentacao/deck_fonte/`.

Fontes atuais:
- Artigo: `artigo/ARTIGO_rascunho_v2.md` (a v1 fica como registro, sem edição).
- Slides: `apresentacao/ROTEIRO_SLIDES.md` (roteiro) e `apresentacao/deck_fonte/project/` (arquivos publicados no artefato de Slides; a publicação é a versão visível). Após mudar um slide, editar o arquivo em `deck_fonte/` e republicar no mesmo link.
- Artigo publicado no Claude Docs (https://claude.ai/artifact/7debwP1qtWSMGUh1UUqcjZ): ainda é a v1. Atualizar a partir da v2 após a resposta do professor.

## Itens

| Código | Assunto | Onde está no artigo (v2) | Onde está nos slides | O que mudar conforme a resposta |
|---|---|---|---|---|
| A1 | Procedimento quando a normalidade é rejeitada (Shapiro-Wilk, W = 0,8618) | §4.2, bullet "Normalidade"; §5.3, parágrafo após a FIGURA 4 | slide 15 (`diagnosticos.html`), nota do orador | Se o professor aceitar a limitação: manter. Se pedir outro procedimento: reescrever o parágrafo de §5.3 e a tabela de inferência; atualizar a nota do slide 15. |
| A2 | Forma funcional rejeitada pelo RESET (F = 14,49) | §4.2, bullet "Forma funcional"; §5.3 (tabela 4); §6 (Discussão) | slide 15 (nota); slide 20 (`limitacoes.html`) | Se o professor orientar outra especificação, rodar o modelo alternativo em `R/` e substituir os coeficientes na TABELA 3, a previsão da TABELA 5 e o texto da seção 4 e 5. |
| A3 | Autocorrelação positiva dentro dos municípios (DW mediana 0,25; 14 de 29 municípios) | §5.3 (tabela 4); APÊNDICE A (nota final); §6 | slide 16 (`autocorrelacao.html`), nota; slide 20 | Se o professor pedir correção: a inferência da TABELA 3 muda; refazer resultados e o slide 16. Se aceitar a limitação: manter. |
| A4 | Escolha do corte do Chow (2017, pelo gráfico) e comparação em 2016 | §4.2, bullet "Estabilidade"; legenda da FIGURA 1; tabela 4 | slide 10 (`tempo.html`), slide 16 (nota) | Se o professor pedir outro corte: escolher a partir da FIGURA 1, atualizar `ANO_CORTE` em `R/06_especificacao_chow.R` e os números da tabela 4 e do slide 16. |
| A5 | Projeção de 2021 dentro da amostra e correção aproximada exp(s²/2) = 1,0075 | §4.3; §5.5 (tabela 5) | slide 17 (`robustez.html`), nota | Se o professor rejeitar a correção: mostrar a previsão sem correção (já calculada em `projecao_selic_m2.csv`) e atualizar a TABELA 5 e o slide 17. |
| A6 | n = 87 no Gini e tratamento das divisões como indivíduos (fórmula de Hoffmann, aula) | §3.4 (Gini); TABELA 1 (linha X4) | slide 6 (`variaveis.html`), nota | Se o professor pedir outra definição: alterar §3.4, a TABELA 1, a seção 5.2 (H3) e os resultados; o Gini sem divisões vazias já está em `robustez_x4_definicao_gini.csv`. |
| A7 | Modelo sem variáveis binárias de município (orientação de Econometria I) | §4.1 (último parágrafo) | slide 11 (`modelo.html`), nota | Confirmação por escrito. Se o professor aceitar binárias: abrir decisão nova (D-AAAA-MM-DD-NN) e refazer o modelo; hoje o modelo principal não as usa. |

## Itens que não dependem do professor (mantidos no backlog de `_Trilha/BACKLOG.md`)

- Literatura do referencial (seção 2) e interpretação econômica (§5.2, §6, §7): pesquisador.
- Abstract, datas de acesso, editoras e anos de referências: marcações `[a confirmar]` e `[a inserir]` no artigo.
- Causa do salto de Adrianópolis em 2015 (R4 e R5 no backlog).

## Como refazer a figura ou a tabela após a resposta

1. Alterar a fonte em `R/` (script indicado em cada item) e rodar `Rscript R/00_executar_tudo.R` na raiz.
2. Reconstruir a pasta de envio com `bash _Trilha/ferramentas/reconstruir_envio.sh`.
3. Atualizar o artigo (`artigo/ARTIGO_rascunho_v2.md`), os slides (`apresentacao/deck_fonte/`) e republicar.
4. Remover a marcação "aguardando orientação do professor" do trecho resolvido e registrar a decisão em `_Trilha/DECISOES.md`.

## Tamanho e imagens (23/11/2026)

- Exemplos da disciplina em `Trabalhos Referencias/`: 6, 9, 19, 22 e 18 páginas (média 14,8; mediana 18).
- Artigo v2: texto de cerca de 2.700 palavras, com 5 tabelas, 4 figuras e 2 apêndices. Estimativa de 11 a 13 páginas em Arial 12 e entrelinha 1,5, com a seção 2 (referencial) ainda vazia. A diferença para a média dos exemplos vem sobretudo da revisão de literatura e da interpretação, que são do pesquisador.
- Figuras: largura de 16 cm no artigo (mancha de texto da UFPR) e altura máxima de 600 px nos slides, respeitando a proporção original de cada PNG (1,14 a 1,87).

## Comentário do professor sobre a resposta (23/11/2026, D-2026-11-23-08)

Avaliação completa em `_Trilha/AVALIACAO_COMENTARIO_PROFESSOR_20261123.md`. O professor não rejeitou métodos; pediu revisão da literatura, metodologia detalhada, discussão com a literatura, contribuição clara e explicação dos pontos levantados. Os itens A1 a A7 seguem abertos até o pesquisador confirmar com o professor; o texto agora os explica.

| Código | Pedido | Onde está no artigo (v2) | Estado |
|---|---|---|---|
| B1 | Revisão da literatura | Seção 2 (subseções 2.1 a 2.6, com placeholders [a inserir]) | Aberto: obras a ler pelo pesquisador |
| B2 | Metodologia detalhada | Seções 3.5, 4.1, 4.2 e 4.3 | Redigido; revisar |
| B3 | Discussão com a literatura | Seção 6 (6.1 a 6.6, com resultados e espaços [a inserir]) | Aberto: depende de B1 |
| B4 | Contribuição | Seções 6.7 e 7 | Candidatas redigidas; pesquisador decide |
| B5 | Pontos a explicar | Dummies: 4.1; normalidade, RESET, autocorrelação e Chow: 4.2 e 5.3; Gini: 3.4; projeção: 4.3; Adrianópolis e Araucária: 3.3 | Redigido; justificativas a validar |

Slides: acrescentados em 23/11/2026 os slides 3 (revisão da literatura) e 19 (contribuição), ambos com marcações de revisão; a numeração acima já considera os 22 slides.

## Referências (fontes/REFERENCIAS.md)

Lista central com links. Resolvido em 23/11/2026: autoria do Gujarati (4ª edição, só Gujarati, 2003), aulas de Hasegawa, links da fábrica de Adrianópolis, URLs das fontes de dados. Aberto: editora de Hoffmann, título e data do `.doc` da AEN, datas de acesso, edição de Gujarati das aulas (5ª), literatura de periódicos.

