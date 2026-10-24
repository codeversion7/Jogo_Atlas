# Fase 02 — efeitos sonoros e configurações

Aplique `INICIAR.md`; consuma o inventário da fase 01.

## Integração de mídia

Confirme codec/decodificação real dos oito arquivos em `SONS/`. Se forem comprovadamente bitstreams MP3 válidos, crie cópias de runtime com extensão adequada em `assets/audio/`, preservando originais; não recomprimir sem necessidade. Se formato diferente, converter de verdade com ferramenta disponível e autorização necessária, ou registrar bloqueio específico. Não presumir ffmpeg no PATH nem que renomear converte formato. Validar importação e decodificação no Godot, ouvir quando houver recurso disponível e não alegar audição por leitura de cabeçalho.

Mapa candidato baseado nos nomes, a confirmar pelo conteúdo: grama→passo; espada→ataque da adaga; parry→parry bem-sucedido; página→obtenção; garras→Fenda; tiro venenoso→Esporo; toupeira/terra→ações do Escavador, verificando distinção. Não inventar som da Carcaça, fogueira, UI ou trilha; ausência fica pendente, reutilização só se adequada e identificada. Nomes não provam evento/duração do arquivo.

Ligação por eventos e fases reais do ataque, sem reproduzir áudio a cada frame ou várias vezes pelo mesmo contato. Passos seguem movimento/contato e param ao ficar imóvel/pausar. Limite vozes, ajuste ganho e posicionalidade, preserve avisos do combate. Sons não vazam por morte, reinício ou mudança de tela; SFX e música não se duplicam. Não gerar/comprar música por inferência.

## Configurações

Use mixer com volumes Master/Efeitos/Música e mute; canal Música pode ficar preparado sem trilha inexistente. Interface usa o coordenador `session_ui.gd`, sem outro dono de pausa/foco. Configurações acessíveis pelo menu e pausa, valores persistidos em `user://` por mecanismo nativo apropriado. Salvar configurações não salva campanha.

Inclua modo de janela/tela cheia e escala/legibilidade compatíveis com viewport pixel art; preserve padrão atual e ofereça restaurar padrões. Não sobrescrever janela personalizada ao iniciar por rotina. Remapeamento completo de controles é opcional posterior, não requisito para esta fase. Tratar arquivo ausente/corrompido, volume inválido, dispositivo indisponível e saída sem esconder erro.

## Aceite

- Recursos reais importados e todos os caminhos existentes; nenhuma referência para som ausente.
- Evento repetido não multiplica sons; pausa/reinício/cena liberam vozes corretamente.
- Ajuste/mute têm efeito e persistem ao reabrir; falha de arquivo usa padrão seguro.
- Teclado/foco/Esc funcionam sem despausar jogo atrás de painel nem atacar ao clicar.
- Teste funcional e escuta real separados. Registre os arquivos/eventos e mixagem ainda pendente de ouvido humano.
