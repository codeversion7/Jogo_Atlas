extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:failures += 1;push_error(message)
func settle() -> void:
	for i in 3:await process_frame
func shot(name: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/atlas/evidencias/17_"+name+".png")
func run() -> void:
	var game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.start_session()
	await settle()
	check(game.health_bar.size.y<=6 and game.hunger_bar.size.y<=5,"Barras não crescem pelo mínimo do tema nem cobrem rótulos")
	var player = game.player
	var panel = game.character_panel
	check(panel.scene_file_path=="res://scenes/ui/skill_tree.tscn","Partida instancia a cena própria da árvore")
	check(not player.has_method("try_track") and not InputMap.has_action("track_enemies"),"Rastreio removido do ator e entrada")
	check(player.reach_level==0,"Sem alcance gratuito na nova partida")
	check(game.health_bar.position.x==game.hunger_bar.position.x and game.health_bar.position.x<160,"Vida e fome alinhadas à esquerda")
	check(panel.open() and paused and game.session_ui.active==&"tree","Árvore integrada ao único coordenador")
	check(not game.session_ui.claim(&"map"),"Mapa não compete com árvore")
	check(root.gui_get_focus_owner()==panel.buttons[panel.selected],"Abertura coloca foco em nó selecionável")
	panel.buttons["reach.second"].pressed.emit()
	check(panel.selected=="reach.second" and panel.buy_button.disabled,"Nó bloqueado continua selecionável para ler requisito")
	check(player.attributes.owned.is_empty(),"Selecionar não compra")
	panel.close()
	check(not paused and player.input_guard_frames==2,"Saída protege contra ataque acidental")
	var legacy = player.Attributes.new()
	legacy.owned = {"tracking.unlock":true,"tracking.stride":true}
	legacy.spent_costs = {"tracking.unlock":2}
	legacy.retire_tracking()
	check(legacy.owned.is_empty() and legacy.points==2,"Legado reembolsa somente gasto comprovado, sem estimar outro custo")
	legacy.retire_tracking()
	check(legacy.points==2 and is_equal_approx(legacy.dodge_distance(),30.4),"Retirada idempotente, sem bônus oculto de dash")
	player.attributes.reward_encounter(0)
	player.attributes.reward_encounter(1)
	panel.open()
	for id in ["reach.first","reach.second"]:
		panel.buttons[id].pressed.emit()
		panel.buy_button.pressed.emit()
	check(player.reach_level==2 and player.attributes.points==0,"Dois upgrades adquiridos pela seleção/confirmação da UI")
	check(player.melee_reach.radius(player.reach_level)==46,"Compra alimenta o mesmo alcance da geometria visual/física")
	panel.buy_button.pressed.emit()
	check(player.attributes.points==0 and player.reach_level==2,"Compra repetida não altera saldo ou alcance")
	var windows: Array = []
	if "--render" in OS.get_cmdline_user_args():
		for size in [Vector2i(640,360),Vector2i(1920,1080)]:
			DisplayServer.window_set_size(size)
			await shot("tree_"+str(size.x))
			windows.append({"requested":str(size),"actual":str(DisplayServer.window_get_size()),"viewport":str(root.content_scale_size)})
			panel.close()
			await shot("hud_"+str(size.x))
			panel.open()
	panel.close()
	game.queue_free()
	await process_frame
	var file := FileAccess.open("res://docs/atlas/evidencias/17_tree_checks.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"windows":windows,"fixture":"encounter rewards supplied to test actual UI purchases; health and hunger not overridden"},"  "))
	print("ATLAS_MODULE4_TREE checks=",checks," failures=",failures)
	quit(0 if failures==0 else 1)
