# Módulo 3 — estado por fase

## Fechamento técnico do módulo 3 — 25/10/2026

Retomada autorizada para encerrar as pendências. Identificada e corrigida a recarga recorrente da arte da esfera: recursos compartilhados por `preload`, materiais individuais, sem mudar combate. Na carga gráfica equivalente de 1.200 frames, máximo 48,944→8,180 ms; frames >16,67 ms 5→0. Recorte dos passos ajustado para conter o pico real da fonte, sem modificar originais ou ganhos. Auditoria numérica dos oito áudios aprovada; áudio/configurações38, monstros79, suporte/livro40 e percurso real5897 sem falhas. Cópia limpa também validada. [Relatório e limites](MODULO_3_FECHAMENTO.md).

Escopo funcional do módulo encerrado tecnicamente. Aceite humano de áudio/arte e partida prolongada continua não realizado; números editáveis/frentes disponíveis não viram design final por inferência. Backup final anterior preservado; somente checkpoint incremental novo. Mudanças locais anteriores mantidas fora da seleção Git. Nenhum módulo seguinte.

**Saldo consultado nesta retomada:** 99% disponíveis na janela de 5 horas e 100% na semanal (conta, não tarefa); substitui o relato histórico de 7%. A ferramenta passou a estar disponível em 25/10.

Execução iniciada sobre `7d94c88`, branch preservada `codex/preparo-git`, Godot 4.7.2. Backup inicial SHA-256 de 2408 arquivos em `C:/Users/Arthur-Gamer/Documents/atlas/module3-backup-initial`; inclui alterações locais anteriores e mídia. Memória não salva do editor não coberta. Fetch sem divergências, índice vazio, identidade existente preservada. Saldo atual desconhecido, sem ferramenta real disponível; último relato 75%.

| Fase | Estado | Arquivos/evidência | Próximo passo |
|---|---|---|---|
| 01 Base/NPC | validada | Visual existente preservado; `verify_companion_visual` 1838 e `verify_module2` 45, zero falhas; duas capturas novas; inventário de oito MPEG via decoder Godot | avançar à fase 02 |
| 02 Áudio/configurações | validada | 8 MP3 importados, 36 verificações de áudio/configuração em tempo real, módulo 2 45 e percurso ativo 5839 sem falhas; 2 capturas/configuração de janela real | avançar à fase 03 |
| 03 Sobrevivência | validada | 52 verificações de sobrevivência, 45 do módulo 2, 74 de ataques; caminhada física à fogueira e 3 capturas | avançar à fase 04 |
| 04 Escudo/livro | validada | 40 verificações; 1838 visual, 54 combate, 165 percurso; partida real 5897 com resgate/alimento verdadeiro e final; duas capturas de sustentação | avançar à fase 05 |
| 05 Telas/áreas | validada | 23 verificações, 45 módulo 2, 165 percurso, 40 suporte/livro e partida real 5897; quatro capturas | avançar à fase 06 |
| 06 Validação/entrega | validada | 17 suítes aprovadas, original/índice limpo, build/PCK 23 e implementação publicada com SHA remoto confirmado | fechamento técnico de 25/10 documentado; aceite humano separado |

## Fase 01 — verificado nesta execução

Fontes/cópias com hashes preservados; grade 48×64, pivô 24/60 e escala 0,7 no componente vivo, corpo e projeção separados; clipes exportados 64×64 têm pivô próprio 32/52. Espera/caminhada já integradas; corrida/dano/escudo mantidos como API visual. Callbacks de ações emitidos uma vez, pausa herdada e acompanhamento físico cobertos pelos testes. Escudo de 1,12 s é apresentação, ainda sem proteção de 5 s. Revisão artística humana pendente. Não foi refeita a arte nem alterada navegação.

Oito fontes `.mpeg` tiveram duração e criação de playback verificadas com `AudioStreamMP3` do Godot; isso confirma MPEG Layer III decodificável, não importação pelo sufixo nem audição humana. Originais não renomeados/convertidos. Sem trilha musical fornecida. Os eventos abaixo são candidatos provisórios por nome, a confirmar no áudio integrado.

