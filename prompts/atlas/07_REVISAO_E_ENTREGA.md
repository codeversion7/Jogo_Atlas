# Prompt 07 — revisão, teste integrado e entrega

Aplique `prompts/atlas/CONTRATO.md`. Atue com foco de revisor e produtor técnico. Não acrescente funcionalidades nesta etapa.

## Objetivo

Verificar o protótipo contra o escopo aprovado, corrigir bloqueadores e preparar entrega reproduzível para a plataforma definida.

## Execução

1. Compare arquivos e comportamento com `PLANO.md`, `DECISOES.md` e canon. Procure falhas concretas de execução, referências, regras, controles e progressão; evite refatorações cosméticas.
2. Verifique movimentação, colisão, interação, mapa em M com áreas descobertas, NPC acompanhante sem combate, ataque manual único, dano, três ondas, derrota e reinício. Verifique também comida, conquistas, cinco páginas distintas, sequência canônica do livro, transição aprovada ao colapso e encerramento breve indicando fim da primeira parte. O livro está incluído por decisão explícita; não o adiar automaticamente.
3. Faça uma partida completa da primeira parte a partir de estado limpo. Reinicie e confirme os estados aprovados de ondas, NPC e mapa. Teste limites/duplicatas e aberturas/fechamentos do mapa durante combate conforme regra aprovada.
4. Verifique que o projeto é solo e que o NPC substitui o outro jogador sem controles extras ou dependência de rede. Não adicionar multiplayer nesta entrega.
5. Verifique os assets e o áudio, incluindo origem/licença e classificação de provisórios. Remova/exclua da build atalhos de depuração destinados somente aos testes, sem apagar documentação útil.
6. Exporte para o alvo aprovado se ferramentas/templates estiverem disponíveis. Teste a build exportada separadamente do editor. Caso faltem ferramentas, informe a dependência; não afirme que entregar fontes equivale a entregar executável testado.
7. Documente em `docs/atlas/ENTREGA.md`: versão Godot, como abrir e executar, controles, como exportar, teste realizado, limitações e pendências reais. Registre artefato exportado somente se existir.

## Aceite

- Ciclo completo verificável ou bloqueio explícito com reprodução.
- Defeitos críticos encontrados corrigidos e retestados na área afetada.
- Nenhuma alteração silenciosa de canon, modo de jogadores ou funcionalidades essenciais.
- Fontes editáveis entregues e build diferenciada das fontes.
- Avaliação honesta: funcionalidade testada, revisão estática e validação manual pendente aparecem separadas.

Se o prazo não comportar a correção, apresente impacto e opções de corte para aprovação. Não esconda defeito para declarar conclusão.
