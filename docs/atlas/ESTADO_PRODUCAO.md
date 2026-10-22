# ATLAS — estado de produção

## Vers?o jog?vel integrada ? 22/10/2026

Pedido atual: finalizar as metas A?D do anexo de continuidade. Prazo atualizado para 23/10/2026 (S?o Paulo). Implementado percurso por F5 com anima??o autoral articulada, combate por fases com depura??o F3, sete regi?es conectadas, cinco encontros de tr?s ondas, cinco p?ginas distintas, morte/retorno, pausa e sequ?ncia final do livro. N?o ? a ilha ou arte definitiva. As se??es anteriores abaixo ficam preservadas como hist?rico.

In?cio e controles: [JOGAR.md](../../JOGAR.md). Crit?rios, arquivos, comandos, testes e limites: [ENTREGA_JOGAVEL.md](ENTREGA_JOGAVEL.md). Godot 4.7.2; recursos pr?prios provis?rios e refer?ncias originais preservadas. Exporta??o Windows tentada, mas templates 4.7.2 ausentes; execu??o pelo editor/engine dispon?vel. Sem commit, push ou publica??o.


## Estado vigente — arena e primeira página, 22/10/2026

Inspeção nesta sessão confirmou acesso à raiz correta e Godot `4.7.2.stable.official.ed1daf0bf` por execução de `--version`. Sem Git nesta raiz e sem AGENTS.md encontrado na árvore aplicável. Código anterior de locomoção, referências e animações foram preservados. As seções abaixo deste registro descrevem etapas anteriores e não substituem este estado ou as decisões U12–U15.

**Implementado nesta etapa:** `scenes/combat_arena.tscn`, cena de teste separada herdada de `main.tscn`. Abrir no Godot e usar **F6**. F5 continua abrindo a base de locomoção anterior. O recorte reutiliza piso, limites e personagem; remove somente o bloco na instância de teste, fixa a câmera para visualizar a arena e usa velocidade provisória 85 px/s. Cruzar a linha à direita inicia o encontro. Não é o mapa definitivo nem arte de destroços/ilha.

- `scripts/combat_player.gd` estende o controlador existente: adaga curta, um dano por alvo/golpe, recuperação, parry direcional que interrompe o inimigo, esquiva com invulnerabilidade e intervalo, vida/dano/morte e retorno. Mira por mouse; geometria explicita alcance/defesa enquanto não existem animações de combate aprovadas. A pose estável original continua provisória.
- `scripts/test_monster.gd`: único monstro geométrico, perseguição, preparação laranja comprometida com direção, ataque único, recuperação, interrupção ciano por parry e morte processada uma vez. Colisão com cenário/outros monstros. Sem navegação de mapa complexo.
- `scripts/combat_arena.gd`: exploração curta → três ondas configuráveis (2/3/4) → primeira página disponível → aproximação + E → 1/5, sem duplicação. Não libera a página durante ondas nem intervalos. HUD mostra vida, fome, páginas e onda. Falta construir as outras quatro páginas e a sequência final do livro.
- Morte cancela encontro e inimigos ativos. R retorna ao início com 50% da vida máxima e fome restante 25%; não reduz vida máxima permanentemente. Páginas coletadas são mantidas durante os retornos da mesma sessão. Se morrer antes de obter a página, o confronto recomeça ao entrar novamente. Não há salvamento entre aberturas do jogo nem regras de consumo de comida.

**Controles experimentais:** WASD mover, mouse mirar, clique esquerdo atacar, direito parry, Espaço esquivar, E coletar página próxima, R retornar após morte. Entradas adicionais instaladas apenas ao carregar a arena; não alteram `project.godot`. Números exportados nos scripts são hipóteses para avaliação, não balanceamento final. Sem stamina, combos ou bloqueio sustentado.

**Validação executada:** importação no Godot, testes headless e renderização OpenGL. `ATLAS_COMBAT_TEST checks=41 failures=0`; regressão `ATLAS_PLAYER_TEST checks=67 failures=0`; animações `ATLAS_ANIMATION_TEST failures=0 observed_walk_loops=9`. Teste de combate percorre alcance/direção, dano único, recuperação, parry frontal/traseiro/expirado, esquiva/cooldown/parede, ataque anunciado do inimigo, ataques em sobreposição, gatilho por movimento, três ondas vencidas por golpes, E/coleta, duplicação, morte, R/retorno e cancelamento de ondas. Algumas preparações posicionam alvos e restauram estados para isolar os casos; não equivalem a uma partida humana ou balanceamento validado.

