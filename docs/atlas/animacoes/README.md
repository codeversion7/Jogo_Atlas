# ATLAS — revisão técnica das animações

22/10/2026. **Entrega parcial: recortes, transparência, pés da espera e recursos de revisão preparados. Caminhada ainda exige redesenho. Não é uma animação final aprovada.**

Projeto alvo: `GODOT-ATLAS`, indicado pelo usuário em `OneDrive/Documentos/ChatGPT`. O workspace inicial da sessão era outro projeto; as primeiras inspeções de `Documents/atlas` não são evidência sobre este projeto. A preparação foi feita em uma cópia de trabalho e a entrega é direcionada à raiz correta. Godot 4.7.2, base 640 × 360, filtro nearest e Compatibility.

## Fontes e preservação

Lidos: `referencias/personagem/ATLAS_ANIMACAO_HANDOFF.md`, documentos de estado, GDD, história e arquitetura no ZIP junto ao handoff, pesquisa de termos de traje em todos os textos desse ZIP, `prompts/atlas/CONTEXTO.md`, CONTRATO, DECISOES e ESTADO_PRODUCAO. O pacote junto às imagens é uma versão documental anterior: suas lacunas de versão, multiplayer e páginas não substituem as decisões posteriores do projeto. Permanecem cinco páginas e a sequência aprovada do livro; esta tarefa não altera narrativa nem implementa seus sistemas.

Não foi encontrada especificação adicional de corte e cores do traje nesses textos. A fonte visual é `Atlas em pixel art, quatro direções.png`: jaqueta azul acinzentada danificada, camisa clara, calça escura, botas marrons, cabelo castanho em rabo baixo, barba e cachecol preto/bordô. Não declarar o traje confirmado por um documento que não o detalha.

Os três PNGs de referência e os ZIPs são preservados. `medicoes.json` registra SHA-256 das duas folhas e os limites de cada desenho. Não há Git nesta raiz.

## Medição e correções efetuadas

| Item | Resultado |
| --- | --- |
| Caminhada original | 1254 × 1254, RGBA; 24 componentes principais, 6 por direção |
| Espera original | 1024 × 1536, RGBA; 16 componentes principais, 4 por direção |
| Referência aprovada | 1536 × 1024, RGB, fundo opaco; usada para comparação visual |
| Ordem real das linhas | Baixo, esquerda, direita, cima nas duas folhas |
| Alfa original da caminhada | 625594 pixels com alfa 0, 945654 intermediários e 1268 com alfa 255 |
| Alfa original da espera | 720261 pixels com alfa 0 e 852603 intermediários; nenhum pixel com alfa 255 |
| Recortes | Componentes conexos com alfa ≥ 128; não divisão uniforme da folha original |
| Alfa de saída | Somente 0 e 255; RGB zerado nos pixels transparentes |
| Resolução de revisão | 40 × 48 por célula, sem escala no nó; altura máxima da arte 43 px |
| Pivô de revisão | (20,46); `centered=false`, `offset=(-20,-46)` |
| Espera de saída | `idle_rascunho.png`: 160 × 192, grade 4 × 4 |
| Caminhada de saída | `walk_rascunho.png`: 240 × 192, grade 6 × 4 |

A caminhada original não possui linhas uniformes: os topos reais dos sprites estão próximos de y=30, 318, 618 e 922. Dividir 1254 por quatro cortaria cabeças/pés e incluiria desenhos vizinhos. Os limites reais foram detectados individualmente e mantidos em `medicoes.json`. Espaços entre desenhos também variam; não há grade nativa uniforme válida para importar diretamente a folha original.

A escala é isotrópica e constante dentro de cada direção, calculada pela maior altura da linha; quadros não são esticados individualmente. O eixo horizontal usa o centro da região da cabeça para que o cachecol não empurre o corpo ao balançar. A base usa o limite inferior do sprite; isso padroniza o enquadramento, mas não prova que o pé de apoio esteja plantado durante a caminhada. Nearest-neighbor é usado no redimensionamento e na ampliação das prévias.

32 × 48 foi experimentado e não comportou todos os sprites com o eixo da cabeça e margem transparente. A revisão usa 40 × 48 para manter cabelo/cachecol completos. O laboratório mostra essa escala no piso geométrico da fundação; ainda falta cenário definitivo para aprová-la como resolução final do jogo.

