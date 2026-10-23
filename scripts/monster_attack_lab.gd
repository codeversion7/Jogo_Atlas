extends Node2D
const Visual = preload("res://scripts/monster_attack_visual.gd")
var actors: Array[Node2D] = []
var phase_labels: Array[Label] = []
var elapsed := 0.0
var playback := 1.0
var info: Label

func text(value: String, point: Vector2, size: int = 12) -> Label:
	var label := Label.new()
	label.text = value
	label.position = point
	label.add_theme_font_size_override("font_size",size)
	add_child(label)
	return label

func _ready() -> void:
	text("ATLAS / ATAQUES DOS MONSTROS · ESTUDO DE FRENTE",Vector2(12,10),17)
	info = text("Recursos visuais separados; ainda não substituem o combate por F5.",Vector2(12,36),11)
	for kind in 4:
		text(["FENDA","CARCAÇA","ESPORO","ESCAVADOR"][kind],Vector2(24+kind*158,68),13)
		text(["Corte cruzado","Pancada no chão","Esfera explosiva","Emergência no alvo"][kind],Vector2(13+kind*158,88),11)
		var actor := Visual.new()
		actor.monster_kind = kind
		actor.automatic = false
		actor.position = Vector2(78+kind*158,204)
		actor.scale = Vector2.ONE*2
		add_child(actor)
		actor.play(Vector2(0,28) if kind==2 else Vector2.ZERO)
		actors.append(actor)
		phase_labels.append(text("",Vector2(13+kind*158,289),11))
	text("Escavador: aviso fixa o alvo no início · prévia repetida, sem combo/IA nova",Vector2(12,316),11)
	text("Espaço pausa · L lento · R reinicia · animação frontal; outras vistas pendentes",Vector2(12,338),11)
	show_time(0)
	queue_redraw()

func _process(delta: float) -> void:
	elapsed = fmod(elapsed+delta*playback,2.5)
	show_time(elapsed)

func show_time(time: float) -> void:
	for i in actors.size():
		actors[i].sample(minf(time,actors[i].duration()))
		phase_labels[i].text = "%s · %d%%" % [actors[i].phase,int(actors[i].phase_progress*100)]

func _draw() -> void:
	for kind in 4:
		draw_rect(Rect2(6+kind*158,110,151,168),Color("1b292c"))
		draw_line(Vector2(18+kind*158,204),Vector2(145+kind*158,204),Color("3b5048"),1)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_SPACE: playback = 1 if playback == 0 else 0
		KEY_L: playback = 1 if playback == 0.25 else 0.25
		KEY_R: elapsed = 0
