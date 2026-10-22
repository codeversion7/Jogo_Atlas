# Entrega jogável — ATLAS, 22/10/2026

Fonte: pedido “Finalizar todas as metas e apresentar uma versão jogável” e anexo de continuidade, lido antes das alterações. Prazo vigente: **23/10/2026, São Paulo**. As autorizações antigas limitadas à fundação foram ampliadas explicitamente para código, mapas, animações, recursos provisórios e testes locais. Nenhuma compra, publicação, commit, push ou exclusão de trabalho anterior.

## Critérios e evidência

| Critério do pedido | Implementação e verificação |
|---|---|
| Caminhada perceptível em quatro direções | 124 quadros vetoriais autorais de 40×48, transparência, pés articulados, cachecol, rabo baixo, barba e roupas consistentes. `atlas_visual.gd`, fonte em `tools/generate_provisional_character.py`; contato e prévia normal/lenta. Verificador visual: 132 verificações. Referências PNG originais intactas |
| Diagonal, colisão, parada e transição | Física existente reutilizada; 67 verificações de locomoção. Versão por F5 habilita animação, mantém direção ao parar e relógio de caminhada; pose estável continua opção do laboratório |
| Adaga legível | Preparação 0,08s → ativo 0,12s → recuperação 0,20s, parâmetros exportados. Corpo e arma mudam de pose; dano somente ativo, uma vez por alvo. Setores visíveis usam a mesma geometria de acerto |
| Colisão / vulnerabilidade / arma / parry | Física nos pés, círculo vulnerável separado, setor da adaga e parry direcional. F3 mostra física verde, vulnerável magenta e áreas de ataque/defesa. Raios de cenário impedem dano através de obstáculos |
| Esquiva, dano e morte | Janelas/intervalos configuráveis, rastro, flash de dano, pose de morte, inimigo com preparo/ataque/recuperação e cadáver temporário sem duplicar derrota. 54 verificações de combate |
| Mapas base conectados | Recurso `resources/route_layout.tres`, cena `scenes/playable.tscn`; destroços, caminhos, abrigo opcional, bosque e ruínas. Obstáculos, costa, pilares, faróis, destroços e Y-sort. Teste percorre os corredores pelas entradas de movimento |
| Execução normal | `project.godot` abre o percurso por F5, sem montar cenas. Atalho `Jogar-ATLAS.cmd`. Labs e arena antiga continuam separados |
| Hordas e primeira página | Cinco encontros com um tipo de monstro e três ondas provisórias 1/2/3. Espaço para recuar, spawns verificados contra sólidos; se todas as posições estiverem bloqueadas, aguarda espaço sem gerar dentro de parede. Primeira e demais páginas liberadas apenas após horda inteira |
| Cinco páginas e retorno | Identificadores 0–4 distintos, contador 0/5–5/5, E exige proximidade, coleta sem duplicação. Páginas mantidas na morte; R retorna com metade da vida máxima e fome 25%, sem reduzir máximo |
| Livro e encerramento | Estado `flipping` → `light` → `vanishing` → `complete`, animação real de páginas, partículas/torre e desaparecimento; fim da primeira parte. Enter inicia uma nova partida verificada |
| Depuração e pausa | F3 alterna os limites efetivos, Esc congela e retoma o mundo/livro. Testados com eventos de entrada |
| Exportação Windows condicional | Preset preparado, tentativa real de `--export-debug`; templates locais ausentes. Execução pelo engine/editor preservada. Não existe EXE exportado certificado |

## Execução dos testes

Com Godot `4.7.2.stable.official.ed1daf0bf`:

```powershell
& '<Godot-console.exe>' --headless --path . --import
& '<Godot-console.exe>' --headless --path . --fixed-fps 60 --script res://tools/verify_player.gd
& '<Godot-console.exe>' --headless --path . --fixed-fps 60 --script res://tools/verify_combat.gd
& '<Godot-console.exe>' --headless --path . --script res://tools/generate_provisional_character_verify.gd
& '<Godot-console.exe>' --headless --path . --script res://tools/verify_animations.gd
& '<Godot-console.exe>' --headless --path . --fixed-fps 60 --script res://tools/verify_playable.gd
& '<Godot-console.exe>' --path . --fixed-fps 60 --disable-vsync --script res://tools/verify_playable.gd -- --capture
& '<Godot-console.exe>' --path . --fixed-fps 60 --disable-vsync --script res://tools/render_release_review.gd
```

