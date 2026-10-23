extends SceneTree
## Integração real de cena/física. Arte e diversão exigem avaliação humana.

var failures := 0
var checks := 0
var arena
var player

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func step(count: int = 2) -> void:
	for i in count:
		await physics_frame
		await process_frame

func dummy(location: Vector2):
	var monster = load("res://scripts/test_monster.gd").new()
	monster.position = location
	monster.target = player
	arena.get_node("World").add_child(monster)
	monster.set_physics_process(false)
	return monster

func ready_player() -> void:
	player.state = &"ready"
	player.hurt_wait = 0.0
	player.dodge_wait = 0.0

func verify_obstacles() -> void:
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(4, 48)
	collision.shape = rectangle
	wall.add_child(collision)
	wall.position = player.position + Vector2(12, -8)
	arena.get_node("World").add_child(wall)
	var blocked = dummy(player.position + Vector2(24, 0))
	await step()
	ready_player()
	player.try_attack(Vector2.RIGHT)
	await step(6)
	check(blocked.health == 50, "Solid debris occludes player dagger")
	ready_player()
	var before: int = player.health
	check(player.receive_attack(20, blocked) == &"ignored" and player.health == before, "Solid debris occludes enemy damage")
	blocked.set_physics_process(true)
	blocked.state = &"windup"
	blocked.remaining = 0.01
	blocked.attack_direction = Vector2.LEFT
	await step(3)
	check(player.health == before, "Enemy active strike cannot cross solid debris")
	blocked.queue_free()
	wall.queue_free()
	await step()
	ready_player()

func verify_detour_and_lifecycle() -> void:
	var original_health: int = player.health
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(18, 36)
	collision.shape = rectangle
	wall.add_child(collision)
	wall.position = player.position + Vector2(40, -8)
	arena.get_node("World").add_child(wall)
	var walker = dummy(player.position + Vector2(80, 0))
	walker.set_physics_process(true)
	await step(240)
	check(walker.position.distance_to(player.position) <= walker.attack_reach + player.hurt_radius, "Enemy detours around simple solid debris")
	check(player.health < original_health, "Enemy can attack after navigating debris")
	var emitted := [0]
	walker.defeated.connect(func(): emitted[0] += 1)
	walker.take_damage(999)
	walker.take_damage(999)
	check(emitted[0] == 1 and walker.dead, "Enemy death emits once despite repeated damage")
	check(not walker.is_in_group("atlas_combat_targets") and walker.collision_layer == 0, "Corpse immediately leaves contact and target groups")
	wall.queue_free()
	await step(20)
	check(not is_instance_valid(walker), "Death feedback expires without persistent corpse")
	player.health = original_health
	ready_player()