| Fonte em SONS/ | Duração (s) | Evento candidato |
|---|---:|---|
| `Andando _na_grama.mpeg` | 1.097 | passos na grama |
| `Ataque_toupeira.mpeg` | 3.024 | Escavador (candidato pelo nome) |
| `Folha_do_livro_conquista.mpeg` | 9.816 | coleta/página (trecho longo a ajustar) |
| `Monstro_de_garras.mpeg` | 3.024 | Fenda (candidato pelo nome) |
| `Mosntro_de_terra_superfície.mpeg` | 3.024 | Carcaça (candidato pelo nome) |
| `Parry.mp3.mpeg` | 1.698 | parry confirmado |
| `Som_da_espada.mp3.mpeg` | 2.194 | adaga/ataque |
| `Som_do_tiro_venenoso_da_aranha.mpeg` | 1.176 | Esporo/esfera (candidato pelo nome) |

## Fase 02 — áudio e preferências

Oito cópias binariamente idênticas, sem recompressão, em `assets/audio/`; mapeamento/hashes em `sources.json`. Passos usam deslocamento real e terminam em repouso/pausa; adaga na fase ativa, parry só bem-sucedido e página só coletada. Fenda no corte, Esporo no lançamento, Escavador com aviso/impacto distintos. Mapeamentos provisórios pelos recursos fornecidos; não há som da Carcaça/trilha/UI/fogueira inventado. Aviso anterior encerra no impacto; uma voz por emissor/evento e máximo oito, ganhos provisórios por evento. Vozes presas à sessão/emissor, encerradas na morte e remoção, congeladas em pausa; sem loop de música. Audição e mixagem humanas pendentes: este ambiente validou decodificação/playback e renderização, sem alegar escuta.

`session_settings.gd` cria buses Master/Effects/Music, volumes/mute, arquivo `user://atlas_settings.cfg` só de preferências e restauração de padrões. Inicialização sem arquivo não altera janela personalizada. Janela/tela cheia e escala inteira 1–4 disponíveis; viewport 640×360 preservado. Arquivo corrompido, números fora da faixa/não finitos, falha de gravação e ausência de dispositivo têm fallback/erro visível. Não é save da campanha. Configurações usam o mesmo coordenador, com retorno ao menu/pausa sem liberar simulação por baixo. Teclado/foco/Esc cobertos.

Teste novo `verify_module3_audio_settings.gd`: 36 verificações sem falhas em tempo real, sem objetos retidos ao encerrar. A fixture de ConfigFile corrompido gera erro de parse esperado do engine antes do fallback verificado. Testes acelerados de áudio mostraram avisos de playback na finalização que não aparecem na execução em tempo real; não foram omitidos dos logs nem tratados como prova de falha de navegação. Ajustada fixture de teclas para eventos independentes e flush, evitando reuso inseguro no mesmo frame. Regressões desta fase: módulo 2 45 e partida ativa 5839 sem falhas, mesmas regras de vida/dano/ondas. Renderização real confirmou troca de escala/tela cheia e gerou `15_menu_settings.png`/`15_pause_settings.png`. Nenhum áudio regenerado ou original renomeado.

## Fase 03 — sobrevivência, refeição e amigo

`resources/survival.tres` controla números provisórios: chance 7,5% limitada à faixa aprovada 5–10%, fome 0,08/s, refeição +35 de fome/+25 de vida; partilha dá metade desses benefícios ao jogador e +30 de vida ao amigo. Reanimação dá 50 de vida e conta uma única vez como partilha/+0,2 s. Zero fome fica em zero, sem dano ou outra penalidade oculta. Fome só avança em simulação ativa/viva e antes do final. HUD tem barra e quantidades/vida do amigo. Sem fome própria, árvore ou ofensiva do acompanhante.

Estado exclusivo da partida em `survival_state.gd`: quatro mortes válidas consecutivas sem drop garantem a próxima; sucesso sempre zera. Mortes e transações idempotentes; despawn não conta. Carne crua só ingrediente e coleta E por alcance/linha de visão. Fogueiras configuradas no layout em (280,300)/(280,740), acessíveis por corredores. Assar é imediato/atômico, escolha provisória que evita timer travado no painel pausado. Uma porção por comer/dividir/reanimar; callbacks antigos são rejeitados por geração e transação. Dividir com vivo exige proximidade; reanimar permite resgate remoto do amigo caído a ponto da fogueira fisicamente livre, sem exigir caminhada dele. Sem carne, UI informa limitação e permite sair/pausar/reiniciar sem recurso gratuito.