Logs: `docs/atlas/evidencias/04_combate_import.log`, `04_combate_testes.log`, `04_combate_render.log`, `04_movimento_regressao.log`, `04_animacoes_regressao.log`. Capturas reais do viewport inspecionadas: `04_combate.png`, `04_parry.png`, `04_pagina.png` (a captura de página monta explicitamente o estado de apresentação; conclusão das ondas é exercitada antes no teste). A primeira importação restrita teve erros de permissão nas configurações do Godot; repetida com autorização fora do sandbox e sem esses erros. Os testes finais renderizados passaram.

Reprodução com o executável console documentado abaixo:

```powershell
& '<Godot-console.exe>' --headless --path '<GODOT-ATLAS>' --fixed-fps 60 --script res://tools/verify_combat.gd
& '<Godot-console.exe>' --path '<GODOT-ATLAS>' --fixed-fps 60 --resolution 640x360 --script res://tools/verify_combat.gd -- --capture
```

**Validação manual pendente:** F6 na arena; cruzar a linha, atacar/recuar, observar preparação laranja, usar parry de frente e esquiva, vencer as três ondas, recolher a página com E. Em outra tentativa, morrer e usar R para verificar os recursos. Avaliar leitura, responsividade, ritmo, dificuldade e dimensões. Imagens são evidência de apresentação, não animações finais. Sem teste humano de teclado/mouse, mapa completo, comida funcional, persistência em disco, NPC, final do livro, exportação ou medição de desempenho.

**Próximo passo:** avaliar o combate jogando e ajustar seus parâmetros antes de integrar o recorte à cena inicial e construir o mapa de exploração. Decisões de morte/página agora estão registradas em U13/U14; o colapso antigo foi substituído por U15. Nenhuma narrativa adicional foi inventada.

Atualizado em 22/10/2026. Primeiro trecho jogável: base de locomoção implementada. Os registros abaixo da seção atual são históricos e descrevem o estado anterior.

## Estado atual — base do personagem, 22/10/2026

Fonte: pedido direto do usuário para iniciar o trecho jogável na raiz `OneDrive/Documentos/ChatGPT/GODOT-ATLAS`, com movimento, colisão, câmera, transições e representação estável se as animações continuassem problemáticas. Contrato, contexto, decisões, plano, cenas, scripts, ferramentas e handoff foram conferidos. Não há AGENTS.md aplicável encontrado nem Git nesta raiz; a revisão usa comparação dos arquivos com uma cópia anterior preservada no workspace de trabalho.

Implementado:

- `scenes/main.tscn`: conserva o piso e a interface da fundação; substitui os placeholders sobrepostos e o ramo redundante `World2` por um único `World/Player`; adiciona quatro limites físicos e um bloco de teste editável. HUD atualizado para o escopo real.
- `scenes/player.tscn` → `scripts/player.gd`: CharacterBody2D em modo floating, movimento WASD na física, diagonal normalizada, início/parada imediatos, velocidade provisória exportada `move_speed=48` px/s. Camada 2 do jogador colide com camada 1 do cenário. Retângulo de colisão 14×8 nos pés, não na cabeça/cachecol. Camera2D filha acompanha sem suavização.
- Reutilizado `scenes/atlas_visual_revisao.tscn` e `scripts/atlas_visual.gd`: recebe velocidade efetiva após colisão, mantém a última direção ao parar e entra em espera quando bloqueado. Direção pelo eixo dominante; empate diagonal usa vertical com tolerância para arredondamento. `motion_animation` expõe o estado lógico `idle_*`/`walk_*`.
- Padrão estável: primeiro quadro `idle_*` da direção, pausado. Assim o teste de locomoção não reproduz os saltos de proporção dos rascunhos. No Inspector de Player, `preview_animations=true` habilita os oito clipes existentes para revisão, com taxa proporcional à velocidade; não é aprovação artística. O laboratório mantém a reprodução normal.
- `tools/verify_player.gd`: integração de entradas, controlador, física, visual e câmera na cena principal. `tools/verify_animations.gd` teve apenas a expectativa antiga de placeholder atualizada para o personagem jogável.

