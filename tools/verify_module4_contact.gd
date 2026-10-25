extends SceneTree
const Pose = preload("res://scripts/dagger_pose.gd")
var checks := 0
var failures := 0
var game
var target
var player
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func reset(direction: Vector2, level: int = 0) -> void:
	player.state = &"attack"
	player.remaining = player.attack_duration
	player.locked_direction = direction
	player.feedback_wait = 0
	player.dead = false
	player.attributes.owned.erase("reach.first")
	player.attributes.owned.erase("reach.second")
	if level>=1:player.attributes.owned["reach.first"] = true
	if level>=2:player.attributes.owned["reach.second"] = true
	player.struck.clear()
	player.target_positions.clear()
	target.dead = false
	target.health = 50
	target.hurt_radius = 0.1
func run() -> void:
	game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.start_session()
	game.set_physics_process(false)
	player = game.player
	player.set_physics_process(false)
	game.companion.set_physics_process(false)
	player.position = Vector2(180,220)
	target = load("res://scripts/test_monster.gd").new()
	target.target = player
	game.get_node("World").add_child(target)
	target.set_physics_process(false)
	var rows: Array = []
	for i in 8:
		var direction := Vector2.RIGHT.rotated(i*TAU/8)
		for progress in [0.0,0.25,0.5,0.75,1.0]:
			for point in Pose.visible_blade(Pose.sample(&"attack_active",direction,progress)):
				check((point-player.COMBAT_OFFSET).length()<player.melee_reach.first_reach,"Primeiro upgrade excede todo o metal base nesta direção")
		for delta in [1.0/120,1.0/60,1.0/30,0.1]:
			reset(direction)
			var points := Pose.visible_blade(Pose.sample(&"attack_active",direction,1.0))
			if points.is_empty():continue
			target.position = player.position+points[-1]-Vector2(0,-8)
			player.remaining = 0.001
			player._physics_process(delta)
			check(target.health==25,"Último trecho ativo detectado dir=%d delta=%s"%[i,delta])
			player._physics_process(delta)
			check(target.health==25,"Recuperação não repete dano")
			rows.append({"direction":i,"delta":delta,"health_after":target.health})
		for level in [1,2]:
			reset(direction,level)
			var radius: float = player.melee_reach.radius(level)
			target.position = player.combat_center()+direction*(radius+target.hurt_radius)-Vector2(0,-8)
			player.strike_targets()
			check(target.health==25,"Borda da onda recebe dano dir=%d level=%d"%[i,level])
			player.strike_targets()
			check(target.health==25,"Metal e onda não duplicam dano")
			reset(direction,level)
			target.position = player.combat_center()+direction*(radius+target.hurt_radius+1)-Vector2(0,-8)
			player.strike_targets()
			check(target.health==50,"Fora da onda não recebe dano")
			reset(direction,level)
			target.position = player.combat_center()-direction*20-Vector2(0,-8)
			player.strike_targets()
			check(target.health==50,"Onda não causa dano nas costas")
	# Target traverses the visible metal between sampled positions.
	reset(Vector2.RIGHT)
	var point: Vector2 = Pose.visible_blade(Pose.sample(&"attack_active",Vector2.RIGHT,0.5))[-1]
	target.position = player.position+point+Vector2(0,15)-Vector2(0,-8)
	player.target_positions[target.get_instance_id()] = target.combat_center()-Vector2(0,30)
	player.strike_sweep(Vector2(0.5,0.5),player.position,player.position)
	check(target.health==25,"Alvo móvel cruza metal entre amostras")
	for state in [&"windup",&"recovery",&"dead"]:
		reset(Vector2.RIGHT,2)
		target.position = player.combat_center()+Vector2(30,0)-Vector2(0,-8)
		player.state = state
		player.strike_targets()
		check(target.health==50,"Sem dano fora da fase ativa: "+state)
	reset(Vector2.RIGHT,2)
	paused = true
	player.strike_targets()
	check(target.health==50,"Pausa bloqueia contato")
	paused = false
	reset(Vector2.RIGHT)
	player.state = &"windup"
	player.remaining = 1.0/30
	var initial_metal := Pose.visible_blade(Pose.sample(&"attack_active",Vector2.RIGHT,0.0))
	target.position = player.position+initial_metal[-1]-Vector2(0,-8)
	Input.action_press("move_down")
	player._physics_process(1.0/30)
	Input.action_release("move_down")
	check(target.health==50,"Trecho de movimento ainda em preparação não causa dano retroativo")
	reset(Vector2.RIGHT,2)
	target.position = player.combat_center()+Vector2(30,0)-Vector2(0,-8)
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(3,50)
	shape.shape = rectangle
	wall.add_child(shape)
	wall.position = player.combat_center()+Vector2(10,0)
	game.get_node("World").add_child(wall)
	await physics_frame
	await physics_frame
	player.strike_targets()
	check(target.health==50,"Parede bloqueia onda e metal")
	wall.queue_free()
	await physics_frame
	if "--render" in OS.get_cmdline_user_args():
		reset(Vector2.RIGHT,2)
		target.position = player.combat_center()+Vector2(46,0)-Vector2(0,-8)
		player.debug_areas = true
		player.update_visual()
		player.queue_redraw()
		target.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/atlas/evidencias/17_contact_wave.png")
	var file := FileAccess.open("res://docs/atlas/evidencias/17_contact_after.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"last_active_cases":rows},"  "))
	game.audio.stop_all()
	game.queue_free()
	await process_frame
	print("ATLAS_MODULE4_CONTACT checks=",checks," failures=",failures)
	quit(0 if failures==0 else 1)
