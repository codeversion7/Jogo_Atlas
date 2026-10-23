# Ataques dos monstros — primeira versão frontal, 23/10/2026

## Integração posterior no F5 — 23/10/2026

Após aprovação explícita das quatro mecânicas pelo usuário, a execução do módulo 2 integrou estes recursos ao combate. Veja [relatório do módulo 2](../../../desenvolvimento/MODULO_2_MAPA_MUNDO.md). As seções de preparação abaixo registram o estágio anterior, quando ainda não havia integração. Fontes, folhas e laboratório foram preservados; o runtime usa camadas de corpo e FX físicos separados, sem duplicar esfera. Frente é a única vista de ataque disponível; demais direções continuam provisórias.

## Decisões confirmadas pelo usuário

- Fenda: seguir o corte cruzado mostrado na prancha.
- Carcaça: seguir a pancada no chão mostrada na prancha.
- Esporo: uma esfera verde que explode no impacto, conforme o material recebido.
- Escavador: fixar a posição do alvo no começo do aviso, dando tempo para escapar; a marca não acompanha o jogador depois disso.

Essas escolhas aprovam a direção dos ataques. Não aprovam automaticamente tempos, alcance, dano ou acabamento artístico.

## O que foi produzido

Animação visual frontal em `scripts/monster_attack_visual.gd`: preparação, golpe/lançamento/saída e recuperação, com efeitos separados. As quatro pranchas são estudos 2×2 com poses-chave, escala/pivôs variáveis e efeitos misturados a alguns corpos; não são folhas finais prontas para importar diretamente.

As fontes foram preservadas e verificadas por SHA-256. Recortes e malha animada do Godot aproveitam as poses limpas. Corte, terra e explosão são desenhados separadamente; a esfera é um recorte independente da prancha do Esporo. Evitados os impactos com efeitos pintados sobre o corpo. O Escavador usa o corpo frontal limpo já existente, ocultado pelo plano do chão durante a saída, e a nova prancha como referência: não foi redesenhado nem isolado artificialmente de toda a terra da prancha.

Pivô de saída: (64,64) em cada célula de 128×128. Escala constante por espécie; Fenda considera ambos os pés mesmo quando o apoio mais baixo está deslocado. Não foram inventadas vistas laterais ou traseiras.

| Monstro | Quadros | Duração provisória | Fases |
| --- | ---: | ---: | --- |
| Fenda | 20 | 1,06 s | preparação, corte, recuperação |
| Carcaça | 20 | 1,42 s | preparação, impacto, recuperação |
| Esporo | 26 | 1,72 s | preparação, lançamento, voo, impacto, recuperação |
| Escavador | 24 | 1,65 s | aviso, saída, impacto, recuperação |

Em `assets/monstros/ataques_v1/`, cada espécie tem PNG e SpriteFrames para `body`, `effects` e `combined`: 12 folhas e 12 recursos. `attack_down` reproduz o ciclo inteiro, sem repetição; há também clips por fase. Usar corpo+efeitos **ou** composição, evitando desenhar o efeito duas vezes. `profiles.json` registra fontes, recortes, pivôs e tempos; a documentação das APIs está no script visual.

## Como revisar

Abra `scenes/review/monster_attack_lab.tscn` no Godot e pressione **F6**. Espaço pausa, L alterna reprodução lenta e R reinicia. Os quatro ciclos repetem apenas para comparação no laboratório. F5 permanece a partida existente.

Prévias: [normal](previas/ataques_normal.gif) e [lenta](previas/ataques_lento.gif), renderizadas no Godot a partir de 50 capturas. GIF reúne quadros consecutivos idênticos, preservando os 2,5 segundos do ciclo de revisão (7,5 s na prévia lenta).

## Validação e limites

Godot 4.7.2: importação e renderização OpenGL reais; 469 verificações de fases, fim único, alvo fixo, raiz imóvel, camadas, trajetória visual e SpriteFrames, sem falhas. Exportador verifica grade/transparência e ausência de corte nas bordas dos 270 quadros de camadas. Inspeção visual das poses de preparação, golpe, voo e saída. Logs `docs/atlas/evidencias/13_ataques_*`.

**Preparação visual, ainda fora do combate F5.** O projétil é visual; não há nova colisão, dano em área, teleporte, invulnerabilidade subterrânea ou IA específica. O alvo fixo está implementado no componente visual e ainda precisa ser ligado à IA do Escavador. Não foram modificados o protagonista, a adaga, as regras das páginas ou os controladores de combate. Outras direções, ajustes humanos de fluidez/arte e integração das janelas de acerto ficam pendentes.

## Reprodução

1. `tools/prepare_monster_attacks.py`: analisa fontes e gera os perfis; requer Pillow.
2. Godot com `--script res://tools/render_monster_attacks.gd --resolution 640x360`: renderiza capturas, folhas e recursos; precisa de renderizador gráfico.
3. Godot `--headless --editor --import --quit`: importa os novos PNGs.
4. Godot `--headless --script res://tools/verify_monster_attacks.gd`: verifica recursos e ciclos.
5. `tools/export_monster_attack_previews.py`: monta prévias e verifica bordas das folhas.

Sem commit ou push desta preparação; branch `codex/preparo-git` preservada.
