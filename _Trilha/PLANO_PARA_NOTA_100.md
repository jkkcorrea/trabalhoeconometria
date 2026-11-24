# Plano para subir a nota e chegar a 100 (registro de 23/11/2026)

Base: correção do agente `professor-econometria` em 23/11/2026, régua de 100 pontos de `.claude/skills/professor-econometria/SKILL.md`. Nota pela régua: **69/100**. Nota efetiva se o artigo fosse entregue como estava: **55 a 60**, porque o comentário real do professor põe o peso na literatura, na discussão e na contribuição, que a régua não mede. Com a literatura e a discussão escritas, o agente estimou **77**, e **cerca de 84** com as correções técnicas.

Leitura honesta do objetivo: 100 só é alcançável se o professor aceitar o que hoje está fora do escopo (erros agrupados, métodos de painel, binárias de município). Dentro do escopo atual, o teto realista que estimo é de **cerca de 92 a 95**; a estimativa é minha, não do agente. A nova nota só vale depois de uma nova correção com o agente.

Notação: **Código** = a sessão faz em `R/`; **Texto** = a sessão redige o procedimento; **Pesquisador** = decisão ou leitura sua; **Professor** = depende da resposta dele. "Tratado" = já mexido em 23/11/2026, mas ainda não reavaliado.

## 1. Critério por critério da régua

