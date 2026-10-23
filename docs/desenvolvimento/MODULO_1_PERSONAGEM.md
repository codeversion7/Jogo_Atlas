# Módulo 1 — personagem, habilidades e checkpoint

Execução em 23/10/2026. Escopo: prompt 12 integral; módulos 2/3 não iniciados.

## Preservação e fatias

Backup inicial verificado: `C:/Users/Arthur-Gamer/Documents/atlas/module1-backup-initial-20261023`, 1785 arquivos e manifesto SHA-256, sem `.git`/`.godot`/credenciais. Status inicial e patch rastreado no backup. Branch preservada `codex/preparo-git`, base `cf54a93`, índice inicial vazio; fetch confirmou 0/0 em relação ao origin. Checkpoints incrementais em `C:/Users/Arthur-Gamer/Documents/atlas/module1-checkpoints/`: 01 atributos, 02 adaga, 03 rastreio, 04 árvore e 05 regressão/organização. Sem telemetria de cota disponível; último relato 78% não foi tratado como saldo atual nem confundido com contexto/tokens.

## Atributos e regras provisórias

Configuração compartilhada somente leitura em `resources/character/default_character.tres`, com exports em `character_config.gd`. Estado de vida/fome/escudo/recargas/pontos/compras por instância em `character_state.gd`; aliases mantêm os consumidores do controlador antigo. Vida 100, fome 100, dano 25, resistência 0, escudo 0. Resistência limitada a 0–80%; dano positivo → mitigar → arredondar para cima → absorver no escudo → vida. Negativo não cura; atuais limitados aos máximos. Escudo não regenera. Retorno: 50% da vida máxima, 25% da fome máxima, escudo 0. Fome continua sem consumo/alimentação.

Dash base: 30,4 px / 0,16 s = 190 px/s, recarga 0,65 s, movimento físico com colisão; sem teleporte nem quarto ramo. Lâmina corpo a corpo preserva exatamente os pontos visíveis e a máscara/oclusão anteriores. Melhorias de dano só ocorrem pela compra explícita.

## Exatamente três ramos

- **Adaga de retorno:** Q, comprável por 1 ponto. Dano 25 por alvo na ida e 25 na volta, uma vez por trecho; projétil único. Alcance 120 px, velocidade 220 px/s, recarga 3 s desde o lançamento. Retorna por alcance/sólido e segue a mão móvel. Parede no retorno ou timeout de 2 s recolhe com segurança, sem dano além do obstáculo. A arma na mão fica oculta durante voo; ataques/parry que usam a adaga aguardam seu retorno. Movimento/esquiva continuam disponíveis. Morte, remoção e saída da cena cancelam; nunca deixa arma permanentemente perdida. Fio preciso (+1 ponto): +5 dano em corpo a corpo e arremesso.
- **Rastreio:** F, comprável por 1 ponto. Raio 160 px, duração 4 s, recarga 8 s desde ativação. Consulta grupo de inimigos vivos a cada 0,2 s; valida somente os já rastreados entre consultas. Setas direcionais locais, sem revelar mapa/páginas/alvos distantes. Morte/saída do raio remove indicador; expiração/morte/reinício limpa estado. Passo ágil (+1 ponto): +6,08 px de dash, duração mantida, velocidade resolvida 228 px/s.
- **Parry:** botão direito já disponível desde o início, sem compra. Janela base 0,16 s e mesmas regras de direção/interrupção/ataques aparáveis. Foco (+1 ponto): +0,04 s de janela; Guarda (+1 ponto, exige Foco): +10% resistência e 20 de escudo concedidos uma vez na aquisição, sem regeneração. Não há contra-ataque obrigatório.

Todos os valores são provisórios editáveis, não progressão permanente aprovada. Custos/recompensas também são parâmetros. Um ponto por encontro concluído, uma única vez; duas vitórias permitem adquirir Q e F antes do último encontro. Compras não gastam páginas, não duplicam nem acumulam por reabrir. Aquisições e pontos sobrevivem ao retorno na mesma partida; nova partida começa limpa, sem save em disco.

## Interface e controles

F5 continua `scenes/playable.tscn`, nome `Atlas_Verdadeiro`, viewport 640×360 e janela do usuário preservados. Tab abre/fecha árvore/status; Esc também fecha a árvore. Mostra três ramos, requisitos/custos, parry base, pontos, atributos e recargas. Pausa simulação durante compras, captura Tab mesmo em botão focado e bloqueia ataques acidentais ao fechar. Q/F e botão esquerdo/direito não ativam habilidades enquanto pausado. HUD mostra disponibilidade, voo, duração de rastreio, recargas e pontos. WASD, mouse, E, M, Esc, Espaço, R e controles de revisão preservados.

## Organização conservadora

Entrada/componentes: `playable.tscn`, `player.tscn`, `atlas_visual_revisao.tscn`. `main.tscn`/`combat_arena.tscn` continuam consumidores de teste, preservados. Reservas F6 movidas para `scenes/review/`: `animation_lab.tscn`, `dagger_attack_review.tscn`, `monster_animation_lab.tscn`; ferramentas e referências estáticas atualizadas, sem recriar/apagar arte. `monster_visual.tscn` preservada como componente de revisão; combate usa o script. Nenhuma cena por atributo/habilidade: dados/scripts separados e uma interface coesa. Inventário em `scenes/README.md`. Organização não é prova de ganho de FPS.

## Validação e limites

