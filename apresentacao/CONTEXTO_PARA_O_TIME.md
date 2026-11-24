# Contexto para o time de apresentação

Written for: colegas do time de apresentação, sem acesso ao código, que vão falar sobre os slides e explicar o artigo.

**Status: [revisar]** Este documento inteiro é rascunho. Qualquer número, frase ou leitura pode mudar após a revisão do pesquisador e a resposta do professor. Antes de usar, conferir a data e os itens marcados com `[aguardando orientação do professor]`, listados em `_Trilha/REGISTRO_PENDENCIAS_PROFESSOR.md`.

## 1. O que o trabalho pergunta

A estrutura produtiva de um município da Região Metropolitana de Curitiba (RMC) se associa ao salário médio real dos vínculos formais? A estrutura produtiva é descrita por cinco características: escolaridade, participação da indústria, diversificação setorial do emprego, Selic real e distância até Curitiba.

**Ponto de cuidado [revisar]:** o trabalho descreve associações, não causas. Não dizer que um fator "causa" o salário. A frase correta é "está associado a".

## 2. Dados em uma página

- **Unidades:** 29 municípios da RMC, de 2012 a 2021. São 290 observações, em painel balanceado (cada município tem os 10 anos).
- **Fontes:** RAIS (salário, escolaridade e setores de emprego); IBGE/SIDRA, tabela 5938 (valor adicionado por setor, usado na indústria); Banco Central (Selic e IPCA); IBGE (distância até Curitiba).
- **Recorte:** 2012 a 2021. Antes de 2012 e depois de 2021 não há valor adicionado setorial municipal disponível para o modelo.
- **Valores em reais de 2021**, corrigidos pelo IPCA.

## 3. As cinco variáveis, em linguagem simples

| Sigla | Nome | O que significa | Sinal esperado [revisar: decisão do pesquisador] |
|---|---|---|---|
| Y | Salário médio real | Quanto, em média, ganha um vínculo formal no município (usa-se o logaritmo) | — |
| X2 | Escolaridade | % de vínculos com ensino superior completo | positivo |
| X3 | Industrialização | Parcela do valor adicionado que vem da indústria, em % | positivo |
| X4 | Diversificação (Gini) | Quanto o emprego está concentrado em poucos setores (87 divisões da CNAE). Gini alto = concentração. | negativo no Gini (ou seja, mais diversidade associa-se a salário maior) |
| X5 | Selic real | Juros básicos descontada a inflação, em % ao ano | exploratório |
| X6 | Distância | Quilômetros até Curitiba | negativo |

**Ponto de cuidado:** o Gini é difícil de explicar. Use a frase: "quanto menos o emprego se concentra em poucos setores, menor o índice". O índice cai quando mais setores têm vínculos.

## 4. Resultado principal, em uma frase cada

- **Escolaridade:** mais 1 ponto percentual de vínculos com superior associa-se a salário cerca de 1,5% maior.
- **Industrialização:** coeficiente positivo e significativo (p < 0,0001).
- **Gini:** diversificação maior associa-se a salário maior (coeficiente −0,65, p = 0,0001).
- **Selic real:** associação positiva pequena, de cerca de 0,66% por ponto percentual (IC 95%: 0,30% a 1,01%). Ressalva: só há 10 valores anuais.
- **Distância:** mais 10 km associa-se a salário cerca de 1,6% menor.

Modelo: MQO com erros robustos de White. R² ajustado 0,643.

## 5. Diagnósticos: o que dizer quando perguntarem

- Multicolinearidade: não há (FIV máximo 2,33).
- Heterocedasticidade: rejeitada (Breusch-Pagan, p = 0,036). Por isso os erros são robustos.
- Normalidade: rejeitada (Shapiro-Wilk). Limitação declarada. **[aguardando orientação do professor — item A1]**
- Forma funcional: o teste RESET rejeita a forma linear. Limitação declarada. **[aguardando orientação do professor — item A2]**
- Autocorrelação dentro dos municípios: positiva em 14 de 29 municípios. Limitação declarada. **[aguardando orientação do professor — item A3]**
- Quebra estrutural: o teste de Chow não encontra quebra em 2017 (p = 0,146). **[aguardando orientação do professor — item A4]**

