# ATLAS — contexto verificável para prompts

> Atualização de continuidade, 22/10/2026: o texto atual do usuário e U12–U15 em `docs/atlas/DECISOES.md` prevalecem sobre este resumo histórico e os prompts antigos. Combate: adaga desgastada, parry/esquiva e hordas junto às páginas. A página exige vencer toda a horda. Morte mantém páginas; retorno com metade da vida e 25% de fome restante (protótipo usa metade da vida máxima, sem redução permanente). Encerramento: cinco páginas → folhear rápido → torre de luz → livro desaparece; a exigência antiga de colapso foi substituída. Estado real: locomoção e arena separada com primeira página implementadas/testadas; detalhes e limites em ESTADO_PRODUCAO.md. O restante desta fonte preserva o histórico, não indica sistemas já implementados.

Base: `Pacote_continuidade_projeto_ATLAS_v1.1.zip`, versão documental 1.1, 19/10/2026. As fontes abaixo estão dentro do ZIP; não pressuponha diretório extraído. Use leitura de arquivo compactado ou extração segura para consulta. Este resumo não altera as fontes.

## Pedido atual do usuário

- Gerar prompts para produzir o jogo em Godot/GDScript usando VS Code + Codex e testar/editar na Godot.
- Partir do zero em produção. Prazo: até sábado, 24/10/2026. Disponibilidade informada: todos os dias, começando às 13h ou 14h e terminando às 15h50. Horário limite de entrega não confirmado.
- Qualidade, rigor e economia de tokens; pedir aprovação/alteração de processo quando informação necessária estiver ausente.
- Equipe de competências: engenharia de prompts, Godot/GDScript, game design/desenvolvimento, revisão, animação, sonoplastia e trilha. Persona adicional adotada: produtor técnico.

## Decisões documentais vigentes

### Atualização do usuário — 19/10/2026, após a versão 0.1 dos prompts

Estas decisões novas prevalecem nos pontos correspondentes sobre o ZIP e os prompts anteriores:

- Plataforma: Windows. Versão informada e escolhida: Godot 4.7.2; não atualizar automaticamente para outra versão. A versão possui página oficial de distribuição: https://godotengine.org/download/archive/4.7.2-stable/. A instalação local ainda não foi verificada; nenhum comando Godot foi localizado no PATH na inspeção desta atualização.
- Solo nesta entrega, sem multiplayer. O outro jogador será substituído por um NPC, por decisão nova explícita; o comportamento foi depois definido como acompanhar/interagir sem combater. A identidade e o conteúdo da interação continuam sem definição. Não criar automaticamente dois NPCs nem inventar sobreviventes do acidente.
- Visão de cima; roguelike com ondas, RPG, ação e exploração; direção visual em pixel art. Esses rótulos não especificam geração procedural, morte permanente, inventário complexo ou árvore de habilidades; não presumir esses sistemas.
- Entrega limitada à primeira parte. Em esclarecimento posterior, o usuário informou uma animação breve seguida de fechamento indicando o fim da primeira parte e explicou que a expressão anterior era apenas modo de falar. Não exigir efeito de desfoque nem criar uma abertura desfocada como requisito. O fechamento da primeira parte deve ser breve e indicar conclusão.
- Mapa da ilha aparece somente ao apertar M e mostra apenas áreas descobertas. Não colocar minimapa permanente. Alternar com M é uma proposta de interação, ainda sem regra explícita de fechar/pausar o jogo.
- Autorizados os sistemas de conquistas, comida, relação conquistas/páginas e transição ao colapso. O usuário confirmou depois que o livro deve fazer parte da entrega. Preservar cinco páginas, evento do livro e continuidade canônica; não adiar automaticamente essas etapas. Regras concretas de conquistas, alimento e ligação ao colapso ainda não foram especificadas. Não pedir novamente aprovação da existência dos sistemas ou da inclusão do livro.
- Recorte de teste explicitamente aprovado: combate manual simples com um ataque, um tipo de inimigo e três ondas; NPC que acompanha o protagonista e interage, sem combater; números ajustáveis como provisórios. Não perguntar novamente essas escolhas. Conteúdo narrativo da interação, tipo concreto do ataque/inimigo e consequências da derrota continuam sem definição.
- Janela diária: 1h50 a 2h50. Se todas as seis sessões de segunda a sábado estiverem integralmente disponíveis, a soma é de 11h a 17h; não é estimativa de esforço nem garantia de tempo restante hoje.

O plano de produzir um prólogo extenso foi substituído por uma primeira parte compacta, com livro incluído, recorte de três ondas e encerramento breve. O canon das cinco páginas, sequência do livro e colapso permanece preservado. Não inventar continuação após esse fechamento nem retirar o colapso por conta própria.

