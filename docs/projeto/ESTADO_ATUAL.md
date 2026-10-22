# Estado atual — 22/10/2026

## Evidências e limites

| Item | Situação | Base da afirmação |
| --- | --- | --- |
| Cena base no Godot | Existente segundo os responsáveis | Relato; código local não inspecionado nesta consolidação |
| Visual do protagonista | Aprovado pelos responsáveis | Aprovação explícita na conversa |
| Base de animação | Trabalhada com Codex segundo os responsáveis | Resultado local mais recente não inspecionado |
| Folhas originais de espera e caminhada | Geradas, com problemas visuais apontados | Imagens e revisão na conversa |
| Estruturação do jogo | Documentada, com lacunas identificadas | Pacote anterior e decisões posteriores |
| Git instalado no Windows | Informado pelos responsáveis | Configuração e autenticação locais não testadas |
| GitHub remoto | Privado, acessível e com permissão de escrita | Consulta ao conector GitHub |
| Código Godot no remoto | Ausente na inspeção inicial | GitHub retornou repositório vazio |
| Combate, ondas e mapa completo | Não comprovados como implementados | Há decisões e instruções; não há código disponível nesta inspeção |
| Prévias animadas aprovadas e testes no Godot | Não comprovados | Não houve execução local nesta consolidação |

Esta publicação adiciona documentação, metadados Git e preparo de sincronização. Não instala Git nem autentica o computador dos responsáveis, não importa o projeto local e não altera mecânicas do jogo.

## Situação de design

Roguelike 2D de cima em pixel art. Cinco páginas perdidas estruturam o prólogo. Hordas em determinadas áreas próximas às páginas exigem atacar, recuar e retornar rapidamente. A arma inicial é uma adaga de emergência desgastada; defesa com parry e esquiva.

Continuam abertas as regras de morte e retenção das páginas, disponibilidade da página durante/após a horda, alcance do parry, atributos, ondas, monstros, mapa definitivo e versão do Godot.

## Próxima ação técnica

Conectar o checkout local ao remoto preservando mudanças e histórico; trazer este conjunto de documentação; inspecionar `project.godot`, cenas, scripts e animações reais. Só então atualizar a tabela acima com evidências de implementação e teste.

O primeiro objetivo de gameplay proposto é uma arena pequena com um inimigo, ondas configuráveis e ataque/parry/esquiva, seguida da integração com exploração e primeira página. Ver [roadmap](../desenvolvimento/ROADMAP.md).
