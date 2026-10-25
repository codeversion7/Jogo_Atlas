extends SceneTree
var checks := 0
var failures := 0
var arena
var player
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
func target(location: Vector2):
	var enemy = load("res://scripts/test_monster.gd").new()
	enemy.position = location
	enemy.target = player
	enemy.max_health = 100
	arena.get_node("World").add_child(enemy)
	enemy.set_physics_process(false)
	return enemy
func reset_throw() -> void:
	player.cancel_skills()
	player.attributes.cooldowns.throw = 0.0
	player.state = &"ready"
func run() -> void:
	arena = load("res://scenes/combat_arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	player = arena.player
	await step()
	check(not player.try_throw(Vector2.RIGHT),"Throw locked until acquired")
	player.attributes.points = 2
	check(player.attributes.buy("throw.unlock"),"Throw acquired with points")
	check(not player.try_throw(Vector2.ZERO),"Zero throw direction rejected")
	var hand: Vector2 = player.dagger_hand_position()
	var enemy = target(hand+Vector2(48,8))
	check(player.try_throw(Vector2.RIGHT),"Unlocked throw launches")
	check(not player.visual.weapon.visible and is_instance_valid(player.thrown_dagger),"One weapon in flight, none in hand")
	check(not player.try_throw(Vector2.RIGHT) and not player.try_attack(Vector2.RIGHT) and not player.try_parry(Vector2.RIGHT),"No duplicate throw or hand-weapon actions during flight")
	await step(18)
	check(enemy.health == 75,"Outbound blade deals one damage per target")
	await step(65)
	check(enemy.health == 50,"Return leg can hit once, without repeated contact damage")
	check(not is_instance_valid(player.thrown_dagger) and player.visual.weapon.visible,"Blade returns to hand")
	check(not player.try_throw(Vector2.RIGHT),"Cooldown begins at launch and remains after return")
	enemy.queue_free()
	await step()
	reset_throw()
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(5,70)
	shape.shape = box
	wall.add_child(shape)
	wall.position = player.dagger_hand_position()+Vector2(30,0)
	arena.get_node("World").add_child(wall)
	enemy = target(player.dagger_hand_position()+Vector2(60,8))
	await step()
	player.try_throw(Vector2.RIGHT)
	await step(50)
	check(enemy.health == 100 and not is_instance_valid(player.thrown_dagger),"Wall turns blade back and prevents damage behind obstacle")
	wall.queue_free()
	enemy.queue_free()
	await step()
	reset_throw()
	player.try_throw(Vector2.RIGHT)
	await step(3)
	var blade = player.thrown_dagger
	var location: Vector2 = blade.position
	var cooldown: float = player.attributes.cooldowns.throw
	paused = true
	await create_timer(0.1,true).timeout
	check(blade.position == location and is_equal_approx(cooldown,player.attributes.cooldowns.throw),"Pause freezes flight and cooldown")
	check(not player.try_throw(Vector2.LEFT),"Paused UI cannot launch a weapon")
	paused = false
	Input.action_press("move_down")
	await step(20)
	Input.action_release("move_down")
	await step(80)
	check(not is_instance_valid(player.thrown_dagger) and player.visual.weapon.visible,"Return follows moving player without permanent weapon loss")
	reset_throw()
	player.try_throw(Vector2.RIGHT)
	player.hurt_wait = 0
	player.receive_attack(9999,player)
	await step()
	check(player.dead and not is_instance_valid(player.thrown_dagger),"Death cleans projectile")
	player.return_after_death(Vector2(120,180))
	check(player.attributes.owned.has("throw.unlock") and player.visual.weapon.visible,"Same-run return preserves acquisition and restores weapon")
	reset_throw()
	player.try_throw(Vector2.RIGHT)
	var removed = target(player.position+Vector2(80,0))
	removed.queue_free()
	await step(6)
	var blocked_return = player.thrown_dagger
	blocked_return.turn_back()
	wall = StaticBody2D.new()
	wall.collision_layer = 1
	shape = CollisionShape2D.new()
	box = RectangleShape2D.new()
	box.size = Vector2(4,80)
	shape.shape = box
	wall.add_child(shape)
	wall.position = player.dagger_hand_position()+Vector2(15,0)
	arena.get_node("World").add_child(wall)
	await step(12)
	check(not is_instance_valid(player.thrown_dagger) and player.visual.weapon.visible,"Impossible return across new wall safely restores weapon")
	wall.queue_free()
	await step()
	reset_throw()
	player.try_throw(Vector2.RIGHT)
	player.thrown_dagger.timeout = 0.01
	player.thrown_dagger.turn_back()
	await step(3)
	check(not is_instance_valid(player.thrown_dagger),"Return timeout prevents permanent projectile loss")
	check(not player.has_method("try_track") and not InputMap.has_action("track_enemies"),"Tracking input and active API removed")
	player.attributes.points = 2
	check(not player.attributes.buy("reach.second"),"Second reach requires first")
	check(player.attributes.buy("reach.first") and player.reach_level==1,"First reach acquired with points")
	check(player.attributes.buy("reach.second") and player.reach_level==2,"Second reach acquired with points")
	check(is_equal_approx(player.dodge_distance,30.4),"Reach does not grant retired dash bonus")
	reset_throw()
	player.try_throw(Vector2.UP)
	var orphan = player.thrown_dagger
	arena.queue_free()
	await step(2)
	check(not is_instance_valid(orphan),"Scene teardown leaves no orphan dagger")
	print("ATLAS_MODULE1_SKILLS checks=",checks," failures=",failures)
	quit(0 if failures == 0 else 1)