func run() -> void:
	arena = load("res://scenes/combat_arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	player = arena.player
	await step()
	check(arena.encounter == &"explore", "Exploration before trigger")
	check(not arena.collect_page(), "No page before encounter")
	await verify_obstacles()
	await verify_detour_and_lifecycle()
	var front = dummy(player.position + Vector2(20, 0))
	var back = dummy(player.position - Vector2(20, 0))
	var far = dummy(player.position + Vector2(45, 0))
	check(player.try_attack(Vector2.RIGHT), "Dagger starts")
	check(front.health == 50, "No damage during windup")
	player.strike_targets()
	check(front.health == 50, "Manual strike cannot damage outside active phase")
	await step(10)
	check(front.health == 25 and back.health == 50 and far.health == 50, "Active range and facing filter damage")
	check(player.visual.action_state == &"attack_active", "Active strike drives visual action")
	player.strike_targets()
	check(front.health == 25, "One hit per target per swing")
	check(not player.try_attack(Vector2.RIGHT), "No repeated attack during active swing")
	await step(4)
	check(player.state == &"recovery", "Attack recovery is enforced")
	check(not player.try_attack(Vector2.RIGHT), "No attack during recovery")
	await step(15)
	check(player.state == &"ready", "Recovery ends")
	check(player.visual.action_state == &"", "Recovery returns visual to locomotion")
	check(player.try_attack(Vector2.RIGHT), "Next swing starts")
	await step(10)
	check(front.dead, "Next active swing kills target")
	await step()
	ready_player()
	check(player.try_parry(Vector2.LEFT), "Parry starts")
	check(player.receive_attack(20, back) == &"parried" and player.health == 100 and back.state == &"stagger", "Frontal parry prevents damage and staggers")
	ready_player()
	player.try_parry(Vector2.RIGHT)
	check(player.receive_attack(20, back) == &"hit" and player.health == 80, "Rear hit bypasses directional parry")
	ready_player()
	player.try_parry(Vector2.LEFT)
	await step(12)
	check(player.receive_attack(20, back) == &"hit", "Expired parry takes damage")
	ready_player()
	player.try_dodge(Vector2.UP)
	var start: Vector2 = player.position
	check(player.receive_attack(20, back) == &"ignored", "Dodge invulnerability")
	await step(12)
	check(player.position.y < start.y - 10.0, "Dodge moves through physics")
	check(not player.try_dodge(Vector2.UP), "Dodge cooldown after movement ends")
	ready_player()
	player.position = Vector2(120, 94)
	player.try_dodge(Vector2.UP)
	await step(12)
	check(player.position.y >= 91.8, "Dodge cannot cross solid boundary")
	ready_player()
	player.position = Vector2(120, 180)
	back.position = player.position + Vector2(20, 0)
	back.set_physics_process(true)
	back.state = &"chase"
	await step(3)
	check(back.state == &"windup", "Enemy announces attack")
	var before: int = player.health
	await step(42)
	check(player.health == before - back.damage and back.state == &"recovery", "Enemy attacks once after telegraph")
	back.queue_free()
	far.queue_free()
	await step()
	var overlapping = dummy(player.position)
	ready_player()
	player.try_attack(Vector2.RIGHT)
	await step(12)
	check(overlapping.health == 50, "Overlapping body alone does not create invisible blade damage")
	overlapping.set_physics_process(true)
	before = player.health
	await step(39)
	check(player.health == before - overlapping.damage, "Overlapping enemy can attack")
	overlapping.queue_free()
	await step()
	# Entrar no gatilho por entrada real, depois vencer cada onda com golpes reais.
	player.health = player.max_health
	player.position = Vector2(325, 180)
	ready_player()
	Input.action_press("move_right")
	await step(6)
	Input.action_release("move_right")
	check(arena.encounter == &"fighting" and arena.enemies.size() == 2, "Crossing exploration trigger starts first configured wave")
	check(not arena.collect_page(), "Page locked during horde")
	for wave in 3:
		check(arena.enemies.size() == arena.wave_sizes[wave], "Configured wave population")
		for monster in arena.enemies.duplicate():
			monster.set_physics_process(false)
			monster.position = player.position + Vector2(20, 0)
			ready_player()
			player.try_attack(Vector2.RIGHT)
			await step(27)
			player.try_attack(Vector2.RIGHT)
			await step(27)
		check(arena.enemies.is_empty(), "All enemies removed after wave")
		if wave < 2:
			check(arena.encounter == &"between" and not arena.collect_page(), "Page stays locked between waves")
			await step(92)
	check(arena.encounter == &"cleared", "All three waves completed")
	check(not arena.collect_page(), "Collection requires proximity")
	player.position = arena.page_position
	Input.action_press("interact")
	await step()
	Input.action_release("interact")
	check(arena.pages.size() == 1, "E collects first page after horde")
	check(not arena.collect_page() and arena.pages.size() == 1, "Distinct page cannot duplicate")
	# Morte depois de coletar preserva página e aplica os recursos de retorno.
	var source = dummy(player.position + Vector2(20, 0))
	ready_player()
	player.receive_attack(999, source)
	check(player.dead and not player.try_attack(Vector2.RIGHT), "Death blocks actions")
	Input.action_press("test_return")
	await step()
	Input.action_release("test_return")
	check(not player.dead and player.health == 50 and player.hunger == 25.0, "R returns at 50 percent health and 25 percent hunger")
	check(arena.pages.size() == 1 and arena.encounter == &"cleared", "Page survives death and return")
	source.queue_free()
	await step()
	# Morte durante onda cancela os inimigos e reinicia um encontro limpo.
	arena.pages.clear()
	arena.encounter = &"explore"
	arena.begin_encounter()
	var killer = arena.enemies[0]
	ready_player()
	player.receive_attack(999, killer)
	check(arena.enemies.is_empty() and arena.encounter == &"defeated", "Death clears active horde")
	arena.return_player()
	await step(95)
	check(arena.encounter == &"explore" and arena.enemies.is_empty(), "No delayed waves survive return")
	if "--capture" in OS.get_cmdline_user_args():
		arena.begin_encounter()
		await step(3)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/atlas/evidencias/04_combate.png")
		for monster in arena.enemies:
			monster.set_physics_process(false)
		arena.enemies[0].position = player.position + Vector2(21, 0)
		arena.enemies[0].state = &"windup"
		arena.enemies[0].attack_direction = Vector2.LEFT
		arena.enemies[0].queue_redraw()
		ready_player()
		player.try_parry(Vector2.RIGHT)
		await step(2)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/atlas/evidencias/04_parry.png")
		for monster in arena.enemies.duplicate():
			monster.take_damage(999)
		arena.encounter = &"cleared"
		player.position = Vector2(500, 180)
		await step(15)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/atlas/evidencias/04_pagina.png")
	print("ATLAS_COMBAT_TEST checks=", checks, " failures=", failures)
	arena.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)



