# Como baixar e contribuir com o projeto

Projeto: salário médio real formal nos municípios da Região Metropolitana de Curitiba, 2012 a 2021 (Econometria I, UFPR).

Repositório: https://github.com/jkkcorrea/trabalhoeconometria

Este guia serve para quem vai baixar o projeto, rodar os scripts em R e enviar alterações ao repositório no GitHub.

## 1. Requisitos

- Git instalado (`git --version` deve responder).
- Conta no GitHub.
- **Acesso de escrita ao repositório.** Peça ao dono (`jkkcorrea`) para adicionar o seu usuário em *Settings → Collaborators → Add people*. Você recebe um convite por e-mail e precisa **aceitá-lo** antes de conseguir enviar. Sem esse acesso, use o fluxo de fork da seção 7.
- R 4.6.2 (ou a versão indicada em `envio_professor/documentacao/ambiente_r.csv`).
- Rust (`rustup`), necessário apenas para compilar o pacote `gifski` usado nas animações.
- Espaço livre de pelo menos 2 GB. A RAIS bruta (cerca de 3,5 GB) não faz parte do repositório e só é baixada se você rodar o script `01_extracao_dados.R`.

## 2. Configurar o git e a autenticação (uma vez)

### 2.1. Identidade

Os commits levam o seu nome e e-mail. Configure:

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu-email@exemplo.com"
```

Para não expor o e-mail pessoal em um repositório público, use o e-mail de privacidade do GitHub (Settings → Emails → "Keep my email addresses private"), no formato `ID+usuario@users.noreply.github.com`.

### 2.2. Autenticação para enviar (push)

O GitHub **não aceita a senha da conta** para `git push` por HTTPS. Use um token:

1. No GitHub: *Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token (classic)*.
2. Marque o escopo **`repo`** e escolha uma validade.
3. Copie o token na hora (o GitHub só mostra uma vez).
4. No primeiro `git push`, o git pergunta usuário e senha: informe o seu **usuário do GitHub** e cole o **token** no lugar da senha.

Para o git lembrar o token e não perguntar de novo:

```bash
git config --global credential.helper store
```

(o token fica em um arquivo na sua máquina; em computador compartilhado, prefira `credential.helper cache`).

Alternativa: instalar o GitHub CLI (`gh`) e rodar `gh auth login`, que faz o login pelo navegador.

**Nunca cole o token em chat, e-mail, código ou commit.** Se vazar, apague-o em *Settings → Developer settings → Personal access tokens*.

### 2.3. Quebras de linha

Se você alterna entre Windows e Linux/macOS, evite diferenças de fim de linha:

```bash
git config --global core.autocrlf true     # Windows
git config --global core.autocrlf input    # Linux e macOS
```

## 3. Baixar o projeto (primeira vez)

```bash
git clone https://github.com/jkkcorrea/trabalhoeconometria.git
cd trabalhoeconometria
```

**Atenção aos dados.** O `.gitignore` não envia as pastas `dados_brutos/` e `dados_processados/`. O clone, portanto, vem sem elas, e o `02_tratamento_painel.R` precisa dos cinco arquivos `.rds` de `dados_brutos/` (cerca de 100 KB no total: `pib_sidra`, `macro_bacen`, `malha_rmc`, `distancias` e `rais`). Peça essa pasta ao responsável e copie para dentro do projeto, ou refaça a coleta com `Rscript R/01_extracao_dados.R` (download de cerca de 3,5 GB). Não use `git add -f` para forçar a entrada dessas pastas no repositório.

## 4. Atualizar antes de começar a trabalhar

Sempre que for trabalhar, atualize sua cópia local:

```bash
git checkout main
git pull origin main
```

## 5. Rodar o projeto

A partir da raiz da pasta:

```bash
Rscript R/00_executar_tudo.R
```

Esse comando roda os scripts 02 a 08 em ordem, cada um em um processo separado. Para gerar as figuras, o script `03_aede_visualizacoes.R` é necessário. Detalhes estão em `envio_professor/LEIAME.md`.

No VS Code, abra a pasta do projeto como área de trabalho. Os caminhos são relativos à raiz, então o script precisa ser executado a partir dela.

## 6. Regras do repositório

- **Não edite à mão a pasta `envio_professor/`.** Ela é gerada pelo script `_Trilha/ferramentas/reconstruir_envio.sh`. Para mudar algo ali, altere os scripts de `R/` ou o gerador de documentação (`_Trilha/ferramentas/gerar_documentacao.R`) e refaça a pasta com `bash _Trilha/ferramentas/reconstruir_envio.sh`.
- **Não envie dados pessoais, senhas, tokens ou chaves de API.** Se um arquivo desses aparecer no `git status`, não faça o commit; avise o responsável.
- **Não envie a RAIS bruta** nem arquivos temporários de cache.
- **Não envie arquivos gerados que não sejam necessários.** Se uma figura ou CSV mudar por causa de uma alteração no código, rode o pipeline e envie os arquivos novos junto com o código.
- **Não faça push direto na `main`.** Crie um branch para cada alteração e abra um pull request.
- **Não use `git push --force`** em nenhuma situação.

## 7. Fluxo de contribuição

### 7.1. Criar um branch

Dê um nome curto e descritivo, sem espaços:

```bash
git checkout -b ajuste/nome-curto-da-mudanca
```

Exemplos: `ajuste/documentacao-p-valor`, `ajuste/verificacao-prais-winsten`.

### 7.2. Fazer as alterações e conferir

Edite os arquivos e rode o pipeline completo:

```bash
Rscript R/00_executar_tudo.R
```

Se a alteração mexe em resultados, documentação ou nos scripts de `envio_professor/`, refaça e verifique a pasta de envio:

```bash
bash _Trilha/ferramentas/reconstruir_envio.sh
```

O script termina com a linha "N de N verificações aprovadas". Se houver erro ou verificação reprovada, **pare e corrija antes de continuar**; não mude a tolerância de uma verificação para fazê-la passar.

Depois veja o que mudou:

```bash
git status
git diff
```

Confira se só os arquivos esperados aparecem. Arquivos fora do escopo da mudança devem ser desfeitos com `git checkout -- caminho/do/arquivo`.

### 7.3. Registrar a alteração (commit)

Adicione os arquivos pelo nome, não com `git add .`:

```bash
git add R/04_modelagem_diagnosticos.R _Trilha/ferramentas/gerar_documentacao.R envio_professor/
git commit -m "Corrige p-valor de X3 no Mundlak e remove DW da síntese"
```

Boas práticas para a mensagem:
- Escreva em português, no imperativo ou no presente, dizendo o que mudou.
- Uma alteração lógica por commit.

### 7.4. Enviar o branch ao GitHub

```bash
git push -u origin ajuste/nome-curto-da-mudanca
```

Na primeira vez, o git pede usuário e token (seção 2.2).

### 7.5. Abrir o pull request

No site do GitHub, aparecerá um botão "Compare & pull request" para o branch enviado. Preencha:
- **Título:** o que a alteração faz.
- **Descrição:** o motivo da mudança, quais arquivos foram afetados e como foi conferido (por exemplo, "pipeline rodou sem erro; verificação 49/49 aprovada").

Peça revisão ao responsável. Não faça merge sem aprovação.

### 7.6. Se você não é colaborador (fork)

Sem acesso de escrita, o `git push` ao repositório do dono dá erro 403. Nesse caso:

1. No GitHub, clique em **Fork** na página do repositório.
2. Clone o **seu** fork: `git clone https://github.com/SEU-USUARIO/trabalhoeconometria.git`.
3. Registre o original como `upstream` para se manter atualizado:

   ```bash
   git remote add upstream https://github.com/jkkcorrea/trabalhoeconometria.git
   git pull upstream main
   ```
