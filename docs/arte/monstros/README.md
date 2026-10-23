# Monstros — animações articuladas

## Revisão de legibilidade — 23/10/2026

Pedido direto: animações quase imperceptíveis, principalmente a caminhada; ampliar a passada. Ajustado `monster_visual.gd` mantendo tamanho dos sprites, velocidade/IA, colisões e regras de combate. Amplitude base da caminhada **3 → 6,5 px**, corrida **5 → 9 px**; levantamento **1,5 → 3 px** na caminhada e **2,8 → 4,5 px** na corrida. A influência dos membros agora tem centro mais largo e atinge o apoio visível antes da borda transparente; zonas sobrepostas têm sua soma limitada. Tronco acompanha mais o passo. A espera continua somente vertical, agora ±1,8 px; dano recua até 4,5 px com compressão mais clara. Impactos repetidos reiniciam o relógio da reação, sem alterar a vida/dano aplicados.

As constantes de amplitude ficam no início do script. Cache de poses versionado para não reaproveitar malhas antigas após recarga no editor. As taxas e quantidades de quadros foram preservadas.

Também corrigido o enquadramento do laboratório: havia um `Player` acrescentado no editor, fora da grade, cuja câmera mostrava apenas o personagem sobre fundo vazio. `monster_animation_lab.gd` desativa câmeras somente no laboratório; preserva o nó/posição e não altera a câmera do jogo.

Prévias atualizadas em `previas/`. [Comparar caminhada anterior/atual](revisao_passada/comparacao.html); capturas/GIFs anteriores preservados em `revisao_passada/antes/`. A comparação de apoios opostos 03/09 encontrou mais pixels mudando nas 16 vistas, mediana 6,255×, na mesma escala/câmera (limiar RGB 12). É uma medida de mudança visual, não aprovação artística. Dados em `revisao_passada/comparacao_movimento.json`.

Validação desta revisão no Godot 4.7.2: **1374 verificações de animação, zero falhas**; incluem passada de pelo menos 6 px no ponto de apoio amostrado de cada vista, espera visível, recuo e dano repetido, fechamento dos ciclos e câmera do laboratório. Regressão de combate: **54**, sem falhas. Partida com IA ativa: **4596**, sem falhas, cinco páginas, final, 60 ataques e 14 parries. Não equivale a teste humano. Logs `09_monstros_amplitude_testes.log`, `09_monstros_amplitude_render.log`, `09_combate_regressao.log`, `09_partida_regressao.log` em `docs/atlas/evidencias/`.

**Ataques específicos dos monstros não foram adicionados.** Os responsáveis estão produzindo as imagens; o ataque mecânico compartilhado e sua sinalização provisória continuam. A corrida permanece disponível no componente/laboratório, sem nova regra de sprint para a IA. Fontes preservadas, sem commit/push. As limitações da deformação descritas abaixo continuam: apoios encobertos não podem ser redesenhados por esta técnica e amplitudes maiores ainda precisam da avaliação humana em movimento.

## Base inicial — 22/10/2026

Pedido: analisar as quatro artes novas e animar parado (somente oscilação vertical), caminhada com membros alternados, corrida e dano. Ataques específicos ficam para uma próxima etapa.

## Ver e usar

- **No Godot:** abrir `scenes/review/monster_animation_lab.tscn` e pressionar F6. Linhas: Fenda, Carcaça, Esporo, Escavador. Colunas: parado, caminhada, corrida, dano. Setas alternam entre frente/esquerda/direita/costas; Espaço pausa; L alterna reprodução normal/lenta.
- **Prévias animadas:** abrir [previas.html](previas.html). GIFs e APNGs em `previas/` mostram todas as direções de cada estado. Os PNGs `idle.png`, `walk.png`, `run.png` e `hurt.png` são APNGs animados, não capturas estáticas. A prévia de dano segura o último quadro antes de repetir, somente para facilitar a inspeção.
- **No jogo:** F5. Os encontros usam as quatro aparências, com a mesma IA/estatísticas e o ataque provisório já existente. O dano recebido inicia o recuo visual automaticamente. Não foram implementados ataques próprios nem habilidades novas.

## Análise das fontes

O pacote `ATLAS_Monstros_B_PixelArt_v2` contém quatro vistas estáticas por criatura, em grade 2×2 (baixo/esquerda/direita/cima). Os PNGs são fontes ampliadas, não sprites nativos de 32×32. Os recortes e a ordem foram conferidos contra `MANIFESTO.json` e as imagens foram inspecionadas. A Carcaça tem uma folha de largura ímpar e partes próximas às bordas; não se pode dividir todas as fontes em células iguais indiscriminadamente. O Esporo tem halo translúcido e alfa máximo 254.

