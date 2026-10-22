# ATLAS — marcos de produção

## Vers?o jog?vel integrada ? 22/10/2026

Pedido atual: finalizar as metas A?D do anexo de continuidade. Prazo atualizado para 23/10/2026 (S?o Paulo). Implementado percurso por F5 com anima??o autoral articulada, combate por fases com depura??o F3, sete regi?es conectadas, cinco encontros de tr?s ondas, cinco p?ginas distintas, morte/retorno, pausa e sequ?ncia final do livro. N?o ? a ilha ou arte definitiva. As se??es anteriores abaixo ficam preservadas como hist?rico.

In?cio e controles: [JOGAR.md](../../JOGAR.md). Crit?rios, arquivos, comandos, testes e limites: [ENTREGA_JOGAVEL.md](ENTREGA_JOGAVEL.md). Godot 4.7.2; recursos pr?prios provis?rios e refer?ncias originais preservadas. Exporta??o Windows tentada, mas templates 4.7.2 ausentes; execu??o pelo editor/engine dispon?vel. Sem commit, push ou publica??o.


## Atualização vigente — 22/10/2026

O quadro e as notas posteriores são históricos. O pedido atual prioriza o primeiro recorte jogável e substitui o encerramento antigo por colapso: **5/5 → folhear rápido → torre de luz → desaparecimento animado do livro**. Não reintroduzir desabamento como requisito.

1. Base de locomoção conferida: testes anteriores repetidos sem falhas; animações finais continuam pendentes.
2. Arena separada implementada para avaliação: adaga, parry, esquiva, vida/dano/morte, um monstro e ondas configuráveis. Testes automáticos aprovados; ritmo e balanceamento dependem de avaliação humana.
3. Primeira página integrada ao recorte de teste, após vencer toda a horda; contador até 1/5. Páginas mantidas ao morrer; retorno interpretado como 50% da vida máxima e 25% de fome restante.
4. Próximo: avaliar o recorte via F6, ajustar parâmetros e construir o primeiro mapa com exploração/confronto. Geometria atual é provisória; não é mapa final aprovado.
5. Posterior: detalhar conquistas/comida e implementar outras quatro páginas, evento do livro e revisão/exportação. Não implementar consumo ou persistência em disco sem definir o comportamento necessário. Rede e cronologia multiplayer continuam fora desta etapa.

Controles de combate, quantidade de monstros por onda e tempos são experimentais. Decisões atualizadas: U12–U15 em DECISOES.md. Evidências e roteiro em ESTADO_PRODUCAO.md.

Preparado em 19/10/2026. Sequência de trabalho; não aprova detalhes da proposta 10 nem promete conclusão. Entrega solicitada: 24/10/2026; janela diária informada: 13h ou 14h até 15h50. Reavaliar esforço após a fundação; reservar a sessão final para teste, correções e exportação, antecipando-a se surgirem impedimentos.

| Marco | Critério de saída | Dependência |
|---|---|---|
| 1. Fundação, única implementação desta etapa | Projeto 4.7.2, cena principal executável, entradas aprovadas, recursos existentes e editáveis; evidência de importação e execução | Aprovar controles, resolução e recursos visuais provisórios |
| 2. Exploração e mapa | Movimento verificável; M apresenta somente áreas descobertas; sem minimapa permanente | Definir fechamento e pausa do mapa |
| 3. Combate e três ondas | Um ataque manual e um tipo de inimigo; três ondas completas verificadas | Definir ataque, inimigo, início/intervalos, derrota e reinício |
| 4. NPC e comida | NPC acompanha/interage sem combater; escassez de comida observável | Definir interação e regras concretas de alimento |
| 5. Conquistas e páginas | Exatamente cinco páginas distintas, contador sem duplicação e obtenção verificável | Definir relação entre conquistas e obtenção das páginas |
| 6. Livro e encerramento | 5/5 → folhear rápido → torre de luz → desaparecimento animado; colapso preservado; “Fim da primeira parte” | Definir ligação concreta ao colapso e comportamento ao concluir |
| 7. Audiovisual | Recursos reais autorizados, origens registradas quando aplicável; revisão visual e sonora manual | Seleção/autorização dos recursos; não confundir provisórios com acabamento final |
| 8. Revisão e exportação | Ciclo completo testado, falhas corrigidas, build Windows executada; limitações documentadas | Definir formato/arquitetura e verificar templates de exportação |

Não acrescentar procedural, equipamentos, crafting, habilidades extensas ou multiplayer. Não implementar sistemas posteriores durante a fundação. Não retirar livro, cinco páginas ou colapso para acomodar o prazo sem decisão do usuário.
## Situação após a fundação — 19/10/2026

U10 aprovou controles, resolução e recursos visuais provisórios somente para a fundação. Marco 1 implementado: importação, execução headless, instanciação da cena e reconhecimento das entradas passaram; evidências em ESTADO_PRODUCAO.md e docs/atlas/evidencias. Revisão visual/manual permanece pendente. Cena estática, sem movimento ou outros sistemas de jogo.
Próximo marco de implementação: exploração/mapa. Definir fechamento e pausa do mapa antes da parte dependente; não aprovar as outras propostas por inferência. Manter revisão manual da fundação no início da próxima sessão e preservar a reserva final de teste/correção/exportação. A abertura é feita pelo project.godot desta raiz, seguida de F5; F6 executa main.tscn.

## Avanço — 22/10/2026

U11 autoriza o primeiro trecho jogável: personagem WASD, colisão, câmera e transições de locomoção com pose estável enquanto as animações exigem revisão. Implementado como parte do marco 2; mapa, descoberta e interação ainda pendentes. Testes de física/entrada/visual e regressão das animações executados; evidências e limites em ESTADO_PRODUCAO.md. Próxima definição do usuário: armas e regras de combate, sem antecipar a implementação dessas regras.
