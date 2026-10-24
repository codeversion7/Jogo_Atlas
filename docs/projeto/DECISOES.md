# Decisões e pendências

## Módulo 3 — seis fases implementadas e validadas em 23/10/2026

Integrados áudio real e preferências, fome/carne/fogueira, vida/queda/resgate do amigo, suporte frontal de 5 s +0,2 por partilha, redução50% sem reflexão, parry protegido0,5 s, livro com5 páginas/amigo vivo, telas ATLAS e cinco áreas principais expansíveis. Módulos1/2 e assets preservados. Fases/testes/números provisórios/evidências em [MODULO_3_STATUS](../desenvolvimento/MODULO_3_STATUS.md); uso em [MODULO_3_USO](../desenvolvimento/MODULO_3_USO.md).

17 suítes sem falhas de asserção/script; fluxo real5897, 5/5, uma partilha, amigo vivo, Q/F usados, vida93. Build debug Windows local e23 checks no template exportado montando PCK real, sem editor; ZIP externo verificado. Monitores de física são máximos por janelas de~1s, não custos de cada tick: frames p95~7,23ms com pico raro43,3ms; causa do pico não isolada, sem alegar lag resolvido. Escuta/mixagem e avaliação artística humanas pendentes; ataques frontais e valores provisórios. Créditos do engine comprovados por fonte oficial, sem autores de assets inventados. Preservação/publicação autorizada em fechamento; sem módulo4 ou release pública.


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


## Vers?o integrada atual

O pedido de 22/10/2026 ampliou a produ??o para as metas A?D: agora h? percurso por F5, combate/anima??es revisados, cinco p?ginas e evento final. Consulte [entrega e evid?ncias](../atlas/ENTREGA_JOGAVEL.md) e [decis?es U12?U16](../atlas/DECISOES.md). Os registros de preparo Git abaixo descrevem o estado anterior. Prazo vigente: 23/10/2026.


## Confirmações locais — 22/10/2026

- Engine verificado no executável: Godot `4.7.2.stable.official.ed1daf0bf`; `project.godot` usa recursos 4.7. Resolve a versão antes pendente em D01 e no item 10 abaixo.
- Projeto existente: base 640×360, escala inteira, WASD e cena inicial `res://scenes/main.tscn`. Movimento implementado; as entradas reservadas não comprovam combate, mapa ou pausa.
- Autoria Git: somente o e-mail `Codeversion7@gmail.com` foi fornecido nesta solicitação. `user.name` continua pendente; nenhuma identidade foi inventada.
- Este preparo não aprova regras novas de gameplay nem altera o código. A arena de combate preexistente e suas decisões foram encontradas na inspeção; não atribuir sua implementação à integração Git.
- As decisões locais U13/U14 já resolvem as perguntas 1 e 2 do registro remoto abaixo: páginas mantidas após a morte e coleta somente após vencer toda a horda. Retorno de teste com 50% da vida máxima e fome restante 25%, sem redução permanente do máximo. Fonte: [registro local das aprovações](../atlas/DECISOES.md), mantido integralmente. Persistência somente durante a sessão da arena; salvar em disco ainda não implementado.
- U15 confirma cinco páginas e folhear → torre de luz → desaparecimento, substituindo o colapso antigo. U12 registra adaga, parry e esquiva; números e timings são hipóteses ajustáveis de teste. As questões do texto remoto abaixo que conflitam com estas confirmações descrevem pendências anteriores.

## Aprovado / vigente

| ID | Decisão | Observação |
| --- | --- | --- |
| D01 | Godot, GDScript e primeiro protótipo 2D | Versão exata do engine pendente |
| D02 | Perspectiva de cima com movimentação pelo cenário | Vista oblíqua, não jogo lateral |
| D03 | Pixel art pequena e simplificada | Substituiu o acabamento inicial desenhado/pintado |
| D04 | Homem adulto acima de 25 anos, pele média e barba curta definida | Cabeça levemente ampliada, corpo simplificado |
| D05 | Cabelo castanho-escuro comprido em rabo de cavalo baixo | Marca visual do personagem |
| D06 | Cachecol longo preto com traços vermelho-escuros | Marca visual do personagem |
| D07 | Roupas danificadas que usava na nave | Cortes e cores do conceito foram provisórios |
| D08 | Observa com cautela e age apesar do medo | Coragem não significa ausência de medo |
| D09 | Aventura/coragem, medo/desconforto e encanto/curiosidade | Direção emocional aprovada |
| D10 | Queda da nave; protagonista gravemente ferido e único sobrevivente inicial | Relações cronológicas futuras não resolvidas |
| D11 | Atlas Boardship como antagonista central | Monstros não substituem esse papel narrativo |
| D12 | Cinco páginas de um livro rasgado; progresso 0/5 a 5/5 | Supera a quantidade indefinida do pacote antigo |
| D13 | Livro passa páginas rapidamente, torre de luz e desaparecimento animado | Supera o colapso como encerramento automático |
| D14 | Remoção da tarefa de alimentar um buraco | Não reintroduzir sem decisão explícita |
| D15 | Roguelike com combate frenético em hordas em certas áreas próximas às páginas | Atacar, recuar e voltar em pouco tempo |
| D16 | Adaga de emergência desgastada por uso frequente em curta distância | Não foi aprovada arma de fogo inicial |
| D17 | Defesa combinando parry e esquiva | Regras concretas ainda em definição |

## Base documental anterior mantida, com detalhamento pendente

- Escassez de comida com função de exploração/sobrevivência; manter simples no MVP.
- Conquistas/desafios ligados à progressão do livro; conciliar com a busca das cinco páginas e as hordas.
- Estrutura narrativa para três jogadores: personagem da ilha e dois membros da nave, amigos de longa data. Cronologia e rede abertas; não exige multiplayer no primeiro protótipo.

## Propostas, não aprovações definitivas

- Arena pequena e um tipo de monstro antes de expandir conteúdo.
- Ataque curto com recuperação e um acerto por alvo por golpe.
- Parry direcional de janela curta que interrompe o ataque.
- Esquiva com invulnerabilidade breve e intervalo entre usos.
- Ataques inimigos com preparação legível e recuperação.
- Mapa com destroços, caminho principal, rota opcional com recurso e área de confronto.
- Quadros nativos de aproximadamente 32 × 48 pixels; espera com 4 quadros a 4 FPS e caminhada com 6 a 8 FPS. Validar no cenário e nos arquivos reais.

## Decisões ainda abertas

1. Ao morrer, perde as páginas da tentativa ou mantém as já conquistadas?
2. A página exige eliminar a horda ou pode ser coletada durante o combate para fugir?
3. Como as conquistas/desafios liberam páginas nesta estrutura?
4. Parry afeta um ataque ou vários simultâneos? Quais ataques são aparáveis?
5. Quais controles, dano, vida, alcances, janelas e custos das ações?
6. Haverá stamina, combos ou bloqueio sustentado? Não presumir.
7. Como serão monstros, ondas, morte, reinício e recursos de recuperação?
8. Como o roguelike organiza variações entre tentativas e progressão permanente?
9. Mapa, bioma, itens, áudio, interface, origem do livro e detalhes da Atlas Boardship.
10. Versão do Godot, resolução de jogo, disponibilidade de engine/testes e organização real das cenas.

As duas primeiras perguntas foram as últimas feitas aos responsáveis e ainda não receberam resposta na conversa fornecida.
