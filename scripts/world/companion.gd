extends CharacterBody2D
## Acompanhante não combatente; visual independente das regras de navegação.
const Visual = preload("res://scripts/companion_visual.gd")
signal fallen
signal revived
const Geometry = preload("res://scripts/combat_geometry.gd")
var attributes = preload("res://scripts/character/character_state.gd").new()
var dead := false
var hurt_radius := 8.0
var hurt_wait := 0.0
var visual: Node2D
@export var follow_speed := 120.0
@export var follow_distance := 42.0
@export var interaction_distance := 44.0
@export var path_interval := 0.35
var player: Node2D
var navigation: RefCounted
var state: StringName = &"idle"
var route := PackedVector2Array()
var route_index := 0
var remaining := 0.0
var elapsed := 0.0
func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = 8
	collision_mask = 1
	add_to_group("atlas_companion")
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 5
	shape.shape = circle
	shape.position = Vector2(0,-3)
	add_child(shape)
	visual = Visual.new()
	add_child(visual)
func can_interact() -> bool:
	if dead or not is_instance_valid(player) or player.dead or position.distance_to(player.position)>interaction_distance:return false
	var ray := PhysicsRayQueryParameters2D.create(global_position+Vector2(0,-8),player.combat_center(),1)
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()
func _physics_process(delta: float) -> void:
	hurt_wait = maxf(0,hurt_wait-delta)
	if dead:
		velocity = Vector2.ZERO
		state = &"fallen"
		queue_redraw()
		return
	elapsed += delta
	velocity = Vector2.ZERO
	if not is_instance_valid(player) or player.dead:
		state = &"idle"
		visual.set_motion(Vector2.ZERO)
		return
	remaining -= delta
	if position.distance_to(player.position) <= follow_distance:
		state = &"idle"
	else:
		state = &"follow"
		if remaining <= 0 or route.is_empty():
			route = navigation.path(global_position,player.global_position)
			route_index = 1 if route.size()>1 else 0
			remaining = maxf(0.1,path_interval)
		while route_index<route.size() and global_position.distance_to(route[route_index])<5:route_index += 1
		if route_index<route.size():velocity = global_position.direction_to(route[route_index])*maxf(1,follow_speed)
	move_and_slide()
	visual.set_motion(velocity)
	queue_redraw()
func reset_at(safe_point: Vector2) -> void:
	if dead: return # Retornar o jogador não reanima o amigo gratuitamente.
	# Only used at session start / death return, never normal obstacle recovery.
	position = safe_point
	velocity = Vector2.ZERO
	route.clear()
	remaining = 0
	state = &"idle"
	if is_instance_valid(visual):visual.play("idle",0)
func combat_center() -> Vector2: return global_position+Vector2(0,-8)
func receive_attack(amount: int, source: Node2D) -> StringName:
	if dead or hurt_wait>0 or amount<=0 or get_tree().paused or not Geometry.clear_line(self,source.combat_center()): return &"ignored"
	attributes.absorb_damage(amount)
	hurt_wait = 0.35
	visual.play("hurt")
	if attributes.health==0:
		dead = true
		state = &"fallen"
		velocity = Vector2.ZERO
		route.clear()
		visual.modulate = Color(0.45,0.45,0.45)
		fallen.emit()
	queue_redraw()
	return &"hit"
func heal(amount: int) -> void:
	if not dead: attributes.health += maxi(0,amount)
	queue_redraw()
func revive_at(point: Vector2, health: int) -> void:
	if not dead: return
	dead = false
	attributes.health = maxi(1,health)
	visual.modulate = Color.WHITE
	reset_at(point)
	hurt_wait = 0.35
	revived.emit()
func _draw() -> void:
	if dead:
		draw_line(Vector2(-4,-38),Vector2(4,-30),Color.SALMON,2)
		draw_line(Vector2(-4,-30),Vector2(4,-38),Color.SALMON,2)
	else:
		draw_rect(Rect2(-9,-38,18,2),Color(0.05,0.08,0.08))
		draw_rect(Rect2(-9,-38,18.0*attributes.health/attributes.health_max(),2),Color(0.4,0.8,0.8))
	draw_rect(Rect2(-7,-3,14,5),Color(0.03,0.07,0.08,0.6))
