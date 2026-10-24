# Acompanhante — animações v1, 23/10/2026

## Integração posterior no módulo 3

Visual preparado preservado. Agora há vida/queda/resgate e suporte mecânico com sustentação sincronizada, implementados na execução do módulo 3. As seções abaixo descrevem a preparação anterior. Regras, validações e limites atuais: [estado do módulo 3](../../desenvolvimento/MODULO_3_STATUS.md) e [uso](../../desenvolvimento/MODULO_3_USO.md).

Pedido: analisar `NPC_Personagem`, criar animações e o movimento de puxar o escudo, economizando consumo. Aproveitadas as imagens fornecidas; sem geração de novas imagens por IA e sem alterar os PNGs originais. O texto do pacote relata estética aprovada e também informa variações de desenho na caminhada; isso não equivale a aprovação humana desta nova animação.

## Entrega e uso

- Espera com respiração do tronco e pés estáveis, caminhada aproveitando os quatro quadros fornecidos por direção, corrida mais rápida com impulso/inclinação e reação de dano com recuo/tom de impacto.
- Puxar escudo: levantar o braço/bracelete, abrir a projeção, sustentar e recolher. Quatro vistas; de costas, efeito atrás do corpo e acima do piso.
- **Proposta visual provisória:** escudo de energia turquesa a partir do bracelete esquerdo. A pasta não continha arte específica do escudo. O pedido foi entendido como “escudo”; forma/cor e tempos ainda precisam de avaliação humana.
- F5: acompanhante existente passa a usar a nova arte em espera/caminhada. Mantidos acompanhamento, colisão, interação, grupos e velocidade anteriores. Um corpo visual por NPC; removido somente o desenho geométrico provisório.
- Corrida/dano/escudo estão preparados como clipes e API visual. O NPC continua não combatente: não ganha vida/dano, bloqueio, proteção do protagonista ou ativação automática do escudo.

Abra `scenes/review/companion_animation_lab.tscn` e pressione **F6**: cinco estados × quatro direções. Espaço pausa, L lento, R reinicia. [Prévia normal](previas/npc_normal.gif) e [lenta](previas/npc_lento.gif).

## Componentes e recursos

`scripts/companion_visual.gd` controla `Body` (MeshInstance2D) e `ShieldVisualOnly` (efeito separado). `scenes/companion_visual.tscn` permite usar o visual isoladamente. `scripts/world/companion.gd` instancia esse mesmo componente e fornece movimento; suas regras de rota não foram alteradas.

Fontes copiadas byte a byte para `assets/npcs/companheiro/pixel_v2/`, mantendo o SpriteFrames recebido. Grade idle 4×1 e walk 4×4, células 48×64, direções baixo/esquerda/direita/cima. Nearest, escala padrão 0,7 e pivô de origem (24,60), posicionando os pés na raiz. Tamanho aproximado 35 px de altura; ajuste de escala disponível em `art_scale`. As variações entre os quatro desenhos de caminhada recebidos permanecem; oito amostras exportadas não significam oito desenhos inéditos.

API do visual:

```gdscript
visual.set_motion(velocity) # Direção + espera/caminhada.
visual.play("run", 2) # 0 baixo, 1 esquerda, 2 direita, 3 cima.
visual.play("shield", 0) # Animação apenas; não concede proteção.
visual.play("hurt")
# animation_finished: ação terminou e retornou à espera.
```

`automatic=false` + `sample(tempo)` permite revisão/exportação sem avançar o relógio. Em uso normal, `advance(delta)` é chamado pelo processo do componente; pausa herdada congela a animação. Shield/hurt terminam uma vez e retornam à espera; movimento não os interrompe. Parâmetros visuais/tempos são provisórios.

Folhas prontas em `assets/npcs/companheiro/animacoes_v1/`: 60 PNGs e 12 SpriteFrames, com corpo, efeitos e composição por direção. Cada recurso tem idle (8 quadros/1,2 s), walk (8/0,56 s), run (8/0,36 s), hurt (6/0,24 s) e shield (24/1,12 s). Células 64×64, pivô (32,52): AnimatedSprite2D centrado deve usar offset (0,-20). Usar corpo+efeitos **ou** composição, evitando duplicidade. Não usar o recurso recebido de 48×64 com esse offset novo.

Escudo: preparação 0,16 s, abertura 0,24 s, sustentação 0,48 s, recolhimento 0,24 s. Não define duração mecânica, recarga, resistência ou custo da futura habilidade.

## Evidências

Godot 4.7.2, importação e renderização OpenGL reais. **1838 verificações visuais/recursos e 45 de regressão do módulo 2, sem falhas.** Regressão inclui acompanhamento, interação, morte/retorno/reinício e coordenação de painéis; deslocamento máximo do NPC 2,00003 px/tick, sem teleporte normal. Fontes por SHA-256, alfa binário e 20 células sem corte nas bordas. Exportação: 216 poses em três camadas; 648 células verificadas sem corte nas bordas, 40 capturas e GIFs normal/lento. Inspecionados preparação, sustentação e ordem do escudo nas quatro vistas. Testes automatizados não constituem aprovação artística nem teste humano prolongado.

Reprodução: `tools/prepare_companion.py`; Godot gráfico com `--script res://tools/render_companion_animations.gd --resolution 640x360`; importação do editor; `tools/export_companion_previews.py`; Godot headless com `--script res://tools/verify_companion_visual.gd` e `--script res://tools/verify_module2.gd`. Python usa Pillow já disponível. Logs `docs/atlas/evidencias/14_npc_*.log`.

Branch preservada `codex/preparo-git`. Sem commit/push nesta tarefa. Pendente: revisão humana de fluidez/escala e aparência do escudo; regras e ativação da habilidade defensiva em outra implementação.
