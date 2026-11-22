# Limitações

- Desenho observacional: os coeficientes são associações, não efeitos causais.
- Com as dummies de município, X6 (distância) não é identificada. Seu efeito só aparece no Modelo 2, onde está confundido com as diferenças não observadas entre municípios.
- Variáveis de nível de tempo (Selic) têm 10 valores distintos. A inferência do Modelo 4 para X5 trata 290 observações como independentes e superestima a precisão. É o ponto que mais limita a conclusão sobre juros.
- O efeito de X4 muda de sinal entre o Modelo 2 (entre municípios) e o Modelo 4 (dentro dos municípios). A medida acompanha o número de setores com emprego (correlação -0,95).
- A autocorrelação dentro dos municípios cai com as dummies, mas o Breusch-Godfrey ainda rejeita em alguns municípios; não há correção ensinada aplicável ao painel para o resto.
- Heterocedasticidade: o Breusch-Pagan-Godfrey rejeita no Modelo 2 e no Modelo 4. A inferência usa erros de White.
- Sinais esperados e hipóteses ainda não foram definidos no projeto; sem eles não há teste de hipótese econômica.
- A divisão do teste de Chow no ano de 2016 é uma escolha, com duas partes de 145 observações.
- Vínculos com divisão CNAE 'ignorada' ficam fora do cálculo do Gini.
