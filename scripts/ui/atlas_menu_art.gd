extends Node2D
## Composição original em primitivas, sem cópia de screenshots ou mapa real revelado.
var ending := false
var elapsed := 0.0
var duo: Node2D
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	duo = Node2D.new()
	add_child(duo)
	var hero := Sprite2D.new()
	var frames: SpriteFrames = preload("res://assets/personagem/provisorio/atlas_motion.tres")
	hero.texture = frames.get_frame_texture(&"idle_down",0)
	hero.centered = false
	hero.offset = Vector2(-20,-46)
	hero.position = Vector2(495,288)
	hero.scale = Vector2.ONE*1.25
	hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	duo.add_child(hero)
	var companion := Sprite2D.new()
	var texture := AtlasTexture.new()
	texture.atlas = preload("res://assets/npcs/companheiro/pixel_v2/companheiro_idle_48x64.png")
	texture.region = Rect2(0,0,48,64)
	companion.texture = texture
	companion.centered = false
	companion.offset = Vector2(-24,-60)
	companion.position = Vector2(532,288)
	companion.scale = Vector2.ONE*0.875
	companion.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	duo.add_child(companion)
func configure(is_ending: bool) -> void:
	ending = is_ending
	visible = true
	queue_redraw()
func _process(delta: float) -> void:
	if not visible: return
	elapsed += delta
	queue_redraw()
func _draw() -> void:
	draw_rect(Rect2(0,0,640,360),Color("0b171b"))
	# Ilha simbólica: não usa limites, páginas ou caminhos desconhecidos da partida.
	draw_colored_polygon(PackedVector2Array([Vector2(0,289),Vector2(46,267),Vector2(87,214),Vector2(139,207),Vector2(171,230),Vector2(204,222),Vector2(233,267),Vector2(267,287),Vector2(220,322),Vector2(66,330)]),Color("152d30"))
	draw_colored_polygon(PackedVector2Array([Vector2(392,289),Vector2(430,246),Vector2(476,224),Vector2(518,234),Vector2(558,207),Vector2(600,230),Vector2(640,279),Vector2(640,326),Vector2(420,330)]),Color("173033"))
	for i in 11:
		var y := 285+i*6
		draw_line(Vector2(20+i%3*12,y),Vector2(190-i%4*9,y),Color("294042"),1)
		draw_line(Vector2(448+i%3*10,y),Vector2(620-i%4*9,y),Color("294042"),1)
	for i in 22:
		var point := Vector2(32+(i*83)%577,28+(i*37)%190)
		if point.x<185 or point.x>455: draw_rect(Rect2(point,Vector2(1,1)),Color(0.65,0.76,0.66,0.18+0.12*sin(elapsed*0.6+i)))
	# Enquadramento interrompido e fita vermelha, motivos próprios de ATLAS.
	for x in [195,445]:
		var sign_x := 1 if x<320 else -1
		draw_line(Vector2(x,40),Vector2(x+sign_x*22,40),Color("947c51"),1)
		draw_line(Vector2(x,40),Vector2(x,97),Color("947c51"),1)
	draw_colored_polygon(PackedVector2Array([Vector2(210,101),Vector2(268,101),Vector2(260,106),Vector2(218,106),Vector2(210,111)]),Color("994637"))
	draw_line(Vector2(373,104),Vector2(428,104),Color("518b87"),2)
	for i in 5:
		var point := Vector2(266+i*24,158)
		draw_rect(Rect2(point,Vector2(12,16)),Color("d5bd82") if ending else Color("203b3c"))
		draw_rect(Rect2(point,Vector2(12,16)),Color("bda46f"),false,1)
		draw_line(point+Vector2(3,5),point+Vector2(9,5),Color("6a664d"),1)
		draw_line(point+Vector2(3,8),point+Vector2(8,8),Color("6a664d"),1)
	draw_rect(Rect2(208,183,224,138),Color("0c1a1e"))
	draw_line(Vector2(220,321),Vector2(420,321),Color("45564d"),1)
	var font := ThemeDB.fallback_font
	draw_string(font,Vector2(32,337),"ATLAS · PRIMEIRA PARTE" if not ending else "ATLAS · O LIVRO DESAPARECEU",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("97aaa0"))
	draw_circle(Vector2(495,288),8,Color("0b171b"))
	draw_circle(Vector2(532,288),8,Color("0b171b"))
	if not ending:
		draw_rect(Rect2(129,245,22,28),Color("b19b6f"),false,2)
		draw_line(Vector2(133,249),Vector2(147,249),Color("d9c99c"),2)
		draw_line(Vector2(140,245),Vector2(140,273),Color("73634d"),1)
	else:
		for i in 5: draw_rect(Rect2(Vector2(129+i*5,247-i%3*7),Vector2(2,2)),Color("729b8d"))