NPC agora tem atributos/vida independentes e recebe cortes, pancada, esfera e impacto do Escavador por geometria/oclusão reais, um contato por ataque/alvo e graça provisória de 0,35 s. Não entra em grupo de alvos da adaga/rastreio nem ganha `take_damage`; inimigos continuam perseguindo o jogador. Zero vida mantém ator caído escurecido/marcado, sem seguir, conversar ou recuperar gratuitamente no retorno. Carne assada é o resgate. Contador, comida/ingredientes, drops e bônus permanecem no retorno; nova sessão limpa tudo. Configuração base não guarda estado mutável.

Teste `verify_module3_survival.gd`: 52 verificações sem falhas, incluindo RNG nos limites, garantia/reset, morte duplicada/despawn, pickup distante/repetido, assar/consumir, partilha, queda/resgate, fome ativa/pausa/zero/morte/retorno e nova sessão. Caminhada até a primeira fogueira usa controles e colisão reais; mortes/posição/dano e ingrediente extra para resgate são fixtures explicitamente identificadas, não uma horda vencida pelo jogador. Regresso de módulo 2 45 e ataques 74 sem falhas. Execução temporal da versão de 49 casos sem avisos de playback; os três novos casos passaram em execução acelerada. Três capturas reais com inventário/dano de fixture (`15_camp_*.png`). A condição nova do livro e proteção ainda não estão implementadas nesta fase: seguir fase 04.

## Fase 04 — suporte frontal e livro

`companion_support.gd` mantém estado separado, com geometria em `resources/companion_support.tres`: amigo em até 72 px e linha de visão, arco frontal de 120° centrado no jogador, raio visual 18 px. Direção fica travada para o impacto que ativou a proteção; a origem consultada nos golpes é sempre a do impacto/projétil atual, não a posição remota do lançador. Área centrada exatamente no corpo não presume incidência frontal. Indicador turquesa no jogador corresponde ao arco; NPC usa o corpo já existente e FX separados. Valores geométricos são provisórios, validados como finitos.

Após dano válido processado deixar jogador vivo <25%, ativa 5 s + 0,2 por partilha, sem reduzir o golpe disparador nem ressuscitar. 25% exatos não ativa; cura ≥25% rearma, sem novo escudo enquanto ativo. Duração é resolvida na ativação e não cresce com partilha posterior. Sem teto oculto para bônus; estado por partida. NPC caído cancela, distância/parede impedem efeito global, pausa congela tempo. Pipeline: pausa/invulnerabilidade/parry → redução frontal 50% (ceil) → resistência (ceil) → reserva comprada → vida. Não reflete nem reduz duas vezes. Parry bem-sucedido coberto usa `stagger(0.5)` no inimigo atingido, inclusive emissor da esfera; fora do suporte fica a duração base 0,85 s. Tentativa sem sucesso não atordoa. Três ramos preservados.

Visual ganhou sustentação por API: preparação/abertura uma vez, hold além de 1,12 s e recolhimento uma vez; zero clones/armas extras. Dano do NPC pode reagir com corpo/FX separados; queda limpa sustentação. Barra de fome recebeu estilo plano para respeitar 5 px em vez da altura mínima do tema. Avaliação artística humana segue pendente.

Livro agora revalida 5/5 + amigo vivo ao iniciar. Quinta página permanece quando ele está caído; fogueira/resgate permite retomar automaticamente ao fechar o painel, sem recolher página/horda. Sem comida restante, informa opção real de reinício via pausa/menu. Transição válida congela jogador/NPC e cancela inimigos/projéteis antes do livro, impedindo dano incoerente durante a sequência. Ordem folhear/luz/desaparecer preservada.

`verify_module3_support_book.gd`: 40 casos sem falhas (limiares, golpe letal/ignorado/pausado, frente/trás/lado/área, parede/distância, pipeline, rearme, bônus/duração, parry, sustentar/recolher, NPC caído, 4/5 vivo, 5/5 caído, resgate e final único canônico). Visual existente 1838 e combate 54 sem falhas. Percurso 165 passou após corrigir expectativa antiga de fome: retorno dá exatamente 25%, mas os dois ticks seguintes já consomem a taxa ativa; teste limita a diferença a esses ticks, sem alterar a regra do retorno.