4. Crie o branch, faça o commit e envie ao **seu** fork: `git push -u origin ajuste/nome-curto-da-mudanca`.
5. No GitHub, abra o pull request do seu fork para o repositório original.

## 8. Atualizar um pull request depois de pedido de mudança

Continue no mesmo branch, faça o commit e envie de novo:

```bash
git add arquivo_alterado.R
git commit -m "Ajusta conforme revisão"
git push
```

O pull request se atualiza sozinho.

## 9. Resolver conflitos

Se o `git pull` ou o merge acusar conflito:

1. Não force nada (`git push --force` está proibido neste projeto).
2. Abra o arquivo em conflito, escolha o trecho correto e apague as marcações `<<<<<<<`, `=======` e `>>>>>>>`.
3. Rode o pipeline de novo, depois `git add` e `git commit`.

Se não tiver certeza, avise o responsável antes de resolver.

## 10. Problemas comuns no push

| Mensagem | Causa provável | O que fazer |
|---|---|---|
| `Authentication failed` ou pede senha de novo | Usou a senha da conta no lugar do token, ou o token expirou | Gere um token com escopo `repo` e use-o como senha |
| `Permission denied` ou erro `403` | Você não é colaborador, não aceitou o convite ou o token não tem o escopo `repo` | Peça acesso ao dono e aceite o convite, ou use o fluxo de fork (7.6) |
| `Repository not found` | URL errada ou sem acesso a repositório privado | Confira com `git remote -v` e peça acesso |
| `rejected ... fetch first` ou `non-fast-forward` | O branch remoto tem commits que você não tem | `git pull --rebase origin nome-do-branch` e depois `git push` |
| `fatal: could not read Username` | O git está sem terminal para pedir login | Rode o comando em um terminal comum ou configure o `gh auth login` |
| `Updates were rejected` em `main` | A `main` é protegida | Use branch e pull request (7.1 a 7.5) |

## 11. Para o responsável pelo repositório (dono)

Primeira vez, para enviar o projeto (o remoto `origin` já aponta para o repositório):

```bash
git push -u origin main
```

Depois:

1. **Adicionar colegas:** *Settings → Collaborators → Add people*, com permissão *Write*.
2. **Proteger a `main`:** *Settings → Branches → Add branch ruleset* (ou *branch protection rule*) para `main`, exigindo pull request antes do merge. Isso impede push direto e faz valer a regra da seção 6.
3. **Visibilidade:** o repositório pode ser privado (só os colaboradores veem) ou público (*Settings → General → Danger Zone → Change repository visibility*). Antes de tornar público, lembre que o histórico traz o e-mail dos autores dos commits e a resolução completa do trabalho.
4. **Revisar e fazer merge** dos pull requests: depois de aprovar, o merge na `main` é feito pelo botão do GitHub; os colegas então rodam `git pull origin main`.

## 12. Dúvidas e decisões

Decisões metodológicas (modelo de referência, sinais esperados, interpretação) são do pesquisador responsável. Não as altere em um pull request sem combinar antes. Registre o que for decidido em `_Trilha/DECISOES.md`.
