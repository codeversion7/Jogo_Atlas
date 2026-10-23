# Retomada emergencial — ATLAS

## Encerramento técnico do módulo 2 — retomada de 23/10/2026

Escopo funcional do protótipo concluído: mapa com descoberta em M, encontros editáveis, acompanhante interativo sem combate, menu/pausa/árvore/diálogo coordenados e quatro ataques aprovados. Auditoria conferiu fontes atuais sem alterações de gameplay desde a publicação, cobertura/resultados dos 12 testes anteriores, capturas, integridade dos 2131 arquivos do backup e SHA remoto `0ef88af`. Não executou nova suíte longa. Critérios, evidências e limites em [auditoria](AUDITORIA_MODULO_2.md). Último saldo relatado 6%; saldo atual desconhecido. Próximo passo: avaliação humana e diagnóstico de física; nenhum módulo 3.


## Emergência do módulo 2 — 23/10/2026, saldo relatado 6%

Módulo 2 A–E e quatro mecânicas aprovadas integrados no original. Doze suítes sem falhas: 67/54/1384/165/5839/1374/469/74/13/30/24/45 verificações. Percurso com IA ativa 5/5, Q/F adquiridos/usados, livro/final/menu, sem vida/dano/teleporte artificiais; vida final 80. Capturas reais 10 de mundo/UI e 12 de ataques. Arte de ataque apenas frontal; NPC/texto provisórios. Frames p95 7,380 ms no teste de quatro ataques; monitor de física ~37 ms persistente e discrepante, causa pendente. Sem módulo 3, EXE ou Salvar Tudo de abas em memória.

Fontes/checkpoints em `C:/Users/Arthur-Gamer/Documents/atlas/module2-work` e `module2-checkpoints`, backup final SHA-256 em `module2-backup-final`, inicial de 1868 arquivos e backup separado do pacote de ataques em `module2-attacks-initial`. Saldo 6% foi informado pelo usuário, não consultado por ferramenta. Emergência interrompe novas features e suítes longas. Branch `codex/preparo-git`, origin `https://github.com/codeversion7/Jogo_Atlas.git`, autor local `codeversion7 <Codeversion7@gmail.com>`. Implementação preservada no commit `d4a2922fed6d2d364a34c74f0c8cc08988bc9ed6`, enviada a `origin/codex/preparo-git` e confirmada por SHA remoto em 2026-10-23T17:03:59-03:00. Sem force-push/merge. Autenticação Git funcional. Árvore do índice exportada, importada do zero e entrada F5/menu iniciada sem erros; nenhuma suíte longa após emergência. Backup final verificado de 2131 arquivos, atualizado com este checkpoint. Próxima ação apenas avaliação humana/diagnóstico de física; sem módulo 3.

## Checkpoint módulo 1 — 23/10/2026 16:00:58 — America/Sao_Paulo (UTC−03:00)

Módulo 1 implementado e validado no projeto original. Fatias/checkpoints 01–05 salvos em `C:/Users/Arthur-Gamer/Documents/atlas/module1-checkpoints`; backup inicial de 1785 arquivos verificado em `module1-backup-initial-20261023`. Branch `codex/preparo-git`, base `cf54a93`; Implementação salva no commit `91d85e6f8213820009d2dd2fa72f1f8232768c3c`, enviada a `origin/codex/preparo-git`; SHA remoto conferido por `git ls-remote` em 23/10/2026 16:02:37 — America/Sao_Paulo (UTC−03:00). Sem force-push/merge. Este registro documental é posterior ao commit de implementação e não altera fontes de gameplay. Backup final de 1866 arquivos verificado em `C:/Users/Arthur-Gamer/Documents/atlas/module1-backup-final-20261023`. Árvore staged exportada/importada do zero e as nove suítes repetidas sem falhas, provando que as dependências publicadas bastam. Cota real indisponível; nenhum percentual inventado. Atributos, Q retorno, F rastreio, Tab árvore/status, parry inicial/aprimoramentos e pontos por encontro integrados. Nove suítes passaram (67/54/1384/165/4596/1374/13/30/24 verificações); percurso 5/5 e livro/final, seis capturas OpenGL. Sem módulos 2/3, áudio novo ou exportação EXE. Medição antes/depois e limites em `MODULO_1_PERSONAGEM.md`.

