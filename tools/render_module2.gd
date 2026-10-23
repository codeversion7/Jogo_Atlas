extends SceneTree
const OUT := "res://docs/atlas/evidencias/13_module2/"
var game
func _initialize() -> void: run.call_deferred()
func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(OUT+name+".png") == OK)
func walk_to(goal: Vector2) -> void:
	var budget := 1200
	while game.player.position.distance_to(goal)>4 and budget>0:
		var direction: Vector2 = game.player.position.direction_to(goal)
		for action in ["move_left","move_right","move_up","move_down"]:Input.action_release(action)
		if direction.x < -0.05:Input.action_press("move_left",-direction.x)
		if direction.x > 0.05:Input.action_press("move_right",direction.x)
		if direction.y < -0.05:Input.action_press("move_up",-direction.y)
		if direction.y > 0.05:Input.action_press("move_down",direction.y)
		await physics_frame
		budget -= 1
	for action in ["move_left","move_right","move_up","move_down"]:Input.action_release(action)
	assert(budget>0)
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await shot("01_menu")
	game.session_ui.actions.get_child(0).pressed.emit()
	for i in 4:await physics_frame
	await shot("02_inicio_npc")
	game.session_ui.claim(&"map")
	await shot("03_mapa_inicial")
	game.session_ui.close()
	await walk_to(Vector2(280,220))
	await walk_to(Vector2(280,850))
	for i in 60:await physics_frame
	await shot("04_extensao_e_acompanhante")
	game.session_ui.claim(&"map")
	await shot("05_descoberta_local")
	game.session_ui.close()
	assert(game.interact() == &"dialogue")
	await shot("06_dialogo")
	game.session_ui.close()
	# Isolated visual fixture; real acquisition is covered by verify_live_run.
	game.player.attributes.reward_encounter(0)
	game.player.attributes.reward_encounter(1)
	game.character_panel.open()
	await shot("07_arvore_coordenada")
	game.character_panel.purchase("throw.unlock")
	game.character_panel.purchase("tracking.unlock")
	game.character_panel.close()
	var monster = load("res://scripts/test_monster.gd").new()
	monster.monster_kind = 2
	monster.position = game.player.position+Vector2(70,0)
	monster.target = game.player
	game.get_node("World").add_child(monster)
	monster.set_physics_process(false)
	game.player.try_throw(Vector2.RIGHT)
	game.player.try_track()
	for i in 4:await physics_frame
	await shot("08_q_f_e_npc")
	game.session_ui.claim(&"pause")
	await shot("09_pausa")
	game.session_ui.actions.get_child(1).pressed.emit()
	await process_frame
	await process_frame
	game = current_scene
	await shot("10_retorno_menu")
	print("ATLAS_MODULE2_RENDER captures=10")
	quit()
