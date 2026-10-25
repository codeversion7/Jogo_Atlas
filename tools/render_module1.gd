extends SceneTree
const OUT := "res://docs/atlas/evidencias/12_module1/"
func _initialize() -> void: run.call_deferred()
func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(OUT+name+".png") == OK)
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.start_session()
	await physics_frame
	await shot("01_hud")
	game.character_panel.open()
	await shot("02_arvore_inicial")
	game.player.attributes.reward_encounter(0)
	game.player.attributes.reward_encounter(1)
	await shot("03_aquisicao")
	game.character_panel.purchase("throw.unlock")
	game.character_panel.purchase("reach.first")
	game.player.attributes.points = 4
	for id in ["throw.edge","reach.second","parry.focus","parry.guard"]: game.character_panel.purchase(id)
	await shot("04_status_aprimorado")
	game.character_panel.close()
	for kind in 2:
		var target = load("res://scripts/test_monster.gd").new()
		target.monster_kind = kind
		target.position = game.player.position+Vector2(60+kind*20,kind*35)
		target.target = game.player
		game.get_node("World").add_child(target)
		target.set_physics_process(false)
	game.player.try_throw(Vector2.RIGHT)
	for i in 5: await physics_frame
	await shot("05_alcance_e_voo")
	game.character_panel.open()
	await shot("06_pausa_com_recargas")
	game.character_panel.close()
	print("ATLAS_MODULE1_RENDER captures=6")
	quit()
