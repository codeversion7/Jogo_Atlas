# ATLAS — uso do módulo 3

F5 abre `scenes/playable.tscn`: Novo jogo, Configurações, Créditos do engine e Sair. Viewport640×360; janela local do usuário preservada. Build atualizado de 25/10 em `builds/modulo3-fechamento-20261025/ATLAS.exe`, com ATLAS.pck junto; ZIP `builds/ATLAS_Modulo3_Fechamento_20261025_Windows_debug.zip`. Build/ZIP anteriores externos preservados. Não é release pública.

- WASD move; esquerdo ataca; direito faz parry; Espaço esquiva.
- Q adaga e F rastreio após aquisição por pontos em Tab; exatamente três ramos preservados.
- M abre/fecha mapa descoberto e pausa; Esc fecha painel antes de pausar. Configurações acessíveis no menu e pausa.
- E prioriza página desbloqueada, depois carne, fogueira e conversa. Ingrediente cru não é refeição. Na fogueira: assar uma carne, comer sozinho, dividir ou reanimar amigo caído. Assar é atômico/imediato nesta versão.
- Fome desce só em simulação viva/ativa (0,08/s provisório), não mata em zero. Refeição solo +35 fome/+25 vida; dividir dá metade ao jogador e +30 vida ao amigo. Resgate usa uma porção, devolve50 vida e conta como uma partilha. São valores provisórios editáveis.
- Drop normal7,5% (faixa5–10%); quatro mortes consecutivas sem carne garantem a próxima. Qualquer drop zera. Quantidades/contador/páginas/aquisições mantidos no retorno R, com50% vida/25% fome; nova partida limpa tudo.
- Amigo tem vida independente; não é alvo de adaga/rastreio, mas sofre ataques inimigos pela posição. Caído não acompanha nem protege; resgate na fogueira não exige que caminhe até ela.
- Golpe que deixa você vivo abaixo de25% ativa suporte do amigo vivo/próximo com linha livre: 5s +0,2s por partilha, duração resolvida na ativação. Redução frontal50%, sem refletir. O golpe disparador já ocorreu. Cura≥25% rearma, sem empilhar duração ativa. Arco turquesa mostra direção travada pelo impacto inicial; geometria provisória72px/120°. Parry válido coberto atordoa0,5s; normal mantém0,85s.
- Livro só começa com cinco páginas e amigo vivo; se caído, mantém5/5 e aguarda resgate. Final preserva folhear/luz/desaparecer; botões Nova partida/Menu/Sair, Enter no botão focado, Esc para tela inicial.

## Ajustes e persistência

`resources/route_layout.tres`: regiões/conexões/colisões/câmera/descoberta/encontros/fogueiras; cinco `page_area_ids` roots,ruins,lookout,grove,archive, com wreck/shelter auxiliares. Amplie listas paralelas e mundo sem mudar IDs de progresso; não há limite de sete regiões.

`resources/survival.tres`: fome/drop/porções/cura. `resources/companion_support.tres`: alcance/ângulo/indicador. `resources/monster_attacks.tres`: ataques provisórios. `scenes/companion.tscn`: acompanhamento. Não editar recursos de configuração para guardar vida/carne/bônus de uma partida.

Volumes Master/Efeitos/Música e mute, janela/tela cheia e escala inteira ficam em `user://atlas_settings.cfg`, somente preferências; canal Música preparado sem trilha fornecida. Arquivo inválido usa padrões, erro de gravação é mostrado. Sem save de campanha. Padrões podem ser restaurados.

## Evidência e limites

Resultados por fase/testes/capturas/build/backup/publicação em `MODULO_3_STATUS.md`. Arte do NPC/ataques e sons originais preservados, sem geração de imagens. Escuta/mixagem humanas e revisão artística pendentes; ataques só frontais. A recarga recorrente da esfera foi corrigida e a carga medida ficou sem picos acima de16,67ms; isso não garante desempenho universal. Fechamento e aceite humano em `MODULO_3_FECHAMENTO.md`. Não iniciar módulo4 sem novo pedido.
