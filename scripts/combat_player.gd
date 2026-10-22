extends "res://scripts/player.gd"
## Adjustable combat prototype: feet collide, body circles receive strikes.
signal health_changed
signal died
const Geometry = preload("res://scripts/combat_geometry.gd")
const COMBAT_OFFSET := Vector2(0, -8)
@export var max_health: int = 100
@export var dagger_damage: int = 25
@export var dagger_reach: float = 30.0
@export var dagger_half_angle: float = 1.05
@export var attack_windup: float = 0.08
@export var attack_duration: float = 0.12
@export var attack_recovery: float = 0.20
@export var parry_window: float = 0.16
@export var parry_recovery: float = 0.35
@export var dodge_duration: float = 0.16
@export var dodge_cooldown: float = 0.65
@export var dodge_speed: float = 190.0
@export var hurt_grace: float = 0.35
@export var hurt_radius: float = 8.0
@export var feet_radius: float = 6.0
@export var debug_areas: bool = false
var health: int = 100
var hunger: float = 100.0
var dead: bool = false
var aim: Vector2 = Vector2.RIGHT
var state: StringName = &"ready"
var remaining: float = 0.0
var dodge_wait: float = 0.0
var hurt_wait: float = 0.0
var locked_direction := Vector2.RIGHT
var struck: Array[int] = []
var feedback_wait := 0.0
var parry_flash := 0.0

func _ready() -> void:
	super._ready()
	health = max_health
	var feet := CircleShape2D.new()
	feet.radius = feet_radius
	$CollisionShape2D.shape = feet
	$CollisionShape2D.position = Vector2(0, -3)
	add_to_group("atlas_combat_player")

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		debug_areas = not debug_areas
		queue_redraw()

func combat_center() -> Vector2:
	return global_position + COMBAT_OFFSET

func _physics_process(delta: float) -> void:
	dodge_wait = maxf(0.0, dodge_wait - delta)
	hurt_wait = maxf(0.0, hurt_wait - delta)
	feedback_wait = maxf(0.0, feedback_wait - delta)
	parry_flash = maxf(0.0, parry_flash - delta)
	if dead:
		velocity = Vector2.ZERO
		update_visual()
		queue_redraw()
		return
	advance_action(delta)
	var movement := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var mouse_direction := combat_center().direction_to(get_global_mouse_position())
	if not mouse_direction.is_zero_approx():
		aim = mouse_direction
	if Input.is_action_just_pressed("attack"):
		try_attack(aim)
	elif Input.is_action_just_pressed("parry"):
		try_parry(aim)
	elif Input.is_action_just_pressed("dodge"):
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
			&"recovery": action = &"attack_recovery"
		if feedback_wait > 0.0 and not dead:
			action = &"hurt"
		visual.set_action(action, locked_direction if state != &"ready" else aim, action_progress())

func try_attack(direction: Vector2) -> bool:
	if dead or state != &"ready" or direction.is_zero_approx():
		return false
	state = &"windup"
	remaining = attack_windup
	locked_direction = direction.normalized()
	struck.clear()
	queue_redraw()
	return true

func strike_targets() -> void:
	if dead or state != &"attack":
		return
	for target in get_tree().get_nodes_in_group("atlas_combat_targets"):
		var id := target.get_instance_id()
		var offset: Vector2 = target.combat_center() - combat_center()
		if not target.dead and id not in struck and Geometry.touches_sector(offset, locked_direction, dagger_reach, dagger_half_angle, target.hurt_radius) and Geometry.clear_line(self, target.combat_center()):
			struck.append(id)
			target.take_damage(dagger_damage)

func try_parry(direction: Vector2) -> bool:
	if dead or state != &"ready" or direction.is_zero_approx():
		return false
	state = &"parry"
	remaining = parry_window
	locked_direction = direction.normalized()
	return true

func try_dodge(direction: Vector2) -> bool:
	if dead or state != &"ready" or dodge_wait > 0.0 or direction.is_zero_approx():
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
	health = maxi(0, health - amount)
	hurt_wait = hurt_grace
	feedback_wait = 0.18
	health_changed.emit()
	if health == 0:
		dead = true
		state = &"dead"
		velocity = Vector2.ZERO
		died.emit()
	update_visual()
	queue_redraw()
	return &"hit"

func return_after_death(location: Vector2) -> void:
	global_position = location
	health = maxi(1, max_health / 2)
	hunger = 25.0
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
	var color := Color(0.84, 0.78, 0.57)
	if state in [&"windup", &"attack", &"recovery"]:
		var alpha := 0.26 if state == &"attack" else 0.07
		Geometry.draw_sector(self, COMBAT_OFFSET, direction, dagger_reach, dagger_half_angle, Color(0.95, 0.78, 0.42, alpha))
		var angle := -dagger_half_angle
		if state == &"attack":
			angle = lerpf(-dagger_half_angle, dagger_half_angle, action_progress())
		elif state == &"recovery":
			angle = dagger_half_angle
		var blade := direction.rotated(angle)
		var tip := COMBAT_OFFSET + blade * dagger_reach
		draw_line(COMBAT_OFFSET + blade * (dagger_reach - 14.0), tip, color, 2.0)
		draw_line(tip - blade * 5 + blade.orthogonal(), tip - blade * 4 - blade.orthogonal(), Color(0.28, 0.24, 0.2), 1.0)
	else:
		draw_line(COMBAT_OFFSET + direction * 11, COMBAT_OFFSET + direction * 22, color, 2.0)
	if state == &"parry" or parry_flash > 0.0:
		draw_arc(COMBAT_OFFSET, 18, direction.angle() - PI / 3, direction.angle() + PI / 3, 12, Color.CYAN, 3.0)
	elif state == &"dodge":
		draw_line(COMBAT_OFFSET - direction * 15, COMBAT_OFFSET, Color(0.3, 0.8, 0.9, 0.65), 5.0)

