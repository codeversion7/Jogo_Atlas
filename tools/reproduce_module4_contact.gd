extends SceneTree
const Pose = preload("res://scripts/dagger_pose.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.start_session()
	game.set_physics_process(false)
	game.player.set_physics_process(false)
	game.companion.set_physics_process(false)
	var player = game.player
	player.position = Vector2(180,220)
	var monster = load("res://scripts/test_monster.gd").new()
	monster.position = player.position+Pose.visible_blade(Pose.sample(&"attack_active",Vector2.RIGHT,1.0))[-1]-Vector2(0,-8)
	monster.target = player
	monster.hurt_radius = 0.1
	game.get_node("World").add_child(monster)
	monster.set_physics_process(false)
	player.locked_direction = Vector2.RIGHT
	player.state = &"attack"
	player.remaining = 0.001
	var before: int = monster.health
	player._physics_process(1.0/30)
	var row := {"fixture":"last active contact before transition","direction":"right","active_remaining":0.001,"delta":1.0/30,"wall":false,"target_dead":monster.dead,"health_before":before,"health_after":monster.health,"state_after":String(player.state),"miss_reproduced":monster.health==before}
	var file := FileAccess.open("res://docs/atlas/evidencias/17_contact_before.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(row,"  "))
	print("ATLAS_CONTACT_REPRO ",JSON.stringify(row))
	game.audio.stop_all()
	game.queue_free()
	await process_frame
	quit()
