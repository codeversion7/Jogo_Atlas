extends Node2D
const Visual = preload("res://scripts/companion_visual.gd")
const STATES := ["idle","walk","run","hurt","shield"]
var actors: Array[Node2D] = []
var elapsed := 0.0
var playback := 1.0

func label(value: String, at: Vector2, size: int = 12) -> void:
	var text := Label.new()
	text.text = value
	text.position = at
	text.add_theme_font_size_override("font_size",size)
	add_child(text)

func _ready() -> void:
	label("ATLAS · ANIMAÇÕES DO ACOMPANHANTE",Vector2(12,8),17)
	label("Espaço pausa · L lento · R reinicia · escudo visual provisório, sem proteção",Vector2(12,32),11)
	for col in 4:
		label(["FRENTE","ESQUERDA","DIREITA","COSTAS"][col],Vector2(142+col*135,49))
	for row in STATES.size():
		label(["Espera","Caminhada","Corrida","Dano","Puxar escudo"][row],Vector2(8,86+row*53))
		for col in 4:
			var actor := Visual.new()
			actor.automatic = false
			actor.position = Vector2(170+col*135,112+row*53)
			actor.scale = Vector2.ONE*1.25
			add_child(actor)
			actor.play(STATES[row],col)
			actors.append(actor)
	show_time(0)
	queue_redraw()

func show_time(time: float) -> void:
	for actor in actors:
		var duration := float(Visual.TIMES[actor.state])
		actor.sample(fposmod(time,duration+0.4) if actor.state in ["shield","hurt"] else time)

func _process(delta: float) -> void:
	elapsed += delta*playback
	show_time(elapsed)

func _draw() -> void:
	for row in 5:
		draw_rect(Rect2(128,76+row*53,500,51),Color("1b292c"))
		for col in 4:
			draw_line(Vector2(150+col*135,112+row*53),Vector2(190+col*135,112+row*53),Color("45605b"))

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE: playback = 1 if playback == 0 else 0
			KEY_L: playback = 1 if playback == 0.25 else 0.25
			KEY_R: elapsed = 0
