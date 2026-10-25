# ATLAS — módulo4: uso e ajustes

F5 permanece em `scenes/playable.tscn`. Menu/configurações/créditos mantidos. WASD move, esquerdo adaga, direito parry, Espaço esquiva, Q adaga de retorno após compra. Tab abre a cena única `scenes/ui/skill_tree.tscn`: selecionar nó mostra detalhes; Adquirir confirma. Três ramos: adaga, alcance, parry. F/rastreio e bônus Passo ágil removidos; esquiva base30,4px preservada. Nenhum save de campanha.

`resources/character/melee_reach.tres`: ondas de40/52px, meia abertura0,85rad (provisórios). Base mantém metal visível com varredura temporal; upgrades só adquiridos por pontos. Desenho e contato usam a mesma geometria; não há outra espada ou dano através de parede. HUD usa cápsulas de vida/fome, números imediatos e transição apenas visual; zero/morte/retorno resolvem sem saldo fictício.

`resources/revisits.tres`:10% uma vez por visita do NPC a área concluída, entrada100px/saída140px. NPC anda ao centro e aguarda; horda repetida não dá página/ponto extra. Drops normais são escolha provisória.

`resources/survival.tres` e `scripts/world/survival_config.gd`: fome própria do NPC0,05/s, recuperação35 por porção, números provisórios. E na fogueira permite assar, comer, dividir/reanimar. Para2+ porções, reservar ceil(metade) antes de sua parte; lotes quitados não recalculam restos. Novas porções entram em novo lote. Uma porção originalmente avulsa:20% de roubo se amigo faminto; não cura jogador nem soma bônus voluntário. Amigo cheio dispensa restrições. Caído prioriza resgate pela fogueira, nunca comer cru.

Com amigo caído e inventário vazio, carne descoberta/visível/alcançável no chão gera aviso/barra:5 de vida por10s ativos, sem redução por parry/resistência/escudo. Coletar suspende para ir assar/resgatar; pausa congela; sem acesso não pune. Sem fome letal nova ou hostilidade narrativa inventada.

O altar nasce no primeiro encontro original efetivamente vencido, em qualquer ordem. Volte a ele com5/5, amigo vivo, sem confronto e aperte E perto/linha livre. Quinta página ou reanimação não iniciam automaticamente. Livro colocado→folhear→luz→desaparecer, com12 rachaduras e destruição visual local de160px; física e vida dos atores preservadas. Altar só aparece no mapa quando descoberto. Reiniciar limpa a campanha/efeitos.

Build debug local: `builds/modulo4-20261025/ATLAS.exe` +PCK. ZIP: `builds/ATLAS_Modulo4_20261025_Windows_debug.zip`. Templates locais existentes, sem release pública. Testes/evidências/backup/publicação em `MODULO_4_STATUS.md`. Arte/números/áudio dependem de aceite humano; ataques preparados ainda frontais. Não foram gerados assets novos.