Validação com Godot `4.7.2.stable.official.ed1daf0bf`, primeiro na cópia de trabalho e depois repetida no projeto alvo: importação concluída; `ATLAS_PLAYER_TEST checks=67 failures=0`; `ATLAS_ANIMATION_TEST failures=0 observed_walk_loops=9`; verificador Python/Pillow 13.0.0 aprovado (40 quadros, hashes originais, alfa, pés e 32 prévias). O primeiro teste exigiu corrigir limites esperados do retângulo dos pés e tolerância numérica das asserções; não foi desativada nenhuma verificação. Python padrão não tinha Pillow; usado o pacote local já existente em `Documents/atlas/animation_work/python_deps`, sem instalar dependência no jogo. No sandbox houve erro de leitura de certificados do Windows; não afetou os casos de física/animação. As execuções finais no projeto alvo, fora dessa restrição, não apresentaram esse erro.

Evidência final no projeto alvo: importação, teste de personagem, regressão de animações, teste de personagem com renderização OpenGL e abertura normal da cena (`--headless --quit-after 5`) retornaram código 0. Logs em `docs/atlas/evidencias/02_movimento_import.log`, `02_movimento_testes.log`, `02_animacoes_regressao.log`, `02_movimento_render.log` e `02_movimento_inicio.log`. A captura final `02_movimento.png` confirma a interface e pose estável no viewport 640×360; o corte inicialmente observado no texto foi corrigido. O teste Python também foi repetido no alvo com aprovação. Antes de aplicar, os hashes dos sete arquivos existentes envolvidos foram conferidos para não sobrescrever mudanças concorrentes; a cópia anterior está em `Documents/atlas/godot-playable-baseline`. Nenhum commit foi feito.

Casos automatizados: quatro direções e quatro diagonais, velocidade sem ganho diagonal, teclas físicas WASD mapeadas, entradas opostas, início/parada sem deriva, troca durante movimento, última direção após parada, pressão pelos quatro lados do bloco, espera contra obstáculo, deslizamento e passagem pela quina, quatro bordas, modo de prévia animada e câmera ativa seguindo o jogador. Captura do viewport com OpenGL em `docs/atlas/evidencias/02_movimento.png` inspecionada visualmente; isso não equivale a teste com teclado físico.

Limitações: caminhada ainda precisa de apoios/passagens claros, especialmente laterais; espera e transições entre fontes têm variações de contorno/volume. Detalhes preservados em `docs/atlas/animacoes/README.md` e no handoff. Referências e folhas originais não foram alteradas. A pose parada desliza intencionalmente durante a locomoção de teste; não representa um ciclo de passos final. Não executados teste humano com teclado, avaliação contínua dos loops, exportação e medição de desempenho.

Reprodução (Godot console no caminho já documentado abaixo):

```powershell
& '<Godot-console.exe>' --headless --path '<GODOT-ATLAS>' --import
& '<Godot-console.exe>' --headless --path '<GODOT-ATLAS>' --script res://tools/verify_player.gd
& '<Godot-console.exe>' --headless --path '<GODOT-ATLAS>' --script res://tools/verify_animations.gd
& '<Godot-console.exe>' --path '<GODOT-ATLAS>' --script res://tools/verify_player.gd -- --capture
```

Teste manual: abrir este `project.godot` no Godot 4.7.2 e usar F5; mover com WASD, combinar diagonais, inverter direções e soltar; pressionar o bloco por todos os lados, contornar suas quinas e alcançar cada borda. O personagem deve parar ao bloquear e conservar a direção ao soltar; a câmera deve acompanhá-lo. Para comparar os rascunhos, marcar `preview_animations` em `World/Player`, executar novamente e revisar início/parada e troca de direção. O parâmetro é aplicado ao iniciar a cena.

Próximo passo: receber definição de armas e regras de combate. Mapa, interação, pausa, NPC, ondas e progressão não foram implementados neste trecho. Este avanço é uma parte do marco 2, não conclusão de exploração/mapa. Nenhuma decisão narrativa, cinco páginas ou sequência do livro foi alterada.

## Fontes e aprovação

