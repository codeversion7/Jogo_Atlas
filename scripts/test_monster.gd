extends CharacterBody2D
## One provisional creature with committed telegraph, strike and recovery.
signal defeated
const Geometry = preload("res://scripts/combat_geometry.gd")
const MonsterVisual = preload("res://scripts/monster_visual.gd")
const COMBAT_OFFSET := Vector2(0, -8)
@export var max_health: int = 50
@export var move_speed: float = 40.0
@export var damage: int = 20
@export var attack_reach: float = 24.0
@export var windup: float = 0.55
@export var active_duration: float = 0.10
@export var recovery: float = 0.65
@export var stagger_duration: float = 0.85
@export var hurt_radius: float = 8.0
@export var feet_radius: float = 6.0
## Arena legada mantém o setor de referência; o F5 habilita os quatro ataques preparados.
@export var prepared_attacks: bool = false
@export var attack_settings: Resource = preload("res://resources/monster_attacks.tres")
var attack_runtime: Node2D
@export_enum("Fenda", "Carcaça", "Esporo", "Escavador") var monster_kind: int = 0
var visual: Node2D
var health: int
var target: CharacterBody2D
var state: StringName = &"chase"
var remaining: float = 0.0
var attack_direction := Vector2.RIGHT
var dead := false
var hit_target := false
var hurt_flash := 0.0
var death_time := 0.28
var detour_side := 1.0
var detour_wait := 0.0

func _ready() -> void:
	health = max_health
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = 4
	collision_mask = 1 | 4
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = feet_radius
	shape.shape = circle
	shape.position = Vector2(0, -3)
	add_child(shape)
	add_to_group("atlas_combat_targets")
	var shadow := Polygon2D.new()
	shadow.z_index = -2
	shadow.color = Color(0.04,0.05,0.07,0.55)
	var shadow_points := PackedVector2Array()
	for i in 16:
		shadow_points.append(Vector2(cos(i*TAU/16)*8,sin(i*TAU/16)*3-2))
	shadow.polygon = shadow_points
	add_child(shadow)
	visual = MonsterVisual.new()
	visual.monster_kind = monster_kind
	visual.z_index = -1
	add_child(visual)
	if prepared_attacks:
		attack_runtime = preload("res://scripts/monster_attack_runtime.gd").new()
		attack_runtime.actor = self
		attack_runtime.settings = attack_settings
		add_child(attack_runtime)
	detour_side = 1.0 if get_instance_id() % 2 == 0 else -1.0

func combat_center() -> Vector2:
	return global_position + COMBAT_OFFSET

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	hurt_flash = maxf(0, hurt_flash - delta)
	detour_wait = maxf(0, detour_wait - delta)
	if dead:
		visual.visible = false
		if attack_runtime: attack_runtime.cancel()
		death_time -= delta
		queue_redraw()
		if death_time <= 0:
			queue_free()
		return
	if not is_instance_valid(target) or target.dead:
		if attack_runtime: attack_runtime.cancel()
		visual.set_motion(Vector2.ZERO)
		queue_redraw()
		return
	var offset: Vector2 = target.combat_center() - combat_center()
	if prepared_attacks and attack_runtime.playing:
		attack_runtime.advance(delta)
		queue_redraw()
		return
	if state == &"chase":
		var trigger: float = attack_settings.trigger_ranges[monster_kind] if prepared_attacks else attack_reach
		if offset.length() <= trigger and Geometry.clear_line(self, target.combat_center()):
			state = &"windup"
			remaining = windup
			attack_direction = offset.normalized() if not offset.is_zero_approx() else Vector2.RIGHT
			hit_target = false
			if prepared_attacks: attack_runtime.begin()
		else:
			velocity = chase_direction(offset.normalized()) * move_speed
	else:
		remaining -= delta
		if remaining <= 0.0:
			if state == &"windup":
				state = &"attack"
				remaining = active_duration
			elif state == &"attack":
				state = &"recovery"
				remaining = recovery
			else:
				state = &"chase"
		if state == &"attack" and not hit_target and Geometry.touches_sector(offset, attack_direction, attack_reach, PI / 3, target.hurt_radius) and Geometry.clear_line(self, target.combat_center()):
			hit_target = true
			target.receive_attack(damage, self)
	move_and_slide()
	visual.set_motion(get_real_velocity())
	queue_redraw()

func chase_direction(desired: Vector2) -> Vector2:
	# Local detours around simple debris; no navigation-region dependency.
	if not test_move(global_transform, desired * 24):
		return desired
	var angles := [PI / 4, PI / 2, PI * 0.7]
	for angle in angles:
		var candidate := desired.rotated(angle * detour_side)
		if not test_move(global_transform, candidate * 24):
			detour_wait = 0.75
			return candidate
	if detour_wait <= 0:
		detour_side *= -1
		detour_wait = 0.75
	return desired.rotated(PI / 2 * detour_side)

func stagger() -> void:
	if dead:
		return
	if attack_runtime: attack_runtime.cancel()
	state = &"stagger"
	remaining = stagger_duration
	queue_redraw()

func take_damage(amount: int) -> void:
	if dead or amount <= 0:
		return
	health = maxi(0, health - amount)
	hurt_flash = 0.15
	var from_direction := global_position.direction_to(target.global_position) if is_instance_valid(target) else Vector2.RIGHT
	visual.play_hurt(from_direction)
	if health == 0:
		dead = true
		if attack_runtime: attack_runtime.cancel()
		state = &"dead"
		velocity = Vector2.ZERO
		collision_layer = 0
		collision_mask = 0
		remove_from_group("atlas_combat_targets")
		defeated.emit()
	queue_redraw()

func _draw() -> void:
	var color := Color(0.42, 0.24, 0.34)
	if state == &"windup":
		color = Color(0.95, 0.57, 0.23)
	elif state == &"attack":
		color = Color(1.0, 0.82, 0.5)
	elif state == &"recovery":
		color = Color(0.32, 0.28, 0.38)
	elif state == &"stagger":
		color = Color.CYAN
	if hurt_flash > 0:
		color = Color(1.0, 0.65, 0.6)
	if dead:
		draw_ellipse_corpse(color)
		return
	if not prepared_attacks and state in [&"windup", &"attack", &"recovery"]:
		var alpha := 0.3 if state == &"attack" else 0.10
		Geometry.draw_sector(self, COMBAT_OFFSET, attack_direction, attack_reach, PI / 3, Color(1, 0.5, 0.2, alpha))
		if state == &"windup":
			draw_arc(COMBAT_OFFSET, 12, -PI / 2, -PI / 2 + TAU * clampf(1 - remaining / windup, 0.01, 1), 20, Color(1,0.75,0.3), 1)
	if is_instance_valid(target) and target.debug_areas:
		draw_arc(Vector2(0,-3), feet_radius, 0, TAU, 24, Color.LIME_GREEN, 1)
		draw_arc(COMBAT_OFFSET, hurt_radius, 0, TAU, 24, Color.MAGENTA, 1)
	var bar_y: float = -MonsterVisual.Catalog.HEIGHTS[monster_kind]-5
	draw_rect(Rect2(-8, bar_y, 16, 2), Color(0.1,0.1,0.1))
	draw_rect(Rect2(-8, bar_y, 16.0 * health / max_health, 2), Color(0.8,0.9,0.7))

func draw_ellipse_corpse(color: Color) -> void:
	var fade := clampf(death_time / 0.28, 0, 1)
	draw_rect(Rect2(-9,-5,18,5), Color(color, fade))
