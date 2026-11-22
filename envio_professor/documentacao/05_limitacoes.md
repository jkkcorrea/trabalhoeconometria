# Limitações

- Desenho observacional: os coeficientes são associações, não efeitos causais.
- Com as dummies de município, X6 (distância) não é identificada. Seu efeito só aparece no Modelo 2, onde está confundido com as diferenças não observadas entre municípios.
- Variáveis de nível de tempo (Selic) têm 10 valores distintos. A inferência do Modelo 4 para X5 trata 290 observações como independentes e superestima a precisão. É o ponto que mais limita a conclusão sobre juros.
- O efeito de X4 muda de sinal entre o Modelo 2 (entre municípios) e o Modelo 4 (dentro dos municípios). A medida acompanha o número de setores com emprego (correlação -0,95).
- Autocorrelação dentro dos municípios: a correção Prais-Winsten e Cochrane-Orcutt com ρ comum é uma extensão do método de série temporal ao painel [presunção da modelagem]. Newey-West não é aplicado ao painel empilhado.
- Heterocedasticidade: o Breusch-Pagan-Godfrey rejeita no Modelo 2 e no Modelo 4. A inferência usa erros de White.
- Os coeficientes com correção (Prais-Winsten) dependem do ρ estimado, que é alto no Modelo 2. O efeito de X2 entre municípios cai muito com a correção (ver 04_diagnosticos.md).
- Normalidade rejeitada nos dois modelos (Jarque-Bera). A assimetria e a curtose altas são reportadas; a inferência usa as aproximações assintóticas.
- Observações influentes no Modelo 4 (Adrianópolis 2012 e Lapa 2016). A sensibilidade do coeficiente de X4 a elas é alta; o dado de Adrianópolis deve ser conferido na fonte.
- A definição da X4 altera o efeito dentro dos municípios (ver 04_diagnosticos.md, robustez da X4).
- O Modelo 4 usa variáveis dummy de município (Gujarati, cap. 9). Os slides de aulas lidos não trazem dummies; o uso depende de confirmação com o professor.
- A Selic tem 10 valores distintos; sua inferência é otimista, embora retirá-la piore o ajuste (ver 04_diagnosticos.md).
- A divisão do teste de Chow no ano de 2016 é uma escolha, com duas partes de 145 observações.
- Vínculos com divisão CNAE 'ignorada' ficam fora do cálculo do Gini.
