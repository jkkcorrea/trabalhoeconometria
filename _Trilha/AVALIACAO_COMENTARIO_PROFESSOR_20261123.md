# Avaliação do comentário do professor sobre a resposta (23/11/2026)

**Comentário recebido (literal):** "Precisa dar atenção especial ao relatório do trabalho final. Principalmente, a contextualização do problema estudado por meio de uma revisão da literatura, o detalhamento da metodologia, apresentando todo o procedimento metodológico utilizado para obter os resultados e, principalmente, a discussão dos resultados, que precisa fazer o trabalho dialogar com a literatura vigente. Deixar claro qual foi a contribuição do trabalho na discussão dos resultados e nas considerações finais. Há vários pontos levantados que precisam ser melhor explicados."

Registro: decisão D-2026-11-23-08. Seção correspondente em `_Trilha/REGISTRO_PENDENCIAS_PROFESSOR.md` (itens B1 a B5).

## 1. Leitura do comentário

O professor não rejeita nenhum método da resposta; pede que o **relatório** (o artigo) tenha quatro coisas e explique melhor os pontos levantados na resposta. Ele não confirma nem nega os itens A1 a A7. Hipótese de trabalho: os itens A1 a A7 seguem como estão no trabalho, mas **cada um precisa ser explicado no texto**. Essa leitura deve ser confirmada pelo pesquisador com o professor (um item de ressalva: nenhuma resposta explícita sobre o corte do Chow, o n = 87 do Gini e a correção exp(s²/2)).

## 2. Estado atual contra cada pedido

| Pedido do professor | Estado em `artigo/ARTIGO_rascunho_v2.md` | Lacuna | Quem faz |
|---|---|---|---|
| B1. Contextualização por revisão da literatura | §1 tem 4 parágrafos; §2 é um placeholder sem nenhuma referência de periódico | **Maior lacuna.** Sem literatura, as hipóteses H1 a H5 não têm base teórica no texto | Pesquisador escolhe e lê as obras; a sessão pode estruturar e conferir citações |
| B2. Detalhamento da metodologia (todo o procedimento) | §3 e §4 descrevem variáveis, modelo e testes em linhas curtas | Faltam: fórmulas (Fisher, deflator, X2, X3, Gini passo a passo, distância em UTM), estimador e erro de White em forma matricial, estatística de cada teste, regra de decisão, e o passo a passo do tratamento dos dados | **Sessão** (vem do código e dos CSVs) |
| B3. Discussão dialogando com a literatura vigente | §6 tem um parágrafo com três pontos e um marcador [revisar] | Sem literatura não há diálogo. Falta confrontar cada hipótese (H1 a H5) com o que a teoria e os estudos preveem e com a magnitude encontrada | Pesquisador (interpretação teórica); sessão monta a estrutura e confere os números |
| B4. Contribuição clara na discussão e nas considerações finais | Não há | Falta a declaração do que o trabalho acrescenta | Pesquisador decide; abaixo há candidatas |
| B5. Pontos levantados que precisam de explicação | Os 10 itens da resposta (dummies, autocorrelação, RESET, normalidade, Gini, carreiras, influência, projeção, Chow, Adrianópolis e Araucária) aparecem só como limitação ou nota | Cada item precisa de um parágrafo que diga o que foi feito, por quê e o que muda na leitura | Sessão redige o procedimento; pesquisador valida as justificativas |

## 3. O que aplicar (ordem)

1. **Metodologia detalhada (B2 e parte de B5).** Reescrever §3 e §4 com o procedimento completo: coleta, limpeza, construção de cada variável (fórmulas), painel, estimador, cada teste (hipóteses, estatística, regra de decisão), previsão e correção de viés. Tudo sai do código e dos CSVs, sem inventar. **Feito em parte nesta sessão** (ver o artigo v2, §3 e §4).
2. **Estrutura da revisão da literatura (B1).** Montar a §2 em cinco blocos, um por variável e um sobre o método de desigualdade: (a) escolaridade e salário (capital humano); (b) industrialização e salário; (c) diversificação ou especialização setorial e desempenho local; (d) juros reais e mercado de trabalho; (e) localização, distância ao centro e salário (economia regional). A §2 já traz os blocos como subseções com a pergunta que cada um precisa responder. **As obras ficam para o pesquisador** (seção 5 abaixo).
3. **Discussão por hipótese (B3).** Para cada H1 a H5: resultado e magnitude; o que a literatura prevê; concordância ou divergência; explicação possível; limite do trabalho. A §6 já traz o esqueleto com os resultados preenchidos e os espaços da literatura marcados.
4. **Contribuição (B4).** Uma declaração curta na §6 e na §7 (seção 4 abaixo).
5. **Explicações (B5).** Um parágrafo por item da resposta, ligado ao teste na §4.2 ou ao resultado na §5. Tabela de correspondência no registro de pendências.
6. **Slides.** Acrescentar dois slides (revisão de literatura e contribuição) depois que o pesquisador fechar B1 e B4; hoje não há conteúdo conferido para eles.

## 4. Candidatas à contribuição (decisão do pesquisador; sem exagero)

Só o que o trabalho de fato faz, com a ressalva de que são associações:

