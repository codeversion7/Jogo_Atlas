extends CharacterBody2D
## Neutral geometric placeholder; noncombatant, never in enemy/target groups.
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
func can_interact() -> bool:
	if not is_instance_valid(player) or player.dead or position.distance_to(player.position)>interaction_distance:return false
	var ray := PhysicsRayQueryParameters2D.create(global_position+Vector2(0,-8),player.combat_center(),1)
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()
func _physics_process(delta: float) -> void:
	elapsed += delta
	velocity = Vector2.ZERO
	if not is_instance_valid(player) or player.dead:
		state = &"idle"
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
	queue_redraw()
func reset_at(safe_point: Vector2) -> void:
	# Only used at session start / death return, never normal obstacle recovery.
	position = safe_point
	velocity = Vector2.ZERO
	route.clear()
	remaining = 0
	state = &"idle"
func _draw() -> void:
	draw_rect(Rect2(-7,-3,14,5),Color(0.03,0.07,0.08,0.6))
	var bob := 1.0 if state == &"follow" and int(elapsed*8)%2==0 else 0.0
	draw_rect(Rect2(-6,-27+bob,12,12),Color("253844"))
	draw_rect(Rect2(-4,-25+bob,8,7),Color("98b9ac"))
	draw_colored_polygon(PackedVector2Array([Vector2(-5,-17+bob),Vector2(5,-17+bob),Vector2(8,-5),Vector2(-8,-5)]),Color("638b96"))
	draw_rect(Rect2(-5,-5,4,5),Color("24333a"))
	draw_rect(Rect2(2,-5,4,5),Color("24333a"))