Na espera, a região y=32..47 de cada direção foi fixada a partir do primeiro quadro, incluindo pernas inferiores, botas e trecho inferior do cachecol. Antes dessa correção havia mudanças de máscara de até 26 pixels na região dos pés, comparando os quadros ao primeiro. Depois, a região inferior RGBA é idêntica nos quatro quadros de cada direção. Isso corrige os pés instáveis; não certifica que todas as diferenças restantes no tronco/cabeça sejam respiração correta. Conferir também a continuidade na fronteira da região fixa.

## Prévias e tempos

Abra `previas.html` em um navegador: oito clipes, cada um em tamanho nativo e ampliado 4×, em velocidade normal e metade da velocidade. Cada direção também possui uma tira `*_quadros.png` para inspeção lado a lado.

| Clipe | Quadros | Normal | Lento |
| --- | --- | --- | --- |
| `idle_down/left/right/up` | 4 | 4 FPS, ciclo 1000 ms | 2 FPS, ciclo 2000 ms |
| `walk_down/left/right/up` | 6 | 8 FPS, ciclo 750 ms | 4 FPS, ciclo 1500 ms |

Arquivos `*_normal.png` e `*_lento.png` são APNGs transparentes, não imagens estáticas. Os GIFs correspondentes são ampliados 4× sobre xadrez para inspeção das bordas. O GIF normal de caminhada alterna 120/130 ms porque GIF não representa 125 ms exatos; o ciclo permanece 750 ms. APNG usa 125 ms por quadro.

`godot_normal.png/.gif` e `godot_lento.png/.gif` mostram a saída real do viewport do laboratório (640 × 360), capturada em 16 instantes por modo. Os PNGs individuais `captura_*` permitem auditar as amostras. São sequências amostradas, sem alegação de revisão humana contínua dos loops. Nenhum navegador controlável estava disponível na sessão para assistir aos APNGs/GIFs em reprodução contínua.

## Godot: preparado e integrado ao laboratório

- `assets/personagem/revisao/atlas_rascunho.tres`: SpriteFrames editável, oito animações em loop com nomes e tempos acima.
- `scenes/atlas_visual_revisao.tscn`: `Node2D` com `AnimatedSprite2D`; filtro nearest explícito e pivô nos pés.
- `scripts/atlas_visual.gd`: recebe velocidade real por `set_motion(velocity)`, escolhe direção pelo eixo dominante, mantém a direção ao parar, troca espera/caminhada e preserva o relógio quando o estado não muda. A taxa de caminhada acompanha a velocidade relativa a `reference_speed=48` px/s, valor provisório de laboratório.
- `scenes/animation_lab.tscn` → `scripts/animation_lab.gd`: oito clipes simultâneos e personagem de teste no mesmo tom de piso da fundação. WASD move somente esse personagem; Espaço alterna velocidade normal/lenta. Nos limites do piso, a animação recebe o deslocamento efetivo e para quando não há deslocamento.

Abra `scenes/animation_lab.tscn` e use F6. O componente visual não implementa colisão, combate ou progressão. A cena principal permanece `scenes/main.tscn`, com seus placeholders e sistemas intactos. Há dois ramos de fundação, `World` e `World2`, na cena existente; não foram removidos nesta tarefa.

**Integração final ao protagonista pendente:** a inspeção encontrou apenas placeholders estáticos, sem controlador nem estrutura anterior de animações. O laboratório integra as oito sequências para revisão, mas os ciclos reprovados não foram colocados na cena principal como finalizados. Quando houver desenhos válidos, substituir os PNGs/recurso de revisão, revisar os ciclos e conectar `set_motion` à velocidade efetiva do controlador real. O WASD do laboratório não é uma implementação de movimento do jogo.

## Quadros que precisam de redesenho e revisão

Números abaixo são baseados em 1 e indicam a posição pretendida no ciclo final, não uma atribuição confiável de fase aos rascunhos atuais.

| Direção/animação | Trabalho ainda necessário |
| --- | --- |
| `walk_left` e `walk_right`, Q1 e Q4 | Estabelecer contatos opostos inequivocamente, com perna dianteira alternada e braço contralateral |
| `walk_left` e `walk_right`, Q2 e Q5 | Redesenhar transferência de peso e pé livre levantando, em continuidade com os contatos |
| `walk_left` e `walk_right`, Q3 e Q6 | Desenhar passagens reais: pé livre cruza sob o corpo; não existe uma pose confiável equivalente nas folhas atuais |
| `walk_down` e `walk_up`, Q1–Q6 | Há alternância visual de pernas, mas faltam fases de apoio/passagem identificáveis para fechar o ciclo solicitado; redesenhar Q3/Q6 e ajustar contatos/apoios e braços |
| Espera, quatro direções, Q2–Q4 | Pés corrigidos tecnicamente. Refinar respiração do tronco, consistência de cabeça/volume, movimento secundário e fechamento Q4→Q1; não aprovar mudanças de contorno como respiração por inferência |
| Transições entre espera/caminhada | Reconciliar proporção de cabeça/tronco, mãos e marcas do traje entre as duas fontes; pivô comum não elimina diferenças de desenho |

