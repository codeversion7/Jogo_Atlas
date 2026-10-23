extends Node2D
## One physical weapon, swept metal contact, one hit per target on each leg.
const Pose = preload("res://scripts/dagger_pose.gd")
var wielder: WeakRef
var heading := Vector2.RIGHT
var speed := 220.0
var max_range := 120.0
var timeout := 2.0
var damage := 25
var travelled := 0.0
var return_elapsed := 0.0
var returning := false
var finished := false
var hit_ids: Dictionary = {}
var weapon: Sprite2D
var original_angle := 0.0

func _ready() -> void:
	weapon = Sprite2D.new()
	weapon.centered = false
	var pose := Pose.sample(&"attack_recovery",Vector2.RIGHT,1.0)
	weapon.texture = Pose.DAGGER.get_frame_texture(pose.clip,pose.frame)
	weapon.offset = -pose.hand_px
	original_angle = Vector2(pose.tip-pose.hand).angle()
	add_child(weapon)
	update_rotation()
func update_rotation() -> void:
	if weapon != null: weapon.rotation = heading.angle()-original_angle
func owner_player():
	return wielder.get_ref() if wielder != null else null
func turn_back() -> void:
	if returning: return
	returning = true
	hit_ids.clear()
func _physics_process(delta: float) -> void:
	var player = owner_player()
	if not is_instance_valid(player) or not player.is_inside_tree() or player.dead:
		finish()
		return
	var step_length := speed*delta
	var hand: Vector2 = player.dagger_hand_position()
	if returning:
		return_elapsed += delta
		if return_elapsed >= timeout:
			finish()
			return
		heading = global_position.direction_to(hand)
		step_length = minf(step_length,global_position.distance_to(hand))
	else:
		step_length = minf(step_length,maxf(0,max_range-travelled))
	var before := global_position
	var next := before+heading*step_length
	# Ray covers the leading metal too, preventing a blade tip piercing a wall.
	var query := PhysicsRayQueryParameters2D.create(before,next+heading*12,1)
	var wall := get_world_2d().direct_space_state.intersect_ray(query)
	if not wall.is_empty():
		next = before + heading*maxf(0,before.distance_to(wall.position)-12)
	strike_segment(before+heading*2,next+heading*12)
	global_position = next
	travelled += before.distance_to(next) if not returning else 0
	update_rotation()
	if not wall.is_empty():
		if returning: finish() # Safe recall when a wall separates hand and blade.
		else: turn_back()
	elif returning and global_position.distance_to(hand) <= 1.0:
		finish()
	elif not returning and travelled >= max_range-0.01:
		turn_back()
func strike_segment(start: Vector2, end: Vector2) -> void:
	for target in get_tree().get_nodes_in_group("atlas_combat_targets"):
		var id := target.get_instance_id()
		if target.dead or hit_ids.has(id): continue
		var contact := Geometry2D.get_closest_point_to_segment(target.combat_center(),start,end)
		if contact.distance_to(target.combat_center()) > target.hurt_radius+1.0: continue
		var query := PhysicsRayQueryParameters2D.create(start,target.combat_center(),1)
		if not get_world_2d().direct_space_state.intersect_ray(query).is_empty(): continue
		hit_ids[id] = true
		target.take_damage(damage)
func finish() -> void:
	if finished: return
	finished = true
	var player = owner_player()
	if is_instance_valid(player): player.dagger_returned(self)
	queue_free()
func _exit_tree() -> void:
	if not finished:
		finished = true
		var player = owner_player()
		if is_instance_valid(player): player.dagger_returned(self)
