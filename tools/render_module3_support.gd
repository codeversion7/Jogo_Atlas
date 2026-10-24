extends SceneTree
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
	game.player.set_physics_process(false)
	game.companion.position = Vector2(150,235)
	var source = load("res://scripts/test_monster.gd").new()
	source.target = game.player
	source.position = Vector2(204,220)
	game.get_node("World").add_child(source)
	source.set_physics_process(false)
	game.player.receive_attack(76,source) # Vida de fixture para mostrar o gatilho.
	for i in 120: await physics_frame
	assert(game.support.active and game.companion.visual.opening==1)
	await shot("support_hold_after_two_seconds")
	game.support.cancel()
	for i in 20: await physics_frame
	assert(not game.companion.visual.shield.visible)
	await shot("support_retracted")
	game.queue_free()
	await process_frame
	print("ATLAS_SUPPORT_RENDER captures=2 sustained_guard=true")
	quit()
