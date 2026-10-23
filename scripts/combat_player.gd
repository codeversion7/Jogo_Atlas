extends "res://scripts/player.gd"
## Adjustable combat prototype: feet collide, body circles receive strikes.
signal health_changed
signal died
const Geometry = preload("res://scripts/combat_geometry.gd")
const Dagger = preload("res://scripts/dagger_pose.gd")
const EnemyTracker = preload("res://scripts/character/enemy_tracker.gd")
var input_guard_frames := 0
var tracker: Node2D
const ReturningDagger = preload("res://scripts/character/returning_dagger.gd")
var thrown_dagger: Node2D
signal skills_changed
const COMBAT_OFFSET := Vector2(0, -8)
const Attributes = preload("res://scripts/character/character_state.gd")
var attributes = Attributes.new()
@export var character_config: Resource = preload("res://resources/character/default_character.tres")
@export var max_health: int:
	get: return attributes.health_max()
	set(value):
		attributes.overrides["health_max"] = maxi(1,value)
		attributes.health = attributes.health
@export var max_hunger: float:
	get: return attributes.hunger_max()
	set(value):
		attributes.overrides["hunger_max"] = maxf(1,value)
		attributes.hunger = attributes.hunger
@export var resistance: float:
	get: return attributes.resistance()
	set(value): attributes.overrides["resistance"] = clampf(value,0,0.8)
@export var max_shield: int:
	get: return attributes.shield_max()
	set(value):
		attributes.overrides["shield_max"] = maxi(0,value)
		attributes.shield = attributes.shield
var shield: int:
	get: return attributes.shield
	set(value): attributes.shield = value
@export var dagger_damage: int:
	get: return attributes.damage()
	set(value): attributes.overrides["melee_damage"] = maxi(0,value)
## Legacy sector tuning, retained for scene compatibility; contact now follows authored blade.
@export var dagger_reach: float = 30.0
@export var dagger_half_angle: float = 1.05
@export var attack_windup: float = 0.08
@export var attack_duration: float = 0.12
@export var attack_recovery: float = 0.20
@export var parry_window: float:
	get: return attributes.parry_window()
	set(value): attributes.overrides["parry_window"] = maxf(0.01,value)
@export var parry_recovery: float:
	get: return attributes.parry_recovery()
	set(value): attributes.overrides["parry_recovery"] = maxf(0.01,value)
@export var dodge_duration: float:
	get: return attributes.dodge_duration()
	set(value): attributes.overrides["dodge_duration"] = maxf(0.01,value)
@export var dodge_cooldown: float:
	get: return attributes.dodge_cooldown()
	set(value): attributes.overrides["dodge_cooldown"] = maxf(0.01,value)
@export var dodge_distance: float:
	get: return attributes.dodge_distance()
	set(value): attributes.overrides["dodge_distance"] = maxf(0,value)
@export var dodge_speed: float:
	get: return dodge_distance / dodge_duration
	set(value): attributes.overrides["dodge_distance"] = maxf(0,value) * dodge_duration
@export var hurt_grace: float = 0.35
@export var hurt_radius: float = 8.0
@export var feet_radius: float = 6.0
@export var debug_areas: bool = false
var health: int:
	get: return attributes.health
	set(value): attributes.health = value
var hunger: float:
	get: return attributes.hunger
	set(value): attributes.hunger = value
var dead: bool = false
var aim: Vector2 = Vector2.RIGHT
var state: StringName = &"ready"
var remaining: float = 0.0
var dodge_wait: float:
	get: return attributes.cooldowns.dodge
	set(value): attributes.cooldowns.dodge = maxf(0,value)
var hurt_wait: float = 0.0
var locked_direction := Vector2.RIGHT
var struck: Array[int] = []
var feedback_wait := 0.0
var parry_flash := 0.0
var recovery_pose: StringName = &"attack_recovery"

func _ready() -> void:
	attributes.config = character_config
	super._ready()
	health = max_health
	hunger = max_hunger
	var feet := CircleShape2D.new()
	feet.radius = feet_radius
	$CollisionShape2D.shape = feet
	$CollisionShape2D.position = Vector2(0, -3)
	add_to_group("atlas_combat_player")
	install_skill_inputs()
	tracker = EnemyTracker.new()
	tracker.name = "EnemyTracker"
	tracker.wielder = weakref(self)
	add_child(tracker)