1. **Medida de diversificação setorial do emprego com o Gini discreto da aula (Hoffmann 2006, cap. 17) sobre as 87 divisões da CNAE**, e a verificação de que o índice é dominado pelo número de divisões com vínculo (correlação de −0,95 com essa contagem).
2. **Painel municipal da RMC (29 municípios, 2012 a 2021)** que combina RAIS, SIDRA, Banco Central e IBGE em uma só base documentada e verificada (22 de 22 conferências).
3. **Evidência descritiva** de que escolaridade, industrialização e proximidade de Curitiba se associam a salário maior, e de que a diversificação (Gini menor) também.
4. **Registro dos limites**: forma funcional, normalidade e autocorrelação, e do caso de Adrianópolis (salto industrial de 2015, causa não confirmada).

Evitar: "efeito causal", "política pública recomendada" e qualquer afirmação de novidade sem a revisão da literatura que a sustente.

## 5. Literatura candidata (nenhuma foi lida; não inserir no artigo sem ler)

Regra do projeto: só entra referência conferida na fonte. Os itens abaixo são pontos de partida para o pesquisador procurar e **todos levam `[a conferir]`**.

| Bloco | Obra candidata | Observação |
|---|---|---|
| Escolaridade e salário | Becker, G. S. *Human capital* (1964); Mincer, J. *Schooling, experience, and earnings* (1974) | Obras clássicas do capital humano; conferir edição e páginas. |
| Diversificação e especialização | Glaeser, E.; Kallal, H.; Scheinkman, J.; Shleifer, A. "Growth in cities". *Journal of Political Economy*, v. 100, n. 6, 1992 | Debate sobre especialização e diversidade; conferir. |
| Localização e salário | Krugman, P. "Increasing returns and economic geography". *Journal of Political Economy*, v. 99, n. 3, 1991; Roback, J. "Wages, rents, and the quality of life". *Journal of Political Economy*, v. 90, n. 6, 1982 | Distância ao centro e salário; conferir. |
| Geografia e salários no Brasil | Fally, T.; Paillacar, R.; Terra, C. "Economic geography and wages in Brazil: evidence from micro-data". *Journal of Development Economics*, 2010 | Evidência brasileira; conferir volume e páginas. |
| Juros e mercado de trabalho | sem candidata segura | Buscar estudos sobre política monetária e emprego ou salários no Brasil (termos: "política monetária", "mercado de trabalho", "salário real", "taxa Selic"). |
| Região Metropolitana de Curitiba | sem candidata segura | Buscar estudos do IPARDES e da UFPR sobre a estrutura produtiva e o mercado de trabalho da RMC. |
| Método de desigualdade | Hoffmann (2006, cap. 17) e Hasegawa (2020) | Já no projeto. |

Onde buscar: Periódicos CAPES (acesso UFPR), Google Scholar, SciELO, anais da ANPEC, RePEc e a biblioteca da UFPR. Critério: periódico revisado por pares ou livro de editora conhecida, com texto lido. Ao ler, anotar em `fontes/REFERENCIAS.md` a página que sustenta cada afirmação.

## 6. Cuidados

- **Escopo da disciplina:** a literatura pode citar métodos que a disciplina não ensina (painel, efeitos fixos). Citá-los só para situar o debate, sem usá-los no trabalho (D-2026-11-23-01).
- **Associação, não causalidade**, também na comparação com a literatura: se um estudo estima efeito causal, dizer que o resultado deste trabalho é descritivo.
- **Interpretação teórica é do pesquisador** (`CLAUDE.md`, seção 1). A sessão estrutura, confere números e redige o procedimento; não escreve a teoria nem os sinais esperados.
- **Páginas:** a meta de cerca de 15 páginas (média dos exemplos: 14,8) fica assim: introdução 1,5; revisão da literatura 3; metodologia 3,5; resultados 2,5; discussão 2,5; conclusão 0,8; referências 1. Os apêndices ficam fora da conta.
- **Resposta ao professor:** o comentário indica que a resposta foi enviada. Atualizar o backlog (R6) depois que o pesquisador confirmar o envio.

## 7. Tamanho do artigo após as mudanças (estimativa, 23/11/2026, noite)

- Texto do artigo v2 sem apêndices e sem tabelas: cerca de 4.800 palavras, que incluem os marcadores e a lista de referências; 5 tabelas e 4 figuras.
- Estimativa em Arial 12, entrelinha 1,5, margens da UFPR: 17 páginas de texto, mais 2 de tabelas e 2 a 3 de figuras, ou seja, cerca de 21 páginas antes do apêndice. Estimativa por contagem de palavras, sem renderização.
- Os exemplos da disciplina têm 6, 9, 19, 22 e 18 páginas (média 14,8; o maior tem 22). A revisão da literatura (cerca de 3 páginas) ainda vai entrar, então o artigo ficaria perto de 24 páginas, acima do maior exemplo.
- Ajustes sugeridos, a decidir pelo pesquisador: (a) levar as estatísticas dos testes (seção 4.2) e a FIGURA 2 e a FIGURA 3 para o apêndice; (b) encurtar a lista de referências, mantendo só o que o texto cita; (c) manter no corpo o procedimento da seção 3.5, que é o que o professor pediu.
