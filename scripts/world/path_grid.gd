extends RefCounted
var grid := AStarGrid2D.new()
var cell_size := 24.0
func build(size: Vector2, obstacles: Array[Rect2]) -> void:
	grid.region = Rect2i(Vector2i.ZERO,Vector2i((size/cell_size).ceil()))
	grid.cell_size = Vector2.ONE*cell_size
	grid.offset = Vector2.ONE*cell_size/2
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	for obstacle in obstacles:
		var area := obstacle.grow(7)
		var minimum := Vector2i((area.position/cell_size).floor()).max(Vector2i.ZERO)
		var maximum := Vector2i((area.end/cell_size).ceil()).min(grid.region.end-Vector2i.ONE)
		for y in range(minimum.y,maximum.y+1):
			for x in range(minimum.x,maximum.x+1):
				var key := Vector2i(x,y)
				if area.has_point(grid.get_point_position(key)):grid.set_point_solid(key)
func nearest(point: Vector2) -> Vector2i:
	var origin := Vector2i((point/cell_size).floor())
	var best := Vector2i(-1,-1)
	var distance := INF
	for y in range(-2,3):
		for x in range(-2,3):
			var key := origin+Vector2i(x,y)
			if not grid.is_in_boundsv(key) or grid.is_point_solid(key):continue
			var delta := grid.get_point_position(key).distance_squared_to(point)
			if delta < distance:best = key;distance = delta
	return best
func path(from: Vector2, to: Vector2) -> PackedVector2Array:
	var start := nearest(from)
	var end := nearest(to)
	if start.x < 0 or end.x < 0:return PackedVector2Array()
	return grid.get_point_path(start,end)
