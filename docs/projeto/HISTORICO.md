# Histórico de produção

## Módulo 4 — execução iniciada em 25/10/2026

Fechamento anterior confirmado no SHA4462421; execução sequencial, sem agentes extras. Fases01–02 implementadas/validadas: contato final/intermediário da adaga corrigido após reprodução, onda34/46px ligada a dois upgrades; rastreio/F/Passo ágil removidos, esquiva base preservada. Árvore em cena própria e HUD de vida/fome à esquerda. Números provisórios; nenhuma compra gratuita. Estado/testes/backup/pendências em [MODULO_4_STATUS](../desenvolvimento/MODULO_4_STATUS.md). Novas regras seguintes só constam implementadas quando a fase correspondente estiver validada.

## Fechamento técnico do módulo 3 — 25/10/2026

Retomada autorizada para encerrar as pendências. Identificada e corrigida a recarga recorrente da arte da esfera: recursos compartilhados por `preload`, materiais individuais, sem mudar combate. Na carga gráfica equivalente de 1.200 frames, máximo 48,944→8,180 ms; frames >16,67 ms 5→0. Recorte dos passos ajustado para conter o pico real da fonte, sem modificar originais ou ganhos. Auditoria numérica dos oito áudios aprovada; áudio/configurações38, monstros79, suporte/livro40 e percurso real5897 sem falhas. Cópia limpa também validada. [Relatório e limites](../desenvolvimento/MODULO_3_FECHAMENTO.md).

Escopo funcional do módulo encerrado tecnicamente. Aceite humano de áudio/arte e partida prolongada continua não realizado; números editáveis/frentes disponíveis não viram design final por inferência. Backup final anterior preservado; somente checkpoint incremental novo. Mudanças locais anteriores mantidas fora da seleção Git. Nenhum módulo seguinte.

## Módulo 3 — seis fases implementadas e validadas em 23/10/2026

Integrados áudio real e preferências, fome/carne/fogueira, vida/queda/resgate do amigo, suporte frontal de 5 s +0,2 por partilha, redução50% sem reflexão, parry protegido0,5 s, livro com5 páginas/amigo vivo, telas ATLAS e cinco áreas principais expansíveis. Módulos1/2 e assets preservados. Fases/testes/números provisórios/evidências em [MODULO_3_STATUS](../desenvolvimento/MODULO_3_STATUS.md); uso em [MODULO_3_USO](../desenvolvimento/MODULO_3_USO.md).

17 suítes sem falhas de asserção/script; fluxo real5897, 5/5, uma partilha, amigo vivo, Q/F usados, vida93. Build debug Windows local e23 checks no template exportado montando PCK real, sem editor; ZIP externo verificado. Monitores de física são máximos por janelas de~1s, não custos de cada tick: frames p95~7,23ms com pico raro43,3ms; causa do pico não isolada, sem alegar lag resolvido. Escuta/mixagem e avaliação artística humanas pendentes; ataques frontais e valores provisórios. Créditos do engine comprovados por fonte oficial, sem autores de assets inventados. Implementação publicada e preservada; sem módulo4 ou release pública.



Implementação no commit `d2628328501d2dccaa63d9e0d077a7caaf6b32b1`, enviada e confirmada em `origin/codex/preparo-git` em 2026-10-23T22:37:54-03:00. Autenticação funcional; sem force-push/merge. Usuário informou **7% restantes** e solicitou emergência: nenhuma feature, refatoração ou suíte longa iniciada após esse aviso. Backup final já verificado de2574 arquivos em `C:/Users/Arthur-Gamer/Documents/atlas/module3-backup-final` preservado sem refazer ou alterar; novo checkpoint incremental em `module3-checkpoints/07-emergency-7-percent`. ZIP Windows verificado em `C:/Users/Arthur-Gamer/Documents/atlas/ATLAS_Modulo3_Windows_debug.zip`. Fontes estão no disco; não se alega Salvar Tudo de memória do editor. Pendências: audição/mixagem, revisão artística/humana e causa dos picos raros de frame; ataques frontais e números provisórios permanecem registrados. Próxima ação: avaliação humana pelo F5/ZIP e definição de ajustes; não iniciar módulo4 automaticamente. Execução encerrada após publicar este checkpoint.


