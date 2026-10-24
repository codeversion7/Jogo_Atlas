extends SceneTree
## Integração na cena configurada por F5; entradas reais de movimento e golpes reais.
var failures := 0
var checks := 0
var game
var player
var capture := false

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	run.call_deferred()

func step(count: int = 2) -> void:
	for i in count:
		await physics_frame
		await process_frame

func release() -> void:
	for action in ["move_up","move_down","move_left","move_right"]:
		Input.action_release(action)

func walk_to(point: Vector2) -> void:
	var budget := 720
	while player.position.distance_to(point) > 3 and budget > 0:
		var direction: Vector2 = player.position.direction_to(point)
		release()
		if direction.x < -0.05:
			Input.action_press("move_left",-direction.x)
		elif direction.x > 0.05:
			Input.action_press("move_right",direction.x)
		if direction.y < -0.05:
			Input.action_press("move_up",-direction.y)
		elif direction.y > 0.05:
			Input.action_press("move_down",direction.y)
		await step()
		budget -= 2
	release()
	await step()
	check(player.position.distance_to(point) < 4,"Traversable waypoint " + str(point) + " actual " + str(player.position))

func shot(name: String) -> void:
	if capture:
		await RenderingServer.frame_post_draw
		var result := root.get_texture().get_image().save_png("res://docs/atlas/evidencias/05_"+name+".png")
		check(result == OK,"Capture " + name)

func solid_free(point: Vector2) -> bool:
	var params := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8
	params.shape = circle
	params.transform = Transform2D(0,point+Vector2(0,-3))
	params.collision_mask = 1
	return game.get_world_2d().direct_space_state.intersect_shape(params,1).is_empty()