Foi feita uma tentativa de redesenho com ImageGen, usando a identidade aprovada e a caminhada como referências. O resultado `redesenho_rejeitado.png` também não resolveu as passagens laterais e ficou fora dos PNGs e SpriteFrames entregues. Não há substituição silenciosa dos rascunhos por essa tentativa.

## Evidências e limites

- `verificacao_artefatos.json`: valida hashes dos originais, limites dos 40 quadros, alfa binário, RGB transparente zerado, pés da espera idênticos e contagens/durações das 32 prévias direcionais. Todos os asserts passaram.
- `testes.log`: Godot instancia SpriteFrames, componente, laboratório e fundação; verifica oito clipes e seus tempos/dimensões, loops de cada clipe, atualização sem reinício do relógio, última direção ao parar, taxa relativa à velocidade e ação WASD simulada no laboratório. Esses testes são automáticos, não teclado físico.
- `renderizacao.log`: Godot/OpenGL gera 32 capturas do laboratório. Foram inspecionados os quadros lado a lado e uma captura em tamanho nativo; não houve teste de cenário definitivo.
- O primeiro import no sandbox registrou erros de permissão nos diretórios de configuração do Godot. Os testes locais usaram APPDATA/LOCALAPPDATA isolados; ainda houve aviso de leitura do armazenamento de certificados. Esse problema de ambiente não equivale a uma falha de animação. Os logs finais no projeto alvo registram o resultado da execução fora dessa restrição.
- Não certificado: alternância clara de apoio lateral, respiração convincente, ausência de deslizamento do pé plantado, volume consistente entre fontes, fechamento suave e transições artísticas. Não existe controlador real para ajustar passos à velocidade do jogo.
- Não executados: revisão humana contínua em loop, interação com teclado físico, cenário definitivo, combate/progressão/livro, exportação Windows ou avaliação de desempenho.

## Reprodução

Execute no projeto alvo com Godot 4.7.2 console:

```powershell
& '<caminho-do-Godot-console.exe>' --headless --path . --import
& '<caminho-do-Godot-console.exe>' --headless --path . --script res://tools/verify_animations.gd
& '<caminho-do-Godot-console.exe>' --path . --script res://tools/render_animation_review.gd --fixed-fps 60 --resolution 640x360
```

As ferramentas Python em `tools/animations/` requerem Pillow (usado aqui: 13.0.0). `prepare_animations.py` reconstrói os derivados a partir dos originais; `verify_artifacts.py` verifica as saídas e cria as prévias das capturas após a renderização. Não instalar Pillow como dependência de execução do jogo; Godot consome apenas os PNGs e os recursos.

API consultada: [AnimatedSprite2D, documentação oficial](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html). A validação efetiva dos recursos e scripts foi feita no executável 4.7.2 local.


## Execução final no projeto alvo — 22/10/2026

- Importação: `--headless --path <GODOT-ATLAS> --import`, saída 0, sem erros no log final.
- Testes: `--headless --path <GODOT-ATLAS> --script res://tools/verify_animations.gd`, saída 0; `failures=0 observed_walk_loops=9`.
- Renderização: `--path <GODOT-ATLAS> --script res://tools/render_animation_review.gd --fixed-fps 60 --resolution 640x360`, saída 0; 32 capturas no viewport real, normal e lento, sem erros no log final.
- Verificador Python executado sobre os arquivos finais: aprovado; 40 quadros dentro das células, 32 prévias direcionais com contagens e durações corretas, alfa binário, originais preservados e pés inferiores idênticos nas quatro esperas.
- Hashes de `project.godot`, `scenes/main.tscn`, `scripts/main.gd`, handoff, três imagens originais e ZIP da pasta de referências iguais aos da cópia inicial. O manifesto registra os hashes.
- A integração final ao protagonista permanece pendente pelas falhas artísticas descritas acima. A execução sem erros certifica o laboratório e os recursos, não transforma poses insuficientes em uma caminhada aprovada.
