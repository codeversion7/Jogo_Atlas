extends Node2D
## Full group query at limited cadence; tracked handles are weak and validated locally.
var wielder: WeakRef
var remaining := 0.0
var poll_remaining := 0.0
var radius := 160.0
var interval := 0.2
var targets: Array[WeakRef] = []
var scans := 0
func start() -> bool:
	var player = wielder.get_ref()
	if not is_instance_valid(player) or player.dead or get_tree().paused or not player.attributes.owned.has("tracking.unlock") or player.attributes.cooldowns.tracking > 0:
		return false
	radius = clampf(player.character_config.tracking_radius,16,500)
	interval = clampf(player.character_config.tracking_interval,0.1,2)
	remaining = clampf(player.character_config.tracking_duration,0.1,60)
	player.attributes.cooldowns.tracking = clampf(player.character_config.tracking_cooldown,0.01,120)
	scan()
	player.skills_changed.emit()
	return true
func valid_target(target: Node2D, player: Node2D) -> bool:
	return is_instance_valid(target) and target.is_inside_tree() and not target.dead and target.global_position.distance_squared_to(player.global_position) <= radius*radius
func scan() -> void:
	var player = wielder.get_ref()
	if not is_instance_valid(player): return
	targets.clear()
	for target in get_tree().get_nodes_in_group("atlas_combat_targets"):
		if valid_target(target,player): targets.append(weakref(target))
	poll_remaining = interval
	scans += 1
	queue_redraw()
func _physics_process(delta: float) -> void:
	if remaining <= 0: return
	var player = wielder.get_ref()
	if not is_instance_valid(player) or player.dead:
		cancel()
		return
	remaining = maxf(0,remaining-delta)
	if remaining <= 0:
		cancel()
		player.skills_changed.emit()
		return
	poll_remaining -= delta
	if poll_remaining <= 0: scan()
	for i in range(targets.size()-1,-1,-1):
		if not valid_target(targets[i].get_ref(),player): targets.remove_at(i)
	queue_redraw()
func cancel() -> void:
	remaining = 0
	targets.clear()
	queue_redraw()
func _draw() -> void:
	if remaining <= 0: return
	var player = wielder.get_ref()
	if not is_instance_valid(player): return
	for handle in targets:
		var target = handle.get_ref()
		if not valid_target(target,player): continue
		var direction: Vector2 = player.global_position.direction_to(target.global_position)
		if direction.is_zero_approx(): direction = Vector2.UP
		var end: Vector2 = player.COMBAT_OFFSET + direction*28
		var side := direction.orthogonal()*3
		draw_colored_polygon(PackedVector2Array([end+direction*4,end-direction*3+side,end-direction*3-side]),Color("75e2ce"))
