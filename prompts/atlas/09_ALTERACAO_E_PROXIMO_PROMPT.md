# Prompt reutilizável — incorporar alteração e produzir a próxima tarefa

Aplique `prompts/atlas/CONTRATO.md`. Nesta tarefa, revise a mudança e gere um prompt de produção; não implemente automaticamente o prompt gerado.

## Entrada do usuário

Alteração desejada ou resultado do último teste: [descrever].

## Processo

1. Compare o pedido com os arquivos atuais, decisões aprovadas e resultado efetivamente verificado da etapa anterior.
2. Identifique o que muda em comportamento, canon, dependências, testes e prazo. Referencie arquivos ou decisões específicos; não invente alterações que não foram observadas.
3. Se o pedido já aprovar uma mudança concreta, registre seu escopo sem pedir a mesma aprovação outra vez. Se apenas apresentar uma ideia ambígua, mantenha como proposta e esclareça a decisão necessária.
4. Em conflito com decisão antiga, explique exatamente o trecho substituído. Preserve as demais regras. Se faltar informação essencial, solicite aprovação da alternativa ou alteração do processo antes da tarefa dependente.
5. Gere um único prompt para a próxima menor entrega verificável. Reaproveite o contrato e contexto por referência; não copie o pacote inteiro nem repita as personas em cada seção.

## Estrutura obrigatória do prompt gerado

- Objetivo e comportamento esperado observável.
- Fontes relevantes e estado real de partida.
- Decisões aprovadas e pré-condições não satisfeitas.
- Escopo incluído e limites necessários.
- Entregáveis nos arquivos/cenas apropriados, sem impor nomes inexistentes como fatos.
- Critérios de aceite, casos de borda e testes proporcionais.
- Condição de parada por lacuna/falha; próximo passo independente possível.
- Formato curto de resultado: mudanças, evidências, limitações e continuidade.

Salve o novo prompt em arquivo Markdown numerado dentro de `prompts/atlas/`, preservando anteriores e indicando o que substitui. Se não houver acesso à pasta, entregue o texto copiável e declare que não foi salvo. Diferencie sempre "prompt preparado", "implementação feita" e "resultado verificado".
