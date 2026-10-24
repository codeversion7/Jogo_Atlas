# Fase 05 — início/fim originais e cinco áreas expansíveis

Aplique `INICIAR.md`; preserve eventos e configurações das fases anteriores.

## Identidade e telas

Referências **indicadas pelo usuário**: Deadzone Rogue, Everything is a Crab, Hades, Dead Cells e Sonic, especialmente composição/distribuição de partes e ações centrais. Não copiar assets, logotipos, textos, composição pixel a pixel ou prometer reproduzir tela não inspecionada. Priorize uma direção original ATLAS: livro incompleto, ilha/mistério, detalhes do protagonista/cachecol e linguagem do NPC como motivos possíveis. Não inventar lore para ornamentar menus.

Faça um esboço curto no plano de fase e implemente uma composição intencional, com motivo visual próprio, hierarquia clara, áreas de respiro e botões centrais bem definidos. Base original sugerida: silhueta/contorno da ilha ao fundo, cinco marcas de página como motivo de progressão, título com enquadramento próprio e ações no centro; vermelho do cachecol e turquesa do suporte como acentos contidos. No fim, adapte a composição à ausência do livro e à dupla viva, sem inventar nova cena narrativa. São escolhas visuais provisórias, não canon ou reprodução dos jogos citados. Não se limitar à tela anterior com título e botões padrão soltos sobre retângulo vazio; também não inserir cinemática pesada para evitar simplicidade. Reutilize assets reais/provisórios identificados, pixel art legível, contraste/foco e animação discreta. Não gerar imagens por IA, comprar fonte ou copiar screenshots sem tarefa/autorização específica.

Início: Novo jogo, Configurações, Créditos quando houver autoria comprovada, Sair. Sem Continuar que não carrega save real. Fim: indicação de conclusão, composição coerente com livro desaparecido e amigo vivo, novo jogo/voltar ao menu/sair; não copiar a tela de início sem adaptação nem apresentar queda do amigo como fim canônico. Se exibir resumo, usar estatísticas realmente registradas, sem inventar notas/ranks.

Use o único coordenador de UI existente; foco/teclado, mouse, Esc, mapa e árvore não disputam pausa. Áudio de transição e menu só quando arquivos adequados existirem; crossfade/volume não duplicam vozes nem continuam SFX de batalha no menu. Validar a 640×360 e janela do usuário, sem cortes ou texto ilegível. Configurações devem funcionar, não serem botão cenográfico.

## Preparar expansão do mapa

Objetivo: cinco áreas principais associadas às cinco páginas. O mapa atual tem sete regiões técnicas, incluindo suporte; não apagar duas regiões úteis ou criar sete páginas para fazer contagens coincidirem. Modele `page_area_id`/equivalente configurável e IDs estáveis, com cinco associações únicas. Dados de área/limites/câmera/navegação/descoberta/encontros devem continuar vindo do layout.

Remova somente pressupostos técnicos rígidos de sete regiões que impedem expansão, atualizando consumidores/testes. Prepare dados para ampliar/adicionar trechos posteriormente; não redesenhe toda ilha nesta fase nem invente novos biomas/lore. Documente quais cinco áreas têm as páginas e como ampliá-las sem mudar IDs/progresso. Hub/fogueiras e rotas de retorno devem permanecer acessíveis, incluindo recuperação do NPC.

## Aceite

Renderize/inspecione menu, configurações, créditos disponíveis e final; teste teclado/foco/Enter/Esc/mouse e reinício sem ataques acidentais ou instâncias duplicadas. Comprove cinco vínculos de área/página, expansão pequena em fixture não destrutiva e percurso real após mudanças. UI nova deve respeitar gate do amigo vivo e preservar mapa ocultando desconhecido. Registre composição criada, referências efetivamente inspecionadas e arte ainda provisória.
