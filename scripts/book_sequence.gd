extends Node2D
## 5/5 -> folhear -> torre de luz -> desaparecimento. Atualizado pelo percurso.
var elapsed := -1.0
var phase: StringName = &"hidden"

func advance(delta: float) -> void:
	elapsed += delta
	if elapsed < 1.6:
		phase = &"flipping"
	elif elapsed < 3.6:
		phase = &"light"
	elif elapsed < 5.0:
		phase = &"vanishing"
	else:
		phase = &"complete"
	queue_redraw()

func _draw() -> void:
	if elapsed < 0 or phase == &"complete":
		return
	var alpha := 1.0 if phase != &"vanishing" else clampf((5.0-elapsed)/1.4,0,1)
	if phase in [&"light", &"vanishing"]:
		var strength := minf(1,(elapsed-1.6)*2.0) * (alpha if phase == &"vanishing" else 1.0)
		for i in range(7,0,-1):
			draw_rect(Rect2(-i*7,-360,i*14,360),Color(0.65,0.94,0.88,0.045*strength))
			draw_line(Vector2(-i*3,0),Vector2(-i*3,-350),Color(0.8,1,0.9,0.15*strength),2)
		for i in 25:
			var y := -fmod(elapsed*85+i*17,320)
			draw_rect(Rect2(sin(i*4.1)*32,y,2,4),Color(0.9,1,0.75,strength))
	draw_set_transform(Vector2(0,-28-sin(elapsed*3)*3),0,Vector2.ONE*alpha)
	draw_rect(Rect2(-23,-12,46,29),Color(0.3,0.2,0.15,alpha))
	draw_rect(Rect2(-21,-14,20,27),Color(0.87,0.81,0.62,alpha))
	draw_rect(Rect2(1,-14,20,27),Color(0.98,0.92,0.73,alpha))
	for y in [-7,-2,3,8]:
		draw_line(Vector2(-17,y),Vector2(-5,y),Color(0.42,0.39,0.3,alpha),1)
		draw_line(Vector2(5,y),Vector2(17,y),Color(0.42,0.39,0.3,alpha),1)
	if phase == &"flipping":
		var width := cos(elapsed*32)*20
		draw_colored_polygon(PackedVector2Array([Vector2.ZERO,Vector2(0,-16),Vector2(width,-19),Vector2(width,11)]),Color(1,0.96,0.79))
	draw_set_transform(Vector2.ZERO)
