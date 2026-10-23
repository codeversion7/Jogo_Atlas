# Cenas do ATLAS

- **F5:** `playable.tscn`, única entrada de produção; inclui `player.tscn` → `atlas_visual_revisao.tscn`. Esse visual é essencial, apesar do nome.
- **Testes/base:** `main.tscn` e `combat_arena.tscn`; ainda consumidos por ferramentas, preservados.
- **Reserva F6:** `review/animation_lab.tscn`, `review/dagger_attack_review.tscn`, `review/monster_animation_lab.tscn`. Mantidos com suas artes e scripts; não participam da navegação normal nem da entrada F5.
- **Componente:** `monster_visual.tscn` preservado para revisão; o combate instancia `monster_visual.gd` no inimigo existente.

Árvore/status usa `scripts/ui/character_panel.gd`, sem criar uma cena por atributo ou habilidade. Dados em `resources/character/default_character.tres`; lógica em `scripts/character/`. Mudança de pasta não é otimização de FPS.
