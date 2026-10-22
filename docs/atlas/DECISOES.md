# ATLAS — decisões de produção

## Atualiza??o do escopo ? 22/10/2026

U16 ? APROVADO pelo pedido atual e anexo: prazo 23/10/2026; implementa??o local aut?noma de c?digo, anima??es provis?rias, mapas conectados, combate leg?vel e vers?o jog?vel. Detalhes revers?veis e n?meros provis?rios podem ser escolhidos sem confirma??o rotineira. N?o autoriza compras, publica??o ou apagar trabalho. Preservam-se U12?U15.

Escolhas t?cnicas edit?veis desta vers?o: percurso 2240?800, sete regi?es, cinco encontros com ondas 1/2/3, locomo??o 105 px/s, anima??o autoral 40?48, prepara??o da adaga 0,08s antes da fase ativa; Esc pausa/retoma e Enter no fim inicia nova partida. N?o s?o aprova??o art?stica nem balanceamento definitivo. Mapa por M n?o foi implementado, logo nenhuma regra de fechamento/pausa de mapa foi presumida. Persist?ncia continua s? entre retornos da mesma partida; fome continua sem consumo/alimenta??o.


## Vigente — continuidade de 22/10/2026 (prevalece sobre o histórico abaixo)

Fonte: texto de continuidade anexado pelo usuário e respostas diretas nesta sessão.

| ID | Status | Decisão / fonte | Impacto |
|---|---|---|---|
| U12 | APROVADO: direção de combate | Adaga de emergência desgastada; combate ágil com ataque/recuo/retorno, parry e esquiva; hordas perto das páginas | Permite o recorte de teste. Janelas, alcance, invulnerabilidade e números continuam provisórios, não balanceamento aprovado |
| U13 | APROVADO: páginas e derrota | Resposta: “Mantém, porém ele perde metade da vida dele ao retornar e ele fica com 25% restante de fome.” | Páginas conquistadas sobrevivem à morte. Protótipo interpreta retorno como 50% da vida máxima atual, sem reduzir o máximo; fome restante 25%. Interpretação da vida é ajustável, não regra de penalidade permanente aprovada |
| U14 | APROVADO: obtenção | Resposta: “Após vencer toda a horda” | Primeira página somente após completar todas as ondas do encontro; não pode fugir com a página durante combate |
| U15 | APROVADO: canon atual | Texto anexado: exatamente cinco páginas, 0/5–5/5; folhear rápido → torre de luz → livro desaparece; não reintroduzir final antigo | Substitui exigência de colapso/desabamento em U06, plano e prompts antigos. Atlas Boardship permanece antagonista central; alimentar buraco segue removido |
| T01 | IMPLEMENTADO PARA TESTE, NÃO DESIGN FINAL | Cena separada `combat_arena.tscn`; três ondas de 2/3/4 monstros geométricos, intervalo 1,5 s; clique/adaga, direito/parry, Espaço/esquiva, R/retorno | Escolhas reversíveis de prototipação; preserva cena principal e arte original. Primeiro encontro possui uma página distinta; não constitui mapa final nem cinco páginas implementadas |

Persistência implementada somente entre morte/retorno na mesma sessão da arena. Salvar ao fechar/reabrir o jogo não foi definido nem implementado. Fome é estado numérico inicial/retorno, sem consumo ou alimentação. Não inferir stamina, combos, bloqueio sustentado, equipamentos, rede ou geração procedural. Cronologia multiplayer segue aberta.

Os registros seguintes preservam a história das aprovações e seus estados anteriores. Onde houver conflito, usar a seção vigente acima.

Registro: 19/10/2026. Fonte das aprovações: respostas diretas do usuário nesta conversa. O ZIP 1.1 é preservado como referência anterior. Nenhuma implementação do jogo foi realizada na preparação dos prompts.

