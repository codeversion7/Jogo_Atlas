# Git e Codex no ATLAS

## Destino e limites

Repositório privado: https://github.com/codeversion7/Jogo_Atlas

URL Git esperada: `https://github.com/codeversion7/Jogo_Atlas.git`

Branch padrão identificada: `main`. Antes desta consolidação o remoto estava vazio. Agora contém documentação, instruções e preparo de Git; o jogo deve ser sincronizado pelo ambiente local.

Caminho Windows informado pelos responsáveis:

```text
C:\Users\Arthur-Gamer\OneDrive\Documentos\ChatGPT\GODOT-ATLAS
```

Referências informadas em `referencias\personagem\`, dentro desse projeto. O antigo caminho `C:\Users\Arthur-Gamer\Documents\atlas` não correspondia à pasta mostrada nas capturas.

Git já está instalado segundo os responsáveis. A conexão GitHub deste chat não autentica automaticamente Git no Windows. Esta documentação não configura o computador remotamente e não pressupõe acesso à pasta local.

## Primeira tarefa do Codex local

Abra o projeto correto e execute, inspecionando cada resultado antes de depender dele:

```powershell
Get-Location
Test-Path .\project.godot
git --version
```

Se o projeto não estiver acessível, informe o impedimento real. Não crie outro projeto ou procure indefinidamente em um diretório diferente.

Verifique se a pasta já pertence a um repositório. Em caso afirmativo:

```powershell
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
git diff --stat
git diff --cached --stat
git log -5 --oneline
```

O último comando pode não ter resultado se ainda não houver commits. Não interpretar isso como autorização para descartar arquivos.

## Preparo local conservador

O script [Preparar-AtlasGit.ps1](../../tools/git/Preparar-AtlasGit.ps1) ajuda no diagnóstico e na configuração. Baixe o script do repositório, ou execute sua cópia depois de obter a documentação. Não é preciso clonar dentro da pasta do jogo para obter um único arquivo.

Na pasta real do jogo, execução sem alterações:

```powershell
& .\tools\git\Preparar-AtlasGit.ps1
```

Se o script foi baixado para outro local, use o caminho real do arquivo e passe `-CaminhoProjeto` com a pasta do jogo.

Para aplicar o preparo já solicitado pelos responsáveis:

```powershell
& .\tools\git\Preparar-AtlasGit.ps1 -Aplicar
```

O modo Aplicar inicializa Git somente se não houver repositório, adiciona `origin` somente se ausente, valida o destino, define preferências locais somente quando ainda não configuradas e busca `origin`. Não altera a configuração global, arquivos do jogo, índice ou branch atual. Não faz merge, commit ou push. Se o fetch falhar por autenticação, a preparação pode ter sido parcialmente aplicada; corrigir a autenticação e repetir sem recriar o repositório.

Se nome/email ainda não estiverem configurados, usar somente os valores fornecidos pelos responsáveis:

```powershell
# Exemplo: substituir pelos valores reais escolhidos; não executar os placeholders.
& .\tools\git\Preparar-AtlasGit.ps1 -Aplicar -NomeGit 'SEU_NOME' -EmailGit 'SEU_EMAIL'
```

Não inferir a identidade do autor pelo nome do usuário do Windows. Usar autenticação normal do Git for Windows/Git Credential Manager ou SSH já configurado. Não colocar tokens nos remotes, nos arquivos ou nas mensagens.

## Conciliar o jogo local com esta documentação

O remoto já terá commits documentais. O projeto local pode ter seus próprios commits ou nenhuma história. Não sobrescreva um lado com o outro.

1. Confira status e alterações staged. Preserve alterações de outras tarefas e autores. Se precisar de snapshot local antes de integrar, revise e adicione apenas os arquivos selecionados da tarefa, incluindo os arquivos Godot necessários; confirme identidade antes do commit. Não use `git add .`.
2. Se ainda não existir Git, inicialize na raiz correta. Se já existir, preserve-o. Valide `origin` ou acrescente o remoto correto sem substituir silenciosamente outro destino.
3. Execute `git fetch origin` e compare as branches. Quando houver HEAD local, use `git merge-base HEAD origin/main` para determinar se existe ancestral comum; erro diferente de ausência de ancestral exige diagnóstico.
4. Faça a integração numa branch de trabalho, por exemplo `codex/importacao-projeto`, sem renomear ou apagar a branch anterior.
5. Se ambos os lados já têm commits relacionados, use merge normal. Se forem duas histórias iniciais independentes, e isso tiver sido verificado, use `git merge --no-commit --no-ff --allow-unrelated-histories origin/main`. Não use essa opção indiscriminadamente.
6. Em um repositório local sem commits, não faça checkout que sobrescreva arquivos não rastreados. Primeiro prepare um snapshot local revisado ou organize cópias fora da árvore; depois integre o histórico remoto. Nunca apague a pasta `.git`.
7. Resolva conflitos preservando o conteúdo real. Mescle regras úteis de `.gitignore` e `.gitattributes`; não troque os arquivos inteiros cegamente. A documentação nova prevalece sobre canon antigo, mas os textos anteriores podem ser preservados no arquivo histórico.
8. Revise `git diff --check`, o índice e a lista de arquivos; teste o projeto quando o engine estiver disponível. Finalize o commit de integração somente após revisar o resultado.
9. Quando autorizado pela tarefa, envie a branch: `git push -u origin codex/importacao-projeto`. Abra PR para `main` com descrição dos arquivos importados, testes e pendências. Não use force-push ou merge destrutivo para vencer rejeições.

O script automatiza apenas o preparo anterior; não executa essa conciliação. O Codex deve tomar as decisões com base no estado real do checkout.

## Rotina nas próximas tarefas

Confira status, branch e mudanças staged antes de editar. Use uma branch `codex/<tarefa>` quando iniciar trabalho novo. Busque referências remotas antes de sincronizar e faça `pull --ff-only` somente com contexto adequado e árvore limpa; divergência deve ser analisada.

Depois da implementação, execute verificações proporcionais, revise o diff e faça staging por caminho. Atualize documentos afetados junto ao código. Commit/push respeitam a autorização da tarefa; este guia não cria autorização permanente para publicar mudanças futuras.

Mensagens sugeridas: `docs: consolida histórico do ATLAS`, `feat: adiciona esquiva`, `fix: corrige alinhamento de caminhada`. Não registrar uma mecânica como pronta se apenas um prompt foi produzido.

## Arquivos Godot

Versionar `project.godot`, cenas, scripts, recursos, fontes de arte/áudio aprovadas e metadados necessários (`.uid` e arquivos de configuração `*.import` associados aos assets). Ignorar caches `.godot/`, diretório legado `.import/`, builds e credenciais. Confirmar a versão do engine antes da importação inicial; versões antigas podem guardar credenciais em `export_presets.cfg`.

Os arquivos PNG originais são referências; não são animações finais verificadas. Evite adicionar backups e ZIPs duplicados sem necessidade. Nenhuma configuração de Git LFS foi imposta sem avaliar tamanho/tipos dos assets reais.

## Como o Codex recebe as instruções

`AGENTS.md` na raiz contém o fluxo e os documentos de continuidade. Inicie a tarefa na raiz correta e peça ao Codex para confirmar que leu esse arquivo. Não é necessário instalar um plugin Git no Godot para o Codex usar o executável Git no terminal.

## Fontes técnicas consultadas

- https://learn.chatgpt.com/docs/agent-configuration/agents-md
- https://git-scm.com/docs/git-merge
- https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html

## Validação desta entrega

Os links internos, a consistência documental e as regras de ignore foram conferidos no ambiente de preparação. A execução do script no PowerShell/Windows, autenticação, sincronização do jogo e funcionamento do Godot não foram testados neste ambiente. Não marcar esses itens como concluídos sem executá-los localmente.
