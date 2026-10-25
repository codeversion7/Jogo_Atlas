# Módulo 3 — fechamento técnico de 25/10/2026

Retomada solicitada pelo responsável após preservação emergencial. Godot real 4.7.2 `ed1daf0bf`, OpenGL/RX 6600 XT, viewport 640×360. Nenhum módulo seguinte, nova arte, alteração de dano/vida/cadência ou regra de sobrevivência foi acrescentado. Backup final de 23/10 preservado intacto; checkpoint incremental em `backups/modulo3-fechamento-20261025/`.

## Pendências técnicas encerradas

**Picos de frame:** `monster_orb.gd` carregava textura e shader em `_ready()`; após destruir a esfera, esses recursos podiam deixar o cache e ser carregados outra vez no lançamento seguinte. A mesma carga de quatro atacantes foi medida com 5 s de aquecimento e 1.200 frames, sem FPS fixo, janela 1920×1080. A retenção externa dos dois recursos isolou o problema; a correção final usa dois `preload` compartilhados. AtlasTexture, Sprite2D e ShaderMaterial continuam individuais. Não mudou raio, colisão, dano, parry ou desenho da esfera. Cache por referência segue o contrato de ResourceLoader: https://docs.godotengine.org/en/stable/classes/class_resourceloader.html .

| Condição | Frame mediano / p95 / máximo (ms) | Frames >16,67 ms | Maior intervalo de callbacks de física (ms) |
|---|---|---:|---:|
| Repouso | 6,960 / 7,857 / 13,751 | 0 | 0,495 |
| Combate antes | 6,965 / 7,928 / 48,944 | 5 | 40,765 |
| Combate com áudio Dummy | 6,970 / 7,855 / 53,393 | 5 | 45,642 |
| Controle: recursos retidos externamente | 6,952 / 7,555 / 7,919 | 0 | 0,683 |
| Código corrigido, áudio WASAPI | 6,942 / 7,556 / 8,180 | 0 | 0,670 |

Evidências brutas `16_profile_*.json`, resumo/hash `16_perf_summary.json`; reprodução `--path . --script res://tools/profile_module3_tail.gd -- --after`. O teste usa fixture explícita de quatro monstros, invulnerabilidade e bloqueio de final para manter a carga, não uma partida vencida. O intervalo medido é de `physics_frame` ao último nó de prioridade, não um profiler por função. O resultado encerra a causa reproduzida; não promete ausência universal de travamentos, nem mede outras GPUs/resoluções ou uma sessão longa. Não somar esses intervalos a monitores de máximos retidos da engine.

**Recorte dos passos:** a fonte de grama tem pico principal em 0,2–0,4 s. O trecho anterior 0–0,22 s perdia esse pico. Agora a voz começa em 0,16 s e dura até 0,24 s de simulação; conserva intervalo de 0,32 s, ganho -17 dB, parada por imobilidade/pausa e máximo de oito vozes. Original binário intacto, sem recompressão. `audit_module3_audio.gd` decodifica as oito fontes inteiras via `AudioStreamPlayback.mix_audio`, mede finitude/pico/RMS/janelas de 100 ms e verifica que o recorte contém o passo, tolerando apenas um frame de arredondamento da duração MP3. Relatório `16_audio_audit.json`: oito fontes válidas, zero falhas. O MP3 da adaga chega a 1,016 antes de atenuação; seu pico com ganhos padrão fica em ~0,180. Isso não é aprovação de timbre/mixagem, nem prova contra clipping de qualquer soma de vozes/volumes. Ganhos permanecem editáveis/provisórios.

## Validação da retomada

