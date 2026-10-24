extends SceneTree
## Fixtures visuais explícitas: inventário e dano, sem alegar conquista de recursos real.
func _initialize() -> void: run.call_deferred()
func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://docs/atlas/evidencias/15_"+name+".png")==OK)
func run() -> void:
	var game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.start_session()
	game.player.position = game.layout.campfires[0]
	game.survival.raw = 1
	game.survival.cooked = 1
	game.player.hunger = 30
	for i in 5: await physics_frame
	await shot("camp_in_world")
	assert(game.interact()==&"campfire")
	await shot("camp_meals")
	game.session_ui.close()
	var source = load("res://scripts/test_monster.gd").new()
	source.target = game.player
	source.position = game.companion.position+Vector2(-20,0)
	game.get_node("World").add_child(source)
	source.set_physics_process(false)
	game.companion.receive_attack(9999,source)
	source.queue_free()
	assert(game.interact()==&"campfire")
	await shot("camp_rescue")
	game.queue_free()
	await process_frame
	print("ATLAS_SURVIVAL_RENDER captures=3 fixtures=true")
	quit()
