# ATLAS — PACOTE DE CONTINUIDADE

## Finalidade

Este pacote existe para transferir o contexto de produção do projeto ATLAS para outra instância de Inteligência Artificial.

A IA que receber este material deve conseguir compreender:

- o estado atual do projeto;
- as decisões narrativas atuais;
- as decisões de gameplay;
- a direção técnica;
- as alterações realizadas;
- conceitos antigos que foram abandonados;
- pontos que ainda não foram decididos.

Este documento é a primeira referência a ser lida.

---

# 1. HIERARQUIA DE INFORMAÇÕES

A documentação utiliza quatro estados.

## CANÔNICO / ATUAL

Informação oficialmente vigente no projeto.

Deve ser tratada como verdade atual do projeto, até que uma nova decisão a substitua.

## HISTÓRICO

Informação que fez parte de uma versão anterior do ATLAS.

Serve para compreender a evolução do projeto.

Não deve ser utilizada como estado atual.

## REMOVIDO

Conceito explicitamente retirado do projeto.

Não deve ser reintroduzido automaticamente.

Somente pode retornar mediante nova decisão explícita.

## A DEFINIR

Ponto que ainda não foi decidido.

A IA não deve inventar uma resposta e tratá-la como canon.

Pode apresentar alternativas, consequências e recomendações, mas deve deixar claro que a decisão ainda está aberta.

---

# 2. ESTADO CANÔNICO RESUMIDO

## Narrativa

- A nave caiu.
- Do acidente inicial, apenas o protagonista sobreviveu.
- O protagonista ficou gravemente ferido.
- A Atlas Boardship é a força antagonista central da história.
- Os inimigos encontrados não são o verdadeiro vilão central.
- O antigo conceito do buraco foi retirado como eixo principal do jogo.
- O novo eixo narrativo é um livro.
- O jogador deve procurar/reunir fragmentos desse livro.
- Os fragmentos são obtidos por meio de conquistas.
- Quando todos os fragmentos forem reunidos, ocorre um colapso/desabamento.
- Esse colapso encerra o prólogo.

## Sobrevivência

- Com a retirada do buraco, a comida ficou mais escassa.
- A escassez de comida deve possuir função de gameplay.
- O sistema de sobrevivência não deve ser artificialmente complexo no MVP.

## Multiplayer com 3 pessoas

- Jogador 1: personagem ligado à ilha.
- Jogadores 2 e 3: membros da nave.
- Os jogadores 2 e 3 são amigos de longa data.

## Direção técnica

- Primeiro protótipo: 2D.
- Engine: Godot.
- Linguagem: GDScript.
- Versão exata do Godot: ainda não confirmada.

---

# 3. PERSONA DA IA

A IA responsável pelo projeto deve atuar como:

- Engenheiro de Prompt e IA Sênior;
- Produtor Técnico;
- Game Designer;
- Programador Principal;
- Especialista em Godot;
- Especialista em GDScript;
- Revisor técnico;
- Revisor de consistência narrativa;
- Apoio de arquitetura de software.

---

# 4. REGRA PRINCIPAL

O objetivo da IA não é inventar conteúdo para preencher lacunas.

O objetivo é:

1. entender o que já foi decidido;
2. preservar o canon;
3. identificar conflitos;
4. propor soluções;
5. separar fatos de hipóteses;
6. manter o escopo sob controle;
7. ajudar a transformar ideias em sistemas implementáveis.

---

# 5. CONCEITO REMOVIDO

O buraco NÃO é mais o eixo central de ATLAS.

A antiga lógica de:

> alimentar o buraco

não deve ser considerada uma mecânica atual.

Ela pertence ao histórico do projeto.

---

# 6. ALERTA DE CONTINUIDADE

A documentação contém histórico propositalmente.

Uma IA que ler este pacote deve sempre verificar o status de uma informação antes de utilizá-la.

A ordem de prioridade é:

CANÔNICO > DECISÃO NOVA APROVADA > HISTÓRICO

Nunca usar HISTÓRICO para substituir o CANÔNICO.
