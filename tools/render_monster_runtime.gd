extends SceneTree
## Revisão renderizada no mundo real; posições/vida fixas são fixtures visuais explícitas.
const OUT := "res://docs/atlas/evidencias/13_monster_runtime/"
var game
func _initialize() -> void: run.call_deferred()
func step() -> void:
	await physics_frame
	await process_frame
func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(OUT+name+".png") == OK)
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.start_session()
	game.set_physics_process(false)
	game.player.set_physics_process(false)
	game.hud.visible = false
	var camera: Camera2D = game.player.get_node("Camera2D")
	camera.zoom = Vector2(4,4)
	camera.offset = Vector2(-10,-10)
	for kind in 4:
		game.player.health = game.player.max_health
		game.player.dead = false
		game.player.hurt_wait = 0
		game.player.state = &"ready"
		game.player.position = Vector2(180,220)
		var monster = load("res://scripts/test_monster.gd").new()
		monster.monster_kind = kind
		monster.prepared_attacks = true
		monster.move_speed = 0
		monster.position = game.player.position-Vector2(60 if kind==2 else 24,0)
		monster.target = game.player
		game.get_node("World").add_child(monster)
		await step()
		await step()
		await shot("%d_warning"%kind)
		var goal := &"active" if kind<2 else &"flight" if kind==2 else &"impact"
		var budget := 130
		while monster.attack_runtime.phase != goal and budget>0:
			await step()
			budget -= 1
		assert(budget>0)
		for i in 3: await step()
		await shot("%d_active"%kind)
		while monster.attack_runtime.playing: await step()
		monster.set_physics_process(false)
		await shot("%d_idle"%kind)
		monster.queue_free()
		for orb in get_nodes_in_group("atlas_monster_projectiles"): orb.queue_free()
		await step()
	print("ATLAS_MONSTER_RUNTIME_RENDER captures=12 fixtures=true")
	quit()