Robô real passou 5897 verificações, 5/5, 45 ataques, 13 arremessos, 7 rastreios, 13 parries, 35 esquivas, zero retornos, vida final 93 e 124,2 s simulados. Coleta um drop verdadeiro, caminha pela grade com colisão até a fogueira e usa os botões de assar/resgatar antes do livro. Cura final de +13 vem da porção partilhada real, não de override de teste. Corrigida sondagem do robô para não ultrapassar o próximo waypoint ao antecipar colisão; sem alterar navmesh/mundo/colisores. Nenhuma vida/dano/onda congelada para passar. Prints seguintes registrarão também partilhas e amigo vivo. `15_support_hold_after_two_seconds.png` e `15_support_retracted.png` mostram execução real com fixture de gatilho por dano, não aprovação artística.

## Fase 05 — composição e áreas

Esboço adotado: ATLAS com enquadramento próprio, fita vermelha curta e linha turquesa; ilha simbólica nas laterais, cinco marcas de página e ações centrais com respiro. `atlas_menu_art.gd` desenha a composição em primitivas e usa sprites reais existentes somente como retratos, sem criar outro ator físico. Fundo não reutiliza o contorno/caminhos do mundo real nem revela regiões no mapa. Fim adapta título, cinco marcas preenchidas, livro ausente (partículas discretas) e dupla viva, com Nova partida/Menu/Sair reais. Sem ranks ou estatísticas inventadas, trilha inexistente ou imagens geradas/copiadas.

Referências de jogos são as indicadas pelo usuário; não foram consultadas screenshots de Deadzone Rogue, Everything is a Crab, Hades, Dead Cells ou Sonic nesta execução. A inspiração utilizada é a orientação fornecida de hierarquia/composição e ações centrais, sem alegar reprodução de tela específica. A composição implementada é original/provisória de ATLAS; avaliação humana artística ainda pendente.

`session_ui.gd` continua único dono de painéis. Final confirmado para a simulação, limpa SFX e permite Enter no botão focado/Nova partida e Esc para tela inicial; foco de Configurações funciona por teclado sem iniciar partida por baixo. Créditos têm painel próprio com retorno; botão somente quando atribuições reais forem fornecidas. Captura `15_atlas_credits_fixture.png` é fixture explícita, não crédito/autoria publicados como reais. No teste de Enter, aguardamos também soltar a tecla e a recarga diferida da cena, conforme botão nativo. Corrigido acesso ao viewport após a remoção síncrona da cena no Esc final.

Cinco vínculos de página por ID em `route_layout.gd → page_area_ids`: roots/raízes, ruins/ruínas, lookout/mirante, grove/bosque e archive/arquivo, na ordem das cinco páginas. Wreck/destroços e shelter/abrigo permanecem auxiliares, com fogueiras/retorno. Validação garante cinco IDs de área existentes/únicos e centros correspondentes; início do encontro usa essa associação. Removida exigência técnica de exatamente sete regiões: listas devem estar alinhadas, e HUD/log/câmera/navegação/mapa usam o layout. Teste de percurso verifica regiões originais sem proibir regiões extras.

Para ampliar: ajuste `world_size`, regiões (ID/nome/limite/cor), conexões/barreiras/água/cenário e posições no mesmo recurso; mantenha IDs de encontro/página e cinco `page_area_ids`. Não há decoração procedural nova. Fixture não destrutiva de oitava região (mundo 2560×960 e conexão de teste) comprovou validação, câmera, caminho físico na grade e descoberta local, mantendo cinco páginas; nada foi salvo como biome/ilha canônica extra.

`verify_module3_screens_areas.gd`: 23 verificações sem falhas (mouse/foco/Enter/Esc, nenhum ataque acidental, limpeza/um NPC, final, créditos condicionais e expansão). Módulo 2 45, percurso 165 e suporte/livro 40 sem falhas. Quatro capturas `15_atlas_*.png` inspecionadas: título, configurações, créditos de fixture e final de fixture, sem cortes. Percurso real após alterações: 5897 verificações, 5/5, uma partilha, amigo vivo, vida 93, Q/F usados, 124,2 s simulados, nenhuma falha/erro de script. Não foi alterada precisão, vida/dano base ou colisão para passar.

## Fase 06 — resultados antes da publicação