## 6. Slide a slide

Os slides estão no artefato de Slides (link no registro de pendências). A fonte está em `apresentacao/deck_fonte/project/`. Tempo estimado: 12 a 15 minutos.

1. **Título.** Apresentar o trabalho. Trocar `[Nome do pesquisador]` e `[data da apresentação]` antes de usar.
2. **Pergunta.** Ler a pergunta em voz alta. Dizer que o trabalho descreve associações.
3. **Dados.** Mostrar o mapa dos 29 municípios. Falar das quatro fontes e do painel de 290 observações.
4. **Hipóteses.** Explicar a hipótese nula (o salário não depende das características) e os sinais esperados. **[revisar: sinais definidos pelo pesquisador]**
5. **Variáveis e Gini.** Explicar a fórmula do Gini de forma simples. Mostrar a matriz de correlação (figura `fig1`). Dizer que o Gini é correlacionado com o número de setores (−0,95). **[aguardando orientação do professor — item A6]**
6. **Descrição dos dados.** Médias: salário R$ 2.651; escolaridade 15,3%; indústria 25,7%; Selic 2,3% a.a.; distância 46 km. Mostrar a distribuição do salário por ano (figura `fig2`).
7. **O que o gráfico no tempo mostra.** Salário com pico em 2017; Selic alta em 2016 e 2017 e depois queda; escolaridade desacelera depois de 2017. A linha tracejada marca a quebra testada. **[aguardando orientação do professor — item A4]**
8. **Modelo.** Mostrar a equação. Explicar que não há binárias de município e não há métodos de painel, por escopo da disciplina. **[aguardando orientação do professor — item A7]**
9. **Resultados principais.** Ler a tabela. Lembrar que os erros são de White.
10. **Leitura dos coeficientes.** Ler as frases prontas, com "associado a" em todas. **[revisar: leitura econômica pelo pesquisador]**
11. **Hipóteses e resultado.** H1, H2, H3, H5 confirmadas nos sinais esperados. H4 (Selic) é exploratória, com ressalva.
12. **Diagnósticos.** Mostrar o gráfico Q-Q (figura `diag5`). Explicar por que a normalidade rejeitada é limitação. **[aguardando orientação do professor — itens A1 e A2]**
13. **Autocorrelação e quebra.** Durbin-Watson mediano 0,25; autocorrelação positiva em 14 de 29 municípios. Chow em 2017 e 2016 não rejeita a quebra. **[aguardando orientação do professor — itens A3 e A4]**
14. **Robustez e previsão.** Gini só com divisões com vínculo: −0,638 (mesmo sinal). Previsão de 2021 dentro da amostra: R$ 2.622, com +1 ponto de Selic R$ 2.639 e com −1 ponto R$ 2.605. **[aguardando orientação do professor — item A5]**
15. **Caso de Adrianópolis.** Participação da indústria saltou de 7,1% (2014) para 45,5% (2015). A hipótese de uma fábrica de cimento (inaugurada em dezembro de 2015) é plausível e **não confirmada**. O emprego industrial formal só cresce em 2017. Mostrar a figura `fig3`. **[revisar: decidir se o caso fica nos slides ou só no texto]**
16. **Limitações.** Associações, não causas; forma funcional e normalidade rejeitadas; autocorrelação; dependência do Gini; recorte de 2012 a 2021.
17. **Conclusão.** Repetir o que o modelo mostra, com as ressalvas. **[revisar: fechamento a cargo do pesquisador]**
18. **Referências.** Algumas ainda precisam de confirmação. **[revisar: ver `artigo/ARTIGO_rascunho_v2.md`]**

## 7. Seções do artigo

O artigo está em `artigo/ARTIGO_rascunho_v2.md`. Seções:

- **Resumo e palavras-chave** (100 a 250 palavras, conforme a UFPR). **[a inserir: Abstract em inglês]**
- **1 Introdução.** Problema, pergunta, objetivo e sinais esperados. **[revisar: motivação e contribuição, a cargo do pesquisador]**
- **2 Referencial teórico.** Vazio por enquanto. **[a inserir pelo pesquisador: literatura sobre salário, estrutura produtiva e juros]**
- **3 Metodologia.** Subseções: unidades e período; fontes e variáveis (TABELA 1); estatísticas descritivas (TABELA 2, FIGURAS 1 a 3, esta sobre Adrianópolis); construção do Gini (3.4) e procedimento de tratamento dos dados (3.5).
- **4 Modelo e métodos.** Equação (1), testes e diagnósticos, previsão. Os testes têm objetivo declarado.
- **5 Resultados.** Coeficientes (TABELA 3), hipóteses, diagnósticos (TABELA 4, FIGURA 4), robustez, previsão de 2021 (TABELA 5).
- **6 Discussão.** **[revisar: discussão do pesquisador]**
- **7 Conclusão.** **[revisar: a cargo do pesquisador]**
- **Referências.** Algumas marcadas para conferência.
- **Apêndice A.** Autocorrelação por município (29 linhas).
- **Apêndice B.** Lista dos 29 municípios com código IBGE.

**Ponto de cuidado:** o texto não traz interpretação teórica dos sinais. Essa parte é do pesquisador.

## 8. Imagens e figuras

Cada figura tem título acima e fonte abaixo, conforme a UFPR. A figura de Adrianópolis (`fig3`) tem dois painéis. Não usar as figuras animadas (GIFs) no artigo; elas estão em `figuras_graficos/` apenas para apresentação oral, se o pesquisador quiser.

## 9. Quando o professor responder

Consultar `_Trilha/REGISTRO_PENDENCIAS_PROFESSOR.md`. Lá estão os sete itens (A1 a A7), com a localização de cada trecho e o que muda em cada caso. Antes de apresentar, procurar as marcações `aguardando orientação do professor` no artigo e `Aguardando orientação` nas notas dos slides, e tirar as que forem resolvidas.

## 10. Checklist de revisão deste documento [revisar]

- [ ] Números conferidos com `envio_professor/documentacao/`
- [ ] Sinais esperados confirmados pelo pesquisador
- [ ] Itens A1 a A7 resolvidos ou mantidos como limitação
- [ ] Caso de Adrianópolis: decidir se entra nos slides
- [ ] Referências conferidas (editora de Hoffmann, ano de Hasegawa, links do caso de Adrianópolis)
- [ ] Nome e data da apresentação preenchidos

## 11. O que o professor pediu para o relatório (23/11/2026) [revisar]

O professor deu atenção especial ao relatório final e pediu: (1) contextualização do problema por revisão da literatura; (2) metodologia detalhada, com todo o procedimento; (3) discussão dos resultados dialogando com a literatura; (4) contribuição clara na discussão e nas considerações finais; (5) mais explicação dos pontos levantados na resposta a ele.

- **Já no artigo (v2):** metodologia detalhada (seções 3.5, 4.1, 4.2 e 4.3); discussão por hipótese com os resultados e a magnitude (seção 6); contribuição candidata (seção 6.7).
- **Ainda do pesquisador:** a revisão da literatura (seção 2) e a comparação com a literatura na discussão. Os espaços estão marcados com `[a inserir]`. As obras candidatas para procurar estão em `_Trilha/AVALIACAO_COMENTARIO_PROFESSOR_20261123.md`, e nenhuma foi lida.
- **Para quem apresenta:** falar da contribuição como descritiva ("associação"), nunca como causal, e dizer que a revisão da literatura está em construção enquanto a seção 2 estiver com `[a inserir]`.
- **Slides:** faltam dois slides (literatura e contribuição), que entram depois que o pesquisador fechar essas partes.
