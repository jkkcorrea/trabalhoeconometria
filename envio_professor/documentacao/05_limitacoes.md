# Limitações

- Desenho observacional: os coeficientes são associações, não efeitos causais.
- Variáveis de nível de tempo e de município (Selic e distância) têm poucos valores distintos. A significância do modelo principal para X5 não se sustenta na checagem agregada (04_diagnosticos).
- Autocorrelação positiva dentro dos municípios em 14 de 29 séries pela tabela de Durbin-Watson, sem correção ensinada aplicável ao painel. Os erros-padrão, mesmo os de White, tendem a estar subestimados.
- Forma funcional rejeitada pelo RESET (p-valor < 0,0001). A especificação log-linear com estas cinco variáveis não está completa.
- Heterocedasticidade rejeitada a 5% pelo Breusch-Pagan-Godfrey no Modelo 2 (p-valor 0,0363); a inferência usa erros de White.
- A medida X4 acompanha o número de divisões com emprego (correlação de -0,95). Sua leitura precisa ser definida antes da interpretação.
- Sinais esperados e hipóteses ainda não foram definidos no projeto; sem eles não há teste de hipótese econômica.
- A divisão do teste de Chow no ano de 2016 é uma escolha, com duas partes de 145 observações.
- Vínculos com divisão CNAE 'ignorada' ficam fora do cálculo do Gini.