func install_skill_inputs() -> void:
	for entry in [["throw_dagger",KEY_Q],["track_enemies",KEY_F],["skill_tree",KEY_TAB]]:
		if not InputMap.has_action(entry[0]):
			InputMap.add_action(entry[0])
			var event := InputEventKey.new()
			event.physical_keycode = entry[1]
			InputMap.action_add_event(entry[0],event)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		debug_areas = not debug_areas
		queue_redraw()

func combat_center() -> Vector2:
	return global_position + COMBAT_OFFSET

func _physics_process(delta: float) -> void:
	attributes.tick(delta)
	hurt_wait = maxf(0.0, hurt_wait - delta)
	feedback_wait = maxf(0.0, feedback_wait - delta)
	parry_flash = maxf(0.0, parry_flash - delta)
	if dead:
		velocity = Vector2.ZERO
		update_visual()
		queue_redraw()
		return
	var accept_actions := input_guard_frames <= 0
	input_guard_frames = maxi(0,input_guard_frames-1)
	advance_action(delta)
	var movement := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var mouse_direction := combat_center().direction_to(get_global_mouse_position())
	if not mouse_direction.is_zero_approx():
		aim = mouse_direction
	if Input.is_action_just_pressed("track_enemies") and accept_actions:
		try_track()
	if Input.is_action_just_pressed("throw_dagger") and accept_actions:
		try_throw(aim)
	elif Input.is_action_just_pressed("attack") and accept_actions:
		try_attack(aim)
	elif Input.is_action_just_pressed("parry") and accept_actions:
		try_parry(aim)
	elif Input.is_action_just_pressed("dodge") and accept_actions:
		try_dodge(movement if not movement.is_zero_approx() else aim)
	velocity = locked_direction * dodge_speed if state == &"dodge" else movement * move_speed
	move_and_slide()
	visual.set_motion(get_real_velocity())
	if state == &"attack":
		strike_targets()
	update_visual()
	queue_redraw()

func advance_action(delta: float) -> void:
	if state == &"ready":
		return
	remaining -= delta
	if remaining > 0.0:
		return
	if state == &"windup":
		state = &"attack"
		remaining = attack_duration
	elif state == &"attack":
		state = &"recovery"
		remaining = attack_recovery
	elif state == &"parry":
		recovery_pose = &"parry"
		state = &"recovery"
		remaining = parry_recovery
	else:
		state = &"ready"

func action_progress() -> float:
	var duration := attack_windup
	match state:
		&"attack": duration = attack_duration
		&"recovery": duration = attack_recovery
		&"parry": duration = parry_window
		&"dodge": duration = dodge_duration
	return clampf(1.0 - remaining / maxf(0.001, duration), 0.0, 1.0)

func update_visual() -> void:
	visual.modulate = Color(1.0, 0.45, 0.4) if feedback_wait > 0.0 else Color.WHITE
	if visual.has_method("set_action"):
		var action: StringName = &"" if state == &"ready" else state
		match state:
			&"windup": action = &"attack_windup"
			&"attack": action = &"attack_active"
			&"recovery": action = recovery_pose
		if feedback_wait > 0.0 and not dead:
			action = &"hurt"
		visual.set_action(action, locked_direction if state != &"ready" else aim, action_progress())

func try_attack(direction: Vector2) -> bool:
	if get_tree().paused or dead or state != &"ready" or is_instance_valid(thrown_dagger) or direction.is_zero_approx():
		return false
	recovery_pose = &"attack_recovery"
	state = &"windup"
	remaining = attack_windup
	locked_direction = direction.normalized()
	struck.clear()
	queue_redraw()
	return true

func strike_targets() -> void:
	if dead or is_instance_valid(thrown_dagger) or state != &"attack" or feedback_wait > 0.0:
		return
	var pose := Dagger.sample(&"attack_active", locked_direction, action_progress())
	var points := Dagger.visible_blade(pose)
	for target in get_tree().get_nodes_in_group("atlas_combat_targets"):
		var id := target.get_instance_id()
		if target.dead or id in struck:
			continue
		for point in points:
			var contact := global_position + point
			if contact.distance_to(target.combat_center()) <= target.hurt_radius + 1.0 and Geometry.clear_line(self, contact) and Geometry.clear_line(self, target.combat_center()):
				struck.append(id)
				target.take_damage(dagger_damage)
				break

func try_parry(direction: Vector2) -> bool:
	if get_tree().paused or dead or state != &"ready" or is_instance_valid(thrown_dagger) or direction.is_zero_approx():
		return false
	state = &"parry"
	remaining = parry_window
	locked_direction = direction.normalized()
	return true

