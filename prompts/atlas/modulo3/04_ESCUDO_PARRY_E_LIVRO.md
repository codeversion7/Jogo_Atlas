# Fase 04 — suporte frontal, parry e livro condicionado

Aplique `INICIAR.md`; integre vida/partilha da fase 03 e visual real do NPC.

## Proteção aprovada

Após um golpe válido deixar o jogador **vivo abaixo de 25%** da vida máxima, o NPC vivo gera proteção frontal por **5 s base**. Reduzir em **50%** o dano da frente, sem refletir. O golpe que cruza o limiar já foi processado; não reduzir retroativamente nem salvar de golpe letal. Exatamente 25% não ativa. Não ativar por golpe ignorado, parry/esquiva bem-sucedidos ou apenas abrir UI. Rearmar somente depois de recuperar pelo menos 25%; hits seguintes abaixo do limiar não renovam duração continuamente.

Duração resolvida = 5 s + 0,2 s por partilha concluída nesta partida. Ler estado único, preservar bônus durante retorno e limpar em novo jogo. Como escolha operacional de protótipo, resolver duração na ativação: partilha posterior beneficia a próxima ativação, sem renovar a proteção atual. Não ativar outro escudo enquanto um estiver ativo, mesmo se houve cura/rearme. Não aplicar limite de design não pedido silenciosamente; valide valores finitos/configuração. NPC caído cancela/não ativa proteção. Definir geometria frontal, direção/origem, proximidade e linha de visão em configuração provisória explícita, com visual correspondente; não tornar a proteção global através de paredes. Usar origem/direção real do impacto, inclusive projétil/área, sem inferir sempre a posição atual do monstro lançador.

Esta redução é suporte temporário, não a reserva de escudo comprada no ramo de parry. Documente pipeline: invulnerabilidade/parry → proteção frontal aplicável → resistência → absorção de escudo existente → vida, ou equivalente coerente com arredondamento testado. Não somar percentuais arbitrariamente, duplicar mitigação ou aplicar bônus duas vezes. A ativação observa a vida final do golpe, sem recursão de sinais.

Parry bem-sucedido **dentro da proteção** atordoa aquele inimigo por **0,5 s**. Atual `stagger()` usa duração base provisória de cerca de 0,85 s: forneça duração explícita ao evento protegido, sem somar 0,85+0,5 nem mudar parry de fora globalmente. Tentativa sem sucesso não atordoa. Preserve imunidades/regras de ataques aparáveis vigentes; não estender a todos os monstros em volta.

Animação preparada de escudo dura 1,12 s: separar preparação, sustentação e recolhimento; manter sustentação visual coerente com a proteção de 5 s + bônus. Não repetir entrada/recolhimento a cada frame nem deixar efeito ativo após morte/retorno/menu. Pausa congela duração mecânica e apresentação coerentemente. NPC continua sem ataques ofensivos e jogador mantém exatamente três ramos.

## Livro

Exigir cinco páginas **e amigo vivo** ao iniciar o evento. Estar alimentado uma vez não concede imunidade nem dispensa a checagem. Se amigo caído, conservar 5/5 e exibir a necessidade de reanimá-lo; não descartar quinta página nem iniciar final incompleto. Ao recuperar o amigo, permitir ativação conforme fluxo existente, uma vez, sem nova coleta/horda. Revalidar no momento da transição; o início confirmado encerra combate/controla entrada para não ocorrer morte incoerente durante a sequência final.

## Aceite

Casos: acima/exatamente/abaixo de 25%, dano letal/ignorado, golpe frontal/traseiro/lateral/parede, rearme por cura, 5 s e +0,2 por evento, pausa, NPC caído, limpeza/reinício, proteção junto da reserva de escudo/resistência. Testar parry protegido por 0,5 s e normal sem mudança indevida. Livro 4/5+vivo, 5/5+caído e 5/5+reanimado: gatilho único e sequência canônica sem colapso. Registre efeitos visuais como revisados ou pendentes, sem aprovação artística fabricada.
