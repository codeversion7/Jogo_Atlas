extends Node2D
## Revisão somente visual: não aplica dano nem altera o controlador do jogo.
const ROOT := "res://assets/personagem/ataque_adaga_v1/"
const FRAMES = preload("res://assets/personagem/ataque_adaga_v1/atlas_attack_combined.tres")
const DIRECTIONS := ["down","left","right","up"]
const DURATIONS := [0.04,0.04,0.03,0.03,0.03,0.03,0.2/6,0.2/6,0.2/6,0.2/6,0.2/6,0.2/6]
var sprites: Array[AnimatedSprite2D] = []
var phase_label: Label
var elapsed := 0.0
var playback := 1.0
var frame := 0
var show_markers := false
var manifest: Dictionary

func label(value: String, at: Vector2, size: int = 12) -> Label:
	var node := Label.new()
	node.text = value
	node.position = at
	node.add_theme_font_size_override("font_size",size)
	add_child(node)
	return node

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	manifest = JSON.parse_string(FileAccess.get_file_as_string(ROOT+"manifesto.json"))
	label("ATLAS / ATAQUE COM ADAGA · REVISÃO",Vector2(14,10),18)
	label("Corpo, adaga e rastro preparados; integração ao combate em etapa posterior.",Vector2(14,37),11)
	phase_label = label("",Vector2(14,58),12)
	for direction in 4:
		label(["FRENTE","ESQUERDA","DIREITA","COSTAS"][direction],Vector2(44+direction*155,87),11)
		var sprite := AnimatedSprite2D.new()
		sprite.sprite_frames = FRAMES
		sprite.animation = StringName("attack_"+DIRECTIONS[direction])
		sprite.centered = false
		sprite.offset = Vector2(-40,-62)
		sprite.scale = Vector2.ONE*2.3
		sprite.position = Vector2(76+direction*155,242)
		add_child(sprite)
		sprites.append(sprite)
	var dagger := Sprite2D.new()
	dagger.texture = load(ROOT+"adaga_emergencia.svg")
	dagger.centered = false
	dagger.position = Vector2(210,274)
	dagger.scale = Vector2.ONE*2
	add_child(dagger)
	label("Adaga de emergência desgastada\nLâmina curta · camadas substituíveis",Vector2(250,280),12)
	label("Espaço pausa · L lento · ← → quadro a quadro pausado · G marca mão/ponta",Vector2(14,338),11)
	display_frame(0)

func _process(delta: float) -> void:
	if playback == 0:
		return
	elapsed = fmod(elapsed+delta*playback,0.85)
	var cursor := 0.0
	var index := 11
	for i in 12:
		cursor += DURATIONS[i]
		if elapsed < cursor:
			index = i
			break
	display_frame(index)

func display_frame(index: int) -> void:
	frame = clampi(index,0,11)
	for sprite in sprites:
		sprite.pause()
		sprite.set_frame_and_progress(frame,0)
	var phase := "PREPARAÇÃO · sem dano" if frame < 2 else "GOLPE · fase prevista de acerto" if frame < 6 else "RECUPERAÇÃO · sem dano"
	phase_label.text = "%s · quadro %d/12" % [phase,frame+1]
	phase_label.modulate = Color(1,0.8,0.4) if frame in [2,3,4,5] else Color.WHITE
	queue_redraw()

func _draw() -> void:
	for direction in 4:
		var at := Vector2(76+direction*155,242)
		draw_rect(Rect2(at-Vector2(68,135),Vector2(136,155)),Color("1c2a2c"))
		draw_line(at-Vector2(57,0),at+Vector2(57,0),Color("475b57"),1)
		if show_markers and not manifest.is_empty():
			var item: Dictionary = manifest.frames[direction*12+frame]
			var hand := at+(Vector2(item.hand_px[0],item.hand_px[1])-Vector2(40,62))*2.3
			var tip := at+(Vector2(item.tip_px[0],item.tip_px[1])-Vector2(40,62))*2.3
			draw_line(hand,tip,Color.CYAN,1)
			draw_circle(tip,2,Color.GOLD)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_SPACE: playback = 1.0 if playback == 0 else 0.0
		KEY_L: playback = 1.0 if playback == 0.25 else 0.25
		KEY_G: show_markers = not show_markers
		KEY_LEFT:
			playback = 0
			display_frame((frame+11)%12)
		KEY_RIGHT:
			playback = 0
			display_frame((frame+1)%12)
	queue_redraw()
