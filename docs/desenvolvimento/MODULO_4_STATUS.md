# Módulo 4 — execução por fatias

Baseline confirmado: `4462421`, módulo3 encerrado nesta sessão e publicação registrada. Godot4.7.2, F5/playable, viewport640×360; arquivos posteriores e alterações alheias preservados. Backup inicial SHA256: `backups/modulo4/inicial`, 2415 arquivos, exclui caches/Git/segredos/backups/exports (inclusive Jogo_Godot2, somente executáveis). Não cobre memória não salva do editor. Consulta inicial:66% primária/95% semanal; após fase01:61%/94%, conta compartilhada, não previsão de consumo.

| Fase | Estado | Evidência / próximo passo |
|---|---|---|
|01 Contato/onda|validada|Falha reproduzida antes;544 casos atuais de contato e1384 da lâmina sem falhas; captura real17_contact_wave. Config40/52px e meia abertura0,85rad provisórias; base sem onda/gratuidade.|
|02 Árvore/HUD|validada|Cena própria instanciada,16 casos novos,UI24/habilidades24/módulo2 45/combate54 sem falhas; capturas640/1920; seguir03.|
|03 Reativação|validada|15 casos determinísticos, sem falhas; ondas reais de fixture, sem prêmio de progresso.|
|04 Comida/vingança|validada|44 novos casos,52 sobrevivência, zero falhas; fome independente, lotes, roubo/resgate e vingança.|
|05 Altar/final|validada|21 casos altar e41 suporte/livro; final manual, captura real de luz/destruição.|
|06 Revisão/preservação|validada|Cópia limpa/percurso5029, export30 e entrada normal; preservação/publicação ao fechar.|

## 01 — diagnóstico e implementação

Reprodução antes: alvo vivo na lâmina final,0,001s ativos e delta1/30; `advance_action` mudava para recuperação antes da verificação, vida50→50. Registro17_contact_before.json. Correção mantém intervalo ativo e fração de movimento até a transição; verifica poses intermediárias e trajetórias relativas alvo/metal, sem dano da preparação/recuperação. `strike_targets` direto permanece contato instantâneo. Alvos removidos não ficam retidos no histórico. Geometria da onda compartilhada entre desenho/dano, só níveis1/2; cada alvo recebe um dano por golpe mesmo com metal+onda. Parede/pausa/morte/feedback/adaga ausente bloqueiam. Testes oito direções/deltas1/120,1/60,1/30,0,1s, tangência/fora/costas, alvo móvel, parede/cancelamento; captura é fixture/debug, não arte final. Tolerância numérica de0,0001px na tangência da onda, sem inflar hurtbox dos monstros.

## 02 — catálogo, cena e HUD

Ramos throw/reach/parry. reach.first/second substituem tracking.unlock/stride; sem rastreio, F, consultas ou bônus de dash. Arquivo de tracker legado neutralizado preservando path/UID. Dash30,4px/0,16s permanece. Compras guardam custo real; retirada de IDs legados apaga bônus e reembolsa apenas ledger comprovado, uma vez (sem save de campanha/migração fictícia). Onda40/52px do recurso da fase01 é lida pelo atributo comprado.

`scenes/ui/skill_tree.tscn` é a única cena da árvore; mesmo personagem/coordenador. Nó selecionável mostra detalhes/requisito/custo; compra separada e estado textual. Atributos em seção própria. Vida/fome no canto inferior esquerdo, barras retangulares iniciais6/5px (substituídas pelo refinamento abaixo), labels separados; corrigido tamanho mínimo de tema detectado na inspeção. Capturas640×360/1920×1080 mantêmviewport640. Recursos/valores reais, apenas pontos de fixture para comprar; avaliação humana da legibilidade pendente.

## 03 — visitas e hordas repetidas

`revisits.gd` mantém entrada/visita/RNG por partida;10% uma vez por entrada até100px, saída140px provisórias em resources/revisits.tres. Vitória dentro da área marca visita ocupada; não vira nova entrada. Pausa/final/morte/NPC caído/horda ativa impedem nova rolagem. NPC segue caminho físico ao centro, aguarda e é liberado ao terminar/morrer/retornar. Horda usa ondas/perfis existentes; callbacks de progresso só para original. Drops normais por mortes reais são escolha provisória, sem pontos/folha extra.15 casos: limite RNG10%, histerese, ausência de rerrolagem, movimento sem salto, três ondas, recompensa única, pausa, queda e cancelamento. Fixture explícita injeta primeira conclusão e RNG, não finge vitória humana.