O teste integrado percorre sete regiões por movimentos simulados, inicia a primeira horda caminhando, cancela na morte, retorna, conclui cinco hordas de três ondas com golpes reais, coleta cinco páginas por E, verifica retenção, sequência do livro, F3, Esc e reinício. Na parte de combate/progressão, o teste posiciona alvos e interrompe sua perseguição para isolar os casos; isso não equivale a uma partida humana nem aprova dificuldade. A suíte separada de combate exercita perseguição/ataque e desvio de obstáculos.

Há capturas do viewport real `05_*.png`, 60 amostras em `release_frames/` e prévias animadas `05_animacoes.png` (APNG) / `.gif`, quatro segundos. Foram inspecionadas as imagens de destroços, arena, livro e fim, além da folha de contato. Não declarar avaliação humana contínua ou teste de teclado/mouse físico. Os testes temporários no sandbox registraram erro de certificados do Windows, sem impacto na física; logs finais no projeto original distinguem o ambiente.

## Limites e continuidade

Arte e parâmetros são provisórios, sem aprovação artística final ou balanceamento humano. O cenário é uma base compacta autoral, não a ilha definitiva. Áudio, mapa M, comida funcional, NPC, conquistas extras e persistência em disco permanecem fora das metas explícitas A–D; fome no HUD é somente o estado de retorno solicitado. Não foram acrescentados stamina, combos, rede, procedural, arma de fogo, buraco ou encerramento por colapso.

O ZIP de fontes e o launcher dependem do Godot 4.7.2. Exportação independente permanece condicionada aos templates ausentes. Próxima prioridade: teste humano do ritmo/clareza e substituição dos desenhos provisórios pelos recursos definitivos dos responsáveis, seguida de exportação com templates locais.

## Resultado final no projeto original

Aplicado em `C:\Users\Arthur-Gamer\OneDrive\Documentos\ChatGPT\GODOT-ATLAS`, preservando a mudança concorrente de nome para `Atlas_Verdadeiro`, a branch `codex/preparo-git`, o histórico e os oito arquivos originais de referências. Os arquivos anteriores modificados têm cópia externa em `Documents/atlas/atlas-release-original-backup`; nenhuma exclusão ou commit.

- Importação limpa: código 0, sem erros no log final. A primeira aplicação detectou BOM UTF-8 na cena visual; corrigido em três arquivos e repetida a importação com sucesso, sem depender do cache anterior.
- `05_verify_playable.log`: **155 verificações, zero falhas**, 5/5 e quatro fases canônicas; reinício confirmado com 0/5.
- `05_verify_combat.log`: **54 verificações, zero falhas**.
- `05_verify_player.log`: **67 verificações, zero falhas**.
- `05_generate_provisional_character_verify.log`: **132 verificações, zero falhas**.
- `05_verify_animations.log`: **zero falhas, nove ciclos observados**.
- `05_release_render.log`: **163 verificações, zero falhas**, incluindo gravação de oito capturas reais do fluxo completo. `05_f5_inicio.log` confirma a abertura normal da cena integrada. Os oito logs finais de importação/runtime/testes não contêm erros ou avisos.
- `05_exportacao_windows.log`: saída 1, exclusivamente por templates Windows 4.7.2 ausentes nos caminhos reais de APPDATA. Não é um EXE pronto e não houve download automático.
- `builds/ATLAS_jogavel_fontes.zip`: integridade conferida, extraído em pasta limpa sem `.godot` e importado do zero. O pacote extraído repetiu **155 verificações do percurso sem falhas**; o erro de certificados reapareceu apenas no ambiente restrito de teste, sem falha de script. Os fontes de runtime entregues são iguais aos testados no projeto original.

O pacote contém [JOGAR.md](../../JOGAR.md), launcher, cenas, scripts, recursos, testes e documentação. É uma versão compacta completa do percurso das cinco páginas com recursos provisórios, não aprovação artística, balanceamento humano ou certificação de exportação Windows.
