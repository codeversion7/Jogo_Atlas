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
	game.session_ui.open_settings()
	await shot("menu_settings")
	game.settings.set_value("window_scale",2)
	assert(DisplayServer.window_get_size()==Vector2i(1280,720))
	game.settings.set_value("fullscreen",true)
	assert(DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN)
	game.settings.set_value("fullscreen",false)
	game.settings.restore_defaults()
	game.session_ui.close_settings()
	game.start_session()
	for i in 3: await physics_frame
	game.session_ui.claim(&"pause")
	game.session_ui.open_settings()
	await shot("pause_settings")
	game.queue_free()
	await process_frame
	print("ATLAS_SETTINGS_RENDER captures=2 window_scale_and_fullscreen=true")
	quit()