func try_dodge(direction: Vector2) -> bool:
	if get_tree().paused or dead or state != &"ready" or dodge_wait > 0.0 or direction.is_zero_approx():
		return false
	state = &"dodge"
	remaining = dodge_duration
	dodge_wait = dodge_cooldown
	locked_direction = direction.normalized()
	return true

func receive_attack(amount: int, source: Node2D) -> StringName:
	if dead or state == &"dodge" or hurt_wait > 0.0 or amount <= 0:
		return &"ignored"
	if not Geometry.clear_line(self, source.combat_center()):
		return &"ignored"
	var incoming := combat_center().direction_to(source.combat_center())
	if state == &"parry" and (incoming.is_zero_approx() or locked_direction.dot(incoming) >= 0.5):
		source.stagger()
		parry_flash = 0.18
		return &"parried"
	attributes.absorb_damage(amount)
	hurt_wait = hurt_grace
	feedback_wait = 0.18
	health_changed.emit()
	if health == 0:
		dead = true
		state = &"dead"
		velocity = Vector2.ZERO
		cancel_skills()
		died.emit()
	update_visual()
	queue_redraw()
	return &"hit"

func return_after_death(location: Vector2) -> void:
	cancel_skills()
	global_position = location
	health = maxi(1, max_health / 2)
	hunger = max_hunger * 0.25
	shield = 0
	dead = false
	state = &"ready"
	remaining = 0.0
	dodge_wait = 0.0
	hurt_wait = hurt_grace
	feedback_wait = 0.0
	velocity = Vector2.ZERO
	visual.set_motion(Vector2.ZERO)
	update_visual()
	health_changed.emit()
	queue_redraw()

func _draw() -> void:
	if debug_areas:
		draw_arc(Vector2(0, -3), feet_radius, 0, TAU, 24, Color.LIME_GREEN, 1.0)
		draw_arc(COMBAT_OFFSET, hurt_radius, 0, TAU, 24, Color.MAGENTA, 1.0)
	if dead:
		return
	var direction := locked_direction if state != &"ready" else aim
	if debug_areas and state == &"attack" and feedback_wait <= 0.0:
		var pose := Dagger.sample(&"attack_active", locked_direction, action_progress())
		for point in Dagger.visible_blade(pose):
			draw_circle(point, 1.0, Color.YELLOW)
	if state == &"parry" or parry_flash > 0.0:
		draw_arc(COMBAT_OFFSET, 18, direction.angle() - PI / 3, direction.angle() + PI / 3, 12, Color.CYAN, 3.0)
	elif state == &"dodge":
		draw_line(COMBAT_OFFSET - direction * 15, COMBAT_OFFSET, Color(0.3, 0.8, 0.9, 0.65), 5.0)


func dagger_hand_position() -> Vector2:
	return visual.to_global(visual.weapon.position) if visual.weapon != null else combat_center()

func try_throw(direction: Vector2) -> bool:
	if get_tree().paused or dead or state != &"ready" or direction.is_zero_approx() or get_tree().paused or is_instance_valid(thrown_dagger) or not attributes.owned.has("throw.unlock") or attributes.cooldowns.throw > 0:
		return false
	var projectile := ReturningDagger.new()
	projectile.wielder = weakref(self)
	projectile.heading = direction.normalized()
	projectile.speed = clampf(character_config.throw_speed,20,1000)
	projectile.max_range = clampf(character_config.throw_range,16,500)
	projectile.timeout = clampf(character_config.return_timeout,0.1,10)
	projectile.damage = attributes.throw_damage()
	thrown_dagger = projectile
	get_parent().add_child(projectile)
	projectile.global_position = dagger_hand_position()
	visual.set_weapon_in_flight(true)
	attributes.cooldowns.throw = clampf(character_config.throw_cooldown,0.01,120)
	skills_changed.emit()
	return true

func dagger_returned(projectile: Node2D) -> void:
	if thrown_dagger == projectile:
		thrown_dagger = null
		if is_instance_valid(visual): visual.set_weapon_in_flight(false)
		skills_changed.emit()

func try_track() -> bool:
	return tracker.start() if is_instance_valid(tracker) else false

func cancel_skills() -> void:
	if is_instance_valid(tracker): tracker.cancel()
	if is_instance_valid(thrown_dagger): thrown_dagger.finish()

func _exit_tree() -> void:
	cancel_skills()