func run() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	game = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	if not game.has_method("begin_encounter"):
		push_error("Playable root failed to load")
		quit(1)
		return
	root.add_child(game)
	current_scene = game
	game.start_session()
	root.size = Vector2i(640,360)
	root.content_scale_size = Vector2i(640,360)
	player = game.player
	await step(4)
	check(game.name == &"AtlasPlayable","F5 opens integrated route")
	check(not player.visual.stable_pose and player.visual.sprite.is_playing(),"Release animates; no stable sliding")
	check(game.pages.is_empty() and game.layout.encounter_centers.size() == 5,"Exactly five pages")
	check(not game.collect_page(),"No page before horde")
	var debug_key := InputEventKey.new()
	debug_key.keycode = KEY_F3
	debug_key.pressed = true
	Input.parse_input_event(debug_key)
	await step()
	check(player.debug_areas and game.markers.z_index == 20,"F3 reveals matching combat/solid areas")
	debug_key.pressed = false
	Input.parse_input_event(debug_key)
	await step()
	debug_key.pressed = true
	Input.parse_input_event(debug_key)
	await step()
	debug_key.pressed = false
	Input.parse_input_event(debug_key)
	check(not player.debug_areas,"F3 toggles debug off")
	var pause_key := InputEventKey.new()
	pause_key.keycode = KEY_ESCAPE
	pause_key.pressed = true
	Input.parse_input_event(pause_key)
	await process_frame
	check(paused,"Esc pauses the game")
	var before_pause: Vector2 = player.position
	Input.action_press("move_right")
	for i in 4:
		await process_frame
	check(player.position == before_pause,"No movement during pause")
	Input.action_release("move_right")
	pause_key.pressed = false
	Input.parse_input_event(pause_key)
	await process_frame
	pause_key.pressed = true
	Input.parse_input_event(pause_key)
	await process_frame
	pause_key.pressed = false
	Input.parse_input_event(pause_key)
	check(not paused,"Esc resumes the game")
	await shot("destrocos")
	# Isola navegação das hordas para conferir todos os corredores com entradas reais.
	game.ending = &"route_test"
	for point in [Vector2(500,210),Vector2(620,210),Vector2(840,210),Vector2(1110,210),Vector2(1400,210),Vector2(1960,210),Vector2(1400,210),Vector2(1400,450),Vector2(1400,610),Vector2(840,610),Vector2(840,450),Vector2(840,210),Vector2(280,210),Vector2(280,610),Vector2(180,610),Vector2(280,610),Vector2(280,220),Vector2(180,220)]:
		await walk_to(point)
	var original_regions_reached := true
	for id in ["wreck","roots","ruins","lookout","shelter","grove","archive"]:
		if not game.visited.has(game.layout.region_ids.find(id)): original_regions_reached = false
	check(original_regions_reached,"All original route regions reached; extra regions remain allowed")
	await shot("rota_opcional")
	game.ending = &"none"
	# Inicia a primeira horda por movimento até o gatilho, não chamada direta.
	await walk_to(Vector2(650,210))
	Input.action_press("move_right")
	await step(45)
	release()
	check(game.active_encounter == 0 and game.enemies.size() == 1,"Walking into clearing starts initial wave")
	if game.enemies.is_empty():
		quit(1)
		return
	await shot("arena")
	var old_max: int = player.max_health
	player.hurt_wait = 0
	var source = game.enemies[0]
	player.receive_attack(1000,source)
	await step()
	check(player.dead and game.enemies.is_empty(),"Death cancels active horde")
	Input.action_press("test_return")
	await step()
	Input.action_release("test_return")
	check(not player.dead and player.health == old_max/2 and player.hunger<=25 and absf(player.hunger-25)<=game.survival.config.hunger_per_second*2.0/Engine.physics_ticks_per_second+0.00001,"R returns at half health and 25% hunger, then drains only elapsed active ticks")
	check(player.position.distance_to(game.player_spawn) < 1,"Return goes to wreck")
	# Região temporariamente sem espaço: aguarda em vez de gerar dentro de sólidos.
	var blocked := StaticBody2D.new()
	blocked.collision_layer = 1
	blocked.position = game.layout.encounter_centers[0]
	var blocked_shape := CollisionShape2D.new()
	var blocked_box := RectangleShape2D.new()
	blocked_box.size = Vector2(340,340)
	blocked_shape.shape = blocked_box
	blocked.add_child(blocked_shape)
	game.get_node("World").add_child(blocked)
	await step()
	game.begin_encounter(0)
	check(game.enemies.is_empty() and game.encounter == &"between" and game.wave_index == -1,"No invalid spawns when every candidate is blocked")
	blocked.queue_free()
	await step(24)
	check(game.enemies.size() == 1 and game.wave_index == 0,"Wave retries when valid space becomes available")
	player.hurt_wait = 0
	player.receive_attack(1000,player)
	await step()
	game.return_player()
	# Exercita as cinco hordas inteiras. Posicionamento controlado isola combate/progressão.
	for index in 5:
		player.position = game.layout.encounter_centers[index]
		await step(3)
		check(game.active_encounter == index,"Encounter starts once: " + str(index))
		for wave in 3:
			var budget := 240
			while game.encounter == &"between" and budget > 0:
				await step()
				budget -= 2
			check(game.wave_index == wave,"Three configured waves in encounter " + str(index))
			check(not game.collect_page(),"No collection during horde")
			for monster in game.enemies.duplicate():
				check(solid_free(monster.position),"Spawn is clear of solid scenery")
				# Keep the target stationary and prevent incoming damage for deterministic strike tests.
				monster.set_physics_process(false)
				monster.position = player.position + Vector2(22,0)
				var tries := 0
				while not monster.dead and tries < 180:
					if player.state == &"ready":
						player.try_attack(Vector2.RIGHT)
					await step()
					tries += 2
				check(monster.dead,"Dagger defeats wave target")
			await step()
		check(game.cleared.has(index) and game.active_encounter == -1,"Horde unlocks only its page")
		check(player.attributes.points == index+1,"Exactly one skill point per completed encounter")
		check(not player.attributes.reward_encounter(index),"Completed encounter cannot reward points twice")
		player.position = game.page_position(index)
		Input.action_press("interact")
		await step()
		Input.action_release("interact")
		check(game.pages.size() == index+1,"E collects distinct page " + str(index+1))
		check(not game.collect_page(),"No duplicate page")
		if index == 0:
			await shot("pagina")
			player.hurt_wait = 0
			player.receive_attack(1000,player)
			await step()
			game.return_player()
			check(game.pages.size() == 1,"Page survives death/return")
			check(player.max_health == old_max,"Maximum health never permanently reduced")
		# Restore the player to ready through the actual recovery clock before next horde.
		await step(35)
	check(game.pages.size() == 5 and game.ending == &"playing","5/5 starts book")
	var book_clock: float = game.book.elapsed
	pause_key.pressed = true
	Input.parse_input_event(pause_key)
	for i in 6:
		await process_frame
	check(game.book.elapsed == book_clock,"Book animation clock pauses")
	pause_key.pressed = false
	Input.parse_input_event(pause_key)
	await process_frame
	pause_key.pressed = true
	Input.parse_input_event(pause_key)
	await process_frame
	pause_key.pressed = false
	Input.parse_input_event(pause_key)
	await shot("livro_folheando")
	await step(110)
	await shot("livro_luz")
	await step(120)
	await shot("livro_desaparecendo")
	await step(100)
	check(game.ending == &"complete","Ending finishes")
	check(game.ending_phases == [&"flipping",&"light",&"vanishing",&"complete"],"Canonical book order")
	check(game.session_ui.active==&"ending" and not player.is_physics_processing(),"Ending UI uses shared coordinator and combat is disabled")
	await shot("fim")
	var old_instance: int = game.get_instance_id()
	var restart_key := InputEventKey.new()
	restart_key.keycode = KEY_ENTER
	restart_key.pressed = true
	Input.parse_input_event(restart_key)
	await step(4)
	restart_key = restart_key.duplicate()
	restart_key.pressed = false
	Input.parse_input_event(restart_key)
	Input.flush_buffered_events()
	await step(2) # Native focused button activates on release; scene reload is deferred.
	check(current_scene != null and current_scene.get_instance_id() != old_instance,"Enter starts a new scene")
	game = current_scene
	check(game.pages.is_empty() and game.ending == &"none","New run explicitly resets pages and ending")
	check(game.player.position.distance_to(game.player_spawn) < 1,"New run starts at wreck")
	print("ATLAS_PLAYABLE_TEST checks=",checks," failures=",failures," completed_pages=5 restarted_pages=",game.pages.size()," canonical_phases=4")
	game.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
