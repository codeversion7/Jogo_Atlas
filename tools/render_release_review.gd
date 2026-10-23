extends SceneTree
## Amostras de animação do viewport real. Nada é redesenhado fora do jogo.
func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.start_session()
	root.size = Vector2i(640,360)
	root.content_scale_size = Vector2i(640,360)
	await process_frame
	var p = game.player
	var dir := "res://docs/atlas/evidencias/release_frames"
	DirAccess.make_dir_recursive_absolute(dir)
	for tick in 240:
		if tick == 0:
			Input.action_press("move_right")
		if tick == 60:
			Input.action_release("move_right")
			p.try_attack(Vector2.RIGHT)
		if tick == 90:
			p.try_parry(Vector2.RIGHT)
		if tick == 125:
			p.try_dodge(Vector2.RIGHT)
		if tick == 155:
			p.try_attack(Vector2.LEFT)
		if tick == 195:
			p.hurt_wait = 0
			p.receive_attack(20,p)
		if tick == 220:
			p.hurt_wait = 0
			p.receive_attack(1000,p)
		await physics_frame
		await process_frame
		if tick%4 == 0:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(dir+"/frame_%03d.png" % tick)
	print("ATLAS_RELEASE_ANIMATION frames=60 physics_ticks=240")
	game.queue_free()
	await process_frame
	quit()
