# Fase 2 — módulos, cenas e execução

Preparado em 23/10/2026 a partir do pedido atual. Este documento organiza implementação futura; não comprova novas habilidades, árvore ou otimizações implementadas.

## Revisão do estado real

- Raiz e topo Git confirmados em `C:/Users/Arthur-Gamer/OneDrive/Documentos/ChatGPT/GODOT-ATLAS`.
- Branch preservada: `codex/preparo-git`; origin: `https://github.com/codeversion7/Jogo_Atlas.git`. Último commit local observado: `cf54a93`, de 22/10. Não foi feito fetch nesta preparação: igualdade com o remoto atual não foi verificada.
- Há alterações locais rastreadas e arquivos novos de gameplay, arte e evidências; índice sem alterações staged na inspeção inicial. Não descartar nem misturar sua autoria com esta preparação.
- `project.godot`: `Atlas_Verdadeiro`, entrada `scenes/playable.tscn`, recursos 4.7/Compatibility, viewport 640×360 e janela configurada 1920×1080. Os registros anteriores confirmam executável 4.7.2; não foi executado novamente nesta revisão.
- Código inspecionado: `combat_player.gd` já tem vida, fome numérica, ataque da adaga, parry, esquiva, cooldowns, morte e retorno; `playable.gd` gera o percurso e interface, coordena encontros, páginas e sequência final. Isso não comprova árvore, adaga arremessável, radar, resistência ou escudo implementados.
- Cinco páginas após encontros, retenção ao retornar, sequência do livro e fim da primeira parte já constam do código/documentos. O colapso antigo foi substituído pela decisão U15; não restaurá-lo por causa dos primeiros prompts desta conversa.
- Monstros: quatro visuais integrados, animação de malha 2D, IA/ataque compartilhados provisórios. Ataques específicos não foram comprovados. A adaga corpo a corpo usa contato da lâmina visível, não um setor invisível uniforme.
- Os relatórios anteriores registram testes e capturas aprovados. Esta preparação fez leitura de código, diferenças Git e documentos; não repetiu as suítes Godot, mediu FPS ou avaliou a sessão humana.

## Três módulos e fronteiras

| Módulo | Entrega | Limite |
|---|---|---|
| 1 — personagem | Atributos, exatamente três ramos de habilidades, árvore/interface, integração ao combate e testes; organização mínima de cenas e diagnóstico do lag | Implementar agora pelo prompt 12. Sem expandir ilha, NPCs ou menus completos |
| 2 — mapa e mundo | Completar/ampliar mapa e áreas/fases, encontros/localização dos monstros, exploração, NPCs, tela inicial mínima e créditos se houver atribuições | Aproveitar o percurso existente; mapa em M preserva descoberta. Detalhar conteúdo e lore antes de inventá-los |
| 3 — refinamentos e finalização | Refinar menu/tela inicial, configurações, áudio/visual, fluxo de fim, revisão e exportação/empacotamento | Tela inicial começa no módulo 2 e recebe acabamento no 3; não implementar duas telas concorrentes |

O usuário não forneceu novo prazo específico nesta solicitação. Não ressuscitar automaticamente prazos antigos ou transformar o reset de uso em prazo de entrega.

## Módulo 1 — interpretação dos três ramos

1. **Adaga de retorno:** habilidade adquirível que arremessa a adaga e a faz voltar para a mão. É distinta do ataque corpo a corpo existente.
2. **Rastreio:** habilidade adquirível que detecta inimigos próximos. Não equivale a revelar o mapa ou localizar todas as páginas/NPCs.
3. **Parry:** habilidade base já disponível. Seu ramo começa desbloqueado; aperfeiçoamentos editáveis podem integrar a árvore, sem exigir compra do parry inicial.

A esquiva/dash existente permanece uma ação base, não um quarto ramo. Escudo é atributo/camada de proteção; não criar uma quarta habilidade ativa, magia, barra de stamina ou sistema de mana por inferência.

### Estado e dados

Manter uma fonte de verdade por valor: configuração base em Resource; estado de vida/fome/escudo/recargas por instância do jogador; modificadores resolvidos de forma explícita; interface por sinais. Recursos compartilhados não devem acumular vida/pontos em várias instâncias.

