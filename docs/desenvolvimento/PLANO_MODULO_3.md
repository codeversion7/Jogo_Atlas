# Módulo 3 — plano e decisões de preparação

23/10/2026. Escopo: preparar prompts por fases com Codeversion Prompt Enginner e investigação com Codeversion Engineering. Nenhum comportamento abaixo foi implementado por esta preparação. Não confundir este plano com execução, revisão humana ou publicação.

## Base conferida

- Raiz/topo Git corretos; branch `codex/preparo-git`, origin `https://github.com/codeversion7/Jogo_Atlas.git`. Últimos commits locais observados: `7d94c88`, `0ef88af`, `d4a2922`. Sem nova consulta remota nesta revisão.
- Módulo 2 registrado como concluído: sete regiões de suporte/percurso, cinco encontros/páginas, descoberta em M, coordenação de menu/mapa/árvore/diálogo/pausa, NPC e quatro ataques específicos. Relatórios registram 12 suítes; não foram repetidas nesta preparação. Física elevada/discrepante e revisão humana continuam pendentes.
- Arte nova do NPC já está localmente integrada em espera/caminhada; clipes de escudo/dano/corrida estão preparados. Fontes em `NPC_Personagem/`, recursos em `assets/npcs/companheiro/`, documentação `docs/arte/npc/README.md`. Há alterações locais não publicadas; preservar, não regenerar por inferência.
- Visual do escudo atualmente é somente apresentação, com ciclo de 1,12 s; não equivale a proteção mecânica de 5 s. A sustentação deverá ser sincronizada com o novo sistema.
- Oito arquivos em `SONS/`: passos na grama, ataques de monstros, coleta/página, parry e adaga. Todos terminam em `.mpeg`; cabeçalhos sugerem áudio MPEG, sem decodificação/duração/qualidade confirmadas. Nenhum executável ffmpeg/ffprobe foi localizado no PATH nesta inspeção; isso não comprova ausência em outro caminho. Não foi encontrada trilha musical separada nessa pasta.
- `session_ui.gd` já centraliza posse de painéis/pausa; `character_state.gd` já centraliza atributos; fome ainda não tem consumo. Reutilizar esses contratos.

## Decisões novas — fonte: respostas diretas do usuário

| Tema | Aprovado / especificado |
|---|---|
| Drops | Chance normal configurável entre 5% e 10% por monstro; após quatro mortes consecutivas sem carne, a próxima garante; qualquer drop zera a sequência |
| Refeição | Única comida consumível: carne de monstro assada. Carne crua pode existir como ingrediente, não segunda refeição. Levar à fogueira e assar; comer sozinho ou dividir |
| Partilha | Recupera a vida do amigo e acrescenta 0,2 s à duração do escudo dele. Vida usa modelo compatível com o jogador; valores de porção/cura são provisórios configuráveis |
| Amigo caído | Em zero de vida fica caído; carne assada na fogueira pode reanimá-lo |
| Livro | Só pode ativar se amigo estiver vivo. Alimentar ajuda a mantê-lo vivo; não concede invencibilidade nem dispensa a checagem |
| Escudo | Após um golpe deixar o jogador vivo abaixo de 25% da vida máxima, ativar proteção frontal por 5 s, reduzir dano frontal em 50%, sem reflexão; rearmar somente após recuperar pelo menos 25% de vida |
| Parry protegido | Parry bem-sucedido dentro do escudo atordoa o inimigo por 0,5 s. Não aplicar por tentativa sem sucesso nem substituir globalmente o parry fora da proteção |
| Mundo | Estrutura preparada para cinco áreas principais, cada qual associada a uma das cinco páginas; manter hub/áreas auxiliares quando úteis, sem transformar sete regiões técnicas em sete páginas |
| Telas | Atualizar início e fim com identidade própria. Referências declaradas pelo usuário: Deadzone Rogue, Everything is a Crab, Hades, Dead Cells e Sonic, sobretudo distribuição/composição dos elementos e ações centrais |
| Saldo | Último relato: **75% restantes**; substitui relato inicial de 80%. Não é telemetria fixa nem nova consulta de conta |

Nomes dos jogos são referências fornecidas pelo usuário; não foram descritos como interfaces verificadas nesta preparação. Criar composição original com a identidade ATLAS, sem copiar assets, logotipos, textos, animações ou layout pixel a pixel. Não alegar inspiração visual específica não inspecionada.

## Fases de execução

