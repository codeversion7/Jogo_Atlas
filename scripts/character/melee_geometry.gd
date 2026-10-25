extends RefCounted
const Pose = preload("res://scripts/dagger_pose.gd")
const Sector = preload("res://scripts/combat_geometry.gd")

static func blade_contacts(direction: Vector2, interval: Vector2, origin_from: Vector2, origin_to: Vector2, target_from: Vector2, target_to: Vector2, radius: float) -> PackedVector2Array:
	var contacts := PackedVector2Array()
	var steps := maxi(1,ceili(absf(interval.y-interval.x)*8))
	var old_points := Pose.visible_blade(Pose.sample(&"attack_active",direction,interval.x))
	for step in range(1,steps+1):
		var a := float(step-1)/steps
		var b := float(step)/steps
		var points := Pose.visible_blade(Pose.sample(&"attack_active",direction,lerpf(interval.x,interval.y,b)))
		for i in points.size():
			var point_to: Vector2 = origin_from.lerp(origin_to,b)+points[i]
			var point_from := point_to
			if not old_points.is_empty(): point_from = origin_from.lerp(origin_to,a)+old_points[roundi(float(i)/maxi(1,points.size()-1)*(old_points.size()-1))]
			var relative_from := point_from-target_from.lerp(target_to,a)
			var relative_to := point_to-target_from.lerp(target_to,b)
			if Geometry2D.get_closest_point_to_segment(Vector2.ZERO,relative_from,relative_to).length()<=radius+1.0:contacts.append(point_to)
		old_points = points
	return contacts

static func wave_touches(direction: Vector2, from: Vector2, to: Vector2, radius: float, reach: float, half_angle: float) -> bool:
	if reach<=0:return false
	var steps := maxi(1,ceili(from.distance_to(to)))
	for i in range(steps+1):
		if Sector.touches_sector(from.lerp(to,float(i)/steps),direction,reach,half_angle,radius+0.0001):return true
	return false

static func draw_wave(canvas: Node2D, origin: Vector2, direction: Vector2, reach: float, half_angle: float) -> void:
	if reach>0: Sector.draw_sector(canvas,origin,direction,reach,half_angle,Color(0.35,0.85,0.8,0.23))