Fontes salvas e importação real concluída. Abas não salvas na memória do editor não foram verificadas; não foi usado “Salvar Tudo”, fechado editor ou encerrado processo alheio. Laboratórios movidos com referências para `scenes/review/`; não alegamos ganho de desempenho pela pasta. Próxima ação: avaliação humana pelo F5/Tab/Q/F e ajuste de valores provisórios se desejado. Módulo 1 encerrado; módulos 2/3 não iniciados. F5 permanece `scenes/playable.tscn`; Q/F exigem aquisição em Tab; parry é base.


## Objetivo e último pedido

Produção anterior: finalizar as metas A–D e entregar versão compacta jogável; agora interrompida pelo pedido de preservação emergencial. Protocolo autoriza backup local, commit e push para o repositório configurado. Cota de uso indisponível nesta sessão: nenhum percentual foi estimado.

Raiz: `C:\Users\Arthur-Gamer\OneDrive\Documentos\ChatGPT\GODOT-ATLAS`. Nome do projeto preservado: `Atlas_Verdadeiro`. Godot confirmado: `4.7.2.stable.official.ed1daf0bf`. Branch atual: `codex/preparo-git`; origin: `https://github.com/codeversion7/Jogo_Atlas.git`. E-mail `Codeversion7@gmail.com`; usuário aprovou nome de autor `codeversion7` nesta sessão. Não houve alterações staged anteriores.

## Implementado e verificado antes da emergência

- Percurso por F5 em `scenes/playable.tscn`, controlador `scripts/playable.gd`, configuração `resources/route_layout.tres` e scripts de cenário. Sete regiões conectadas: destroços, exploração/ruínas, abrigo opcional e cinco clareiras de confronto.
- 124 quadros autorais provisórios de personagem, recursos em `assets/personagem/provisorio/`, gerador `tools/generate_provisional_character.py`, visual `scripts/atlas_visual.gd`; referências originais preservadas.
- Adaga por preparação/ativo/recuperação, parry, esquiva, dano/morte, áreas matemáticas compartilhadas em `scripts/combat_geometry.gd`, depuração F3 e pausa Esc.
- Cinco páginas distintas após hordas de três ondas; retenção ao morrer, R com 50% da vida máxima e fome 25%; final folhear → torre de luz → desaparecer, Enter reinicia.
- Suítes no projeto original: percurso 155/0, combate 54/0, movimento 67/0, visual 132/0, animações 0 falhas/nove ciclos. Renderização 163/0, importação e abertura normal sem erros nos oito logs finais. Pacote extraído sem cache repetiu 155 verificações sem falhas. Não houve teste humano de teclado/mouse físico nem aprovação artística/balanceamento.
- `builds/ATLAS_jogavel_fontes.zip` preparado, íntegro e testado em extração limpa; pacote de fontes, não EXE. Exportação Windows tentada e bloqueada por templates 4.7.2 ausentes; log `docs/atlas/evidencias/05_exportacao_windows.log`. Não instalar templates durante esta emergência.

## Incompleto e ainda não iniciado

- Pedido mais recente de produção informado no protocolo: analisar B1 Fenda, B2 Carcaça, B3 Esporo e B4 Escavador em `assets/monstros/`, preparar parado/oscilação, caminhada articulada, corrida e dano. A inspeção atual encontrou quatro PNGs de quatro direções e metadados `.import` em `pixel_v2/`; não foram encontrados clipes/recursos de animação desses quatro monstros. Não declarar animações prontas. Ataques específicos ficam para outra etapa.
- Recursos de monstros recebidos também em `ATLAS_Monstros_B_PixelArt_v2/` e ZIP de origem: preservar no backup e arquivos extraídos no Git. O monstro ativo do percurso ainda é o desenho provisório em `scripts/test_monster.gd`.
- Arte definitiva, avaliação humana, comida funcional, NPC, mapa M, persistência em disco e EXE Windows não concluídos; não confundir fome do HUD com sobrevivência.

## Arquivos e riscos

Treze arquivos existentes alterados na versão jogável: project.godot, README, cena visual, atlas_visual, combat_player, test_monster, verify_combat e registros de estado/decisões/plano/histórico. Novos: percurso/cenário/livro/pausa, recursos, quadros de personagem, testes, launcher, preset, JOGAR.md, relatório e evidências. A lista exata de produção está no backup e no commit; alterações incompletas de monstros são preservadas.

