# Estado atual — 22/10/2026

## Vers?o integrada atual

O pedido de 22/10/2026 ampliou a produ??o para as metas A?D: agora h? percurso por F5, combate/anima??es revisados, cinco p?ginas e evento final. Consulte [entrega e evid?ncias](../atlas/ENTREGA_JOGAVEL.md) e [decis?es U12?U16](../atlas/DECISOES.md). Os registros de preparo Git abaixo descrevem o estado anterior. Prazo vigente: 23/10/2026.


## Verificação local — 22/10/2026

Esta seção atualiza as evidências anteriores desta página. O projeto real foi inspecionado em `C:\Users\Arthur-Gamer\OneDrive\Documentos\ChatGPT\GODOT-ATLAS`. Godot local: `4.7.2.stable.official.ed1daf0bf`; base 640×360, filtro nearest, Compatibility. O trecho de movimentação já existe em `scenes/main.tscn`, `scenes/player.tscn`, `scripts/player.gd` e `scripts/atlas_visual.gd`: WASD, diagonal normalizada, colisão nos pés e obstáculos, câmera e estados espera/caminhada mantendo direção. Pose estável padrão; animações originais continuam em revisão. Evidências da implementação anterior: [estado técnico](../atlas/ESTADO_PRODUCAO.md) e logs em `docs/atlas/evidencias/`; não confundir testes anteriores com testes executados pelo preparo Git.

Git 2.55.0.windows.5. Não havia `.git`, histórico local, staging ou remotes antes deste preparo. Inicializado somente nesta raiz. Login pelo Git Credential Manager concluído para `codeversion7`; leitura/fetch autenticados de `origin` aprovados. Remoto: `https://github.com/codeversion7/Jogo_Atlas.git`; base documental `4846b4a70882ca1fe2341606f70d189f62b109c5` e seu ancestral preservados. Integração local na branch `codex/preparo-git`, com `main` preservada na base remota. Arquivos de gameplay permanecem alterações locais não commitadas/não publicadas; nenhum commit ou push autorizado nesta tarefa.

E-mail de autor informado pelos responsáveis: `Codeversion7@gmail.com`, configurado somente neste repositório. Nome de autor ainda pendente; não foi inferido da conta GitHub. Preferências locais: `fetch.prune=true`, `pull.ff=only`, `push.default=simple`, aplicadas apenas onde ausentes. O script `Preparar-AtlasGit.ps1` foi lido, mas sua execução foi bloqueada pela política de execução do PowerShell; o preparo equivalente foi feito com comandos Git explícitos, sem alterar essa política.

Preservação: cópia e manifesto SHA-256 dos 184 arquivos originais fora da árvore em `C:\Users\Arthur-Gamer\Documents\atlas\git-preparation-20261022`; documentos remotos acrescentados e regras de `.gitignore`/`.gitattributes` conciliadas. Índice representa exclusivamente a base remota, sem staging adicional de código ou documentação nova. Também foram encontrados arquivos preexistentes de arena (`scenes/combat_arena.tscn`, `scripts/combat_player.gd`, `scripts/combat_arena.gd`, `scripts/test_monster.gd` e `tools/verify_combat.gd`), com combate, três ondas e primeira página em cena separada. O registro local relata 41 verificações de combate aprovadas na etapa anterior; essa suíte não foi repetida pelo preparo Git. Nenhuma mecânica foi alterada nesta tarefa. As decisões locais U12–U15 e os limites atuais estão em [decisões técnicas](../atlas/DECISOES.md) e foram conciliados com o resumo abaixo. Mapa completo, cinco páginas completas, livro e exportação continuam pendentes.

Validações deste preparo: `git diff --check` aprovado; índice sem diferenças staged em relação ao commit-base; ancestral remoto e duas branches preservados; hash de todos os 184 arquivos anteriores conferido, com somente `.gitignore` e `.gitattributes` tratados pela conciliação. Os demais 182 arquivos originais permaneceram byte a byte iguais. Ignore confirmado para caches/builds/credenciais; metadados `.uid` e configuração `.import` de assets continuam disponíveis para versionamento. Sintaxe do script PowerShell analisada sem executá-lo; abertura normal da cena Godot em headless executada com código 0, sem erros. Nenhuma alegação de teste interativo ou exportação.

## Registro anterior da consolidação remota

## Evidências e limites

| Item | Situação | Base da afirmação |
| --- | --- | --- |
| Cena base no Godot | Existente segundo os responsáveis | Relato; código local não inspecionado nesta consolidação |
| Visual do protagonista | Aprovado pelos responsáveis | Aprovação explícita na conversa |
| Base de animação | Trabalhada com Codex segundo os responsáveis | Resultado local mais recente não inspecionado |
| Folhas originais de espera e caminhada | Geradas, com problemas visuais apontados | Imagens e revisão na conversa |
| Estruturação do jogo | Documentada, com lacunas identificadas | Pacote anterior e decisões posteriores |
| Git instalado no Windows | Informado pelos responsáveis | Configuração e autenticação locais não testadas |
| GitHub remoto | Privado, acessível e com permissão de escrita | Consulta ao conector GitHub |
| Código Godot no remoto | Ausente na inspeção inicial | GitHub retornou repositório vazio |
| Combate, ondas e mapa completo | Não comprovados como implementados | Há decisões e instruções; não há código disponível nesta inspeção |
| Prévias animadas aprovadas e testes no Godot | Não comprovados | Não houve execução local nesta consolidação |

Esta publicação adiciona documentação, metadados Git e preparo de sincronização. Não instala Git nem autentica o computador dos responsáveis, não importa o projeto local e não altera mecânicas do jogo.

## Situação de design

Roguelike 2D de cima em pixel art. Cinco páginas perdidas estruturam o prólogo. Hordas em determinadas áreas próximas às páginas exigem atacar, recuar e retornar rapidamente. A arma inicial é uma adaga de emergência desgastada; defesa com parry e esquiva.

Continuam abertas as regras de morte e retenção das páginas, disponibilidade da página durante/após a horda, alcance do parry, atributos, ondas, monstros, mapa definitivo e versão do Godot.

## Próxima ação técnica

Conectar o checkout local ao remoto preservando mudanças e histórico; trazer este conjunto de documentação; inspecionar `project.godot`, cenas, scripts e animações reais. Só então atualizar a tabela acima com evidências de implementação e teste.

O primeiro objetivo de gameplay proposto é uma arena pequena com um inimigo, ondas configuráveis e ataque/parry/esquiva, seguida da integração com exploração e primeira página. Ver [roadmap](../desenvolvimento/ROADMAP.md).
