# Prompt 02 — movimentação, exploração e interação

Aplique `prompts/atlas/CONTRATO.md`. Execute somente esta etapa, sobre a fundação existente e validada.

## Pré-condições

Visão de cima e solo já estão aprovados. Confirme somente controles, câmera e layout provisório ainda ausentes. Mapa em M e revelação exclusiva de áreas descobertas são requisitos aprovados, não propostas.

## Entrega

Implemente personagem controlável, colisões, câmera e um espaço curto de exploração aprovado. Crie uma interação mínima reutilizável com indicação clara de disponibilidade. Implemente descoberta de áreas com granularidade simples aprovada e uma tela de mapa acessada por M, sem minimapa permanente. Consulte a decisão sobre fechar o mapa e pausar o jogo; não imponha pausa em um jogo de ondas sem aprovação. Use uma situação neutra de interação aprovada, sem conceder páginas ou criar conquistas definitivas antecipadamente.

Se houver corrida, salto, diagonal, aceleração ou outra regra não definida pela perspectiva/controles aprovados, pergunte somente quando indispensável; não acrescente mecânicas para enriquecer o escopo. Mantenha os parâmetros autorizados editáveis no editor.

## Aceite e validação

- Movimento corresponde à perspectiva e controles aprovados, inclusive estabilidade com diferentes taxas de quadros quando aplicável.
- Personagem não atravessa obstáculos no cenário de teste.
- Interação exige alcance/contexto correto; não dispara fora da área nem se multiplica indevidamente com entrada mantida.
- Há feedback legível para interagir, usando recursos provisórios autorizados.
- Mapa oculto na partida normal e visível mediante M; áreas ainda não descobertas não aparecem, inclusive por ícones/objetivos que revelem o restante da ilha.
- Revelação permanece coerente ao abrir/fechar o mapa na mesma partida; persistência entre partidas só se aprovada.
- Fechamento e pausa seguem a regra aprovada; entrada de mapa não dispara ações de combate indevidas.
- Teste no jogo o trajeto inicial → obstáculo → interação → retorno. Registre observação real ou validação manual pendente.

Informe as cenas/nós/scripts envolvidos e o procedimento curto de verificação no editor.
