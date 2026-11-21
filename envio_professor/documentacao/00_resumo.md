# Resumo dos resultados validados

Todos os números abaixo vêm dos arquivos de `resultados_econometricos/` e foram recomputados de forma independente (`08_verificacao.md`).

## Desenho

- Painel de 29 municípios da Região Metropolitana de Curitiba, 2012 a 2021 (290 observações). Variável dependente: ln do salário médio real formal (R$ de 2021).
- Linha de base da disciplina: MQO empilhado (Modelo 2), com diagnósticos do modelo clássico.
- Estimativas de referência para X2, X3 e X4: efeitos fixos (equivalentes às do modelo de Mundlak, que preserva X5 e X6), porque o teste F de efeitos individuais, o Hausman e o Mundlak rejeitam o MQO empilhado.

## Coeficientes principais (erro agrupado por município, t com 28 graus de liberdade)

| Termo | MQO empilhado | p-valor  | Mundlak | p-valor |
|---|---|---|---|---|
| X2 ensino superior (%) | 0,0159 | < 0,0001 | 0,0086 | < 0,0001 |
| X3 dominância industrial (%) | 0,0054 | < 0,0001 | -0,0005 | 0,4746 |
| X4 diversificação (Shannon) | 0,0762 | 0,1541 | -0,0737 | 0,1057 |
| X5 Selic real (% a.a.) | 0,0066 | 0,0003 | 0,0040 | 0,0005 |
| X6 distância a Curitiba (km) | -0,0016 | 0,3394 | -0,0016 | 0,3305 |

## Diagnósticos do Modelo 2

- Multicolinearidade: maior FIV 2,6166 (limite 10).
- Breusch-Pagan: 13,0536 (p-valor = 0,0229); Durbin-Watson empilhado: 0,4227; Jarque-Bera: 517,5486; RESET: 18,4638.
- O Modelo 2 viola homocedasticidade, ausência de autocorrelação, normalidade e forma funcional; o erro-padrão clássico não é válido, e a inferência usa erros robustos e agrupados.

## O que a calibração mostrou

- O efeito de município é significativo (F = 75,8928) e correlacionado com X2, X3 e X4 (Mundlak: p-valor < 0,0001; Hausman: p-valor < 0,0001).
- Com efeitos fixos, X2 vale 0,0086 (MQO empilhado: 0,0159) e X3 deixa de ser significativo (-0,0005, p-valor = 0,4707).
- Selic real: p-valor de 0,0005 a 0,0547 conforme o procedimento de inferência; a Selic nominal e o IPCA entram com sinais opostos.
- Forma funcional: com quadráticos, o RESET de regressores passa a 0,0811, mas o de valores ajustados piora para 0,0515 e, com efeitos de ano, o de regressores rejeita (0,0024); o quadrático de X2 sugere retornos decrescentes e o Box-Cox não rejeita o logaritmo de Y com efeitos fixos.
- Os resultados são associações; ver `06_limitacoes.md`.

## Onde ler

`01_dados_e_variaveis.md`, `02_especificacao_e_metodos.md`, `03_resultados_modelos_classicos.md`, `04_calibracao.md`, `05_fragilidades.md`, `06_limitacoes.md`, `07_criterios_da_disciplina.md` e `08_verificacao.md`.
