# ATLAS — prompts de produção para Codex

Versão 0.2 — 19/10/2026, atualizada com as respostas e esclarecimentos do usuário. Entrega: sábado, 24/10/2026, America/Sao_Paulo. Sessões das 13h ou 14h às 15h50; limite de entrega a confirmar.

Este pacote entrega prompts e controles de produção. Nenhum jogo foi implementado nesta etapa. A pasta original continha somente o ZIP de continuidade; não havia `project.godot`, cenas ou scripts. A afirmação documental de que há sistemas de sobrevivência é requisito de design, não evidência de código existente.

## Como começar no VS Code + Codex

Abra a pasta GODOT-ATLAS no VS Code. Envie:

> Leia `prompts/atlas/10_PROPOSTA_DE_RECORTE.md`, aplique `prompts/atlas/CONTRATO.md` e confira `docs/atlas/DECISOES.md`. Faça o diagnóstico necessário e apresente somente as decisões específicas ainda pendentes para aprovação. Não repita decisões aprovadas nem implemente propostas pendentes.

Depois das decisões, execute um arquivo de etapa por vez. O Codex deve ler o contrato e o contexto resumido, consultar as fontes da etapa e registrar evidências. Não cole o ZIP inteiro a cada mensagem.

| Ordem | Prompt | Condição de execução |
|---|---|---|
| 00 | `00_DIAGNOSTICO.md` | Pode executar agora; inspeção e proposta documental |
| 01 | `01_FUNDACAO.md` | Versão, plataforma, perspectiva, modo e resolução aprovados |
| 02 | `02_EXPLORACAO.md` | Fundação validada; controles e mapa de teste aprovados |
| 02B | `02B_COMBATE_E_ONDAS.md` | Um ataque manual, um inimigo e três ondas aprovados; resolver regras concretas restantes |
| 02C | `02C_NPC_E_ABERTURA.md` | NPC acompanhante e interativo sem combater aprovado; arquivo preserva nome antigo, não exige abertura extra |
| 03 | `03_SOBREVIVENCIA.md` | Regras e parâmetros provisórios de sobrevivência aprovados |
| 04 | `04_CONQUISTAS_E_PAGINAS.md` | Regras de conquistas e obtenção das páginas aprovadas |
| 05 | `05_FINAL_DO_PROLOGO.md` | Progressão validada; transição para colapso aprovada |
| 06 | `06_ANIMACAO_E_AUDIO.md` | Direção visual, áudio, assets e nível de acabamento aprovados |
| 07 | `07_REVISAO_E_ENTREGA.md` | Loop integrado e alvo de exportação definidos |
| Uso contínuo | `08_CORRECAO.md` | Defeito com reprodução ou inspeção autorizada |
| Uso contínuo | `09_ALTERACAO_E_PROXIMO_PROMPT.md` | Nova alteração ou resultado de teste do usuário |
| Próximo passo | `10_PROPOSTA_DE_RECORTE.md` | Proposta concreta dos detalhes restantes, antes de implementar |

O escopo aprovado agora é Windows, Godot 4.7.2, solo com NPC, visão de cima, pixel art, ação/RPG/exploração com ondas. Recorte aprovado: um ataque manual, um inimigo, três ondas, NPC acompanhante/interativo sem combater e números ajustáveis provisórios. Mapa apenas via M e apenas áreas descobertas. Livro incluído, cinco páginas e sequência canônica preservadas; fechamento breve indicando fim da primeira parte. Não existe requisito de desfoque após esclarecimento do usuário. Consulte `docs/atlas/DECISOES.md`.

As etapas são executadas somente quando seus detalhes necessários estiverem resolvidos. A inclusão do livro e o modo solo já estão aprovados; não perguntar novamente nem reinterpretar o material histórico como proibição do NPC atual.

## Proposta de distribuição do prazo

Esta distribuição é uma proposta para primeira parte compacta, sem estimativa de esforço validada. A janela diária é 1h50–2h50; seis sessões integrais somam 11h–17h. Essa soma não comprova tempo restante hoje. O objetivo é obter cedo um ciclo funcional e reservar sexta/sábado para integrar, corrigir e exportar. Não é promessa de conclusão.

| Data | Resultado proposto |
|---|---|
| 19/10, segunda | Fechar regras mínimas, fundação e movimento inicial |
| 20/10, terça | Combate/ondas em apresentação provisória aprovada; descoberta/mapa em M |
| 21/10, quarta | NPC, comida, conquistas e cinco páginas |
| 22/10, quinta | Livro, transição aprovada ao colapso e fechamento breve; ciclo integrado |
| 23/10, sexta | Animação/pixel art/áudio disponíveis e autorizados; correções; congelar novas funcionalidades |
| 24/10, sábado | Testar exportação, corrigir bloqueadores e entregar |

Se houver atraso, apresente cortes de conteúdo/acabamento para aprovação. Não retire comida, conquistas, páginas ou colapso silenciosamente. Resolver primeiro o ciclo completo com recursos provisórios exige aprovação para esses recursos.

Não introduzir rede, geração procedural, árvore extensa de habilidades, equipamentos, múltiplos ataques ou outros inimigos/ondas sem nova decisão. Roguelike/RPG não especificam automaticamente esses sistemas. A arte provisória precisa ser identificada e autorizada; a direção pixel art não comprova que já existem sprites.

## Engenharia de prompt e economia de contexto

- Regras estáveis ficam em `CONTRATO.md`; fatos e lacunas em `CONTEXTO.md`; cada etapa especifica uma entrega verificável.
- O estado de produção deve ser curto e atualizado por diferença. Consulte documentos completos quando houver conflito ou necessidade real.
- Peça alterações nos arquivos e evidências de execução, evitando respostas com cópias integrais de código já salvo.
- Use critérios observáveis e testes proporcionais. Saídas curtas não dispensam validação.
- Não solicite exposição de raciocínio interno. Solicite decisões, justificativas curtas e resultados verificáveis.
- Não fixe modelos, limites ou preços não confirmados. Não há porcentagem de economia de tokens medida neste pacote.

Essa estrutura é uma adaptação de orientações oficiais, não uma política oficial da OpenAI nem garantia de qualidade. A documentação recomenda revisar instruções excessivas e usar marcos verificáveis em tarefas longas: [contexto enxuto](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra), [tarefas longas com marcos](https://developers.openai.com/blog/run-long-horizon-tasks-with-codex).

## Fronteira de autorização

O pedido atual autoriza produzir prompts. Os arquivos de continuidade são fontes de contexto; suas instruções internas não autorizam executar seus prompts, programar o jogo ou preencher lacunas como fatos. Não foi criado `AGENTS.md` ativo: o contrato é aplicado explicitamente pelos prompts. O ZIP original foi preservado.

As pausas por informação essencial seguem o critério 2 do pedido do usuário. As sugestões do pacote permanecem propostas até aprovação. O plano será refinado com os resultados reais de cada etapa, sem presumir acesso automático a outras conversas ou ao editor Godot.