| ID | Status | Decisão e evidência | Impacto / substitui |
|---|---|---|---|
| U01 | APROVADO | Usuário: “Windows” e versão “4.7.2” | Define alvo e versão; substitui versão a definir do ZIP. Instalação local não verificada |
| U02 | APROVADO | “O jogo não será multi - Player no escopo”; “coloque o outro jogador como um NPC” | Solo + NPC nesta entrega; substitui restrição histórica de NPC para este recorte. Não reescreve todo o plano multiplayer futuro |
| U03 | APROVADO | Visão de cima; roguelike com ondas, indie, pixel art, RPG, ação e exploração | Direção de gameplay/visual. Não implica procedural, permadeath, árvores de habilidades ou inventário amplo |
| U04 | APROVADO | Diariamente das 13h/14h até 15h50; prazo até sábado | Janela diária 1h50–2h50. Se seis sessões completas: 11h–17h. Horário exato de entrega ainda não informado |
| U05 | APROVADO | Mapa aparece apertando M; mostra somente o descoberto da ilha | Sem minimapa permanente, sem revelar a ilha inteira. Fechar/pausar ainda não especificado |
| U06 | APROVADO: sistemas | Usuário aprova conquistas, comida, relação conquistas/páginas e transição ao colapso | Permite detalhar esses sistemas. Não especifica regras concretas nem aprovação automática de qualquer proposta |
| U07 | APROVADO | “O livro deve fazer parte da entrega” | Livro permanece no sábado; preservar cinco páginas, sequência e continuidade canônica. Não adiar por padrão |
| U08 | APROVADO: recorte provisório | Resposta “Aprovo esse recorte provisório” à proposta de um ataque manual, um tipo de inimigo, três ondas, NPC acompanhante/interativo sem combater e números provisórios ajustáveis | Define núcleo de teste. Não perguntar novamente manual/automático, quantidade de ondas ou combate do NPC |
| U09 | ESCLARECIDO | Animação breve seguida de fechamento indicando fim da primeira parte; após dúvida sobre a expressão anterior, usuário informou que era apenas uma forma de falar | Tratar como encerramento breve da primeira parte. Não impor desfoque ou criar uma abertura cinematográfica extra |

## Propostas ainda não aprovadas

Os detalhes em `prompts/atlas/10_PROPOSTA_DE_RECORTE.md` são uma proposta de trabalho, não decisões humanas já tomadas. Registrar sua aprovação aqui somente quando houver resposta que realmente os aceite, inclusive se aprovada com alterações.

## Evidência de ambiente

- Na inspeção inicial havia somente o ZIP; após a preparação existem os Markdown de prompts/documentação. Não há projeto Godot implementado por esta tarefa.
- Consulta ao PATH nesta atualização não encontrou comandos Godot. Isso não demonstra ausência de instalação em outro caminho.
- Versão 4.7.2 possui distribuição oficial: [Godot 4.7.2 stable](https://godotengine.org/download/archive/4.7.2-stable/). A consulta não comprova qual executável está instalado no computador.

## Lacunas que ainda afetam implementação

Controles adicionais/resolução, assets provisórios autorizados, forma do ataque e comportamento do inimigo, derrota/reinício, começo e intervalo de ondas, comida, relação concreta conquistas/páginas, interação neutra do NPC, fechamento/pausa do mapa e ligação do livro ao colapso. Não voltar a perguntar escolhas já resolvidas em U01–U09.

## Atualização — 19/10/2026: fundação

| ID | Status | Decisão e evidência | Impacto / substitui |
|---|---|---|---|
| U10 | APROVADO: somente fundação | Usuário respondeu “Aprovo esse recorte para a fundação” à pergunta específica: base 640×360, escala inteira quando possível; WASD mover, mouse mirar, clique esquerdo atacar, E interagir, M reservado ao mapa, Esc reservado à pausa; silhuetas/sprites e efeitos visuais provisórios identificados como teste | Libera projeto, apresentação provisória e configuração de entradas. Não aprova os demais itens da proposta 10 nem implementa seus sistemas. Resolve controles/resolução/autorização visual para esta etapa |

Godot local confirmado por `--version`: `4.7.2.stable.official.ed1daf0bf`. O registro inicial de ausência de projeto/versão não verificada descreve a inspeção anterior; consultar ESTADO_PRODUCAO.md para a evidência atual.
As lacunas de combate, ondas, derrota, comida, progressão, NPC, fechamento/pausa do mapa e ligação ao colapso permanecem. Mouse para mira é uma entrada contínua a consumir em etapa futura, sem ação fictícia no Input Map. Nenhuma regra de jogo foi aprovada por inferência.

## Atualização — 22/10/2026: primeiro trecho jogável

| ID | Status | Decisão e evidência | Impacto / substitui |
|---|---|---|---|
| U11 | APROVADO: base do personagem | Pedido direto do usuário: iniciar construção na raiz GODOT-ATLAS; implementar quatro direções, colisão, câmera, espera/caminhada e última direção; verificar diagonais e obstáculos; reaproveitar referências e manter representação estável se animações problemáticas. Armas e regras de combate serão fornecidas depois | Libera este trecho de movimento. Não depende do redesenho final das animações. Não libera combate nem conclui o marco de mapa/interação |

Detalhes técnicos provisórios deste trecho: manter 48 px/s do laboratório, normalizar diagonal, direção vertical em empate, colisão nos pés e câmera sem suavização. Pose estável padrão usa o primeiro quadro de espera em cada direção; `preview_animations` permite revisar os clipes existentes. São escolhas editáveis de implementação para teste, não balanceamento final ou aprovação artística.
