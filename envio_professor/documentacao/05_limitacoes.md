# Limitações

- Desenho observacional: os coeficientes são associações, não efeitos causais.
- Autocorrelação positiva dentro dos municípios, sem correção ensinada aplicável ao painel (ver 04_diagnosticos).
- Forma funcional rejeitada pelo RESET: a especificação log-linear com estas cinco variáveis não é completa.
- Heterocedasticidade rejeitada pelo Breusch-Pagan-Godfrey no Modelo 2; a inferência usa erros de White.
- O Gini setorial tem correlação de 0,73 com a distância a Curitiba. Os FIVs ficam abaixo de 10, mas a colinearidade entre X4 e X6 deve ser lida com cautela.
- A divisão do Chow no ano de 2016 é uma escolha, e o tamanho das duas partes é igual (145 observações cada).
- Dados da RAIS: vínculos com divisão CNAE 'ignorada' ficam fora do Gini.
