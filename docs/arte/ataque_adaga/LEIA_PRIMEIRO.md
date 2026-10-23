# Ataque do protagonista e adaga — revisão 1

## Atualização: integrado no prompt 11

O ataque agora está ligado ao percurso F5. Abaixo permanece o handoff da preparação, para histórico; a indicação antiga de “não integrado” descreve aquela etapa. Estado, decisão de alcance e testes atuais: `docs/projeto/ESTADO_ATUAL.md`, seção Integração do prompt 11. Recursos e manifesto de preparação preservados byte a byte. Rodar `verify_dagger_attack.gd` sem `--assets-only`.


22/10/2026. **Recursos preparados e testados, ainda não ligados ao combate.** Pedido: protagonista e adaga primeiro; integração dos monstros já preparados e deste ataque deve constar do próximo comando ao Codex. Ataques próprios/novos comportamentos de cada monstro ficam para amanhã.

## Abrir e avaliar

- F6 em `scenes/review/dagger_attack_review.tscn`: quatro direções ao mesmo tempo, pés fixos, braço articulado, lâmina e rastro. Espaço pausa, L alterna normal/¼ de velocidade, setas inspecionam quadros pausados, G mostra mão/ponta.
- [Prévias animadas normal e lenta](previas.html), produzidas a partir de capturas reais do Godot. A pausa de 450 ms no fim é somente para revisão; não integra o tempo de ataque.
- Fontes e PNGs em `assets/personagem/ataque_adaga_v1/`. `adaga_emergencia.svg` é o desenho isolado da arma, não uma nova classe de item.

## Arte, formatos e montagem

O personagem atual é provisório e nativo em SVG. `tools/generate_dagger_attack.py` reutiliza sua função de desenho/paleta, removendo os braços antigos e desenhando o novo movimento. Carrega apenas a função/paleta via AST, sem executar o gerador anterior ou sobrescrever seus recursos. Novos desenhos usam primitivas inteiras, contornos e filtro nearest. Nenhum serviço de geração de imagem foi usado nesta etapa, pois os recursos de origem são vetoriais editáveis.

Adaga curta, guarda discreta, cabo gasto e pequena irregularidade no fio: interpretação visual provisória da adaga de emergência já aprovada. O desenho definitivo dos instrumentos continua com os responsáveis.

- 4 direções: baixo, esquerda, direita, cima. A vista esquerda espelha a lateral direita, conforme a base provisória atual; não certifica lateralidade anatômica definitiva.
- 12 poses por direção, 48 poses completas; quatro camadas: `body`, `dagger`, `trail`, `combined`.
- Canvas transparente **80×80**, pivô dos pés **(40,62)**. `centered=false`, offset **(-40,-62)** em `AnimatedSprite2D`. O canvas maior oferece margem para a arma; não representa personagem com tamanho dobrado.
- A locomoção anterior continua em 40×48, pivô (20,46). Restaurar seu offset **(-20,-46)** ao sair do ataque.
- Quatro folhas PNG transparentes **960×320**, grade 12 colunas × 4 linhas, células 80×80. Linhas na ordem acima. PNGs individuais também em `png/`.
- `atlas_attack_body.tres`, `atlas_attack_dagger.tres`, `atlas_attack_trail.tres`, `atlas_attack_combined.tres`: cada recurso contém clipes separados por fase e um clipe completo `attack_<direção>`, todos sem laço.
- Usar **ou** a composição pronta **ou** as camadas separadas. Não desenhar duas adagas. Na composição pronta, a oclusão em costas já está aplicada. Com camadas separadas, respeitar `dagger_behind_body` no manifesto.

| Fase | Índices do ciclo completo | Quadros | Tempo inicial de revisão |
|---|---|---:|---:|
| Preparação (`attack_windup_*`) | 0–1 | 2 | 0,08 s |
| Golpe (`attack_active_*`) | 2–5 | 4 | 0,12 s |
| Recuperação (`attack_recovery_*`) | 6–11 | 6 | 0,20 s |

