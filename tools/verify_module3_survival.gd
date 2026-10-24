extends SceneTree
## RNG e atores controlados são fixtures explícitas. A caminhada até a fogueira é real.
const Survival = preload("res://scripts/world/survival_state.gd")
const Monster = preload("res://scripts/test_monster.gd")
var checks := 0
var failures := 0
var game
var player
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures+=1; push_error(message)
func step(n: int = 1) -> void:
	for i in n:
		await physics_frame
		await process_frame
func run() -> void:
	var food := Survival.new()
	for id in range(1,5): check(not food.record_death(id,Vector2.ZERO,1.0),"Consecutive miss")
	check(food.misses==4 and food.record_death(5,Vector2.ZERO,1.0) and food.misses==0,"Exactly four misses force the next valid death")
	check(not food.record_death(5,Vector2.ZERO,0.0) and food.pickups.size()==1,"Duplicate death does not alter sequence or duplicate drop")
	check(not food.record_death(6,Vector2.ZERO,1.0) and food.record_death(7,Vector2.ZERO,0.0) and food.misses==0,"Early random success resets consecutive count")
	food.config = food.config.duplicate(true)
	for chance in [0.05,0.10]:
		food.config.meat_chance = chance
		check(food.record_death(int(chance*1000),Vector2.ZERO,chance-0.0001),"Configured chance accepts roll below boundary")
		check(not food.record_death(int(chance*1000)+1,Vector2.ZERO,chance),"Configured chance rejects boundary roll")
	check(food.collect(5) and not food.collect(5) and food.raw==1,"Pickup is consumed once")
	check(food.cook(1000) and not food.cook(1000) and food.cooked==1 and food.raw==0,"Cooking converts exactly one ingredient atomically")
	game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.start_session()
	player = game.player
	await step(3)
	var hunger: float = player.hunger
	await step(60)
	check(player.hunger<hunger and player.health==player.max_health,"Hunger decreases only as active simulation advances")
	game.session_ui.claim(&"map")
	hunger = player.hunger
	await step(30)
	check(player.hunger==hunger,"Map/panels freeze hunger")
	game.session_ui.close()
	player.hunger = 0
	await step(30)
	check(player.hunger==0 and player.health==player.max_health,"Zero hunger has no hidden lethal penalty")
	# Valid death callback fixtures: no real horde skipped or claimed as won.
	game.survival.rng.seed = 63
	for i in 5:
		var monster := Monster.new()
		monster.position = game.layout.campfires[0]
		monster.target = player
		game.get_node("World").add_child(monster)
		monster.set_physics_process(false)
		game.enemies.append(monster)
		monster.defeated.connect(game.on_monster_defeated.bind(monster))
		monster.take_damage(9999)
		var count: int = game.survival.deaths.size()
		game.on_monster_defeated(monster)
		check(game.survival.deaths.size()==count,"Duplicate defeat callback does not grant another death/drop")
	check(game.survival.pickups.size()>=1,"Five valid kills always leave accessible meat")
	var count: int = game.survival.deaths.size()
	var cleanup := Monster.new()
	cleanup.target = player
	game.get_node("World").add_child(cleanup)
	cleanup.queue_free()
	await step(2)
	check(game.survival.deaths.size()==count,"Despawn is not counted as a kill")
	game.interact()
	check(game.survival.raw==0,"Distant pickup cannot be collected")
	if game.session_ui.active!=&"": game.session_ui.close()
	# Walk using the same movement controls and physical obstacles as the user.
	var budget := 400
	while player.position.distance_to(game.layout.campfires[0])>4 and budget>0:
		var direction: Vector2 = player.position.direction_to(game.layout.campfires[0])
		Input.action_press("move_right",maxf(0,direction.x))
		Input.action_press("move_down",maxf(0,direction.y))
		await step()
		budget-=1
	Input.action_release("move_right")
	Input.action_release("move_down")
	check(budget>0,"Campfire is physically reachable from initial safe area")
	check(game.interact()==&"meat" and game.survival.raw==1,"E collects nearby ingredient before camp or dialogue")
	while not game.survival.pickups.is_empty(): game.interact()
	check(game.interact()==&"campfire" and paused,"E opens campfire under shared panel ownership")
	check(not game.camp_action("eat",game.food_generation),"Raw meat cannot be consumed as a meal")
	var generation: int = game.food_generation
	check(game.camp_action("cook",generation),"Campfire cooks a real collected ingredient")
	check(not game.camp_action("cook",generation),"Old button callback cannot repeat transaction")
	player.health = 40
	player.hunger = 10
	check(game.camp_action("eat",game.food_generation) and player.health==65 and player.hunger==45,"Solo meal restores configured health/hunger once")
	var cooked: int = game.survival.cooked
	game.session_ui.close()
	game.interact()
	check(game.survival.cooked==cooked,"Reopening camp cannot duplicate a meal")
	game.session_ui.close()
	# Damage fixtures pin player/NPC briefly; actual navigation tested separately.
	player.set_physics_process(false)
	game.companion.set_physics_process(false)
	for kind in 4:
		player.position = Vector2(180,220)
		player.health = player.max_health
		player.dead = false
		player.state = &"ready"
		game.companion.position = Vector2(180,220)
		game.companion.attributes.health = 100
		game.companion.hurt_wait = 0
		var monster := Monster.new()
		monster.prepared_attacks = true
		monster.monster_kind = kind
		monster.move_speed = 0
		monster.position = Vector2(156,220)
		monster.target = player
		game.get_node("World").add_child(monster)
		await step(2)
		player.position += Vector2(0,70)
		var ticks := 150
		while monster.attack_runtime.playing and ticks>0:
			await step()
			ticks-=1
		check(game.companion.attributes.health==80,"NPC receives one spatially valid attack: "+str(kind))
		check(player.health==player.max_health,"Player leaving attack avoids damage while NPC remains exposed")
		monster.queue_free()
		await step(2)
	check(not game.companion.is_in_group("atlas_combat_targets") and not game.companion.has_method("take_damage"),"NPC remains excluded from dagger/tracker targets")
	# A remote fallen friend is rescued only with one cooked portion at a safe camp.
	var source := Monster.new()
	source.target = player
	source.position = game.companion.position+Vector2(-20,0)
	game.get_node("World").add_child(source)
	source.set_physics_process(false)
	game.companion.hurt_wait = 0
	game.companion.receive_attack(9999,source)
	var fallen_position: Vector2 = game.companion.position
	check(game.companion.dead and game.companion.attributes.health==0,"Zero health leaves recoverable fallen NPC")
	game.companion.reset_at(game.layout.companion_start)
	check(game.companion.position==fallen_position and game.companion.dead,"Player return does not grant a free resurrection")
	source.queue_free()
	player.position = game.layout.campfires[0]
	check(game.interact()==&"campfire","Campfire remains available while friend is fallen")
	check(not game.camp_action("revive",game.food_generation),"No cooked portion means no free rescue")
	# Explicit isolated extra ingredient fixture for share/revive resource accounting.
	game.survival.raw += 2
	game.session_ui.show_campfire()
	game.camp_action("cook",game.food_generation)
	check(game.camp_action("revive",game.food_generation) and not game.companion.dead and game.companion.attributes.health==50,"One cooked portion rescues friend to safe positive health")
	check(game.survival.shares==1 and is_equal_approx(game.survival.shield_bonus_seconds(),0.2),"Rescue counts as exactly one share/+0.2 seconds")
	game.camp_action("cook",game.food_generation)
	var before: int = game.companion.attributes.health
	check(game.camp_action("share",game.food_generation) and game.companion.attributes.health==before+30,"Nearby sharing heals friend independently")
	check(game.survival.shares==2 and is_equal_approx(game.survival.shield_bonus_seconds(),0.4),"Each consumed shared portion adds exactly 0.2")
	game.session_ui.close()
	var misses: int = game.survival.misses
	var shares: int = game.survival.shares
	player.hurt_wait = 0
	player.receive_attack(99999,player)
	var dead_hunger: float = player.hunger
	await step(3)
	check(player.hunger==dead_hunger,"Dead player does not consume hunger")
	check(game.return_player() and player.hunger==25 and game.survival.misses==misses and game.survival.shares==shares,"Return preserves food counter/bonus and 25% hunger")
	game.return_to_menu()
	await step(3)
	game = current_scene
	check(game.survival.raw==0 and game.survival.cooked==0 and game.survival.shares==0 and game.survival.misses==0 and not game.companion.dead,"New session resets survival without changing saved preferences")
	game.queue_free()
	await step(2)
	print("ATLAS_MODULE3_SURVIVAL checks=",checks," failures=",failures)
	quit(0 if failures==0 else 1)
