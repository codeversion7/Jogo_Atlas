# ATLAS — design consolidado

## Visão e ciclo

Roguelike 2D de cima que combina exploração, recursos escassos, descoberta narrativa e combate ágil. O protagonista busca cinco páginas perdidas de um livro rasgado. Certas áreas próximas às páginas ativam hordas, exigindo aproximação, ataque, recuo e retorno rápidos.

Ciclo conceitual: explorar → lidar com recursos e ameaças → cumprir condições de progressão → obter páginas → atualizar livro → alcançar 5/5 → sequência do livro e continuidade da história.

A condição exata de obtenção da página e sua retenção na morte seguem abertas. Não se pode concluir a estrutura final das tentativas apenas pelo rótulo roguelike.

## Narrativa

Queda da nave, protagonista único sobrevivente inicial gravemente ferido e Atlas Boardship como antagonista central. Livro e ilha guardam mistérios ainda sem respostas oficiais. Não inventar a causa da queda, origem do livro ou objetivos da companhia.

Ao reunir cinco páginas: elas passam rapidamente no livro, surge uma torre de luz e o livro desaparece com animação; a narrativa continua. A transição concreta para a cena seguinte precisa de implementação e conferência da continuidade.

## Combate aprovado

- Ritmo frenético nos encontros de hordas.
- Adaga de emergência desgastada pelo uso frequente em combate próximo.
- Parry e esquiva como ferramentas de defesa.
- Necessidade de atacar, recuar e retomar o combate em pouco tempo.

## Proposta para o primeiro teste

Um inimigo com aproximação, preparação legível, ataque, recuperação e morte. Ondas configuráveis numa arena com espaço para circulação. Ataque da adaga curto, sem repetir dano no mesmo alvo durante um único golpe. Parry inicialmente direcional e esquiva curta com invulnerabilidade temporária; são hipóteses de funcionamento a validar.

Validar primeiro leitura, resposta aos comandos, utilidade das três ações e circulação. Só então aumentar inimigos e complexidade. Os valores de balanceamento devem ser ajustáveis.

## Exploração, mapa e recursos

O mapa definitivo não foi aprovado. Como protótipo, sugeriu-se destroços para orientação, caminho principal, rota opcional com recurso e área de confronto. Layout, bioma, gates de arena e formas de fuga ainda precisam ser definidos.

Comida escassa e sobrevivência simples vêm da documentação anterior. Recuperação, inventário e relação com as tentativas precisam de definição. Não presumir fome contínua, crafting, economia ou dezenas de atributos.

## Multiplayer

Há uma estrutura narrativa anterior de três papéis: personagem da ilha e dois membros da nave, amigos de longa data. Não há rede, autoridade de partida ou cronologia confirmadas nesta consolidação. O primeiro teste de combate não exige implementar multiplayer.

## Próximas decisões

Responder primeiro retenção de páginas na morte e condição de coleta na horda. Depois fechar alvo/alcance do parry, ações que interrompem outras, controles, custos, monstros, ondas e estrutura das tentativas. Consultar [decisões](../projeto/DECISOES.md).
