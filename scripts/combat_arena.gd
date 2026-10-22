extends "res://scripts/main.gd"
## Primeiro recorte de exploração/confronto. Não é o mapa definitivo.

const Monster = preload("res://scripts/test_monster.gd")
@export var wave_sizes: Array[int] = [2, 3, 4]
@export var wave_interval: float = 1.5
@export var encounter_x: float = 330.0
@export var page_position := Vector2(550, 180)

@onready var player = $World/Player
var enemies: Array[CharacterBody2D] = []
var wave_index := -1
var wait_remaining := 0.0
var encounter: StringName = &"explore"
var pages: Dictionary = {} # Conquistas desta sessão sobrevivem ao retorno.
var markers: Node2D

func _ready() -> void:
	install_test_inputs()
	markers = Node2D.new()
	markers.name = "Markers"
	$World.add_child(markers)
	markers.draw.connect(draw_markers)
	$World/Obstacle.queue_free() # Área de recuo livre neste recorte, sem mapa final.
	$Interface/Title.text = "ATLAS / PRIMEIRA PÁGINA · TESTE"
	$Interface/Title.add_theme_font_size_override("font_size", 18)
	$Interface/Scope.text = "Arte provisória · laranja: preparação · ciano: parry"
	$Interface/Inputs.text = "WASD mover · mouse mirar · clique atacar · direito parry · Espaço esquivar\nAvance à direita para iniciar as ondas. E recolhe a página após o confronto.\nAo morrer: R retorna com metade da vida e 25% de fome; páginas mantidas."
	$Interface/Inputs.add_theme_font_size_override("font_size", 10)
	player.died.connect(on_player_died)
	markers.queue_redraw()

func install_test_inputs() -> void:
	# Mapeamentos experimentais locais à cena, sem substituir as entradas aprovadas.
	if not InputMap.has_action("parry"):
		InputMap.add_action("parry")
		var mouse := InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_RIGHT
		InputMap.action_add_event("parry", mouse)
	for action in {"dodge": KEY_SPACE, "test_return": KEY_R}:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var key := InputEventKey.new()
			key.physical_keycode = {"dodge": KEY_SPACE, "test_return": KEY_R}[action]
			InputMap.action_add_event(action, key)

func _physics_process(delta: float) -> void:
	if player.dead:
		if Input.is_action_just_pressed("test_return"):
			return_player()
	elif encounter == &"explore" and player.position.x >= encounter_x:
		begin_encounter()
	elif encounter == &"between":
		wait_remaining -= delta
		if wait_remaining <= 0.0:
			spawn_wave()
	if Input.is_action_just_pressed("interact"):
		collect_page()
	var phase := "Explore à direita"
	if player.dead:
		phase = "Derrota · R para retornar"
	elif encounter in [&"fighting", &"between"]:
		phase = "Onda %d/%d · monstros %d" % [wave_index + 1, wave_sizes.size(), enemies.size()]
	elif encounter == &"cleared":
		phase = "Página disponível · aproxime-se e use E" if not pages.has("first") else "Primeira página recuperada"
	status_label.text = "Vida %d/%d · Fome %d%% · Páginas %d/5\n%s" % [player.health, player.max_health, int(player.hunger), pages.size(), phase]
	status_label.add_theme_font_size_override("font_size", 11)
	markers.queue_redraw()

func begin_encounter() -> void:
	if encounter != &"explore" or player.dead:
		return
	wave_index = -1
	spawn_wave()

func spawn_wave() -> void:
	wave_index += 1
	if wave_index >= wave_sizes.size():
		encounter = &"cleared"
		return
	encounter = &"fighting"
	var spawn_points := [Vector2(70, 115), Vector2(570, 245), Vector2(570, 115), Vector2(70, 245)]
	# Toda a onda nasce neste passo: não há spawns pendentes ao contar mortes.
	for i in maxi(0, wave_sizes[wave_index]):
		var monster := Monster.new()
		var spawn: Vector2 = spawn_points[i % spawn_points.size()]
		if spawn.distance_to(player.position) < 65.0:
			spawn = Vector2(640 - spawn.x, spawn.y)
		monster.position = spawn
		monster.target = player
		enemies.append(monster)
		monster.defeated.connect(on_monster_defeated.bind(monster))
		$World.add_child(monster)
	if enemies.is_empty():
		finish_wave()

func on_monster_defeated(monster: CharacterBody2D) -> void:
	enemies.erase(monster)
	if enemies.is_empty() and encounter == &"fighting":
		finish_wave()

func finish_wave() -> void:
	if wave_index + 1 >= wave_sizes.size():
		encounter = &"cleared"
	else:
		encounter = &"between"
		wait_remaining = wave_interval

func on_player_died() -> void:
	encounter = &"defeated"
	for monster in enemies:
		monster.queue_free()
	enemies.clear()

func return_player() -> void:
	if not player.dead:
		return
	player.return_after_death(Vector2(120, 180))
	wave_index = -1
	encounter = &"cleared" if pages.has("first") else &"explore"
	wait_remaining = 0.0

func collect_page() -> bool:
	if player.dead or encounter != &"cleared" or pages.has("first") or player.position.distance_to(page_position) > 25.0:
		return false
	pages["first"] = true
	markers.queue_redraw()
	return true

func draw_markers() -> void:
	markers.draw_line(Vector2(encounter_x, 92), Vector2(encounter_x, 235), Color(0.3, 0.5, 0.5), 1.0)
	if encounter == &"cleared" and not pages.has("first"):
		markers.draw_rect(Rect2(page_position - Vector2(5, 8), Vector2(10, 16)), Color(0.95, 0.85, 0.65))
