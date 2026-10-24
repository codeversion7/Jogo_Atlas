# Fase 03 — fome, carne, fogueira e vida do amigo

Aplique `INICIAR.md`; não reformar inventário/combate sem necessidade.

## Contrato aprovado

Chance normal por monstro entre 5% e 10%, configurável. Conte mortes válidas sem drop; com quatro falhas consecutivas, a próxima morte garante uma carne. Qualquer drop zera a contagem. Exemplo de teste: falha/falha/falha/falha→garantido→contador 0; sucesso na segunda morte zera antes de acumular outra sequência. Não usar blocos fixos de cinco nem contar despawn/limpeza como morte.

Estado por partida e evento idempotente: mesma morte não concede duas carnes, pontos ou alterações no contador. Injete RNG/seed para testes determinísticos; não use poucas amostras aleatórias como prova de probabilidade. Preserve o contador ao retornar na mesma partida; nova partida limpa.

Carne crua é ingrediente; a única refeição consumível é carne assada de monstro. Coletar → levar a fogueira alcançável → assar → comer sozinho ou dividir. Use quantidades/estado mínimos, sem inventário de grade/crafting amplo. Cozinhar/consumir são operações atômicas: não duplicar por duplo clique, reabrir UI ou cancelar; ingrediente/porção usados uma vez. Tempo/animação de assar são detalhes provisórios, não criar timer que continua em pausa ou não pode terminar porque seu próprio painel pausou a simulação.

Fome real em `character_state.gd`, com barra legível e consumo só durante sessão ativa. Taxa, restauração e efeito em zero são parâmetros provisórios explicitamente documentados; escolha o mínimo compatível com o ritmo existente. Não adicionar penalidade letal escondida: explique e teste qualquer regra de zero adotada, sem alterar retorno de 25%. Nenhum consumo durante menu/mapa/árvore/diálogo/pausa ou após fim/morte.

## Vida, partilha e recuperação

Amigo possui vida atual/máxima independente, usando modelo compatível com o jogador; não compartilhar variáveis de estado nem copiar habilidades do jogador. Recebe dano conforme ataques/áreas válidos e posições reais, sem multiplicar o mesmo golpe por callbacks ou virar alvo do jogador/rastreio. Não reduzir vida por encostar em decoração. A integração de dano do NPC deve distinguir ataques direcionais, projéteis e áreas atuais.

Como configuração operacional provisória para porções, comer sozinho restaura fome e vida do jogador; dividir reparte o benefício do jogador e recupera vida do amigo, acrescentando **0,2 s** à duração do escudo dele por partilha concluída. A cura do amigo e o bônus foram explicitamente pedidos; valores, divisão da porção e cura do jogador são escolhas reversíveis de integração, não números/design final aprovados. Exponha-os e documente-os, incluindo cura que rearma a proteção ao atingir ≥25%. Emitir evento único consumido pelo suporte da fase 04; bônus integra o estado da partida, não nova habilidade na árvore. Não transformar uma porção em bônus repetido.

Vida zero deixa amigo caído, sem morte definitiva: interromper acompanhamento e suporte, apresentar estado claramente. Na fogueira, uma porção assada pode reanimá-lo; restauração positiva configurável. Reanimação consome porção uma vez e pode reapresentá-lo em ponto seguro do local como evento de resgate, sem teleporte de navegação normal. Não exigir que ator caído caminhe até a fogueira. Trate oferecer essa porção como partilha para cura/bônus, sem aplicar +0,2 duas vezes ao mesmo consumo; documente essa escolha operacional reversível.

Sem carne acessível, comunicar risco/bloqueio e manter reinício possível; não gerar recursos falsos ou reanimar grátis para passar no teste. Não ligar fome própria do amigo ou árvore/loja/ataque novos: usuário pediu recuperação de vida, não segundo sistema de alimentação.

## Aceite

Teste RNG nos limites/garantia/reset; morte duplicada/despawn; pickup distante/repetido; ingrediente→assar→porção sem duplicação; comer/dividir/reanimar uma vez; fome em pausa/zero/retorno; dano/queda do NPC e recuperação. Verifique partida real com fogueira acessível e interface E sem coletar página e comida/conversar simultaneamente. Documente o balanço escolhido e estados preservados/limpos ao reiniciar. Não declarar condição final do livro pronta antes da fase 04.