Os quatro hashes SHA-256 continuam iguais aos do manifesto: nenhuma arte-fonte foi alterada. Um shader de apresentação descarta alfa menor que 0,85 e usa filtro nearest para retirar os halos; isso não corrige nem sobrescreve o PNG original.

Fenda tem duas pernas de leitura mais clara. Carcaça tem apoios parcialmente encobertos; o tronco não deve ser confundido com perna. Esporo alterna grupos de membros ao redor do núcleo. Escavador alterna membros dianteiros grandes e apoios traseiros. As zonas de influência por criatura/direção ficam em `scripts/monster_animation_catalog.gd`.

## Implementação

`scripts/monster_visual.gd` + `scenes/monster_visual.tscn`: malha 2D texturizada com a imagem original, em escala de jogo (34–38 px de altura), articulada por zonas de membros. Não é uma nova folha redesenhada por IA ou à mão. É animação nativa do Godot, com poses discretas reutilizadas entre instâncias; o collider e a posição do inimigo não são animados.

| Estado | Poses por direção | Taxa base | Comportamento |
|---|---:|---:|---|
| Parado | 8 | 6 FPS | Subir/descer até 1,8 px; sem mover pernas nem alterar escala |
| Caminhada | 12 | 12 FPS | Membros alternados, amplitude base 6,5 px e levantamento de até 3 px |
| Corrida | 12 | 18 FPS | Amplitude base 9 px, levantamento de até 4,5 px e inclinação lateral |
| Dano | 5 | 20 FPS | Recuo de até 4,5 px, compressão e flash, sem laço automático |

São 592 poses ao todo: 4 criaturas × 4 direções × 37 poses. A taxa de locomoção acompanha a velocidade. Corrida é selecionada acima de 1,45× a velocidade de referência de 40 px/s (ou `set_motion(velocity, true)`). A IA mantém a velocidade anterior de 40 px/s, portanto caminha normalmente; esta etapa disponibiliza corrida sem criar uma regra nova de sprint. A espera conserva a direção, e dano tem prioridade antes de retornar à locomoção atual.

`scripts/test_monster.gd` consome o visual; `monster_kind` seleciona a arte. `scripts/playable.gd` distribui as quatro aparências pelos encontros. Sombras e barras de vida foram ajustadas à apresentação. Camadas, raios de física/vulnerabilidade, dano e contagem de ondas foram preservados. A pose de morte provisória anterior continua; morte não foi solicitada nesta etapa.

## Validação e limites

Godot local `4.7.2.stable.official.ed1daf0bf`:

- `tools/verify_monster_animations.gd`: **1332 verificações, zero falhas** (recortes, todas as poses, escala, fechamento matemático dos ciclos, espera somente vertical, corrida distinta, seleção/transições e dano real ligado ao visual).
- `tools/verify_combat.gd`: **54 verificações, zero falhas**.
- `tools/verify_playable.gd`: **155 verificações headless, zero falhas**; depois **163 verificações com renderização, zero falhas**, cinco páginas e reinício.
- `tools/render_monster_animations.gd`: 38 capturas reais do viewport, inspecionadas em amostras de caminhada/corrida/dano nas quatro direções e no percurso integrado.
- `tools/export_monster_previews.py`: empacotou as capturas em quatro GIFs e quatro APNGs, contagens de quadros verificadas. Usa Pillow do runtime já disponível; não é dependência do jogo.
- Logs finais: `docs/atlas/evidencias/06_monstros_*.log`, `06_combate_regressao.log`, `06_percurso_regressao.log`, `06_percurso_render.log`. Uma primeira renderização encontrou conflito de nome com um método nativo no laboratório; corrigido, renderização final limpa.

As deformações são provisórias e podem esticar detalhes junto às articulações. Não revelam superfícies que não existem nas quatro imagens originais; a oclusão dos membros da Carcaça limita a leitura da passada. Não são sprites redesenhados quadro a quadro nem acabamento artístico aprovado. Filtro nearest preserva amostragem nítida, mas não certifica grade/paleta nativa estrita. Pé plantado e fluidez artística ainda precisam de avaliação humana em loop; testes matemáticos e capturas não substituem essa avaliação.

Não houve teste humano com teclado/mouse, medição de desempenho, exportação Windows, commit ou push. Preservadas as mudanças anteriores em `project.godot`, `scenes/main.tscn` e `assets/personagem/revisao/atlas_rascunho.tres`.

## Reproduzir

```powershell
& '<Godot-console.exe>' --headless --path . --script res://tools/verify_monster_animations.gd
& '<Godot-console.exe>' --path . --resolution 640x360 --fixed-fps 60 --disable-vsync --script res://tools/render_monster_animations.gd
& '<Python-com-Pillow>' tools/export_monster_previews.py
```

API utilizada: [MeshInstance2D, documentação oficial](https://docs.godotengine.org/en/stable/classes/class_meshinstance2d.html). Os testes foram executados na versão local indicada acima.