Regressão completa nesta execução na cópia: 17 suítes sem falhas de asserção/script — movimento 67, combate 54, lâmina 1384, percurso 165, partida ativa 5897, animações de monstros 1374, recursos de ataques 469, mecânicas de monstros 74, visual NPC 1838, atributos 13, habilidades 30, UI 24, módulo 2 45, áudio/configuração 38, sobrevivência 52, suporte/livro 40 e telas/áreas 24. Quatro suítes novas também executadas sem FPS fixo, sem objetos retidos ao encerrar. Arquivo de preferências corrompido é fixture esperada (erro de parse do ConfigFile antes do fallback verificado). Logs acelerados anteriores registram avisos de playback ao finalizar antes de o backend de áudio esvaziar; execução temporal de áudio e teste exportado não reproduziram esse aviso. Sandbox Windows também emite erro de leitura do repositório de certificados, sem uso de rede pelo jogo; classificado como ambiente, não erro de script.

### Física e frames

Investigação pelo código exato do engine `ed1daf0bf`: `main/main.cpp` acumula máximos de processo/física e publica aproximadamente uma vez por segundo (linhas 4679–4680 e 4743–4762). Portanto mediana/p95 de 300 consultas ao monitor são percentis de máximos retidos, não mediana/p95 de cada tick. Isso explica a aparente incompatibilidade dos ~37 ms com frames tipicamente de ~7 ms; não prova ausência de picos. Fonte primária: https://raw.githubusercontent.com/godotengine/godot/ed1daf0bf/main/main.cpp . O novo `measure_module3.gd` nomeia corretamente esses campos e também mede máximo/contagem de frames lentos. Números antigos do módulo 2 ficam preservados como medições históricas com essa correção de interpretação.

Comparação sequencial gráfica, RX6600XT/OpenGL, 1920×1080/viewport640×360, quatro ataques preparados, aquecimento 5 s e 300 amostras, sem FPS fixo: módulo 2 publicado (cópia limpa de verificação, não backup) frame mediana/p95/máx 6,942/7,239/43,496 ms; uma amostra >16,67 ms, monitor de máximos de física mediana/p95 36,553/36,866 ms; ready40,196 ms, memória40,226 MiB, desenhos162,78. Módulo 3 frame 6,948/7,226/43,328 ms, uma amostra >16,67 ms; monitor de máximos de física36,437/37,154 ms, ready31,355 ms, memória42,205 MiB, desenhos169,77. Carga inicial antes3243,282 ms/depois1135,275 ms, com cache frio não controlado: não atribuir essa diferença a otimização. Sem ganho geral de lag demonstrado. Picos raros foram reproduzidos; causa específica ainda não isolada e requer profiler humano/dirigido posterior. Sem sacrificar lâmina, fome, dano/queda do amigo ou gate final.

### Windows local

Templates reais 4.7.2 encontrados. Build **debug local**, não release pública, em `C:/Users/Arthur-Gamer/Documents/atlas/module3-build/`: ATLAS.exe + ATLAS.pck (console opcional). ZIP verificado por SHA-256 em `C:/Users/Arthur-Gamer/Documents/atlas/ATLAS_Modulo3_Windows_debug.zip`; manifesto `15_windows_build.json`. Preset original com mudanças anteriores foi preservado: comando passou saída isolada explicitamente; sem instalar templates ou baixar ferramentas.

Revisão detectou esfera carregando PNG em `referencias/`, excluída pelo preset. Corrigido com cópia byte a byte em `assets/monstros/ataques_v1/spore_orb_source.png` e referência de runtime ajustada, sem regenerar arte, modificar fonte ou relaxar export filter. `sources`/hash auxiliar registram procedência.

Teste separado do editor: template Windows não aceita override CLI `--script`; a primeira tentativa abriu o menu normal e foi encerrada apenas em sua própria instância. Não foi contada como aprovação de smoke. Criado harness exportado mínimo **sem recursos/scripts de gameplay como fallback**, que monta o PCK real do ATLAS; 23 verificações sem falhas, `OS.has_feature("editor")==false`, movimento, oito MP3 decodificados/playback avançando, quatro perfis de ataque, esfera com textura real, configurações persistindo separadas da campanha e um NPC/áudio após recarga. Harness fica fora do ZIP entregue; ferramentas para reproduzir: `prepare_export_smoke.py` + `verify_export_runtime.gd`. Perfil de usuário isolado confirmado no log.

