extends SceneTree
var checks := 0
var failures := 0
var game
var player
var max_npc_step := 0.0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func step(n: int = 1) -> void:
	for i in n:
		await physics_frame
		await process_frame
func key(code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await step()
	event.pressed = false
	Input.parse_input_event(event)
	await step()
func walk_to(goal: Vector2) -> void:
	var budget := 1400
	while player.position.distance_to(goal)>3 and budget>0:
		var direction: Vector2 = player.position.direction_to(goal)
		for action in ["move_left","move_right","move_up","move_down"]:Input.action_release(action)
		if direction.x < -0.05:Input.action_press("move_left",-direction.x)
		if direction.x > 0.05:Input.action_press("move_right",direction.x)
		if direction.y < -0.05:Input.action_press("move_up",-direction.y)
		if direction.y > 0.05:Input.action_press("move_down",direction.y)
		var before: Vector2 = game.companion.position
		await step()
		max_npc_step = maxf(max_npc_step,before.distance_to(game.companion.position))
		budget -= 1
	for action in ["move_left","move_right","move_up","move_down"]:Input.action_release(action)
	check(budget>0,"Real movement reaches "+str(goal))
func run() -> void:
	game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	player = game.player
	check(not game.session_started and game.session_ui.active == &"menu" and paused,"F5 enters menu before simulation")
	check(game.session_ui.actions.get_child_count() == 3+(0 if game.layout.credits.is_empty() else 1),"Menu has working settings and only explicit verified credits")
	check(game.layout.validate().is_empty(),"Layout records validate before use")
	var start: Vector2 = player.position
	await step(10)
	check(player.position == start and game.discovery.cells.is_empty(),"Menu freezes world, discovery and combat")
	game.session_ui.actions.get_child(0).pressed.emit()
	await step(3)
	check(game.session_started and not paused,"New-game button uses public session entry")
	check(game.layout.region_ids.size()>=5 and game.layout.region_names.size()==game.layout.region_ids.size() and game.layout.encounter_ids.size()==5 and game.layout.page_area_ids.size()==5,"Aligned expandable regions and five stable encounter/page IDs")
	check(game.layout.world_size.y == 960 and player.get_node("Camera2D").limit_bottom == 960,"Controlled extension and camera share layout")
	check(game.discovery.known(player.position) and not game.discovery.known(Vector2(1400,210)),"Local discovery never unlocks distant region")
	check(not game.discovery.known(Vector2(180,140)),"Solid wreck blocks local discovery behind it")
	check(game.discovery.cells.size()<30,"A corner visit does not reveal an entire region")
	player.attributes.cooldowns.throw = 1.0
	await key(KEY_M)
	check(game.session_ui.active == &"map" and paused,"M opens discovered-only map and pauses")
	var cd: float = player.attributes.cooldowns.throw
	var elapsed: float = game.elapsed
	await step(12)
	check(is_equal_approx(cd,player.attributes.cooldowns.throw) and is_equal_approx(elapsed,game.elapsed),"Map freezes cooldown and world time")
	await key(KEY_TAB)
	check(game.session_ui.active == &"map" and not game.character_panel.opened,"Tree cannot stack over map")
	await key(KEY_ESCAPE)
	check(game.session_ui.active == &"" and not paused,"Esc closes map before pause")
	await key(KEY_TAB)
	check(game.session_ui.active == &"tree" and paused,"Tree acquires shared panel ownership")
	await key(KEY_M)
	check(game.session_ui.active == &"tree","Map cannot stack over tree")
	await key(KEY_ESCAPE)
	await key(KEY_ESCAPE)
	check(game.session_ui.active == &"pause" and paused,"Esc pauses when no other panel is open")
	game.session_ui.actions.get_child(0).pressed.emit()
	await step(3)
	check(not paused and game.session_ui.active == &"","Continue releases pause without hidden overlay")
	# Physical curve through existing passage into expanded southern exploration.
	for point in [Vector2(280,220),Vector2(280,610),Vector2(280,850)]:await walk_to(point)
	await step(80)
	check(game.companion.position.y>790 and game.companion.position.distance_to(player.position)<65,"Noncombatant follows curve and passage into extension")
	check(max_npc_step<=game.companion.follow_speed/60+0.2,"No visible island teleport used to recover companion")
	check(not game.companion.is_in_group("atlas_combat_targets") and not game.companion.has_method("take_damage"),"NPC excluded from targeting/damage/rewards")
	check(game.discovery.known(Vector2(280,850)) and not game.discovery.known(Vector2(1400,850)),"Expansion discovery remains local")
	check(game.interact() == &"dialogue" and paused,"Nearby E opens one noncombat dialogue")
	await key(KEY_TAB)
	check(game.session_ui.active == &"dialogue","Dialogue owns input over tree")
	await key(KEY_E)
	await step(3)
	check(game.session_ui.active == &"" and not paused,"Closing dialogue restores controls without reopening on same E")
	# Explicit isolated fixture for page/NPC priority; route test covers real hordes.
	game.cleared[0] = true
	player.position = game.page_position(0)
	game.companion.position = player.position+Vector2(-20,0)
	check(game.interact() == &"page" and game.pages.has(0) and not paused,"Unlocked page wins E priority over nearby NPC")
	# Explicit spawn fixture verifies configurable visuals and duplicate callbacks.
	player.position = game.layout.encounter_centers[1]
	check(game.begin_encounter(1),"Configured encounter starts only once")
	check(not game.begin_encounter(1),"Active encounter cannot be duplicated")
	var victim = game.enemies[0]
	check(victim.monster_kind == game.layout.monster_kind(1,0),"Monster appearance follows editable encounter lineup")
	check(not game.navigation.path(victim.position,player.position).is_empty(),"Spawn has a traversable pursuit route")
	victim.take_damage(9999)
	var wave: int = game.wave_index
	game.on_monster_defeated(victim)
	check(game.wave_index == wave and game.encounter == &"between","Last enemy callback processed once")
	var known_before: int = game.discovery.cells.size()
	player.attributes.points = 2
	player.attributes.buy("throw.unlock")
	player.attributes.buy("reach.first")
	player.try_throw(Vector2.RIGHT)
	player.hurt_wait = 0
	player.receive_attack(9999,player)
	await step()
	check(player.dead and game.companion.state == &"idle" and not is_instance_valid(player.thrown_dagger),"Death stops companion and cleans skills")
	check(game.return_player(),"Death return uses existing rule")
	check(game.pages.has(0) and game.discovery.cells.size()>=known_before and player.attributes.owned.size()==2,"Return preserves pages, acquisitions and discovery")
	check(game.companion.position == game.layout.companion_start and player.health == 50 and player.hunger == 25,"Return resets companion only at documented safe start")
	check(get_nodes_in_group("atlas_companion").size()==1,"One companion per session")
	var old_npc = game.companion
	game.session_ui.claim(&"pause")
	game.session_ui.actions.get_child(1).pressed.emit()
	await step(3)
	game = current_scene
	check(game.session_ui.active == &"menu" and paused and not is_instance_valid(old_npc),"Return-to-menu reloads cleanly and removes old actors")
	check(game.pages.is_empty() and game.player.attributes.owned.is_empty() and game.discovery.cells.is_empty(),"New session state is clean, without disk persistence")
	await key(KEY_ENTER)
	check(game.session_started and not paused,"Focused menu button also starts with keyboard Enter")
	game.queue_free()
	await step(2)
	check(get_nodes_in_group("atlas_companion").is_empty(),"Teardown leaves no companion orphan")
	# Credits fixture, never a claim of actual project authorship/licensing.
	game = load("res://scenes/playable.tscn").instantiate()
	game.layout = game.layout.duplicate(true)
	game.layout.credits = PackedStringArray(["Atribuição de teste · fixture isolada"])
	root.add_child(game)
	current_scene = game
	check(game.session_ui.actions.get_child_count()==4,"Credits button exists only with explicit attribution data")
	game.session_ui.actions.get_child(2).pressed.emit()
	check(game.session_ui.text.text.contains("fixture isolada"),"Credits display provided attribution without invented names")
	game.queue_free()
	await step()
	print("ATLAS_MODULE2 checks=",checks," failures=",failures," max_npc_step=",max_npc_step)
	quit(0 if failures == 0 else 1)