Na cópia de trabalho: atributos 13, habilidades 30, UI/aquisição 24, movimento 67, combate 54, lâmina 1384, percurso 165 e monstros 1374, sem falhas. Partida com IA ativa: 4596 verificações, 5/5 e livro/final, 60 ataques, 14 parries, zero retornos, vida final 100, 100,67 s simulados. Percurso confirma recompensa única nas cinco hordas, morte/retorno, páginas e reinício. Habilidades incluem ida/volta, parede, retorno impossível/timeout, alvo removido, pausa, jogador móvel, morte e limpeza. UI cobre bloqueios/duplicação/saldo/estado limpo e parry inicial.

Renderização real OpenGL: seis capturas de HUD/árvore inicial/aquisição/status aprimorado/rastreio/voo/pausa em `docs/atlas/evidencias/12_module1/`. Falhas intermediárias de codificação e teste UTF-8 foram corrigidas; não foram escondidas reduzindo asserções. No sandbox ocorre erro de leitura dos certificados do Windows; a validação final no original elimina essa limitação. Aprovação artística/humana, áudio, sessão longa com teclado/mouse e exportação executável não são provados por testes headless. Fontes salvas não equivalem a “Salvar Tudo” das abas em memória do editor.

## Lag: medição, não hipótese de quantidade de cenas

Benchmark renderizado antes do módulo no original, Godot 4.7.2/Compatibility/RX6600XT, 1920×1080 e viewport 640×360, quatro monstros/IA/animações, 300 amostras após 60 de aquecimento. Frame mediana 6,947 ms, p95 7,231 ms; processo mediana 10,806 ms/p95 13,911 ms; física mediana 0,684 ms/p95 1,266 ms; 159,68 draw calls médios, memória estática 38,11 MiB. Carregamento do PackedScene 935,775 ms, ready 15,019 ms. Monitores são etapas distintas, não devem ser somados nem usados como promessa de FPS/latência humana. Cache de malha existente confirmado; atribuições repetidas de pose/material, redesenho de marcadores/HUD e raios da lâmina são pontos inspecionados, não causas demonstradas. Sem reescrever malha nem relaxar precisão da lâmina por suposição. Comparação final será registrada sob a mesma carga. Lag do editor/laboratório precisa de reprodução específica se não aparecer nessa carga; nove arquivos de cena não significam nove cenas rodando.

## Resultado final no projeto original

Importação e as nove suítes foram repetidas no original sem falhas: movimento 67, combate 54, lâmina 1384, percurso 165, partida ativa 4596, monstros 1374, atributos 13, habilidades 30, UI 24. Seis capturas renderizadas também repetidas no original. Nenhum arquivo de arte ou regras de páginas/livro foi refeito. Pontos, habilidades, recargas e efeitos são realmente consumidos pela partida, não apenas telas de demonstração.

Medição depois, mesma carga renderizada/resolução e 300 amostras: frame mediana 6,715 ms/p95 7,816 ms; processo mediana 13,939 ms/p95 14,448 ms; física mediana/p95 1,322 ms; draw calls médios 159,17, memória estática 38,93 MiB; load 1106,451 ms e ready 20,62 ms. Variação mista: não comprova otimização nem redução geral do lag. A carga curta não reproduziu travamento sustentado; carregamento de cerca de 1 s é mensurado, mas o lag do editor/laboratório continua sem reprodução específica. Não atribuímos causa ao número de `.tscn` e não sacrificamos a precisão da lâmina para reduzir custo. Os JSONs antes/depois e o script permitem repetir a comparação; não são benchmark universal ou teste humano.

Publicação incluirá fontes do módulo, testes e dependências anteriores indispensáveis (ataque da adaga, integração visual dos monstros e laboratórios). Esses componentes preexistentes não são apresentados como autoria nova desta etapa. Alterações anteriores de `README.md`, `project.godot` (janela do usuário), `scenes/main.tscn`, `assets/personagem/revisao/atlas_rascunho.tres`, planos gerais, imagens antigas e pacotes/ZIPs ficam fora da publicação, preservados no backup/árvore local. Nos resumos/checkpoint existentes, somente o novo registro do módulo será staged, preservando seções locais anteriores fora do commit. Não há merge/force-push. O SHA/resultados remotos serão registrados no checkpoint após a verificação do destino.

Validação adicional da publicação: árvore staged exportada em checkout isolado, importada do zero e nove suítes repetidas com as mesmas contagens e zero falhas. Isso confirma independência das alterações alheias deixadas fora do commit. Backup final: 1866 arquivos e manifesto SHA-256 verificado em `C:/Users/Arthur-Gamer/Documents/atlas/module1-backup-final-20261023`.

## Publicação confirmada

Implementação salva no commit `91d85e6f8213820009d2dd2fa72f1f8232768c3c`, enviada a `origin/codex/preparo-git`; SHA remoto conferido por `git ls-remote` em 23/10/2026 16:02:37 — America/Sao_Paulo (UTC−03:00). Sem force-push/merge. Este registro documental é posterior ao commit de implementação e não altera fontes de gameplay.

Para usar: F5 → vença encontros para obter pontos → Tab para adquirir → Q arremessa / F rastreia. Parry inicial no botão direito, Espaço esquiva. Reservas F6 em `scenes/review/`. Balanceamento/avaliação humana e reprodução específica do lag no editor permanecem abertos; não bloqueiam a integração entregue. Não houve exportação EXE nem alegação de “Salvar Tudo” do editor.
