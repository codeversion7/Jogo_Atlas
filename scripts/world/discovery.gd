extends RefCounted
## Session-only local cells. No full-region unlock, hidden outline or global marker scan.
var cells: Dictionary = {}
var landmarks: Dictionary = {}
var last_cell := Vector2i(-999,-999)
var layout: Resource
var revision := 0
func cell_at(point: Vector2) -> Vector2i: return Vector2i((point/maxf(16,layout.discovery_cell_size)).floor())
func known(point: Vector2) -> bool: return cells.has(cell_at(point))
func observe(player: Node2D, force: bool = false) -> void:
	var current := cell_at(player.global_position)
	if current == last_cell and not force: return
	last_cell = current
	var size := maxf(16,layout.discovery_cell_size)
	var radius := clampf(layout.discovery_radius,size,160)
	var steps := ceili(radius/size)
	var changed := false
	for y in range(-steps,steps+1):
		for x in range(-steps,steps+1):
			var key := current+Vector2i(x,y)
			var point := (Vector2(key)+Vector2(0.5,0.5))*size
			if layout.region_at(point) < 0 or point.distance_to(player.global_position)>radius:continue
			var ray := PhysicsRayQueryParameters2D.create(player.combat_center(),point,1)
			if not player.get_world_2d().direct_space_state.intersect_ray(ray).is_empty():continue
			if not cells.has(key):
				cells[key] = true
				changed = true
	# Current occupied cell is always known; no hidden region boundary is inferred.
	if not cells.has(current): cells[current] = true; changed = true
	for i in layout.encounter_centers.size():
		var point: Vector2 = layout.page_position(i)
		if known(point) and point.distance_to(player.global_position)<=radius:
			var ray := PhysicsRayQueryParameters2D.create(player.combat_center(),point,1)
			if player.get_world_2d().direct_space_state.intersect_ray(ray).is_empty() and not landmarks.has(i):
				landmarks[i] = true
				changed = true
	if changed: revision += 1