## Encerramento técnico do módulo 2 — retomada de 23/10/2026

Escopo funcional do protótipo concluído: mapa com descoberta em M, encontros editáveis, acompanhante interativo sem combate, menu/pausa/árvore/diálogo coordenados e quatro ataques aprovados. Auditoria conferiu fontes atuais sem alterações de gameplay desde a publicação, cobertura/resultados dos 12 testes anteriores, capturas, integridade dos 2131 arquivos do backup e SHA remoto `0ef88af`. Não executou nova suíte longa. Critérios, evidências e limites em [auditoria](../desenvolvimento/AUDITORIA_MODULO_2.md). Último saldo relatado 6%; saldo atual desconhecido. Próximo passo: avaliação humana e diagnóstico de física; nenhum módulo 3.


## Preservação emergencial — 23/10/2026

Usuário informou 6% restantes. Implementação do módulo 2 e ataques aprovada nas 12 suítes do original; preservação/backup/checkpoint e publicação autorizada em andamento. Limitação material: vistas de ataque frontais e monitor de física elevado/discrepante, diagnóstico pendente. Sem módulo 3. Ver [relatório](../desenvolvimento/MODULO_2_MAPA_MUNDO.md).

## Integração de ataques no módulo 2 — 23/10/2026

Decisão explícita posterior do usuário: integrar animações e mecânicas de corte cruzado (Fenda), pancada (Carcaça), esfera explosiva (Esporo) e ataque na marca fixa (Escavador), com valores provisórios editáveis. Implementados no F5 sobre os recursos frontais preparados, preservando vida/dano e módulos anteriores. Corpo único e FX separados; aviso sem dano, impacto único, parry/esquiva/parede e cancelamento. Escavador trava marca no começo e só emerge em espaço livre. Apenas frente disponível para o corpo de ataque; alcance/tempos/raios ajustáveis e pendentes de balanceamento humano. Preparação frontal descrita abaixo passa a ser registro anterior à integração. Fluxo real com IA ativa 5839 verificações, 5/5 páginas, Q/F e final/menu, sem falhas; 74 casos de mecânicas. Detalhes e evidências em [Módulo 2](../desenvolvimento/MODULO_2_MAPA_MUNDO.md). Não executar módulo 3.

## Módulo 2 — mundo, mapa e entrada integrados em 23/10/2026

Mapa da primeira parte centralizado no recurso de layout, sete regiões e ampliação inferior controlada; M mostra somente células/marcos observados. Encontros têm distribuição editável dos quatro visuais e três ondas preservadas. Um acompanhante provisório não combatente segue por rotas com colisão e interage por E, com prioridade para páginas. F5 continua `scenes/playable.tscn`, agora com menu básico antes da simulação; menu/mapa/árvore/diálogo/pausa compartilham posse de entrada. Módulo 1, cinco páginas e livro mantidos. Detalhes, ajustes, testes e limites: [Módulo 2](../desenvolvimento/MODULO_2_MAPA_MUNDO.md). Sem módulo 3 ou EXE.


## Módulo 1 — personagem integrado em 23/10/2026

Implementados atributos centralizados por instância, exatamente três ramos (adaga de retorno Q, rastreio F e parry inicial), aquisição por pontos de encontros, árvore/status em Tab e feedback de recargas. Vida/dano/esquiva base, lâmina visível, páginas e livro preservados. Parâmetros/decisões provisórias, testes, backup, medições e limites em [Módulo 1](../desenvolvimento/MODULO_1_PERSONAGEM.md). Laboratórios conservados em `scenes/review/`; F5 permanece `scenes/playable.tscn`. Sem módulos 2/3.