| Ordem | Prompt em `prompts/atlas/modulo3/` | Entrega e ponto de parada |
|---|---|---|
| 1 | `01_BASE_E_NPC.md` | Backup/baseline, conferência das mídias, integração visual do NPC sem quebrar módulos anteriores |
| 2 | `02_AUDIO_E_CONFIGURACOES.md` | Oito SFX importados/validados e ligados a eventos, mixer, configurações persistentes e fluxo de UI |
| 3 | `03_FOME_COMIDA_E_FOGUEIRA.md` | Barra funcional, drops com garantia, ingrediente→assar→comer/dividir, vida/queda/reanimação do amigo |
| 4 | `04_ESCUDO_PARRY_E_LIVRO.md` | Proteção frontal, aumento por partilha, parry de 0,5 s e gate do livro com retomada após reanimação |
| 5 | `05_TELAS_E_AREAS.md` | Início/fim originais, cinco áreas principais configuráveis e mapa preparado para expansão, sem obra de mundo infinito |
| 6 | `06_VALIDACAO_E_ENTREGA.md` | Regressão completa, desempenho/limites, build local quando possível e preservação/publicação autorizada |

`INICIAR.md` é o contrato comum e o orquestrador. Ler somente contrato, estado vigente e fase corrente. Ao retomar, começar da primeira fase ainda não validada; não repetir fases aprovadas sem alteração/falha nova. Não iniciar módulo 4 ou funcionalidades não solicitadas.

## Contratos e bordas materiais

- Novo suporte defensivo substitui a restrição antiga de NPC sem proteção, somente neste escopo. NPC não ganha ataques ofensivos, árvore própria, loja ou magia adicional.
- Vida do amigo é estado independente, não alias da vida do jogador. Queda cancela movimento/escudo/interação normal, mantém ator recuperável e bloqueia livro. Reanimação consome uma porção uma única vez na fogueira e restaura vida positiva configurável; posicionamento seguro é evento de recuperação, não teleporte normal de navegação.
- Contador de drops global da partida, baseado somente em mortes válidas de monstros, nunca em despawn/limpeza. Reset em novo jogo; preservar durante retorno na mesma partida como escolha operacional reversível. Não criar mortes falsas ou drops duplicados por callbacks repetidos.
- Fome deve diminuir apenas durante simulação ativa. Taxa/recuperação/penalidade em zero não foram definidas numericamente; executor pode usar configuração provisória mínima e deve identificá-la. Não esconder regra letal nova: se escolher efeito de zero, registrar claramente e testar o fluxo real, sem ampliar sobrevivência.
- Partilha deve ter custo/efeito atômico. Uma porção não pode reaplicar cura/+0,2 por reabrir UI ou recarregar visual. Duração é 5 s base + 0,2 s por partilha concluída na partida. Não zerar bônus por retorno comum nem criar progressão permanente em disco. Sem teto de design inventado; validar finitude e entrada, expor parâmetro se necessário e não limitar silenciosamente a regra aprovada.
- Escolha operacional provisória do prompt de alimentação: carne também pode restaurar vida do jogador, em quantidade configurável, e partilha reparte o benefício. Cura do amigo/+0,2 são pedidos explícitos; essa relação de porções/cura do jogador não deve ser registrada como número ou design final fornecido pelo usuário.
- Novo suporte reduz dano, distinto da reserva de escudo comprada na árvore. Pipeline documentado, sem reduzir duas vezes o mesmo dano. O golpe que cruza 25% é processado antes da ativação; golpe letal não ressuscita. Exatamente 25% não ativa; recuperar ≥25% rearma para nova queda, sem refresh infinito a cada hit abaixo do limiar.
- Parry atual usa stagger de duração provisória, hoje 0,85 s. Dentro da proteção, o caso novo tem duração 0,5 s; não trocar `stagger_duration` global de todos os monstros ou acumular 0,85+0,5. Tornar a duração do evento explícita e preservar casos fora do escudo.
- Cinco páginas continuam coletáveis e persistentes quando amigo está caído; só a ativação do livro é bloqueada. Ao reanimar, permitir continuar o fluxo sem duplicar página, horda ou final. Sem comida acessível, comunicar bloqueio e manter opção real de reinício, sem duplicar recurso, reanimar de graça ou prender a UI.
- Configuração salva não é save da campanha. Não guardar partida/vida/recursos permanentemente por acidente.

## Economia e preservação

Os arquivos foram separados para reduzir leitura repetida. Relatórios curtos por fase, buscas dirigidas e testes afetados primeiro; regressão ampla no fim ou quando houver motivo. Sem agentes extras, geração de assets, dependências pagas ou novas suítes duplicadas por rotina.

Saldo inicial deve ser reconsultado quando houver recurso real; último relato 75%. Aos ≤15%, não iniciar fase ampla. Aos ≤8% ou aviso de limite próximo, parar features, salvar/validar mínimo, backup e checkpoint Git/publicação autorizada, relatar e encerrar. Sem telemetria, não inventar percentual: checkpoints por fase e parada por aviso real. Não esperar reset nem retomar automaticamente.

Esta preparação alterou documentação/prompts apenas; nenhuma configuração de áudio, código, asset, commit ou push foi executada. Seguir permissões e `security-and-release.md` antes de publicar na execução futura. A nova tarefa enviada pelo usuário deve conter a autorização específica de commit/push; não tratar autorizações dos módulos anteriores como permanentes.