Raiz correta indicada pelo usuário: `C:\Users\Arthur-Gamer\OneDrive\Documentos\ChatGPT\GODOT-ATLAS`. Os cinco documentos solicitados e o ZIP existem; CONTRATO, CONTEXTO, DECISOES, proposta 10 e fundação 01 foram lidos. O ZIP não precisou ser consultado nem foi alterado. Na reinspeção anterior à criação, não havia project.godot, cenas ou scripts nesta raiz.
Usuário aprovou somente o recorte da fundação em 19/10/2026; registro U10 em DECISOES.md. Demais regras da proposta 10 continuam pendentes.
Nenhum projeto foi criado em Documents\atlas; testes dessa outra pasta não compõem a evidência abaixo.

## Implementado

- `project.godot`: Godot 4.7, renderizador Compatibility, cena inicial `res://scenes/main.tscn`; base 640×360, janela inicial 1280×720, proporção preservada e escala inteira; filtro de textura nearest.
- Input Map: `move_up` W, `move_left` A, `move_down` S, `move_right` D, `interact` E, `map` M, `pause` Esc e `attack` clique esquerdo. Teclas físicas. Mouse para mira será consumido diretamente em etapa futura; não há ação de mira artificial.
- `scenes/main.tscn`: raiz `Atlas` (Node2D) → `scripts/main.gd`; `World/TestGround` (Polygon2D); `World/PlayerPlaceholder` (Node2D) com três Polygon2D editáveis; `Interface` (CanvasLayer) com Labels.
- `scripts/main.gd`: atualiza `Interface/Status` pelo campo exportado `status_text` e registra carregamento. Esse texto é ajustável no Inspector da raiz Atlas.
- Silhueta e piso geométricos provisórios criados nesta etapa, sem arquivos externos ou áudio; identificados em tela como teste, sem alegação de arte final.
- `.gitignore` exclui cache .godot e builds; `.gitattributes` define texto. O UID de main.gd é gerado pelo Godot.

A cena é estática. Movimento, mira efetiva, combate, interação, mapa, pausa, NPC, comida, ondas, conquistas, páginas e livro não foram implementados. Entradas reservadas não significam sistemas concluídos.

## Evidência de execução — 19/10/2026

Executável descoberto nos metadados do projeto inicial e confirmado, sem busca indiscriminada:
`C:\Users\Arthur-Gamer\OneDrive\Documentos\Godot\Godot_v4.7.2-stable_win64.exe`.
Existe também o executável `_console.exe` na mesma pasta, usado no diagnóstico de entradas. Versão confirmada: `4.7.2.stable.official.ed1daf0bf`.
Os caminhos acima são evidência local; cenas, scripts e recursos de execução usam caminhos relativos `res://`.

Comandos executados a partir desta raiz, usando o executável indicado:

1. `--version` e `--help`: versão e opções disponíveis confirmadas.
2. `--headless --path <raiz> --import --log-file docs/atlas/evidencias/01_importacao.log`: código de saída 0; log de inicialização do editor e escaneamento concluídos, sem erros reportados.
3. `--headless --path <raiz> --quit-after 3 --log-file docs/atlas/evidencias/02_execucao.log`: código de saída 0; log registra “ATLAS: fundação carregada; cena principal pronta.”; sem erros reportados.
4. Executável console com `--headless --path <raiz> --script res://.godot/validate_foundation.gd --log-file docs/atlas/evidencias/03_entradas.log`: código de saída 0. Diagnóstico temporário no cache cria eventos físicos W/A/S/D/E/M/Esc e clique esquerdo, verifica o reconhecimento pelo InputMap e instancia a cena definida em application/run/main_scene. Resultado: sete teclas e clique reconhecidos, cena instanciada, viewport 640×360 e escala integer. O diagnóstico no cache não é dependência do projeto.
5. Inspeção de referências: main.tscn e main.gd existem; não há caminhos absolutos em project.godot, cenas ou scripts de execução. A única dependência externa da cena é main.gd.

Logs preservados em `docs/atlas/evidencias/`. Execuções liberadas fora da restrição de escrita da sessão, pois a raiz correta e as configurações/cache do Godot estão fora de Documents\atlas.

## Não executado / limites

