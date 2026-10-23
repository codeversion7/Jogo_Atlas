extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func run() -> void:
	var State = load("res://scripts/character/character_state.gd")
	var a = State.new()
	var b = State.new()
	check(a.config == b.config,"Base resource shared but read-only")
	a.health = -10
	a.hunger = 400
	a.shield = 9
	check(a.health == 0 and a.hunger == 100 and a.shield == 0,"Current attributes clamp to safe bounds")
	check(b.health == 100 and b.hunger == 100,"Mutable state isolated per character")
	a.health = 100
	a.absorb_damage(-5)
	check(a.health == 100,"Negative damage cannot heal")
	a.overrides.resistance = 0.25
	a.overrides.shield_max = 10
	a.shield = 10
	check(a.absorb_damage(20) == 5 and a.health == 95 and a.shield == 0,"Mitigation then shield then health")
	a.overrides.resistance = 9
	check(is_equal_approx(a.resistance(),0.8),"Resistance upper limit")
	var arena = load("res://scenes/combat_arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var player = arena.player
	player.set_physics_process(false)
	check(player.max_health == 100 and player.dagger_damage == 25 and player.resistance == 0 and player.max_shield == 0,"Existing combat bases preserved")
	check(is_equal_approx(player.dodge_distance,30.4) and is_equal_approx(player.dodge_speed,190) and is_equal_approx(player.dodge_cooldown,0.65),"Dash distance/time/speed coherent with old movement")
	player.resistance = 0.25
	player.max_shield = 10
	player.shield = 10
	check(player.receive_attack(20,player) == &"hit" and player.health == 95 and player.shield == 0,"Damage pipeline integrated to live combat")
	player.hurt_wait = 0
	player.receive_attack(9999,player)
	check(player.dead and player.health == 0,"Lethal damage remains lethal")
	player.return_after_death(Vector2(120,180))
	check(player.health == 50 and player.hunger == 25 and player.shield == 0,"Return keeps existing percentages without shield regeneration")
	player.max_health = 10
	player.max_hunger = 5
	check(player.health == 10 and player.hunger == 5,"Lower maxima clamp current state immediately")
	player.dodge_duration = 0
	player.dodge_cooldown = -2
	check(player.dodge_duration >= 0.01 and player.dodge_cooldown >= 0.01,"Invalid dash tuning cannot divide by zero")
	arena.queue_free()
	await process_frame
	print("ATLAS_MODULE1_ATTRIBUTES checks=",checks," failures=",failures)
	quit(0 if failures == 0 else 1)