| Tema | Definição | Fonte dentro do pacote |
|---|---|---|
| Tecnologia | Primeiro protótipo 2D, Godot, GDScript; versão atual escolhida 4.7.2 | `06_GODOT_GDSCRIPT_E_ARQUITETURA.md`, §1; versão substituída pela resposta do usuário acima |
| Progressão | Exatamente cinco páginas perdidas de um livro rasgado; contador de 0/5 a 5/5 | `07_HISTORICO_E_DECISOES.md`, decisão 10 |
| Conquistas | Vinculadas à obtenção das páginas; relação exata com busca ainda aberta | `04_GAMEPLAY_E_PROGRESSAO.md`, atualização 1.1 |
| Evento visual | Completar 5/5 → folhear rápido → torre de luz → desaparecimento animado do livro | `01_ESTADO_ATUAL.md`, §4 |
| Encerramento | Colapso/desabamento encerra o prólogo; ligação com evento visual a definir | `03_HISTORIA_E_NARRATIVA.md`, §6 |
| Sobrevivência | Comida mais escassa; função de pressão na exploração; parâmetros não definidos | `02_GDD_ATUAL.md`, §6 |
| Narrativa | Nave caiu; só o protagonista sobreviveu ao acidente inicial, gravemente ferido | `03_HISTORIA_E_NARRATIVA.md`, §1–2 |
| Antagonismo | Atlas Boardship é força antagonista central; inimigos não são vilão central | `03_HISTORIA_E_NARRATIVA.md`, §3–4 |
| Multiplayer | Estrutura de três jogadores pertence ao planejamento mais amplo; nesta entrega: solo + NPC | `05_MULTIPLAYER_3_JOGADORES.md`, §1; escopo substituído pela resposta do usuário acima |
| Protótipo | Primeira parte compacta, livro incluído, três ondas, NPC acompanhante não combatente e animação breve de encerramento | Respostas atuais e esclarecimento do usuário; substituem o plano inicial de prólogo extenso |

Nenhum código foi encontrado na inspeção de 19/10/2026. Reinspecione se o usuário tiver produzido arquivos depois disso.

## Conceitos removidos ou não aprovados

- Alimentar o buraco foi removido; não restaurar a mecânica.
- Fragmentos, neste contexto, são as cinco páginas; não criar uma segunda coleção.
- Segundo personagem como NPC era histórico no ZIP, mas foi explicitamente reautorizado para o escopo solo atual. Não usar a regra antiga para impedir essa mudança.
- Uma conquista por página não foi estabelecida.
- AchievementManager e GameState aparecem como exemplos conceituais, não arquitetura obrigatória.
- Categorias sugeridas de conquistas não são conquistas aprovadas.
- A existência de dois membros da nave no multiplayer e a sobrevivência única no acidente inicial exigem cuidado de cronologia. Não inventar explicação nem declarar contradição insolúvel.

## Decisões pendentes e impacto

| ID | Informação necessária | Bloqueia |
|---|---|---|
| D01 | Godot 4.7.2 definido; falta caminho/execução local | Teste automatizado, não escolha de versão |
| D02 | Windows definido; formato e arquitetura da build pendentes | Exportação |
| D03 | Solo + NPC acompanhante/interativo sem combate definidos; identidade e conteúdo da interação pendentes | Conteúdo do NPC |
| D04 | Visão de cima e ataque manual único definidos; teclas e forma do ataque pendentes | Entrada e configuração do ataque |
| D05 | Janela diária definida; início exato e limite de sábado pendentes | Compromisso de prazo |
| D06 | Mapa em M e descoberta definidos; resolução/layout, pausa e fechamento pendentes | Fundação visual e mapa |
| D07 | Sistemas autorizados; conquistas, locais e regra de páginas pendentes | Progressão específica |
| D08 | Comida autorizada; consumo, consequência e recuperação pendentes | Sobrevivência específica |
| D09 | Livro na entrega, sequência canônica e encerramento breve definidos; ligação concreta com colapso pendente | Integração do final |
| D10 | Pixel art definido; assets, animação, música e sons pendentes | Acabamento audiovisual |
| D11 | Ataque manual único, um inimigo, três ondas e números provisórios aprovados; tipo de ataque/inimigo, spawn e derrota pendentes | Regras específicas do ciclo |
| D12 | Expressão sobre abertura esclarecida; animação breve e indicação de fim definidas; duração e ação após conclusão pendentes | Apresentação do encerramento |

Não tratar esses dez itens como perguntas obrigatórias numa única rodada. Pergunte primeiro o necessário à próxima etapa; proponha opções concretas para aprovação quando autorizado. Ausência de executável impede testes locais, mas pode permitir preparar arquivos compatíveis se a versão estiver confirmada; classifique como não verificados.