| Critério | Atual | Perdido | Por que perdeu (evidência da correção) | O que fazer | Quem | Ganho possível |
|---|---|---|---|---|---|---|
| 1. Especificação e coerência econômica | 4/10 | −6 | Seção 2 vazia, sinais esperados sem fundamento, H4 declaradamente sem teoria; porte omitido (Gini × ln dos vínculos: −0,88); RESET rejeita | (a) escrever a revisão da literatura e fundamentar H1 a H5; (b) decidir H4: fundamentar com literatura ou tratar a Selic como controle macro e não como hipótese; (c) decidir A8 (porte no modelo principal); (d) testar reespecificação para o RESET, por exemplo termos quadráticos de X2 e X3 (a aula de 2022 trata da forma funcional incorreta), e reportar o RESET de cada versão | Pesquisador (a, b); Professor e Código (c, d) | +4 a +5 |
| 2. Dados e construção das variáveis | 8/10 | −2 | X3 negativo sem sensibilidade; painel carrega `valor_producao_mil` e `ln_producao_agricola` sem uso | Sem Araucária 2012 e 2013: **tratado** (`robustez_porte_e_negativos.csv`). Tirar as colunas da PAM do painel final ou justificar o uso | Código | +2 |
| 3. Estimação e memorial matricial | 13/15 | −2 | Artigo não traz ANOVA, memorial nem F incremental (só em `envio_professor/`); valores fora das quatro casas (W = 0,862 nos slides; p = 0,001) | Levar ANOVA, determinação parcial, F incremental e o resumo de (X'X)⁻¹ para um apêndice do artigo; padronizar quatro casas no artigo e nos slides (artigo e slides **tratados**) | Texto | +2 |
| 4. Inferência clássica | 7/10 | −3 | O erro de White ignora a dependência dentro do município (Selic: 10 valores; distância: 29), então p = 0,0003 e 0,0033 podem estar otimistas; F geral e intervalos da previsão são clássicos; H4 chamada "significativa" | (a) F geral robusto (`lmtest::waldtest` com HC1) e intervalos da previsão com a matriz robusta; (b) reescrever H4 com a ressalva; (c) pedir ao professor se aceita um erro agrupado por município apenas como sensibilidade (hoje fora do escopo, D-2026-11-23-01) | Código e Texto (a, b); Professor (c) | +2, +3 com (c) |
| 5. Multicolinearidade | 5/5 | 0 | Atende (FIV, tolerância, det(R) = 0,3657) | Manter; conferir o limite FIV = 10 no slide da aula (texto em imagem) | Pesquisador | 0 |
| 6. Heterocedasticidade | 8/10 | −2 | Falta o teste de White; Breusch-Pagan (p = 0,0363) e Goldfeld-Quandt (p = 0,3885, só pela distância) divergem sem discussão | Acrescentar o teste de White (a aula de 2016 lista) e Goldfeld-Quandt ordenado por outras variáveis; explicar a divergência | Código e Texto | +2 |
| 7. Autocorrelação | 5/10 | −5 | Descrição do Breusch-Godfrey errada (**tratado**); autocorrelação lida como pura, mas em 16 de 29 municípios os dez resíduos têm o mesmo sinal (efeito de município que o modelo empilhado não capta); dL e dU com k = 5 aproximados porque X6 é constante no município; 14 (DW) contra 3 (BG) sem explicação (**tratado em texto**) | Calcular o Durbin-Watson também com os resíduos centrados na média do município e relatar; declarar o limite do dL e do dU; levar a explicação 14 × 3 ao artigo (feito em parte). A afirmação do agente de que o DW mediano vai a 1,16 e só 1 município fica abaixo de dL **não foi conferida por mim** | Código e Texto; Professor (A3) | +3 |
| 8. Normalidade e forma funcional | 6/10 | −4 | Nenhuma correção tentada nem investigação dos resíduos (assimetria 1,74; curtose 8,52); corte do Chow escolhido pelo gráfico; texto do Chow trocado (**tratado**) | Examinar os resíduos (gráfico de resíduos por município e por variável, como na aula de 2022) para localizar de onde vêm as caudas; tentar a reespecificação do item 1(d); relatar o resultado; manter o corte e a sensibilidade de 2016 | Código e Texto; Professor (A1, A2, A4) | +3 |
| 9. Endogeneidade e robustez | 5/10 | −5 | Só uma verificação de robustez; sem sensibilidade a Araucária; sem discussão de simultaneidade (salário e escolaridade se determinam juntos; o VAB industrial contém massa salarial) | Sem Araucária e controle de porte: **tratado**. Falta o parágrafo de endogeneidade (simultaneidade, variável omitida, medição) na discussão, sem inventar método fora do escopo | Texto; Pesquisador valida | +3 a +4 |
| 10. Reprodutibilidade e organização | 4/5 | −1 | `02_tratamento_painel.R` para sem o arquivo da PAM, e `00_executar_tudo.R` não roda `01b_extracao_pam.R` | Incluir o `01b` no `00_executar_tudo.R` ou tirar a dependência da PAM do painel | Código | +1 |
| 11. Limitações e honestidade | 4/5 | −1 | Texto chamava o Gini de "robusto" com uma só verificação (**tratado**) | Conferir que nenhum trecho do artigo e dos slides afirma mais do que os testes mostram; incluir a ressalva da Selic com 10 valores em todos os lugares | Texto | +1 |

Soma dos pontos recuperáveis dentro do escopo, se tudo for feito: cerca de +23 a +26 em teoria; na prática o teto fica perto de 92 a 95, porque 4(c), 7 e parte de 1 dependem de aceitar métodos hoje excluídos.

## 2. O que a régua não mede e o professor cobrou (peso real)

| Item | Estado | O que fazer | Quem |
|---|---|---|---|
| Revisão da literatura (seção 2) | vazia; nenhuma obra de periódico | 5 blocos (escolaridade, indústria, diversificação, juros, distância) com pelo menos 2 obras lidas cada, registradas em `fontes/REFERENCIAS.md` com a página que sustenta cada afirmação | Pesquisador |
| Discussão dialogando com a literatura (seção 6) | resultados e magnitudes prontos; comparação em branco | Para cada H1 a H5: o que a literatura prevê, concorda ou diverge, e por quê | Pesquisador; sessão confere os números |
| Contribuição explícita (6.7 e 7) | candidatas redigidas | Escolher e confirmar; após A8, reavaliar a candidata sobre o Gini | Pesquisador |
| Pontos da resposta ao professor "melhor explicados" | metodologia redigida | Justificativas de A1 a A8 em linguagem do pesquisador | Pesquisador |
| Tamanho | cerca de 21 páginas estimadas; exemplos: média 14,8, maior 22 | Levar fórmulas dos testes, Figuras 2 e 3 e o memorial para o apêndice; encurtar as referências ao que o texto cita | Pesquisador decide |
| Formato UFPR/ABNT | rascunho em Markdown | Montar no template `fontes/modelos_ufpr/template-artigo-de-periodico-ufpr_2026-06.docx`; títulos e fontes de tabelas e figuras já seguem o padrão | Pesquisador, com a sessão |
| Versão final limpa | marcações [revisar], [a inserir], nota para os colegas | Remover marcações, nota de versão e referências a `_Trilha`; resolver `[a confirmar]` | Pesquisador |

## 3. Ordem de ataque sugerida

1. **Decidir o porte (A8) com o professor.** Muda H3, a especificação, o resumo e a conclusão. Tudo que vem depois depende disso.
2. **Revisão da literatura e fundamentação dos sinais** (maior ganho no critério 1 e no peso real do professor).
3. **Pacote técnico de baixo custo, em um dia de código:** teste de White; F geral e previsão robustos; Durbin-Watson com resíduos centrados; exame de resíduos; reespecificação para o RESET; PAM no `00_executar_tudo.R` ou fora do painel; novos arquivos no verificador. Reconstruir o envio e rodar a verificação.
4. **Texto técnico:** apêndice com ANOVA, F incremental e determinação parcial; parágrafo de endogeneidade; H4 com ressalva; quatro casas em todo o texto.
5. **Discussão com a literatura, contribuição e considerações finais.**
6. **Slides:** preencher literatura e contribuição; atualizar robustez, limitações e conclusão com o resultado de A8.
7. **Limpeza e formatação:** template ABNT/UFPR, remover marcações, conferir referências (editora de Hoffmann, documento da AEN-PR, datas de acesso, edição do Gujarati).
8. **Nova correção com o agente `professor-econometria`**, conferir a nota e repetir só o que ainda perde pontos.

## 4. Riscos e cuidados

- **Escopo.** Só métodos ensinados nas aulas de Hasegawa. Erro agrupado, efeitos fixos, Mundlak e bootstrap só entram como sensibilidade se o professor autorizar por escrito.
- **Não maquiar a nota.** Resultado que não resiste (H3 com porte) é reportado, não escondido. Nenhuma obra entra sem ser lida.
- **Reespecificar muda tudo.** Se o porte ou termos quadráticos entrarem no modelo principal, refazer R/04 a R/07, o memorial, as tabelas 3 a 5, o resumo, os slides e a pasta de envio, e regenerar a documentação.
- **A nota do agente é uma estimativa** feita com a régua configurada; a nota do professor real pode diferir, sobretudo no peso dado ao texto.

## Estado em 24/11/2026

Feito (código, texto e verificação em 26 de 26): teste de White e Goldfeld-Quandt por outras variáveis (critério 6); F geral e intervalos da média com a matriz de White (critério 4); Durbin-Watson com resíduos centrados e explicação de 14 contra 3 (critério 7); exame de resíduos, reespecificação para o RESET e identificação das caudas (critério 8); robustez com porte e sem VAB negativo, mais o parágrafo de endogeneidade (critério 9); apêndice do memorial no artigo (critério 3); PAM fora do painel (critérios 2 e 10).

Achado novo que muda a leitura: o porte do município (ln dos vínculos ativos) explica boa parte da rejeição do RESET (F de 14,49 para 3,98) e eleva o R² ajustado de 0,6433 para 0,6744, mas inverte o sinal do Gini. Se o professor ou o pesquisador adotarem o porte no modelo principal, o ganho técnico é grande e o custo é refazer H3 e a conclusão. Decisão em aberto (A8).

Ainda fora do alcance do código nesta rodada: literatura e discussão (pesquisador), erro agrupado por município (fora do escopo), formatação final no template e limpeza das marcações.
