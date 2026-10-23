extends Node2D
@export var layout: Resource
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,layout.world_size),Color("152c2b"))
	for i in layout.region_bounds.size():
		draw_rect(layout.region_bounds[i].grow(-18),layout.region_colors[i])
	for path in layout.paths:draw_line(Vector2(path.x,path.y),Vector2(path.z,path.w),Color("4a4b38"),layout.path_width)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7771
	for i in 1800:
		var point := Vector2(rng.randf_range(24,layout.world_size.x-24),rng.randf_range(24,layout.world_size.y-24))
		if layout.region_at(point) >= 0:draw_rect(Rect2(point,Vector2(rng.randi_range(2,5),2)),Color("536044") if i%3==0 else Color("304b39"))
	for center in layout.encounter_centers:
		draw_circle(center,108,Color(0.28,0.29,0.23,0.65))
		for i in 16:
			var point: Vector2 = center+Vector2.from_angle(TAU*i/16)*110
			draw_rect(Rect2(point-Vector2(4,3),Vector2(8,6)),Color("6c7060"))
	for water in layout.water:
		draw_rect(water,Color("102a32"))
		for y in range(int(water.position.y)+20,int(water.end.y),28):draw_line(Vector2(water.position.x+20,y),Vector2(water.end.x-20,y-8),Color("1e4249"),2)
	for path in layout.paths:
		var point := Vector2(path.x,path.y)
		draw_colored_polygon(PackedVector2Array([point+Vector2(-5,-5),point+Vector2(6,0),point+Vector2(-5,5)]),Color("b69d68"))
