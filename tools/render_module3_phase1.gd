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
	for i in 5: await physics_frame
	await shot("companion_in_world")
	game.queue_free()
	await process_frame
	var lab = load("res://scenes/review/companion_animation_lab.tscn").instantiate()
	root.add_child(lab)
	lab.set_process(false)
	lab.show_time(0.6)
	await shot("companion_layers")
	print("ATLAS_PHASE1_RENDER captures=2")
	quit()