Durante integração, preservada alteração concorrente de `config/name` para `Atlas_Verdadeiro`; não substituir pelo nome antigo. BOM UTF-8 removido de três arquivos autorais após importação limpa apontar problema; importação repetida sem erros. Fontes anteriores modificados têm cópia externa em `Documents/atlas/atlas-release-original-backup`.

Não há processos de teste confirmados em andamento; o empacotamento anterior terminou antes da emergência. Nenhum Godot foi fechado à força. Alterações apenas na memória do editor não podem ser verificadas/salvas pela interface disponível: se houver abas não salvas, usar Salvar Tudo no editor. Arquivos abertos em `.godot/editor/` são cache e não substituem fontes.

## Próximo passo exato

1. Ler este checkpoint e conferir git status, branch/remoto e atualizações de outros autores.
2. Abrir `project.godot` no Godot 4.7.2; F5 executa o percurso. WASD, mouse, esquerdo/adaga, direito/parry, Espaço/esquiva, E/página, R/retorno, Esc/pausa e F3/áreas. `Jogar-ATLAS.cmd` usa o Godot local.
3. Para a próxima tarefa de produção, inspecionar tecnicamente os quatro PNGs em `assets/monstros/*/pixel_v2/`, preservar originais e definir quadros/pivôs. Criar cópias animadas de parado/caminhada/corrida/dano e verificar antes de integrar. Não gerar ataques específicos nesta etapa.
4. Continuar pela documentação `docs/projeto/ESTADO_ATUAL.md`, `docs/projeto/DECISOES.md`, `docs/desenvolvimento/ROADMAP.md` e `docs/atlas/ENTREGA_JOGAVEL.md`. Nenhuma suíte longa deve ser iniciada durante o salvamento emergencial.

## Preservação

Backup previsto: `C:\Users\Arthur-Gamer\OneDrive\Documentos\ChatGPT\GODOT-ATLAS\backups\ATLAS-emergencial-20261022-193121.zip`. Estado inicial: sendo criado. Inclui todos os fontes, arte original/derivada e recursos ignorados relevantes; exclui somente .git, .godot, a própria pasta backups e caches/temporários/credenciais. Commit e push: pendentes no momento da primeira gravação. Resultado final será acrescentado abaixo.

### Backup concluído

Arquivo: `C:\Users\Arthur-Gamer\OneDrive\Documentos\ChatGPT\GODOT-ATLAS\backups\ATLAS-emergencial-20261022-193121.zip`

Tamanho: 56100667 bytes. Fontes/recursos: 670 arquivos. ZIP aberto e íntegro, arquivos essenciais e quatro PNGs de monstros presentes. SHA-256: `243ca5b3102f1e3cc583dee5d910dbbac38bb893e2cad9b183b49cf698bbab70`. O backup contém o checkpoint inicial; o checkpoint final ficará no Git e no arquivo local.

### Revis?o anterior ao commit

Nome de autor configurado localmente como `codeversion7`, confirmado pelo usu?rio; e-mail preservado. Revisados 611 caminhos de produ??o: nenhum padr?o de segredo nem arquivo acima de 50 MiB sinalizado. Nove logs finais de evid?ncia inclu?dos explicitamente. Cinco ZIPs de origem/continuidade ficaram fora do Git, mas est?o no backup; caches, builds e backups n?o foram staged. `git diff --cached --check` apontou somente espa?os/finais de linha em arquivos e log existentes; conte?do foi preservado sem refatora??o durante a emerg?ncia. O commit de checkpoint registra trabalho incompleto; resultado de commit/push ser? registrado na sequ?ncia.

### Commit e envio confirmados

Commit de preserva??o: `302807a0b446a26e41eefe9d6782f2c3cb73bd24` na branch `codex/preparo-git`. Push para `https://github.com/codeversion7/Jogo_Atlas.git` conclu?do sem force; `git ls-remote --heads origin refs/heads/codex/preparo-git` confirmou o mesmo SHA no GitHub. O checkpoint com este recibo ser? salvo em um segundo commit documental normal. Nenhum PR ou merge foi executado.

Fora do Git: cinco ZIPs de origem/continuidade (conte?do preservado no backup), builds, backups, caches e logs n?o selecionados. C?digo, recursos, imagens originais e derivadas, ferramentas e trabalho incompleto foram inclu?dos. A produ??o foi interrompida conforme o protocolo; a pr?xima tarefa ? inspecionar e animar os quatro novos monstros, sem presumir que j? est?o animados.
