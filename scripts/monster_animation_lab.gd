extends Node2D
## F6: quatro monstros e quatro ações simultâneas. Não altera o jogo.
const Visual = preload("res://scripts/monster_visual.gd")
const Catalog = preload("res://scripts/monster_animation_catalog.gd")
const MODES := [&"idle", &"walk", &"run", &"hurt"]
var actors: Array[Node2D] = []
var direction := 0
var elapsed := 0.0
var playback := 1.0
var info: Label

func label(value: String, at: Vector2, size: int = 12) -> Label:
	var node := Label.new()
	node.text = value
	node.position = at
	node.add_theme_font_size_override("font_size",size)
	add_child(node)
	return node

func _ready() -> void:
	# Personagens de referência adicionados no editor não devem deslocar a grade.
	# Preserva os nós/posições existentes; apenas o laboratório usa câmera fixa.
	for camera in find_children("*","Camera2D",true,false):
		camera.enabled = false
	label("ATLAS / ANIMAÇÕES DOS MONSTROS",Vector2(14,8),18)
	info = label("",Vector2(14,32),11)
	for col in 4:
		label(["PARADO","ANDANDO","CORRENDO","DANO"][col],Vector2(145+col*128,56),11)
	for kind in 4:
		label(Catalog.NAMES[kind],Vector2(14,101+kind*61),12)
		for col in 4:
			var actor := Visual.new()
			actor.monster_kind = kind
			actor.automatic = false
			actor.position = Vector2(174+col*128,126+kind*61)
			actor.visual_scale = 1.15
			add_child(actor)
			actors.append(actor)
	label("← → direção · Espaço pausa · L lento · F6 inicia este laboratório",Vector2(14,335),11)
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta*playback
	for i in actors.size():
		var mode: StringName = MODES[i%4]
		var count: int = Visual.COUNTS[mode]
		var index := int(elapsed*float(Visual.FPS[mode])) % (count+10 if mode == &"hurt" else count)
		if mode == &"hurt" and index >= count:
			actors[i].sample(&"idle",Catalog.DIRECTIONS[direction],0)
		else:
			actors[i].sample(mode,Catalog.DIRECTIONS[direction],index)
	info.text = "Direção: %s · velocidade %.2f× · arte original, animação por malha 2D" % [Catalog.DIRECTIONS[direction],playback]

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_RIGHT: direction = (direction+1)%4
		KEY_LEFT: direction = (direction+3)%4
		KEY_SPACE: playback = 1.0 if playback == 0 else 0.0
		KEY_L: playback = 1.0 if playback == 0.25 else 0.25

func _draw() -> void:
	for row in 4:
		draw_rect(Rect2(120,78+row*61,508,55),Color("1b292c"))
		for col in 4:
			draw_shadow(Vector2(174+col*128,127+row*61))

func draw_shadow(at: Vector2) -> void:
	draw_rect(Rect2(at-Vector2(16,2),Vector2(32,4)),Color(0.02,0.03,0.04,0.5))
