# ATLAS

## Jogar a vers?o atual

Abra `project.godot` no Godot 4.7.2 e use **F5**, ou `Jogar-ATLAS.cmd`. Percurso integrado, adaga/parry/esquiva, cinco p?ginas e evento do livro. [Controles e limites](JOGAR.md) ? [Entrega e testes](docs/atlas/ENTREGA_JOGAVEL.md). Recursos provis?rios. A documenta??o hist?rica abaixo permanece preservada.


## Projeto local integrado — 22/10/2026

A pasta Windows real já contém o projeto Godot 4.7.2 e os recortes de movimentação e arena de combate em cenas separadas. A documentação remota foi integrada localmente preservando o histórico, na branch `codex/preparo-git`. O código do jogo ainda não foi commitado nem publicado. Consulte o [estado verificado localmente](docs/projeto/ESTADO_ATUAL.md); o registro da consolidação inicial abaixo descreve o remoto antes desta integração.

Jogo roguelike 2D em desenvolvimento com Godot e GDScript, com exploração, sobrevivência simples e combates frenéticos em hordas próximas às cinco páginas perdidas de um livro.

## Comece aqui

- [Estado real do projeto](docs/projeto/ESTADO_ATUAL.md)
- [Histórico e decisões](docs/projeto/HISTORICO.md)
- [Decisões aprovadas e pendências](docs/projeto/DECISOES.md)
- [Design atual](docs/design/GDD.md)
- [Personagem e animações](docs/arte/PERSONAGEM_E_ANIMACOES.md)
- [Git e preparação do Codex](docs/desenvolvimento/GIT_E_CODEX.md)
- [Próximas entregas e critérios de teste](docs/desenvolvimento/ROADMAP.md)
- [Instruções do agente](AGENTS.md)
- [Índice e origem das fontes](docs/README.md)

## Estado em 22/10/2026

Os responsáveis informaram uma base de cena no Godot, visual aprovado do protagonista, base de animação trabalhada com o Codex e documentação do jogo. A construção integrada de personagem, mapa, mecânicas e combate é a próxima fase.

Na inspeção que iniciou esta documentação, o repositório remoto estava vazio. Esta publicação adiciona documentação e preparação de Git; não contém a cópia local do jogo, nem comprova a implementação das mecânicas descritas.

O projeto Godot precisa ser sincronizado pelo Codex que tem acesso ao computador dos responsáveis. O guia de Git explica como preservar um histórico local existente e conciliar os arquivos de documentação.

## Continuidade

Decisões explícitas mais recentes prevalecem sobre os documentos antigos. O prólogo exige cinco páginas (0/5 a 5/5); ao completar o livro, suas páginas passam rapidamente, surge uma torre de luz e o livro desaparece com animação. Não restaurar automaticamente o antigo buraco ou o antigo encerramento em colapso.

As regras de perda de páginas na morte e de liberação da página durante ou após a horda continuam abertas. A versão exata do Godot também precisa ser confirmada.