- Mecânicas de monstros: **79 verificações, zero falhas**; cinco novas cobrem emissões sucessivas reutilizando textura/shader depois da destruição anterior, com material individual.
- Proteção/livro: **40 verificações, zero falhas**.
- Áudio/configurações: **38 verificações, zero falhas**, em tempo real, também na cópia limpa atualizada.
- Percurso real no original e na cópia limpa: **5.897 verificações, zero falhas**, 5/5 páginas, 45 ataques, 13 arremessos, 7 rastreios, 13 parries, 35 esquivas, uma partilha, amigo vivo, zero retornos, vida final 93. Regras e IA reais; 124,2 s simulados.
- A cópia limpa parte de `77553f7`, acrescentando somente fontes/testes desta tarefa. Não depende de rascunho, preset, alterações de editor nem `Jogo_Godot2/` do usuário. As 17 suítes anteriores permanecem registradas como execução de 23/10; não foram apresentadas como repetidas agora.
- Inspeção visual das capturas reais existentes de título/configurações/sustentação: textos visíveis, botões íntegros, um corpo do acompanhante e arco frontal. É inspeção do agente; não é aceite artístico humano.

A fixture de ConfigFile corrompido emite o erro de parse esperado antes do fallback testado. Encerramentos acelerados de monstros/percurso e o controle Dummy podem emitir avisos de playback/recursos ainda referenciados; a execução verbose de 79 casos não os reproduziu. Não foram ocultados ou classificados como falha de asserção. A tentativa inicial dentro do sandbox impediu a gravação temporária de `project.binary`: esse pacote foi recusado e refeito com a execução autorizada fora do sandbox, sem download. O harness também ganhou include/exclude explícitos para evitar avisos de preset incompleto. Nenhuma proteção de gravação/antivírus foi desabilitada.

## Entrega Windows e preservação

Build debug local atualizado em `builds/modulo3-fechamento-20261025/ATLAS.exe`; PCK ao lado. [ZIP Windows](../../builds/ATLAS_Modulo3_Fechamento_20261025_Windows_debug.zip), **44.313.686 bytes**, com SHA-256 de cada arquivo verificado após compactar. Manifesto versionado `docs/atlas/evidencias/16_windows_build.json`. O ZIP anterior e o backup final de 2.574 arquivos em `C:/Users/Arthur-Gamer/Documents/atlas/module3-backup-final` foram preservados, sem recriar ou sobrescrever.

Exportação final sem erros de gravação/script. Harness independente montou o PCK real, sem fontes de gameplay alternativas: **25 verificações, zero falhas**, incluindo cabeçalho ECFG do projeto, áudio/movimento, quatro perfis de monstros, persistência somente de preferências e retenção da arte após liberar esfera. Execução direta de `ATLAS.console.exe --quit-after 90` abriu o menu real sem erros. Perfil de usuário isolado dentro do checkpoint, sem alterar preferências pessoais. Build usa configuração versionada com janela inicial1280×720; janela local1920×1080 do projeto original permanece preservada. Não é release pública.

O checkpoint incremental `backups/modulo3-fechamento-20261025/final/` guarda os arquivos desta tarefa com manifesto; os logs/cópia de validação ficam ao lado. O backup anterior não foi tratado como memória salva do editor. Commit/push seguem a branch existente `codex/preparo-git`, origin `https://github.com/codeversion7/Jogo_Atlas.git`, sem force/merge; SHA final será conferido no remoto ao encerrar.

## Aceite e fronteiras

Não resta funcionalidade obrigatória deste módulo por implementar. Valores provisórios configuráveis e ataques corporais frontais são limites conhecidos, não autorização para produzir arte direcional nova ou rebalancear arbitrariamente. Aprovação humana de timbre/volume, qualidade artística e partida prolongada permanece **não realizada** e não pode ser assinada pelo agente. Sem trilha fornecida, save de campanha, release pública ou módulo 4.

Próxima ação humana: abrir o projeto original, F5 (`scenes/playable.tscn`), jogar e escutar; registrar defeitos concretos se houver. Configurações somente em `user://atlas_settings.cfg`. Preservar as mudanças locais anteriores fora do commit desta tarefa.
