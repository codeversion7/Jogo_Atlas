extends SceneTree
## Captures real gameplay plus all attack phases with actual runtime visuals.
const OUT := "res://docs/atlas/evidencias/08_adaga"
const Pose = preload("res://scripts/dagger_pose.gd")
var actors: Array = []
func _initialize() -> void:
	run.call_deferred()
func capture(path: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(path) == OK)
func run() -> void:
	root.size = Vector2i(960,540)
	DirAccess.make_dir_recursive_absolute(OUT)
	var game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await physics_frame
	await capture(OUT+"/f5_inicio.png")
	game.player.position = game.layout.encounter_centers[0]
	game.begin_encounter(0)
	await physics_frame
	await capture(OUT+"/f5_monstro.png")
	game.player.set_physics_process(false)
	game.player.try_attack(Vector2(1,-1))
	game.player.state = &"attack"
	game.player.remaining = game.player.attack_duration*0.375
	game.player.update_visual()
	await capture(OUT+"/f5_ataque.png")
	game.queue_free()
	await process_frame
	root.content_scale_size = Vector2i(960,540)
	root.size = Vector2i(960,540)
	var stage := Node2D.new()
	root.add_child(stage)
	current_scene = stage
	var background := Polygon2D.new()
	background.polygon = PackedVector2Array([Vector2.ZERO,Vector2(960,0),Vector2(960,540),Vector2(0,540)])
	background.color = Color("4a5558")
	stage.add_child(background)
	var directions := [Vector2.RIGHT,Vector2(1,1).normalized(),Vector2.DOWN,Vector2(-1,1).normalized(),Vector2.LEFT,Vector2(-1,-1).normalized(),Vector2.UP,Vector2(1,-1).normalized()]
	for i in 8:
		var actor = load("res://scenes/player.tscn").instantiate()
		actor.set_script(load("res://scripts/combat_player.gd"))
		actor.preview_animations = true
		actor.position = Vector2(100+(i%4)*250,220+int(i/4)*255)
		actor.scale = Vector2(3,3)
		actor.get_node("Camera2D").enabled = false
		stage.add_child(actor)
		actor.set_physics_process(false)
		actors.append(actor)
	for frame in 12:
		var phase: StringName = &"attack_windup" if frame < 2 else &"attack_active" if frame < 6 else &"attack_recovery"
		var start := 0 if frame < 2 else 2 if frame < 6 else 6
		var count := 2 if frame < 2 else 4 if frame < 6 else 6
		for i in 8:
			actors[i].visual.set_action(phase,directions[i],(frame-start+0.5)/count)
		await capture(OUT+"/oito_direcoes_%02d.png"%frame)
	for frame in 6:
		for i in 8:
			actors[i].visual.set_action(&"",directions[i])
			actors[i].visual.set_motion(directions[i]*48)
			actors[i].visual.sprite.pause()
			actors[i].visual.sprite.set_frame_and_progress(frame,0)
		await capture(OUT+"/locomocao_%02d.png"%frame)
	print("ATLAS_DAGGER_INTEGRATION_RENDER captures=21 directions=8")
	quit()