Registro do material disponível; datas ausentes não foram inventadas. A descrição de uma ação planejada não implica implementação.

## 19/09/2026 — documentação de continuidade

Foi disponibilizado um pacote para transferir contexto do ATLAS entre conversas e instâncias de IA. Ele reúne GDD, narrativa, gameplay, arquitetura proposta, multiplayer, histórico, backlog, protocolo e prompt inicial.

O pacote descreve retirada do buraco e substituição pelo livro, sobrevivente da queda da nave, ferimentos, escassez de comida e Atlas Boardship como antagonista. A redação antiga ainda fala em fragmentos de quantidade indefinida e encerramento por colapso.

Em instrução posterior explícita, os responsáveis fixaram cinco páginas perdidas e a sequência de páginas rápidas, torre de luz e desaparecimento do livro. A data exata dessa instrução não é atribuída aqui; sua prioridade sobre o pacote antigo está registrada em DECISOES.md.

## 18/10/2026 — intenção de integração das ferramentas

Foi solicitada orientação para ligar ChatGPT e Godot, com objetivo de alterar o projeto por prompts. Antigravity IDE e Obsidian foram mencionados no contexto de integração. A conversa disponível não comprova configuração concluída ou conexão técnica ativa dessas ferramentas.

## 20/10/2026 — direção de arte e personagem

Brainstorming por perguntas objetivas definiu visão de cima, inicialmente arte 2D desenhada, e sensações de aventura/coragem, medo/desconforto e encanto/curiosidade.

O protagonista foi definido como homem adulto acima de 25 anos, pele média, cabelo castanho-escuro comprido amarrado baixo, barba curta e postura cautelosa. Roupas danificadas da nave e cachecol longo preto com traços vermelho-escuros tornaram-se elementos de continuidade e reconhecimento.

Foi gerada uma prancha pintada com vistas e expressões. O traje foi proposto provisoriamente porque o documento inicial ainda não estava acessível naquele momento. Depois, a pedido dos responsáveis, foram geradas versões em pixel art e uma versão menor e simplificada nas quatro direções. Esta última recebeu aprovação explícita dos responsáveis, incluindo Enzo.

## 20/10/2026 — primeiras folhas de animação

Foram geradas folhas de espera/respiração e caminhada nas quatro direções. A revisão visual identificou poses semelhantes, transição de pés pouco clara, possíveis variações de posição/escala e necessidade de verificar transparência.

Naquela sessão, o ambiente de execução estava indisponível. Não foram montadas prévias em loop nem realizados testes de pixels ou no Godot. Foi fornecido um handoff para o Codex, mantendo os quadros como rascunhos.

## 22/10/2026 — arquivos, pacote e localização do projeto

Com o ambiente disponível, foi criado `ATLAS_ANIMACAO_HANDOFF.md` e salvo na pasta GODOT-ATLAS. Depois foi montado `ATLAS_Pacote_Para_Codex.zip`: cinco arquivos em `referencias/personagem/` e `LEIA_PRIMEIRO.txt` na raiz.

O ZIP foi testado quanto à integridade e as cópias internas comparadas às fontes. Isso valida o transporte, não a qualidade da animação.

O Codex local não encontrou os arquivos em `C:\Users\Arthur-Gamer\Documents\atlas`. Capturas mostraram outro projeto em OneDrive/Documentos/ChatGPT/GODOT-ATLAS. Os responsáveis foram orientados a copiar a pasta `referencias` extraída para junto de `project.godot` e informaram o caminho completo. O acesso efetivo do Codex ao caminho precisa ser confirmado no computador.

## 22/10/2026 — início da construção de gameplay

Os responsáveis informaram cena base, visual em pixel art aprovado, base de animação do Codex e estruturação do jogo. Solicitou-se iniciar construção de personagem, mecânicas, mapa e combate.

