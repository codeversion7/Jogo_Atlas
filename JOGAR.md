# ATLAS — versão jogável compacta

Abra `project.godot` no **Godot 4.7.2** e pressione **F5**. No computador de produção também pode usar `Jogar-ATLAS.cmd`; `GODOT_BIN` permite escolher outro caminho para o mesmo engine.

## Controles

| Entrada | Ação |
|---|---|
| WASD | Mover, inclusive diagonais normalizadas |
| Mouse | Mirar |
| Clique esquerdo | Adaga: preparação, golpe e recuperação |
| Clique direito | Parry na direção da mira |
| Espaço | Esquiva na direção do movimento, ou da mira quando parado |
| E | Recolher página próxima após vencer toda a horda |
| R | Retornar aos destroços após morrer |
| Esc | Pausar / continuar; também exibe os controles |
| F3 | Mostrar / ocultar colisão física, áreas vulneráveis e combate |
| Enter no encerramento | Nova partida |

## Percurso

Comece nos destroços e siga o caminho à direita: trilha das raízes, pátio das ruínas e mirante. As bifurcações ao sul levam ao bosque e ao arquivo. A rota ao sul dos destroços termina em um abrigo opcional com suprimentos cenográficos.

Há **cinco páginas distintas**, cada uma protegida por **três ondas**. Ataque, recue e use a preparação laranja do monstro para escolher parry ou esquiva. A página só aparece após vencer o confronto inteiro; aproxime-se e use E. É possível circular e recuar pelos caminhos durante a horda.

Ao morrer, as páginas conquistadas permanecem **nesta partida**. R retorna com 50% da vida máxima e 25% de fome restante. Não há salvamento ao fechar o jogo. A fome ainda não tem consumo/alimentação. Enter após o final inicia uma partida nova e zera as páginas explicitamente.

Em 5/5 o livro folheia, cria uma torre de luz e desaparece; então aparece “Fim da primeira parte”.

## Recursos provisórios e distribuição

Personagem articulado, cenários, monstros e efeitos são recursos próprios de teste, substituíveis. As referências originais foram preservadas. Os clipes autorais têm fonte reproduzível e revisão em `assets/personagem/provisorio/`; os rascunhos anteriores permanecem disponíveis no laboratório.

Não há mapa consultável por M, minimapa, sistema de comida, NPC, áudio final ou salvamento em disco nesta versão. Esses sistemas não foram inferidos para fechar o percurso solicitado.

O preset Windows x86_64 está em `export_presets.cfg`. A exportação foi tentada, mas faltam os templates `4.7.2.stable/windows_debug_x86_64.exe` e `windows_release_x86_64.exe`. O ZIP entregue é o projeto jogável com fontes, **não um executável exportado**. Instalar os templates correspondentes permite repetir `--export-debug "Windows Desktop"` e testar a distribuição; nenhum download ou publicação foi realizado.

Testes, evidências e limites: [entrega](docs/atlas/ENTREGA_JOGAVEL.md).
