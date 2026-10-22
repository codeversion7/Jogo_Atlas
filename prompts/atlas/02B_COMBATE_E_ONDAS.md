# Prompt — combate e ondas da primeira parte

Aplique `prompts/atlas/CONTRATO.md`. Este prompt integra o roteiro atualizado e deve ser executado após movimentação/interação, antes do acabamento.

## Estado e pré-condições

Godot 4.7.2, Windows, visão de cima, solo, ação/RPG/exploração com ondas e pixel art estão aprovados. O usuário aprovou depois explicitamente: um ataque manual, um tipo de inimigo, três ondas e números ajustáveis provisórios. Resolva somente tipo concreto do ataque/inimigo, vida, spawn, regra de início das ondas, derrota/reinício e ligação ao livro ainda ausentes. Não pedir novamente aprovação do recorte já aceito.

## Entrega

Implemente o menor ciclo aprovado: explorar → enfrentar uma onda → receber o feedback/recompensa aprovada → próxima onda → término ou derrota. Não presumir drops, XP, equipamentos, habilidades, geração procedural ou morte permanente só pelo rótulo roguelike/RPG.

Exponha números provisórios autorizados para ajuste no editor. Separe vida/dano do controle de ondas e evite ampliar a arquitetura. Spawns devem seguir posições/regras autorizadas e não prender inimigos em áreas inacessíveis. Use os assets aprovados ou apresentação provisória autorizada, sem declarar pixel art final com formas de teste.

## Aceite

- Ataque causa dano conforme alcance, alvo e intervalo definidos, sem duplicação por colisão/evento repetido.
- Mortes são processadas uma vez; contagem de inimigos nunca fica negativa.
- Uma onda não termina antecipadamente por inimigos ainda aguardando spawn e não fica presa após eliminar todos.
- Ondas respeitam quantidade, intervalo e condição de término aprovados.
- Derrota/vitória bloqueiam ações e permitem reinício conforme regra, sem tarefas de spawn ou inimigos herdados indevidamente.
- Mapa em M interage com o tempo e os controles conforme decisão explícita, sem disparar ataques acidentais.
- Execute uma partida completa e teste dano repetido, último inimigo, morte do jogador e reinício. Registre testes não executados.

Não declare balanceamento ou desempenho final sem medição/teste. Atualize estado com o ciclo efetivamente observado.