Foi proposta uma entrega pequena: validar personagem; criar mapa inicial e arena; implementar combate; ligar interação e primeira página; testar o conjunto. Layout de destroços/rota/arena permaneceu como proposta.

Foi aprovado o combate roguelike ágil com hordas perto das páginas, adaga de emergência desgastada e defesa com parry e esquiva. Parry direcional, invulnerabilidade na esquiva, timings e regras de ondas foram apresentados como propostas, não decisões finais.

Ficaram sem resposta as regras de retenção das páginas após a morte e de coleta durante/após a horda. Foi preparado um prompt de continuidade para outro chat com decisões, caminhos, limitações e próximos passos.

## 22/10/2026 — repositório e preparação Git

Os responsáveis solicitaram documentar o projeto no GitHub e preparar o Codex para Git, já instalado segundo seu relato.

O repositório privado `codeversion7/Jogo_Atlas`, branch padrão `main`, foi encontrado com acesso de escrita. A API confirmou que estava vazio, sem commits e sem código do jogo.

Foi preparada esta consolidação, o arquivo `AGENTS.md`, metadados Git, guia de integração e script PowerShell de diagnóstico/preparo local. A configuração do Windows, autenticação, importação do jogo e testes do engine permanecem dependentes do ambiente local.

## Histórico anterior, preservado como histórico

O pacote de origem registra os conceitos antigos de alimentar o buraco e considerar um segundo personagem como NPC para reduzir escopo. Não são decisões atuais. Registra também a simplificação documental de “Brothers Forever” para “Brothers”; não há base para inventar outro significado.

## Como continuar este registro

Acrescentar fatos com evidências: decisão explícita, arquivos alterados, commit/PR e testes. Não registrar tarefas propostas como prontas. Atualizar ESTADO_ATUAL.md após a importação e inspeção do projeto real.


## 22/10/2026 — preparo e integração no projeto Windows real

Inspeção confirmou o jogo na raiz GODOT-ATLAS indicada, ainda sem Git. Foram preservados 184 arquivos em cópia externa com manifesto SHA-256. Git inicializado nessa raiz e `origin` configurado para o repositório correto. Os responsáveis forneceram `Codeversion7@gmail.com`; e-mail aplicado localmente, nome ainda pendente. Autenticação oficial pelo Git Credential Manager concluída como `codeversion7`, seguida de consulta e fetch de `main`.

Lidos AGENTS.md, GIT_E_CODEX.md, estado, decisões, histórico e script remoto. Preservados os dois commits documentais remotos, sem criar histórico independente. Documentação integrada na branch `codex/preparo-git`; jogo e referências mantidos. Regras úteis de ignore/atributos conciliadas; nenhuma alteração de gameplay. Execução do script PowerShell bloqueada pela política do sistema; comandos Git equivalentes aplicados sem desabilitar a política. Não houve commit, push, force-push, limpeza ou descarte. Estado e pendências em ESTADO_ATUAL.md.

Inspeção da conciliação também encontrou a arena preexistente e as decisões locais U12–U15, posteriores às lacunas do remoto sobre retenção/coleta da página. Os resumos foram atualizados com referências ao registro local preservado. Abertura headless do Godot aprovada neste preparo; suítes anteriores de movimento/combate/animação não foram repetidas, pois o código permaneceu intacto.

## 22/10/2026 ? percurso jog?vel de cinco p?ginas

Metas A?D do anexo implementadas em c?pia de trabalho e verificadas antes da aplica??o: anima??o pr?pria articulada, fases reais de adaga, parry/esquiva/dano/morte e depura??o, percurso conectado com cinco hordas/p?ginas e encerramento can?nico. Labs anteriores preservados, sem commit/push. Evid?ncias e limites, inclusive templates Windows ausentes, em ../atlas/ENTREGA_JOGAVEL.md.
