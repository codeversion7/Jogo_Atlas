extends SceneTree
var game
func _initialize() -> void: run.call_deferred()
func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://docs/atlas/evidencias/15_"+name+".png")==OK)
func run() -> void:
	game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await shot("atlas_title")
	game.session_ui.open_settings()
	await shot("atlas_settings")
	game.session_ui.close_settings()
	game.session_ui.show_credits()
	await shot("atlas_credits")
	game.session_ui.return_to_menu_panel()
	game.start_session()
	game.record_first_victory(0) # Explicit final/altar rendering fixture.
	game.player.position = game.altar.position
	game.pages = {0:true,1:true,2:true,3:true,4:true} # Fixture de renderização do gate/final.
	assert(game.start_ending())
	for i in 330: await physics_frame
	assert(game.session_ui.active==&"ending")
	await shot("atlas_ending")
	game.queue_free()
	await process_frame
	print("ATLAS_SCREENS_RENDER captures=4 final_fixture=true credits=verified_engine")
	quit()