- Abertura e revisão visual no editor com interface: NÃO EXECUTADAS.
- Interação física com teclado/mouse, redimensionamento e avaliação de legibilidade: NÃO EXECUTADOS; o diagnóstico de eventos não substitui teste manual.
- Exportação Windows e teste de build: NÃO EXECUTADOS. Formato/arquitetura e templates serão conferidos no marco de exportação.
- Não há medição de desempenho nem promessa de conclusão até sábado sem reavaliar as etapas restantes.

## Como abrir, editar e conferir manualmente

1. No Godot 4.7.2, importe/abra o `project.godot` desta raiz.
2. Abra `scenes/main.tscn`. A raiz Atlas expõe `status_text` no Inspector; as formas e os Labels podem ser editados diretamente na árvore.
3. Use F6 para a cena ou F5 para a cena principal configurada. Deve aparecer a apresentação “ATLAS / FUNDAÇÃO”, a silhueta e os avisos de teste; não esperar movimento nesta etapa.
4. Redimensione a janela e confira escala inteira, proporção, margens e legibilidade. Verifique Debugger/Output sem erros. Encerre com F8 no editor ou pelo fechamento normal da janela; Esc está apenas reservado.
5. Em Project Settings → Input Map, confira as oito ações e suas associações. Em Display → Window e Rendering, ajuste os valores provisórios de apresentação quando necessário, respeitando U10.

## Próximo marco

Exploração e mapa conforme PLANO.md. Fechamento e pausa do mapa ainda precisam de decisão específica; a proposta M abre/fecha e pausa não foi aprovada por U10. Não implementar etapas posteriores sem solicitação. Preservar exatamente cinco páginas, livro e colapso nos marcos correspondentes.

## Atualização — 22/10/2026: revisão das animações (parcial)

Fonte do escopo: pedido do usuário nesta sessão e `referencias/personagem/ATLAS_ANIMACAO_HANDOFF.md`. Materiais localizados na raiz correta indicada pelo usuário. Consultados o ZIP junto ao handoff e a referência visual aprovada; o ZIP antigo não substitui as decisões posteriores sobre versão, solo/NPC e cinco páginas.

Preparados dois PNGs de revisão com grade 40×48, alfa binário, recorte dos 40 desenhos por componentes reais, margem transparente e pivô (20,46). Corrigidos os pés da espera fixando pernas inferiores/botas nos quatro quadros de cada direção. A escala ainda é provisória para o piso da fundação; 32×48 ficou estreito para o cachecol com o alinhamento usado. A caminhada não recebeu um ciclo final: faltam poses confiáveis de passagem/apoio, sobretudo nas laterais; lista de redesenhos em `docs/atlas/animacoes/README.md`.

Criados SpriteFrames com oito clipes, componente visual desacoplado e `scenes/animation_lab.tscn` para F6. WASD e velocidade provisória de 48 px/s existem somente nesse laboratório. `set_motion` preserva a direção ao parar e não reinicia o relógio a cada atualização. A fundação real ainda não tem controlador de jogador; nenhuma mecânica, cena principal, duplicata World2 ou narrativa foi alterada para simular essa existência. Integração definitiva ao protagonista pendente até os desenhos passarem na revisão.

Entregues 16 APNGs transparentes e 16 GIFs direcionais, normais e lentos; tiras por quadro; prévias e 32 capturas do viewport real do Godot. No projeto alvo, importação, testes automáticos e renderização finalizaram com saída 0 e sem erros nos logs finais. Teste: `ATLAS_ANIMATION_TEST failures=0 observed_walk_loops=9`. Verificação Python: 40 quadros dentro das células, alfa/temporização/contagens corretos, pés inferiores idênticos e hashes de originais/fundação preservados. Logs, relatório, manifesto e ferramentas em `docs/atlas/animacoes/` e `tools/`.

Não certificados: leitura artística dos apoios, pé plantado sem deslizamento, respiração convincente, volume entre fontes, fechamento suave e transições artísticas. Não executados: revisão humana contínua dos loops, teclado físico, cenário definitivo, exportação ou sistemas narrativos. Uma tentativa de redesenho com ImageGen foi rejeitada por não resolver as passagens e está identificada no relatório, fora dos recursos de animação.

Próximo passo: redesenhar as fases listadas no README, revisar em loop e no cenário; só então substituir o visual da cena principal e conectar o componente ao controlador real. A continuidade do livro e das cinco páginas permanece intacta.