## 04 — comida e vingança

Fome própria do NPC:0,05/s ativo/vivo, +35 por porção recebida, configurável e provisório, sem morte por fome. Lotes de porções assadas congelados na primeira tentativa de consumir, não a cada abertura/cocção. Reserva ceil(lote/2) para2+, satisfeita por partilhas; parte quitada continua do jogador até acabar. Novas porções formam lote posterior. NPC cheio libera reservas/riscos; cota não consome com NPC caído. Uma porção originalmente avulsa tem20% de roubo por transação válida: dá só fome ao NPC, sem cura, comida do jogador ou bônus0,2. Compartilhar/resgatar mantém benefícios anteriores. Ledger/IDs impedem duplicação.

Com caído e carne no inventário, bloquear comer/dividir e orientar fogueira/resgate; cru não é refeição. Vingança usa um relógio: drop no viewport, descoberto, linha livre e caminho, sem carne já obtida, gera aviso/barra e5 de vida por10s. Débito explícito ignora parry/escudo/resistência, dispara morte normal; coleta suspende, resgate/sem acesso limpa, pausa congela.44 testes incluindo0/1/2/3/4, reserva parcial/nova, saciedade, limites20%, idempotência, fome/pausa/queda,9,9/10s, dois drops, parede/mapa/caminho/coleta.52 testes anteriores passaram com RNG de não roubo explícito para isolar seu contrato. Capturas17_revenge/17_camp_lot são fixtures identificadas, não aceites humanos.

## 05 — altar manual

Primeira conclusão original registra ID do layout e altar; reativações não alteram. Centro livre verificado por forma/linha/navegação, com candidatos seguros±24/48px na mesma clareira. Marcador/mínimapa só quando descoberto. Quinta página ou resgate não iniciam final. E perto/linha livre exige5/5, amigo vivo, jogador apto e sem encontro/inimigos atuais; mesma tecla não coleta/abre outro painel. Livro único é colocado no altar, atores/ameaças congelados e sequência folhear→luz→desaparecer preservada.

`altar.gd`: raio160px editável;12 rachaduras com2 segmentos e fragmentos limitados; props locais desvanecem somente durante transição confirmada. Física/solo não são removidos, sem morte cinematográfica/tremor obrigatório/som inexistente. Nova cena restaura mundo.21 casos verificam primeira vitória por evento na ordem2→0, requisitos/parede/E repetido/quinto item longe, proteção dos atores e limpeza.41 de suporte/livro preservam escudo/parry/resgate e agora exigem interação manual explícita. Captura17_altar_light é fixture com vitórias via dano de teste, não percurso humano.

## Refinamento posterior do HUD — incorporado antes do fechamento

Detectada alteração do usuário em `prompts/atlas/modulo4/02_ARVORE_E_HUD.md` apontando `REFINO_HUD_ARREDONDADO.md`; ambos preservados. Fases03–05 já salvas antes do refinamento. `vital_capsule.gd` substitui somente apresentação: cápsulas156×18, contorno/sombra, ícones próprios, coral/âmbar, sem painel quadrado opaco. Preenchimento é interseção do polígono arredondado com o percentual, inclusive1%/0%; não um retângulo vazando no canto. Valor/atributo real muda imediatamente, visual move até o alvo em≤0,2s, números sem atraso. Pulso curto em alteração significativa/entrada crítica, sem tremor ou flash contínuo de fome. Nenhum tween/sinal por frame; zero estável não pede redraw sem mudança. Pausa permite concluir a transição visual; morte resolve0, retorno faz snap50/25, nova sessão sem estado antigo. Sem opção de redução de efeitos existente ou shader novo.24 verificações UI/atributos, capturas0/1/50/100 e640/1920, sem falhas. Fixtures de valores claramente separadas do percurso real. Aceite artístico humano continua pendente.

