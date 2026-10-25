extends Control
var game: Node2D
var origin := Vector2(30,72)
var zoom := 0.24
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
	var layout = game.layout
	zoom = minf(580/layout.world_size.x,238/layout.world_size.y)
	var size: float = maxf(16,layout.discovery_cell_size)
	var font := ThemeDB.fallback_font
	for key in game.discovery.cells:
		var area := Rect2(Vector2(key)*size,Vector2.ONE*size)
		var region: int = layout.region_at(area.get_center())
		if region < 0:continue
		draw_rect(Rect2(origin+area.position*zoom,area.size*zoom),layout.region_colors[region].lightened(0.2))
		for wall in game.solid_rects:
			if area.intersects(wall):
				var clip := area.intersection(wall)
				draw_rect(Rect2(origin+clip.position*zoom,clip.size*zoom),Color("8d9780"))
	for i in layout.region_bounds.size():
		var anchor: Vector2 = layout.region_bounds[i].get_center()
		if game.discovery.known(anchor):draw_string(font,origin+anchor*zoom,layout.region_names[i],HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("e9e1c4"))
	for index in game.discovery.landmarks:
		if game.pages.has(index):continue
		var point: Vector2 = layout.page_position(index)
		draw_circle(origin+point*zoom,3,Color("edce83"))
	if game.discovery.known(game.player.position):draw_circle(origin+game.player.position*zoom,3.5,Color("84e2de"))

	if is_instance_valid(game.altar) and game.discovery.known(game.altar.position):
		draw_rect(Rect2(origin+game.altar.position*zoom-Vector2(3,3),Vector2(6,6)),Color("e7d48c"),false,1)
