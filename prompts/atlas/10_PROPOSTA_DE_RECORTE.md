# Próximo prompt — fechar detalhes da primeira parte compacta

Aplique `prompts/atlas/CONTRATO.md`. Leia `CONTEXTO.md` e `docs/atlas/DECISOES.md`. Este prompt autoriza diagnóstico e preparação de tarefas; suas propostas não autorizam implementação antes de aprovadas.

## Objetivo e fatos de partida

Preparar a execução no VS Code + Codex de uma primeira parte compacta para Windows/Godot 4.7.2: visão de cima, pixel art, exploração, comida, conquistas, cinco páginas, livro e encerramento breve. Combate aprovado: um ataque manual, um tipo de inimigo e três ondas. NPC acompanha/interage, sem combater. Mapa acessado por M mostra apenas áreas descobertas. Números ajustáveis provisórios já foram autorizados.

O usuário tem 1h50–2h50 por sessão diária até sábado, 24/10/2026. Não há código implementado por esta preparação. Faça o diagnóstico mínimo para confirmar se isso mudou e localizar o Godot em caminho conhecido/informado, sem busca indiscriminada no computador.

## Proposta concreta dos detalhes restantes — AINDA NÃO APROVADA

Apresente esta proposta ao usuário para revisão, preservando escolhas já aprovadas. Se houver decisão posterior, use-a em vez desta proposta.

| Área | Proposta provisória | Justificativa curta |
|---|---|---|
| Tela/entrada | Base 640×360 com escala inteira quando possível; WASD mover, mouse mirar, clique esquerdo atacar, E interagir, M alternar mapa, Esc pausa | Recorte de entrada simples e legível; resolução é proposta, não direção de arte final |
| Combate | Ataque corpo a corpo curto na direção da mira; um inimigo aproxima-se e causa dano por contato com intervalo de invulnerabilidade ajustável | Valida ataque, posicionamento e dano sem armas/sistemas adicionais |
| Ondas | Três ondas com contagens provisórias 3/5/7; início por interação com um ponto neutro no cenário após preparar-se; próxima onda disponível após eliminar todos | Dá espaço para explorar e alimentar-se entre ondas; não presume sobrevivência contínua por tempo |
| Derrota | Vida esgotada abre tela de derrota; reiniciar limpa toda a partida, incluindo páginas, ondas e descoberta | Define recorte de reinício sem afirmar que morte permanente é canon do jogo final |
| Mapa | M abre/fecha mapa e pausa simulação; mostra só células/áreas visitadas, sem ícones de conteúdo não descoberto | Evita revelar locais e permite consultar o mapa no protótipo solo |
| NPC | Segue o jogador com distância ajustável; colisão com cenário; interação E exibe apenas identificação neutra de teste, sem lore nova; não recebe dano nesta versão | Testa acompanhamento/interação sem ampliar combate ou inventar sobreviventes |
| Comida | Medidor simples de fome cai durante jogo ativo; alimento recupera; em zero causa perda gradual de vida; três pontos de comida de uso único, números ajustáveis | Produz escassez observável sem inventário/crafting; a regra de dano ainda é proposta |
| Conquistas/páginas | Duas conquistas de exploração liberam páginas em dois marcos visitados; cada uma das três ondas vencidas libera uma página em seu ponto de conclusão; E coleta página liberada e próxima | Recorte de cinco páginas com busca e conquistas. Esta associação é proposta local, não regra universal de uma conquista por página |
| Livro/final | Quinta página inicia folhear rápido → torre de luz → desaparecimento; tremor/efeito curto representa o colapso aprovado; depois tela “Fim da primeira parte” com reinício/saída | Preserva canon e fechamento breve, sem inventar causa narrativa. A forma do colapso requer aprovação |
| Assets | Silhuetas/sprites e efeitos provisórios explicitamente identificados; prioridade de acabamento nos elementos visíveis do ciclo. Áudio só com arquivos reais autorizados | Permite testar cedo sem declarar arte/trilha final. Não fabricar autoria ou licença |

Esses números são sementes de teste, não balanceamento medido. A aprovação de números ajustáveis não aprova por si só regras novas como fome causar dano, NPC invulnerável ou mapa pausar. A proposta depende de aprovação dessas regras. Não acrescente XP, equipamentos, procedural, novos inimigos ou narrativa para enriquecer o recorte.

## Processo após a revisão

1. Se ainda faltar aprovação, entregue o pacote de decisões em linguagem clara e peça aprovação com possibilidade de alterar itens. Continue somente diagnóstico/documentação independente. Não faça perguntas já resolvidas sobre versão, modo, perspectiva, livro ou três ondas.
2. Registre aprovação real com data/fonte em `docs/atlas/DECISOES.md`, preservando as alterações que o usuário fizer. Não marque a tabela inteira aprovada por resposta restrita a um item.
3. Quando as escolhas necessárias estiverem aprovadas, prepare o prompt da fundação usando `01_FUNDACAO.md`, referenciando as decisões específicas. Execute implementação somente se a instrução atual do usuário a autorizar; o pedido de preparar prompts não é pedido automático de executar o jogo inteiro.
4. Próxima sequência proposta: fundação → exploração/mapa → combate/ondas → NPC/comida → conquistas/páginas → livro/encerramento → audiovisual → revisão/exportação. Ajuste marcos à evidência real, reservando tempo para testes.

## Aceite deste prompt

- Decisões já aprovadas reaproveitadas sem nova confirmação.
- Propostas concretas restantes identificadas sem falsos fatos ou aprovação fabricada.
- Nenhum código do jogo criado só por leitura deste arquivo.
- Próximo prompt de implementação curto, com cena inicial, arquivos editáveis, critérios de execução e verificação na Godot, pronto assim que as decisões necessárias estiverem aprovadas.

## Saída curta

Estado observado; decisões específicas pendentes em pacote revisável; próximo prompt/etapa. Sem repetir o ZIP, expor raciocínio interno ou prometer conclusão de sábado sem evidência.