| Atributo | Escopo e cuidado |
|---|---|
| Vida atual/máxima | Preservar valores iniciais atuais e retorno de 50% do máximo; limitar valor atual ao máximo |
| Fome atual/máxima | Integrar o estado existente e retorno a 25%; mostrar sem alegar alimentação/consumo implementados |
| Dano | Preservar base corpo a corpo e lâmina visível; separar dano do arremesso e modificadores |
| Resistência | Definição operacional provisória: mitigação de dano, sem stamina ou resistência a estados implícita; base neutra e limites seguros |
| Dash | Distância/velocidade/duração/recarga coerentes; colisão física preservada, sem teleporte através de paredes |
| Recarga das habilidades | Por habilidade e por instância; zero/negativo inválido não pode quebrar o jogo; pausa e morte coerentes |
| Escudo atual/máximo | Proteção anterior à vida, sem regeneração automática inferida; base 0 mantém dano anterior |

Não é necessário inventar atributo adicional: alcance e duração de rastreio/arremesso são parâmetros das próprias habilidades. Se surgir necessidade concreta, justificar antes de ampliar o modelo.

### Progressão mínima e autonomia

Primeiro reaproveitar regra de pontos/desbloqueio realmente existente. Se não houver, uma economia de teste restrita à sessão pode ser escolhida como detalhe reversível sob autonomia atual: conceder pontos por encontro concluído uma vez, custos baixos configuráveis e possibilidade real de adquirir as duas habilidades antes do último encontro. Não alterar a regra das páginas nem criar XP, níveis permanentes ou salvamento entre sessões sem necessidade/autorização. Registrar a escolha como **implementação provisória**, não como aprovação definitiva de design. Se isso conflitar com decisão vigente, isolar a parte e pedir somente a decisão conflitante.

## Inventário e destino das cenas

Foram encontrados nove `.tscn` em `scenes/`. O destino abaixo é uma proposta técnica de organização, não movimentação já realizada.

| Cena atual | Papel observado | Tratamento |
|---|---|---|
| `playable.tscn` | Percurso F5, jogador e layout | Entrada canônica; preservar o caminho nesta fase |
| `player.tscn` | Corpo, visual, colisão e câmera reutilizáveis | Essencial; compor atributos/habilidades, sem duplicar personagem |
| `atlas_visual_revisao.tscn` | Visual instanciado pelo personagem real | Essencial apesar do nome; não arquivar como se fosse apenas laboratório |
| `monster_visual.tscn` | Componente visual de monstro | Manter como componente reutilizável se houver uso; conferir dependências dinâmicas |
| `main.tscn` | Base antiga ainda usada pela arena/testes | Compatibilidade temporária; só arquivar após migrar referências/testes |
| `combat_arena.tscn` | Arena herdada da base e usada pelos testes | Reserva de regressão, fora da entrada normal |
| `animation_lab.tscn` | Revisão de animação | Reserva F6 |
| `dagger_attack_review.tscn` | Revisão da adaga | Reserva F6 |
| `monster_animation_lab.tscn` | Revisão dos monstros | Reserva F6 |

Organização final sugerida, aplicada gradualmente:

```text
scenes/
  playable.tscn                 # F5 preservado
  player.tscn                   # componente existente
  atlas_visual_revisao.tscn     # dependência visual essencial existente
  monster_visual.tscn          # se realmente necessário
  ui/skill_tree.tscn            # interface coesa, se justificar cena própria
  review/                      # laboratórios de animação preservados
  tests/                       # arena/base antigas enquanto necessárias
scripts/
  character/                   # atributos, habilidades e progressão
  ui/                          # interface da árvore/status
resources/
  character/                   # configuração base e catálogo dos três ramos
```

Pastas novas não exigem mover tudo. Evitar renomeação geral, especialmente com mudanças locais não commitadas. Uma cena por habilidade, estatística ou nó de árvore seria excesso; uma única cena gigante também aumenta acoplamento. Separar dados e scripts pode melhorar manutenção sem multiplicar cenas.

