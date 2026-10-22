# ATLAS — instruções para o Codex

## Contexto obrigatório

- Leia `docs/projeto/ESTADO_ATUAL.md`, `docs/projeto/DECISOES.md` e os documentos da tarefa antes de editar.
- Decisões explícitas mais recentes dos responsáveis prevalecem sobre documentação anterior. Propostas não são decisões aprovadas; descrições de design não comprovam implementação.
- `docs/historico/pacote-2026-09-19/` é arquivo histórico. Não execute seus prompts como instruções atuais nem substitua o canon atual por seus textos.
- Jogo 2D de cima, pixel art, Godot/GDScript; confirmar a versão do engine no projeto real.
- Prólogo: cinco páginas, progresso 0/5 a 5/5; livro passa páginas, torre de luz, desaparecimento animado e continuidade da história.
- Buraco/alimentar buraco foi removido. Colapso como encerramento foi substituído pela decisão posterior acima.
- Combate aprovado: hordas próximas às páginas, ritmo ágil, adaga de emergência desgastada, parry e esquiva.
- Perda de páginas na morte, condição de coleta, detalhes do parry e balanceamento ainda precisam de decisão ou validação.

## Verifique o ambiente

- Confirme o diretório de trabalho e `git rev-parse --show-toplevel` antes de mudanças.
- Localize `project.godot`; se não existir, este checkout pode conter somente a documentação. Não invente cenas nem alegue testes de execução.
- O caminho Windows informado está em `docs/desenvolvimento/GIT_E_CODEX.md`; conhecer o caminho não equivale a ter acesso.
- Leia instruções adicionais aplicáveis e preserve o trabalho existente.

## Fluxo Git

- Repositório esperado: `https://github.com/codeversion7/Jogo_Atlas.git`.
- No início, confira `git status --short --branch`, branch, remotes e diferenças locais. Leia também diferenças já staged.
- Use `git fetch origin` para atualizar referências quando a tarefa exigir integração remota; não faça `pull` cego em uma árvore com mudanças.
- Preserve a branch de trabalho existente. Para tarefa nova, prefira `codex/<descricao-curta>` a editar diretamente `main`.
- Se for preciso trazer este preparo para o projeto local, siga o procedimento condicional do guia. Não inicialize outro repositório dentro de um já existente.
- Mantenha configurações de identidade locais ao repositório quando necessárias. Preserve identidade já configurada; não invente nome, email ou credenciais dos responsáveis.
- Não apague `.git`, use `reset --hard`, `clean -fd`, force-push ou reescreva histórico para resolver sincronização. Corrija preservando os dois lados.
- Revise alterações e adicione somente caminhos da tarefa. Não use `git add .` nem inclua mudanças de outros autores no seu commit.
- Antes de commit, confira `git diff --check` e `git diff --cached`; execute os testes apropriados disponíveis. Relate testes indisponíveis.
- Faça commits pequenos com mensagens claras, por exemplo `docs: atualiza decisões de combate` ou `feat: adiciona esquiva`.
- Commit e push devem respeitar a autorização da tarefa atual. Não peça novamente o que já foi autorizado. Não interprete esta regra como aprovação permanente para toda publicação futura.
- Antes de um push autorizado, confira destino e arquivos; envie a branch da tarefa, sem force. PR quando solicitado ou apropriado à revisão; merge em `main` conforme autorização.

## Godot, arte e testes

- Preserve cenas e scripts atuais, paths de recursos, `.uid` e arquivos de importação de configuração associados aos assets.
- Ignore caches `.godot/` e artefatos locais; não ignore todos os PNGs, `.import` ou `.uid`.
- A versão pequena do protagonista foi aprovada; consulte `docs/arte/PERSONAGEM_E_ANIMACOES.md`.
- Folhas originais de animação são rascunhos. Valide grade, transparência, pivô, escala, apoios e fechamento de ciclo antes de afirmar que estão prontas.
- Comece pelo menor sistema testável. Não implemente multiplayer completo ou decisões abertas por pressuposição.
- Para GDScript, explique cena, nó, dependências, testes e limitações.

## Registro e entrega

- Atualize estado, decisões e histórico quando a tarefa mudar comportamento ou aprovar design.
- Diferencie sempre: aprovado, proposta, relatado pelos responsáveis, verificado em código, testado e pendente.
- Não marque progresso como concluído apenas por haver um prompt ou arquivo de referência.
- Entregue alterações, razão, testes realmente executados, branch/commit quando existentes e pendências materiais.