Revisão de contato também isolou a fração ainda em preparação ao entrar no ativo;135 casos temporais/limites +409 verificações de extensão =544 checks atuais. Raios finais40/52px, ambos além do metal base (máximo37,055px entre oito direções/poses), provisórios. O primeiro passe34/46 dos checkpoints antigos foi ajustado antes da entrega para garantir ampliação em todas as vistas.

## 06 — integração, custo e entrega

Percurso normal final na cópia limpa (base3198866 + fontes desta execução):5029 verificações, zero falhas,5/5,47 ataques,10 arremessos,1 compra de alcance,11 parries,24 esquivas,0 retornos, vida100,1 partilha e amigo vivo,123,77s simulados. Caminha de volta ao altar e usa E real; sem teleporte, dano/vida/ondas/RNG manipulados. Execuções anteriores originais5153/5549 também passaram; variação de trajetória/combate não é mudança de asserção. Reativação/roubo/limites foram fixtures separadas.

Regressões relevantes: movimento67, combate54, lâmina1384, atributos13, UI24, habilidades24, módulo2 45, ataques79, telas/áreas24, percurso com fixtures166, áudio/configuração38, sobrevivência52, suporte/livro41; novos contato544, árvore16, visitas15, comida44 e altar21. Todos sem falha de asserção/script. Após o refinamento somente visual:24 de cápsulas na cópia limpa,16 de árvore/capturas e30 no template exportado, sem repetir toda regressão. ConfigFile corrompido é fixture com erro de parse esperado; algumas saídas aceleradas registram recursos/playback ainda referenciados ao fechar (já observado nos módulos anteriores). Execuções temporais/cópia limpa/exportação finais não acusaram erros de script; avisos não foram escondidos.

Carga gráfica equivalente (RX6600XT/OpenGL,1920×1080/viewport640,4 atacantes,5s aquecimento,1200 frames, sem FPS fixo), relatório17_perf_*.json: módulo3 mediana/p95/máximo6,947/7,195/34,624ms; módulo4 base6,954/7,688/59,240ms; módulo4 onda2 6,941/7,231/25,611ms. Máximos do intervalo dos callbacks de física0,749/0,974/0,858ms. Um frame acima16,67ms em cada condição, com cauda no intervalo de desenho/apresentação; causa dessa cauda não isolada, não atribuída automaticamente ao driver nem considerada lag resolvido. Precisão/tempo de combate mantidos. Refinamento posterior de cápsulas foi validado visualmente/por smoke; essas medições são anteriores a ele, não um benchmark novo desse acabamento.

Build Windows debug final em `builds/modulo4-20261025`, ZIP verificado por SHA256 de44328935 bytes; manifesto17_windows_build.json. Harness independente monta o PCK real sem gameplay alternativo:30 checks/0 falhas, incluindo ECFG válido, árvore/cápsulas/alcance comprados, regras de comida/revisita,4 ataques, áudio, movimento, preferências e limpeza; executável normal também abriu menu sem erro. Janela padrão do build versionado1280×720; original1920×1080 mantido, mesmoviewport640. Sem instalação/download de templates/release pública.

Backup inicial e final com SHA256 em `backups/modulo4/inicial` e `backups/modulo4/final`; checkpoints01–05 e refinamento preservados. Exclusões: Git/caches/backups/segredos/exports; Jogo_Godot2 continha só executáveis e PCK. Mudanças de outros autores, inclusive prompt02 atualizado durante a execução, preservadas e não absorvidas no commit. O backup não cobre memória não salva do editor.

Não há funcionalidade obrigatória restante do módulo4. Limites: números editáveis/provisórios, arte frontal dos ataques, avaliação artística/sonora e partida humana longa não realizadas, caudas ocasionais de apresentação não diagnosticadas. Próximo passo humano: F5/ZIP e revisão da legibilidade/ritmo; registrar defeitos concretos. Não abrir outro módulo automaticamente. Branchcodex/preparo-git, origin esperado; SHA/publicação final registrados em backups/modulo4/PUBLICACAO.json após conferir remoto.

Auditoria final também atualizou os dois renderizadores antigos de módulos1/2 para os IDs de alcance e retirou chamadas à API de rastreio removida; não foram geradas capturas redundantes desses laboratórios.
