extends Node2D
## Piso e marcos próprios. Detalhes determinísticos; não há geração procedural de gameplay.
@export var world_size := Vector2(2240, 800)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, world_size),Color("152c2b"))
	var colors := [Color("243a36"),Color("243b32"),Color("343e38"),Color("353d3c"),Color("213a35"),Color("23382f"),Color("3d4339")]
	for row in 2:
		for col in 4:
			if row == 1 and col == 3:
				continue
			var tint: Color = colors[mini(row*4+col,colors.size()-1)]
			draw_rect(Rect2(col*560+18,row*400+18,524,364),tint)
	# Ligação clara: caminho principal e ramificações até as clareiras inferiores.
	draw_polyline(PackedVector2Array([Vector2(120,220),Vector2(350,220),Vector2(530,200),Vector2(850,210),Vector2(1400,210),Vector2(1960,210)]),Color("514f3c"),56)
	for x in [280,840,1400]:
		draw_line(Vector2(x,220),Vector2(x,610),Color("4a4b38"),48)
	draw_line(Vector2(280,610),Vector2(1400,610),Color("4a4b38"),50)
	# Lajes quebradas e vegetação baixa fora da passagem central.
	var rng := RandomNumberGenerator.new()
	rng.seed = 7771
	for i in 1800:
		var p := Vector2(rng.randi_range(24,2210),rng.randi_range(24,776))
		if p.x > 1680 and p.y > 390:
			continue
		var color := Color("536044") if i%3 == 0 else Color("304b39")
		draw_rect(Rect2(p,Vector2(rng.randi_range(2,5),2)),color)
	for center in [Vector2(840,210),Vector2(1400,210),Vector2(1960,210),Vector2(840,610),Vector2(1400,610)]:
		draw_circle(center,108,Color(0.28,0.29,0.23,0.65))
		for i in 16:
			var a := TAU * i/16
			var p: Vector2 = center + Vector2.from_angle(a)*110
			draw_rect(Rect2(p-Vector2(4,3),Vector2(8,6)),Color("6c7060"))
	# Coque partido, sulco de impacto e cabos: área inicial reconhecível.
	draw_polyline(PackedVector2Array([Vector2(24,98),Vector2(90,132),Vector2(155,148),Vector2(220,160)]),Color("162628"),22)
	draw_polyline(PackedVector2Array([Vector2(170,140),Vector2(205,170),Vector2(250,166),Vector2(280,194)]),Color("a37d4e"),2)
	# Água inacessível: costa recortada no quadrante sul-leste.
	draw_rect(Rect2(1680,400,560,400),Color("102a32"))
	for y in range(420,800,28):
		draw_line(Vector2(1700,y),Vector2(2220,y-8),Color("1e4249"),2)
	# Glifos de orientação geométricos, sem texto narrativo inventado.
	for x in [510,1070,1630]:
		draw_colored_polygon(PackedVector2Array([Vector2(x,196),Vector2(x+13,205),Vector2(x,214)]),Color("b69d68"))
