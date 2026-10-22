extends RefCounted
## Shared reach sector and solid-world visibility for both combatants.
static func touches_sector(offset: Vector2, direction: Vector2, reach: float, half_angle: float, radius: float) -> bool:
	if offset.length() > reach + radius:
		return false
	if offset.is_zero_approx() or absf(direction.angle_to(offset)) <= half_angle:
		return true
	for angle in [-half_angle, half_angle]:
		var edge := direction.rotated(angle) * reach
		if offset.distance_to(Geometry2D.get_closest_point_to_segment(offset, Vector2.ZERO, edge)) <= radius:
			return true
	return false

static func clear_line(actor: Node2D, destination: Vector2) -> bool:
	var origin: Vector2 = actor.combat_center()
	if origin.is_equal_approx(destination):
		return true
	var query := PhysicsRayQueryParameters2D.create(origin, destination, 1)
	return actor.get_world_2d().direct_space_state.intersect_ray(query).is_empty()

static func draw_sector(canvas: Node2D, origin: Vector2, direction: Vector2, reach: float, half_angle: float, color: Color) -> void:
	var points := PackedVector2Array([origin])
	for i in range(17):
		points.append(origin + direction.rotated(lerpf(-half_angle, half_angle, i / 16.0)) * reach)
	canvas.draw_colored_polygon(points, color)
	canvas.draw_arc(origin, reach, direction.angle() - half_angle, direction.angle() + half_angle, 17, Color(color, minf(1.0, color.a + 0.4)), 1.0)
