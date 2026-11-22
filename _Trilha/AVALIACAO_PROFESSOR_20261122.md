# Avaliação como professor de Econometria I (22/11/2026)

Documento interno. Não entra no envio ao professor. Base: régua de 100 pontos da skill `professor-econometria`, aplicada ao modelo após a restrição aos métodos ensinados (commit 788fdaa e seguintes). Números conferidos em `envio_professor/resultados_econometricos/` e recalculados na verificação (16 de 16 aprovadas, mais C7).

## 1. Nota estimada: 63 de 100. O modelo não sustenta nota 10.

| Critério | Pts | Nota | Evidência |
|---|---|---|---|
| 1. Especificação e coerência econômica | 10 | 5 | Sinais e hipóteses não definidos pelo pesquisador. Gini mede sobretudo número de setores (r = −0,95). |
| 2. Dados e construção | 10 | 7 | Fontes e fórmulas documentadas. Gini com 87 divisões é escolha a confirmar. |
| 3. Estimação e memorial matricial | 15 | 14 | Memorial com quatro casas e conferência contra `lm()`. |
| 4. Inferência clássica | 10 | 3 | X5 e X6 têm 10 e 29 valores distintos; t com 284 gl superestima a precisão. |
| 5. Multicolinearidade | 5 | 5 | FIV máximo 2,33. |
| 6. Heterocedasticidade | 10 | 8 | Breusch-Pagan-Godfrey rejeita (p = 0,0363). Goldfeld-Quandt não rejeita. White aplicado. |
| 7. Autocorrelação | 10 | 5 | Durbin-Watson por município bem feito; 14 de 29 positivos; sem correção ensinada. |
| 8. Forma funcional e influência | 10 | 3 | RESET rejeita (p < 0,0001) e o achado não foi tratado. |
| 9. Painel, endogeneidade e robustez | 10 | 3 | Métodos de painel removidos por regra; sem robustez alternativa. |
| 10. Reprodutibilidade | 5 | 5 | Pipeline, caminhos relativos, verificação independente. |
| 11. Limitações e honestidade | 5 | 5 | Rejeições reportadas; limitações escritas. |
| **Total** | **100** | **63** | |

## 2. Coerência com o que o trabalho pretende explicar

O que o modelo mostra (MQO com erro de White, Modelo 2):
- X2 ensino superior: +0,0150 por ponto percentual; p < 0,0001. Coerente com a correlação de 0,49 com o salário.
- X3 dominância industrial: +0,0055 por ponto percentual; p < 0,0001. Coerente com a correlação de 0,48.
- X4 Gini setorial: −0,6548 por unidade; p = 0,0001. A correlação com o número de setores com emprego é −0,95. Ou seja, quanto mais setores com emprego, maior o salário. A leitura "concentração reduz salário" não se sustenta, porque o Gini não mede concentração entre setores grandes nesta construção.
- X5 Selic real: +0,0065; p = 0,0003 no modelo. Na checagem com médias anuais (n = 10), p = 0,19. A significância depende de tratar 290 linhas como independentes.
- X6 distância: −0,0016 por km; p = 0,0033 no modelo. Na checagem com médias por município (n = 29), a inclinação é −0,0047 com p = 0,0021. O sinal se mantém; a magnitude não é a mesma.

Conclusão de coerência: o que o trabalho pode explicar com segurança é a associação entre o salário e X2, X3, X6 e a estrutura de emprego (medida pelo Gini), com a ressalva da forma funcional. Não é possível afirmar efeito da Selic.

## 3. Resultados que o pesquisador precisa rever antes de escrever

1. **Hipóteses e sinais esperados.** Não estão definidos. Sem eles, o trabalho não testa hipótese econômica (roteiro, slide 5 e 7). Impacto: a seção de metodologia e a discussão ficam sem critério de avaliação.
2. **Leitura do X4 (Gini).** Decidir se a variável será apresentada como diversidade (sinal invertido) ou se será trocada por medida de concentração entre os setores de maior emprego. Impacto: a interpretação do sinal negativo, que hoje contradiria a intuição de "concentração".
3. **Estatuto da Selic (X5).** Manter como associação não significativa fora da amostra de 290 observações, ou retirar do modelo principal. Impacto: afeta a conclusão sobre política monetária, que não pode ser afirmada.
4. **Forma funcional (RESET).** Rejeitada com p < 0,0001. Opções ensinadas: termos quadráticos em X2 e X6, ou uma especificação diferente. Impacto: os coeficientes podem estar viesados; sem tratamento, a interpretação em elasticidade é frágil.
5. **Autocorrelação positiva (14 de 29 municípios).** Sem correção ensinada aplicável ao painel. Impacto: erros-padrão subestimados e os p-valores do modelo principal são otimistas. Declarar como limitação é o mínimo.
6. **Inferência com X5 e X6.** Apresentar os dois procedimentos (290 observações e médias) e explicar a diferença. Impacto: é o ponto que mais derruba a nota de inferência.

## 4. O que já está adequado

- Memorial matricial e conferência contra `lm()`.
- Diagnósticos ensinados aplicados corretamente: VIF, Breusch-Pagan-Godfrey, Goldfeld-Quandt, White, RESET, Chow.
- Autocorrelação por município, em vez do Durbin-Watson do painel empilhado, que seria inválido.
- Limitações escritas e rejeições reportadas.

## 5. Recomendação

Não escrever o artigo com a Selic como resultado significativo. Antes de redigir, decidir os itens 1 a 6 da seção 3. O item 4 (forma funcional) é o que mais pode mudar os coeficientes, por isso deve vir primeiro.
