extends SceneTree
## Partida automática pelo percurso. IA/vida/dano/ondas permanecem nos valores reais.
## Só aciona movimento e APIs públicas de ataque/parry/esquiva/interação/retorno.
var game
var player
var failures := 0
var checks := 0
var ticks := 0
var attacks := 0
var parries := 0
var dodges := 0
var returns := 0
var initial_max_health: int
var initial_damage: int
var capture := false

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, description: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(description)

func step() -> void:
	await physics_frame
	await process_frame
	ticks += 1

func shot(name: String) -> void:
	if capture:
		await RenderingServer.frame_post_draw
		var result := root.get_texture().get_image().save_png("res://docs/atlas/evidencias/06_live_"+name+".png")
		check(result == OK,"Live capture "+name)

func move(direction: Vector2) -> void:
	for action in ["move_up","move_down","move_left","move_right"]:
		Input.action_release(action)
	var choice := direction
	if not choice.is_zero_approx() and player.test_move(player.global_transform,choice*18):
		for angle in [PI/4,-PI/4,PI/2,-PI/2]:
			var alternative := choice.rotated(angle)
			if not player.test_move(player.global_transform,alternative*18):
				choice = alternative
				break
	if choice.x < -0.05:
		Input.action_press("move_left",-choice.x)
	elif choice.x > 0.05:
		Input.action_press("move_right",choice.x)
	if choice.y < -0.05:
		Input.action_press("move_up",-choice.y)
	elif choice.y > 0.05:
		Input.action_press("move_down",choice.y)

func walk_to(point: Vector2, allow_encounter: bool = true) -> bool:
	var budget := 1600
	while player.position.distance_to(point) > 4 and budget > 0:
		if player.dead or (allow_encounter and game.active_encounter >= 0):
			move(Vector2.ZERO)
			return false
		move(player.position.direction_to(point))
		await step()
		budget -= 1
	move(Vector2.ZERO)
	check(budget > 0,"Live traversal reached " + str(point))
	return budget > 0

func blade_can_reach(monster: Node2D, direction: Vector2) -> bool:
	# The bot must approach the visible blade, not the retired uniform sector.
	var pose_script = preload("res://scripts/dagger_pose.gd")
	for progress in [0.125,0.375,0.625,0.875]:
		var pose: Dictionary = pose_script.sample(&"attack_active",direction,progress)
		for point in pose_script.visible_blade(pose):
			if (player.global_position+point).distance_to(monster.combat_center()) <= monster.hurt_radius + 1.0:
				return true
	return false

func fight() -> bool:
	var budget := 4200
	while game.active_encounter >= 0 and not player.dead and budget > 0:
		var nearest: Node2D
		var distance := INF
		var threat: Node2D
		for monster in game.enemies:
			check(monster.is_physics_processing(),"Enemy AI stays enabled")
			var d: float = player.position.distance_to(monster.position)
			if d < distance:
				distance = d
				nearest = monster
			if monster.state == &"windup" and monster.remaining < 0.16 and d < 38:
				threat = monster
		if nearest == null:
			move(Vector2.ZERO)
		else:
			var direction: Vector2 = player.position.direction_to(nearest.position)
			if player.state == &"ready":
				if threat != null:
					if player.try_parry(player.position.direction_to(threat.position)):
						parries += 1
				elif blade_can_reach(nearest,direction):
					if player.try_attack(direction):
						attacks += 1
			if player.state in [&"windup",&"attack",&"parry"]:
				move(Vector2.ZERO)
			elif player.state == &"recovery" and distance < 43:
				move(-direction)
			elif not blade_can_reach(nearest,direction):
				move(direction)
			elif threat != null and player.state == &"ready" and player.try_dodge(-direction):
				dodges += 1
			else:
				move(Vector2.ZERO)
		await step()
		budget -= 1
	move(Vector2.ZERO)
	check(budget > 0,"Live horde finishes without freezing enemies")
	return not player.dead and budget > 0

func run() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	var entry: String = ProjectSettings.get_setting("application/run/main_scene")
	if entry != "res://scenes/playable.tscn":
		push_error("F5 must open res://scenes/playable.tscn; configured entry: " + entry)
		quit(1)
		return
	game = load(entry).instantiate()
	if not game.has_method("collect_page"):
		push_error("Playable root failed to load")
		game.free()
		quit(1)
		return
	root.add_child(game)
	current_scene = game
	player = game.player
	initial_max_health = player.max_health
	initial_damage = player.dagger_damage
	await step()
	await shot("inicio")
	var order := [0,1,2,4,3]
	for index in order:
		var attempts := 0
		while not game.pages.has(index) and attempts < 4:
			if player.dead:
				check(game.return_player(),"Return uses actual rule")
				returns += 1
				await step()
			var center: Vector2 = game.layout.encounter_centers[index]
			for waypoint in [Vector2(player.position.x,210),Vector2(center.x,210),center]:
				await walk_to(waypoint)
				if game.active_encounter >= 0:
					break
			if game.active_encounter >= 0:
				await fight()
			if not player.dead and game.cleared.has(index):
				await walk_to(game.page_position(index))
				check(game.collect_page(),"Live horde releases page " + str(index+1))
			attempts += 1
		check(game.pages.has(index),"Live run collected distinct page " + str(index+1))
		if game.pages.has(index):
			await shot("pagina_"+str(index+1))
		if not game.pages.has(index):
			break
	check(game.pages.size() == 5,"All pages obtained with AI active")
	check(player.max_health == initial_max_health and player.dagger_damage == initial_damage,"Player balance was not overridden")
	if game.pages.size() == 5:
		for i in 330:
			await step()
		check(game.ending == &"complete","Live run reaches ending")
		await shot("fim")
	print("ATLAS_LIVE_RUN checks=",checks," failures=",failures," pages=",game.pages.size()," attacks=",attacks," parries=",parries," dodges=",dodges," returns=",returns," health=",player.health," simulated_seconds=",float(ticks)/60)
	move(Vector2.ZERO)
	game.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
