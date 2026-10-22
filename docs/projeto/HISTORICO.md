# Histórico de produção

Registro do material disponível; datas ausentes não foram inventadas. A descrição de uma ação planejada não implica implementação.

## 19/09/2026 — documentação de continuidade

Foi disponibilizado um pacote para transferir contexto do ATLAS entre conversas e instâncias de IA. Ele reúne GDD, narrativa, gameplay, arquitetura proposta, multiplayer, histórico, backlog, protocolo e prompt inicial.

O pacote descreve retirada do buraco e substituição pelo livro, sobrevivente da queda da nave, ferimentos, escassez de comida e Atlas Boardship como antagonista. A redação antiga ainda fala em fragmentos de quantidade indefinida e encerramento por colapso.

Em instrução posterior explícita, os responsáveis fixaram cinco páginas perdidas e a sequência de páginas rápidas, torre de luz e desaparecimento do livro. A data exata dessa instrução não é atribuída aqui; sua prioridade sobre o pacote antigo está registrada em DECISOES.md.

## 18/10/2026 — intenção de integração das ferramentas

Foi solicitada orientação para ligar ChatGPT e Godot, com objetivo de alterar o projeto por prompts. Antigravity IDE e Obsidian foram mencionados no contexto de integração. A conversa disponível não comprova configuração concluída ou conexão técnica ativa dessas ferramentas.

## 20/10/2026 — direção de arte e personagem

Brainstorming por perguntas objetivas definiu visão de cima, inicialmente arte 2D desenhada, e sensações de aventura/coragem, medo/desconforto e encanto/curiosidade.

O protagonista foi definido como homem adulto acima de 25 anos, pele média, cabelo castanho-escuro comprido amarrado baixo, barba curta e postura cautelosa. Roupas danificadas da nave e cachecol longo preto com traços vermelho-escuros tornaram-se elementos de continuidade e reconhecimento.

Foi gerada uma prancha pintada com vistas e expressões. O traje foi proposto provisoriamente porque o documento inicial ainda não estava acessível naquele momento. Depois, a pedido dos responsáveis, foram geradas versões em pixel art e uma versão menor e simplificada nas quatro direções. Esta última recebeu aprovação explícita dos responsáveis, incluindo Enzo.

## 20/10/2026 — primeiras folhas de animação

Foram geradas folhas de espera/respiração e caminhada nas quatro direções. A revisão visual identificou poses semelhantes, transição de pés pouco clara, possíveis variações de posição/escala e necessidade de verificar transparência.

Naquela sessão, o ambiente de execução estava indisponível. Não foram montadas prévias em loop nem realizados testes de pixels ou no Godot. Foi fornecido um handoff para o Codex, mantendo os quadros como rascunhos.

## 22/10/2026 — arquivos, pacote e localização do projeto

Com o ambiente disponível, foi criado `ATLAS_ANIMACAO_HANDOFF.md` e salvo na pasta GODOT-ATLAS. Depois foi montado `ATLAS_Pacote_Para_Codex.zip`: cinco arquivos em `referencias/personagem/` e `LEIA_PRIMEIRO.txt` na raiz.

O ZIP foi testado quanto à integridade e as cópias internas comparadas às fontes. Isso valida o transporte, não a qualidade da animação.

O Codex local não encontrou os arquivos em `C:\Users\Arthur-Gamer\Documents\atlas`. Capturas mostraram outro projeto em OneDrive/Documentos/ChatGPT/GODOT-ATLAS. Os responsáveis foram orientados a copiar a pasta `referencias` extraída para junto de `project.godot` e informaram o caminho completo. O acesso efetivo do Codex ao caminho precisa ser confirmado no computador.

## 22/10/2026 — início da construção de gameplay

Os responsáveis informaram cena base, visual em pixel art aprovado, base de animação do Codex e estruturação do jogo. Solicitou-se iniciar construção de personagem, mecânicas, mapa e combate.

Foi proposta uma entrega pequena: validar personagem; criar mapa inicial e arena; implementar combate; ligar interação e primeira página; testar o conjunto. Layout de destroços/rota/arena permaneceu como proposta.

Foi aprovado o combate roguelike ágil com hordas perto das páginas, adaga de emergência desgastada e defesa com parry e esquiva. Parry direcional, invulnerabilidade na esquiva, timings e regras de ondas foram apresentados como propostas, não decisões finais.

Ficaram sem resposta as regras de retenção das páginas após a morte e de coleta durante/após a horda. Foi preparado um prompt de continuidade para outro chat com decisões, caminhos, limitações e próximos passos.

## 22/10/2026 — repositório e preparação Git

Os responsáveis solicitaram documentar o projeto no GitHub e preparar o Codex para Git, já instalado segundo seu relato.

O repositório privado `codeversion7/Jogo_Atlas`, branch padrão `main`, foi encontrado com acesso de escrita. A API confirmou que estava vazio, sem commits e sem código do jogo.

Foi preparada esta consolidação, o arquivo `AGENTS.md`, metadados Git, guia de integração e script PowerShell de diagnóstico/preparo local. A configuração do Windows, autenticação, importação do jogo e testes do engine permanecem dependentes do ambiente local.

## Histórico anterior, preservado como histórico

O pacote de origem registra os conceitos antigos de alimentar o buraco e considerar um segundo personagem como NPC para reduzir escopo. Não são decisões atuais. Registra também a simplificação documental de “Brothers Forever” para “Brothers”; não há base para inventar outro significado.

## Como continuar este registro

Acrescentar fatos com evidências: decisão explícita, arquivos alterados, commit/PR e testes. Não registrar tarefas propostas como prontas. Atualizar ESTADO_ATUAL.md após a importação e inspeção do projeto real.