Ao preparar o build, foi comprovada atribuição real do engine. A lista de créditos agora contém somente Godot Engine contributors/MIT e link oficial; não inventa autores/licenças de arte ou áudio. Mesmo painel já implementado, apenas dados reais acrescentados. Fonte consultada: https://docs.godotengine.org/en/stable/about/complying_with_licenses.html . `GODOT_NOTICES.txt` no ZIP foi extraído do binário via API Engine, incluindo avisos de terceiros do engine; não atribui licença aos assets do jogo. Título/configurações/créditos reais/final foram renderizados novamente, `15_atlas_credits.png` é crédito real do engine; o arquivo anterior com sufixo fixture continua explicitamente teste.

### Limites e próxima ação

Audição/mixagem humanas, revisão artística prolongada, ataques apenas frontais, números de comida/geometria e diagnóstico da causa dos picos continuam provisórios/pendentes, sem alegar aprovação artística ou lag resolvido. Não há música nova, save de campanha, módulo 4 ou release pública. Fontes no disco não equivalem a Salvar Tudo de abas em memória. Último saldo relatado75%; atual desconhecido, sem ferramenta real de cota. Checkpoints por fase, sem estimar uso a partir de tokens.

Próxima ação desta fase: aplicar ajuste final com hashes no original, revisar o índice/segredos e dependências em cópia limpa, backup final verificado, commit/push autorizado sem force/merge, confirmar SHA remoto e encerrar. Nenhuma nova feature.

### Conferência do original e da publicação

No original foram repetidos os contratos principais e as dependências: áudio/configurações, sobrevivência52, suporte40, telas/áreas24, visual1838 e partida real5897, todos sem falhas de asserção/script. Árvore selecionada do Git foi exportada sem as alterações locais alheias, extraída em `C:/Users/Arthur-Gamer/Documents/atlas/module3-staged-check`, importada do zero e esses seis verificadores novamente passaram, incluindo partida real com uma partilha/amigo vivo. Isso prova independência das mudanças deixadas locais de projeto/janela, export preset, metadados de main.tscn e rascunho do personagem.

A suíte de áudio final foi reforçada para38 verificações: caminhada real emite passos e parar os encerra, e a pausa verifica também `stream_paused` nativo. Espera três ticks para iniciar o playback antes de pausar, porque AudioStreamPlayer2D agenda play no próximo tick; testar um playback ainda não registrado como se estivesse iniciado era fixture incorreta, corrigida sem alterar o runtime. A fonte da engine confirma essa distinção. Não foi mascarado som vazando nem criada mudança de produto para passar o teste.

Diferenças staged foram revisadas e verificadas com `git diff --cached --check` e busca de padrões de segredo. Entram somente código/testes/recursos do módulo e dependências necessárias previamente fornecidas do NPC/SONS/contrato; não são apresentadas como arte nova de autoria desta execução. README geral, rascunho, janela/viewport do usuário, export_presets, main.tscn e planos anteriores permanecem locais e preservados. No estado/decisões/histórico/checkpoint existentes, somente o novo bloco desta tarefa é selecionado. Backup final e SHA remoto serão confirmados no fechamento.

Backup final concluído e conferido por SHA-256: **2574 arquivos** em `C:/Users/Arthur-Gamer/Documents/atlas/module3-backup-final`, incluindo alterações locais anteriores e originais. ZIP Windows também verificado por hashes próprios. Implementação publicada; este checkpoint registra o encerramento emergencial.

## Emergência e publicação confirmada — 7% informados

Implementação no commit `d2628328501d2dccaa63d9e0d077a7caaf6b32b1`, enviada e confirmada em `origin/codex/preparo-git` em 2026-10-23T22:37:54-03:00. Autenticação funcional; sem force-push/merge. Usuário informou **7% restantes** e solicitou emergência: nenhuma feature, refatoração ou suíte longa iniciada após esse aviso. Backup final já verificado de2574 arquivos em `C:/Users/Arthur-Gamer/Documents/atlas/module3-backup-final` preservado sem refazer ou alterar; novo checkpoint incremental em `module3-checkpoints/07-emergency-7-percent`. ZIP Windows verificado em `C:/Users/Arthur-Gamer/Documents/atlas/ATLAS_Modulo3_Windows_debug.zip`. Fontes estão no disco; não se alega Salvar Tudo de memória do editor. Pendências: audição/mixagem, revisão artística/humana e causa dos picos raros de frame; ataques frontais e números provisórios permanecem registrados. Próxima ação: avaliação humana pelo F5/ZIP e definição de ajustes; não iniciar módulo4 automaticamente. Execução encerrada após publicar este checkpoint.
