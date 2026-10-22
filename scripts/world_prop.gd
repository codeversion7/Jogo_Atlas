extends Node2D
## Arte vetorial própria, desenhada na grade de pixels. Pivô no chão para Y-sort.
@export_enum("rock", "tree", "wreck", "pillar", "crate", "beacon") var kind: String = "rock"
@export var footprint := Vector2(32, 20)
@export var solid := true

func _ready() -> void:
	if solid:
		var body := StaticBody2D.new()
		body.collision_layer = 1
		body.collision_mask = 2 | 4
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = footprint
		shape.shape = rect
		shape.position.y = -footprint.y / 2.0
		body.add_child(shape)
		add_child(body)
	queue_redraw()

func poly(points: Array, tint: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), tint)

func _draw() -> void:
	var w := footprint.x / 2.0
	var h := footprint.y
	draw_ellipse_shadow(w + 6)
	match kind:
		"tree":
			draw_rect(Rect2(-5, -45, 10, 44), Color("30332c"))
			draw_rect(Rect2(-2, -40, 3, 35), Color("72614a"))
			poly([Vector2(-42,-33),Vector2(-28,-64),Vector2(-17,-72),Vector2(-21,-90),Vector2(0,-112),Vector2(23,-85),Vector2(18,-71),Vector2(38,-53),Vector2(43,-29)],Color("122d2b"))
			poly([Vector2(-32,-40),Vector2(-17,-65),Vector2(-10,-65),Vector2(0,-99),Vector2(16,-78),Vector2(9,-60),Vector2(28,-47),Vector2(30,-36)],Color("24463d"))
			draw_line(Vector2(-22,-46),Vector2(10,-46),Color("42604c"),3)
		"wreck":
			poly([Vector2(-w,0),Vector2(-w-12,-h-12),Vector2(-w+6,-h-40),Vector2(w-8,-h-34),Vector2(w+12,-h-3),Vector2(w,0)],Color("253843"))
			poly([Vector2(-w-8,-h-13),Vector2(-w+9,-h-36),Vector2(w-9,-h-31),Vector2(w+7,-h-7),Vector2(4,-h)],Color("596b6c"))
			draw_line(Vector2(-w+8,-h-30),Vector2(w-14,-h-24),Color("8a9b94"),4)
			draw_rect(Rect2(-18,-h-24,30,14),Color("101e26"))
			draw_line(Vector2(-14,-h-20),Vector2(7,-h-17),Color("6aa4aa"),2)
			draw_line(Vector2(w-3,-h-15),Vector2(w-9,-5),Color("9d674a"),3)
		"pillar":
			draw_rect(Rect2(-w,-65,footprint.x,65),Color("404d4a"))
			draw_rect(Rect2(-w+4,-61,7,58),Color("64736a"))
			draw_rect(Rect2(-w-4,-71,footprint.x+8,9),Color("748074"))
			draw_rect(Rect2(-w-3,-8,footprint.x+6,8),Color("313f3b"))
			draw_line(Vector2(1,-55),Vector2(-3,-31),Color("172a29"),2)
		"crate":
			draw_rect(Rect2(-w,-h-8,footprint.x,h+8),Color("554f3d"))
			draw_rect(Rect2(-w+3,-h-5,footprint.x-6,h),Color("847759"))
			draw_line(Vector2(-w+4,-h+1),Vector2(w-4,-4),Color("453e32"),3)
			draw_rect(Rect2(-4,-h-5,8,h),Color("b9a078"),false,2)
		"beacon":
			draw_rect(Rect2(-7,-28,14,28),Color("344a4b"))
			draw_rect(Rect2(-5,-33,10,9),Color("d8b879"))
			draw_rect(Rect2(-2,-31,4,5),Color("fff0b2"))
		_:
			poly([Vector2(-w,0),Vector2(-w-5,-h+4),Vector2(-w+3,-h-10),Vector2(w-8,-h-17),Vector2(w+4,-h+2),Vector2(w,0)],Color("344541"))
			poly([Vector2(-w+1,-h+3),Vector2(-w+5,-h-7),Vector2(w-9,-h-13),Vector2(w-1,-h+2)],Color("647168"))
			draw_line(Vector2(-w+5,-h+4),Vector2(w-6,-h+7),Color("7a8470"),2)

func draw_ellipse_shadow(width: float) -> void:
	draw_rect(Rect2(-width,-5,width*2,8),Color(0.025,0.05,0.06,0.4))