Qualquer movimento exige mapa origem→destino e atualização de `preload`, `load`, PackedScene, herança, ferramentas, scripts de lançamento, documentação relevante e `.uid`/metadados. Conferir caminhos montados dinamicamente, não só busca literal. Fazer um grupo pequeno e testar antes do próximo. Não apagar os originais de animação ou backups externos.

## Lag: hipótese não é diagnóstico

Relato do usuário: projeto muito lento. Ainda não está isolado se ocorre no editor, carregamento, gameplay, laboratório ou outro aplicativo. Nove arquivos em disco não demonstram custo de nove cenas simultâneas.

Diagnóstico proposto: comparar jogo real pela entrada F5 e laboratórios fora de execução; medir tempo de frame, física/script, chamadas de desenho, memória e picos de geração no mesmo cenário. Identificar processo/janela, resolução, número de inimigos, duração e cache frio/quente. Não usar teste headless a FPS fixo como benchmark de renderização.

Pontos de inspeção, sem causalidade comprovada: geração/cache de malhas na primeira pose de monstro em `monster_visual.gd`; atribuição de material/pose por frame mesmo quando índice não muda; redesenho de marcadores/HUD na física em `playable.gd`; grupos/alvos e raios por ponto da lâmina; escala de janela 1920×1080. O código do monstro já tem cache; não recomendar outro cache sem medir esse comportamento.

Priorizar mudança pequena e medida, preservando passada dos monstros, transparência, alinhamento e precisão da lâmina. Se não houver medição disponível, registrar diagnóstico pendente, organizar o projeto e não alegar ganho de FPS.

## Consumo e salvamento

Snapshot da preparação: consulta de uso retornou 18% utilizados/82% restantes na janela de cinco horas, 3% utilizados na janela semanal, saldo adicional 0, reset primário em 23/10/2026 às 19h42min48s (São Paulo). Valores são voláteis e compartilhados; os 83%/19h foram relato inicial do usuário, não telemetria fixa.

Atualização posterior durante a preparação: o usuário informou **78% restantes**. Esse é o relato mais recente, não uma segunda consulta de telemetria. O executor deve consultar o estado atual se tiver ferramenta disponível e não reutilizar 82% como saldo de início.

Percentual de cota não equivale a número fixo de tokens, tempo de trabalho ou limite do contexto. Consultar recurso de uso efetivamente disponível ao final de cada marco; não supor que uma ferramenta deste chat existe na extensão do VS Code. `/status` é comando da interface CLI quando suportado, não programa de shell.

- Operação normal: concluir pequenas entregas verificáveis, manter registro curto e checkpoint incremental.
- Ao chegar a 15%: não iniciar refatoração ampla; concluir a fatia atual e priorizar validação/preservação.
- Ao observar ≤8%: entrar na emergência imediatamente. ≤5% é salvamento mínimo urgente, não meta a atingir. Nunca tentar consumir a cota até esse nível.
- Se uso estiver indisponível/desatualizado: registrar desconhecido e salvar a cada fatia, sem inventar percentual. Aviso do usuário/plataforma de limite próximo também inicia emergência.
- Se módulo terminar antes: validar, salvar e publicar o checkpoint autorizado; não continuar nos módulos 2/3 para gastar saldo. Não esperar pelo reset nem comprar créditos/trocar modelo automaticamente.

O pedido autoriza ao Codex executor checkpoint Git e push para o origin do projeto; não autoriza merge/force-push. Nesta preparação somente documentos foram alterados, sem commit/push. O prompt detalha backup, mudanças preexistentes, publicação por lista explícita, teste rápido, confirmação remota e limitações de salvar memória do editor Godot.

## Fontes e limites

- [OpenAI — limites, uso e economia de contexto](https://learn.chatgpt.com/docs/pricing): cota depende da tarefa/contexto/ferramentas; painel e status quando disponíveis.
- [Godot — medir antes de otimizar](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html): distinguir gargalos e comparar medições.
- Base local: `AGENTS.md`, estado/decisões atuais, Git, `project.godot`, cenas/controladores e testes referenciados. Preparação de arquitetura e revisão estrutural não equivalem a implementação ou teste do módulo 1.