Total 0,40 s, seguindo os parâmetros atuais. Durações individuais estão nos SpriteFrames e em `manifesto.json`. São tempos provisórios, não novo balanceamento aprovado. `damage_phase` indica a intenção para a integração futura; não aplica dano por si só.

`manifesto.json` também guarda mão/ponta em pixels do canvas e os hashes do controlador/recursos existentes durante a preparação. O rastro segue a ponta e é efeito visual; **não é a hitbox**.

## Integração futura: pontos que exigem atenção

1. `scripts/atlas_visual.gd` hoje seleciona quadros 0–2 de todas as ações. Os recursos novos têm 2/4/6 quadros; usar a contagem real do clipe e progresso normalizado, preservando as outras ações.
2. `scripts/combat_player.gd` já desenha arma por linhas em `_draw()`. Evitar duplicá-la quando a nova camada/composição estiver visível. Manter os indicadores necessários de parry/depuração.
3. A mira atual é contínua; as poses têm quatro vistas. Conferir diagonais, direção travada durante o golpe e alinhamento da arma com a mão. Não rotacionar o corpo inteiro para resolver a mira.
4. O alcance matemático anterior de 30 px **não foi certificado como equivalente à lâmina nova em todas as vistas**. Medir e alinhar apresentação/detecção na integração. Não declarar sincronia só porque o timer coincide; preservar um dano por alvo/golpe e bloqueio por sólidos.
5. Não mover colliders/pivô com a animação, não alterar velocidade/vida/dano/cadência por consequência da troca de arte e não congelar a locomoção sem decisão de design. Dano, morte e esquiva precisam interromper/restaurar o visual coerentemente.
6. Na saída do ataque, restaurar recurso/offset da locomoção e tratar a adaga em espera/caminhada sem deixá-la solta ou flutuando. Usar camadas para acompanhar a mão se necessário.

## Verificações executadas

Godot 4.7.2 local: importação e renderização OpenGL concluídas; **622 verificações, zero falhas** em `tools/verify_dagger_attack.gd -- --assets-only`. Conferidos canvas, margens, transparência, quatro direções, clipes sem laço, duração total, comprimento da lâmina, solas fixas e quatro hashes de recursos/controladores antigos intactos. A comparação inicial das solas incluía cachecol e RGB invisível gerado pelo importador; corrigida para comparar as solas visíveis, sem alterar a arte para mascarar o teste.

`tools/render_dagger_attack.gd`: exportou 192 PNGs de camadas, quatro folhas transparentes e 12 capturas do laboratório. Amostras de preparação, golpe e recuperação nas quatro direções foram inspecionadas visualmente. `tools/export_dagger_preview.py` produziu dois GIFs/dois APNGs, com 12 quadros cada e contagem verificada. Logs `07_adaga_import.log`, `07_adaga_testes.log`, `07_adaga_render.log` em `docs/atlas/evidencias/`.

Não verificados nesta preparação: acerto no jogo com a nova arte, alinhamento final da hitbox, controle físico, equilíbrio do combate, transições com todas as ações e aprovação artística humana do ciclo. As prévias repetem o ataque para avaliação; não implementam combo. Sem commit ou push nesta tarefa.

Depois de integrar, executar o teste de assets **sem** `--assets-only`, pois essa opção verifica justamente que os scripts de gameplay ainda não foram modificados. Acrescentar/regredir os testes de integração reais, sem eliminar verificações úteis de arte.

## Reprodução

```powershell
& '<Python>' tools/generate_dagger_attack.py
& '<Godot-console.exe>' --headless --path . --import
& '<Godot-console.exe>' --headless --path . --script res://tools/verify_dagger_attack.gd -- --assets-only
& '<Godot-console.exe>' --path . --resolution 640x360 --fixed-fps 60 --disable-vsync --script res://tools/render_dagger_attack.gd
& '<Python-com-Pillow>' tools/export_dagger_preview.py
```

Comando de implementação preparado em `prompts/atlas/11_INTEGRAR_MONSTROS_E_ADAGA.md`.
