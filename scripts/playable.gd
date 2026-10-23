extends Node2D
## Percurso compacto completo. Não há persistência em disco nem regras de alimentação.

const Monster = preload("res://scripts/test_monster.gd")
const Prop = preload("res://scripts/world_prop.gd")
const Ground = preload("res://scripts/world_ground.gd")
const Book = preload("res://scripts/book_sequence.gd")
const CharacterPanel = preload("res://scripts/ui/character_panel.gd")
var character_panel: CanvasLayer
var skills_bar: Label
const SessionUI = preload("res://scripts/ui/session_ui.gd")
const CompanionScene = preload("res://scenes/companion.tscn")
const PathGrid = preload("res://scripts/world/path_grid.gd")
var companion: CharacterBody2D
var navigation = PathGrid.new()
const Discovery = preload("res://scripts/world/discovery.gd")
var session_ui: CanvasLayer
var session_started := false
var discovery = Discovery.new()
@export var layout: Resource
@onready var player = $World/Player
var enemies: Array[CharacterBody2D] = []
var pages: Dictionary = {}
var cleared: Dictionary = {}
var active_encounter := -1
var wave_index := -1
var wait_remaining := 0.0
var encounter: StringName = &"explore"
var ending: StringName = &"none"
var ending_phases: Array[StringName] = []
var book: Node2D
var markers: Node2D
var hud: CanvasLayer
var title: Label
var stats: Label
var objective: Label
var hint: Label
var help: Label
var modal: ColorRect
var modal_text: Label
var elapsed := 0.0
var visited: Dictionary = {}
var player_spawn := Vector2.ZERO
var solid_rects: Array[Rect2] = []

func _ready() -> void:
	for error in layout.validate():push_error(error)
	install_inputs()
	player_spawn = layout.start
	player.position = player_spawn
	build_world()
	navigation.build(layout.world_size,solid_rects)
	companion = CompanionScene.instantiate()
	companion.player = player
	companion.navigation = navigation
	companion.position = layout.companion_start
	$World.add_child(companion)
	discovery.layout = layout
	build_interface()
	player.died.connect(on_player_died)
	session_ui.claim(&"menu")
	if get_tree().has_meta("atlas_autostart"):
		get_tree().remove_meta("atlas_autostart")
		start_session()
	print("ATLAS_PLAYABLE ready pages=0/5 regions=7 waves=3 menu=",not session_started)

func install_inputs() -> void:
	for action in {"parry": MOUSE_BUTTON_RIGHT}:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event := InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_RIGHT
			InputMap.action_add_event(action,event)
	for action in {"dodge": KEY_SPACE,"test_return": KEY_R}:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event := InputEventKey.new()
			event.physical_keycode = {"dodge": KEY_SPACE,"test_return": KEY_R}[action]
			InputMap.action_add_event(action,event)

func add_wall(rect: Rect2) -> void:
	solid_rects.append(rect)
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	body.collision_layer = 1
	body.collision_mask = 2 | 4
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	body.add_child(shape)
	$World.add_child(body)

func add_prop(kind: String, location: Vector2, size: Vector2, solid: bool = true) -> Node2D:
	var prop := Prop.new()
	prop.kind = kind
	prop.position = location
	prop.footprint = size
	prop.solid = solid
	$World.add_child(prop)
	return prop

func build_world() -> void:
	var ground := Ground.new()
	ground.z_index = -10
	ground.layout = layout
	$World.add_child(ground)
	for rect in layout.all_walls(): add_wall(rect)
	for center in layout.encounter_centers:add_prop("beacon",center+layout.encounter_marker_offset,Vector2(14,10),false)
	for entry in layout.scenery:
		add_prop(entry.kind,entry.position,entry.size,entry.solid)
		if entry.solid: solid_rects.append(Rect2(entry.position-Vector2(entry.size.x/2,entry.size.y),entry.size))
	var camera: Camera2D = player.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(layout.world_size.x)
	camera.limit_bottom = int(layout.world_size.y)
	markers = Node2D.new()
	markers.name = "PageMarkers"
	markers.z_index = -1
	markers.draw.connect(draw_markers)
	$World.add_child(markers)
	book = Book.new()
	book.z_index = 5
	$World.add_child(book)

func make_label(value: String, location: Vector2, size: int, parent: Node = null) -> Label:
	var label := Label.new()
	label.text = value
	label.position = location
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",Color("e6ddbb"))
	(parent if parent != null else hud).add_child(label)
	return label

func build_interface() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var top := ColorRect.new()
	top.color = Color(0.025,0.045,0.05,0.92)
	top.size = Vector2(640,48)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(top)
	title = make_label("ATLAS / DESTROÇOS",Vector2(16,6),15)
	stats = make_label("",Vector2(350,8),12)
	objective = make_label("",Vector2(16,28),11)
	var bottom := ColorRect.new()
	bottom.position = Vector2(0,317)
	bottom.size = Vector2(640,43)
	bottom.color = Color(0.025,0.045,0.05,0.92)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(bottom)
	hint = make_label("",Vector2(16,320),12)
	help = make_label("WASD mover · Mouse atacar/parry · Espaço esquiva · Q adaga · F rastreio · Tab árvore · Esc pausa",Vector2(16,342),10)
	modal = ColorRect.new()
	modal.position = Vector2(72,75)
	modal.size = Vector2(496,205)
	modal.color = Color(0.025,0.045,0.05,0.96)
	modal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal.visible = false
	hud.add_child(modal)
	modal_text = make_label("",Vector2(26,28),17,modal)
	character_panel = CharacterPanel.new()
	character_panel.player = player
	character_panel.game = self
	add_child(character_panel)
	skills_bar = make_label("",Vector2(16,303),10)
	session_ui = SessionUI.new()
	session_ui.game = self
	add_child(session_ui)

func region_at(point: Vector2) -> int:
	return layout.region_at(point)

func page_position(index: int) -> Vector2:
	return layout.page_position(index)

func _physics_process(delta: float) -> void:
	if not session_started: return
	discovery.observe(player)
	elapsed += delta
	markers.z_index = 20 if player.debug_areas else -1
	markers.queue_redraw()
	var region := maxi(0,region_at(player.position))
	visited[region] = true
	title.text = "ATLAS / " + layout.region_names[region].to_upper()
	stats.text = "Vida %d/%d  F%.0f%%  E%d/%d  %d/5" % [player.health,player.max_health,player.hunger/player.max_hunger*100,player.shield,player.max_shield,pages.size()]
	skills_bar.text = "Q adaga: %s   F rastreio: %s   Tab personagem · %d ponto(s)" % [ability_status("throw"),ability_status("tracking"),player.attributes.points]
	if ending != &"none":
		if ending == &"playing":
			book.advance(delta)
			if ending_phases.is_empty() or ending_phases.back() != book.phase:
				ending_phases.append(book.phase)
			if book.phase == &"complete":
				ending = &"complete"
				modal.visible = true
				modal_text.text = "FIM DA PRIMEIRA PARTE\n\nCinco páginas reunidas. O livro desapareceu.\n\nEnter · nova partida    Esc · pausa"
		objective.text = "Livro: " + {&"flipping":"folheando",&"light":"torre de luz",&"vanishing":"desaparecendo",&"complete":"sequência concluída"}.get(book.phase,"")
		hint.text = "Cinco páginas distintas reunidas"
		return
	if player.dead:
		modal.visible = true
		modal_text.text = "VOCÊ CAIU\n\nPáginas conquistadas mantidas: %d/5\nRetorno: 50%% da vida máxima · 25%% de fome\n\nR · retornar aos destroços" % pages.size()
		hint.text = "R para retornar · progresso mantido nesta partida"
		if Input.is_action_just_pressed("test_return"):
			return_player()
		return
	if encounter == &"between":
		wait_remaining -= delta
		if wait_remaining <= 0:
			spawn_wave()
	elif active_encounter < 0:
		for i in layout.encounter_centers.size():
			if not cleared.has(i) and player.position.distance_to(layout.encounter_centers[i]) < layout.encounter_radius:
				begin_encounter(i)
				break
	if Input.is_action_just_pressed("interact") and player.input_guard_frames <= 0:
		interact()
	if active_encounter >= 0:
		objective.text = "Horda %d · onda %d/3 · inimigos %d" % [active_encounter+1,wave_index+1,enemies.size()]
		hint.text = "Ataque, recue, retorne · laranja anuncia o golpe · ciano indica parry"
	else:
		objective.text = "Encontre as cinco páginas · progresso mantido entre retornos"
		hint.text = "Siga os caminhos e os faróis até as clareiras"
		if region == 0:
			hint.text = "WASD para explorar · treine adaga, parry e esquiva antes de seguir à direita"
		elif region == 4:
			hint.text = "Abrigo opcional · suprimentos cenográficos, sem coleta"
	for i in layout.encounter_centers.size():
		if cleared.has(i) and not pages.has(i) and player.position.distance_to(page_position(i)) < 32:
			hint.text = "E · recolher página %d — horda vencida" % [i+1]
	if active_encounter < 0 and companion.can_interact():
		hint.text = "E · conversar com acompanhante"
	if player.debug_areas:
		help.text = "F3 · ocultar áreas | Verde: física · Magenta: vulnerável · Ouro: adaga · Ciano: parry"
	else:
		help.text = "WASD mover · Mouse atacar/parry · Espaço esquiva · Q adaga · F rastreio · Tab árvore · Esc pausa"

func begin_encounter(index: int) -> bool:
	if not session_started or index < 0 or index >= 5 or player.dead or active_encounter >= 0 or cleared.has(index):
		return false
	active_encounter = index
	wave_index = -1
	spawn_wave()
	return true

func valid_spawn(point: Vector2) -> bool:
	var params := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12
	params.shape = circle
	params.transform = Transform2D(0,point)
	params.collision_mask = 1 | 4
	return get_world_2d().direct_space_state.intersect_shape(params,1).is_empty() and not navigation.path(point,player.global_position).is_empty()

func spawn_wave() -> void:
	wave_index += 1
	encounter = &"fighting"
	var center: Vector2 = layout.encounter_centers[active_encounter]
	var planned: Array[Vector2] = []
	for i in layout.wave_count(active_encounter,wave_index):
		var point := Vector2.INF
		for trial in 48:
			var candidate: Vector2 = center + Vector2.from_angle(i*2.3+trial*0.7)*layout.spawn_radii[trial/16]
			var separated := true
			for other in planned:
				if candidate.distance_to(other) < 28:
					separated = false
			if valid_spawn(candidate) and candidate.distance_to(player.position) > layout.spawn_player_clearance and separated:
				point = candidate
				break
		if not point.is_finite():
			# Aguarda espaço; não cria monstro dentro de um sólido nem conclui onda vazia.
			wave_index -= 1
			encounter = &"between"
			wait_remaining = 0.3
			return
		planned.append(point)
	for point in planned:
		var monster := Monster.new()
		# Mecânicas aprovadas com parâmetros provisórios editáveis no layout.
		monster.prepared_attacks = true
		monster.attack_settings = layout.monster_attack_settings
		monster.monster_kind = layout.monster_kind(active_encounter,enemies.size()+wave_index)
		monster.position = point
		monster.target = player
		monster.defeated.connect(on_monster_defeated.bind(monster))
		enemies.append(monster)
		$World.add_child(monster)

func on_monster_defeated(monster: CharacterBody2D) -> void:
	if monster not in enemies: return
	enemies.erase(monster)
	if enemies.is_empty() and encounter == &"fighting":
		if wave_index+1 == layout.wave_sizes.size():
			player.attributes.reward_encounter(active_encounter)
			cleared[active_encounter] = true
			active_encounter = -1
			encounter = &"explore"
		else:
			encounter = &"between"
			wait_remaining = layout.wave_interval

func collect_page() -> bool:
	if player.dead or ending != &"none":
		return false
	for i in layout.encounter_centers.size():
		if cleared.has(i) and not pages.has(i) and player.position.distance_to(page_position(i)) <= 30:
			pages[i] = true
			if pages.size() == 5:
				start_ending()
			return true
	return false

func on_player_died() -> void:
	for monster in enemies:
		if is_instance_valid(monster):
			monster.queue_free()
	enemies.clear()
	active_encounter = -1
	wave_index = -1
	wait_remaining = 0
	encounter = &"defeated"

func return_player() -> bool:
	if not player.dead:
		return false
	player.return_after_death(player_spawn)
	companion.reset_at(layout.companion_start)
	discovery.last_cell = Vector2i(-999,-999)
	modal.visible = false
	encounter = &"explore"
	return true

func start_ending() -> void:
	player.cancel_skills()
	ending = &"playing"
	player.state = &"ready"
	player.remaining = 0.0
	player.feedback_wait = 0.0
	player.parry_flash = 0.0
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	player.queue_redraw()
	player.visual.set_motion(Vector2.ZERO)
	player.visual.set_action(&"idle",Vector2.DOWN,0)
	book.position = player.position + Vector2(0,-25)
	book.elapsed = 0.0
	book.phase = &"flipping"
	ending_phases.append(&"flipping")

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and ending == &"complete" and event.keycode == KEY_ENTER:
		new_game()

func draw_markers() -> void:
	if player.debug_areas:
		for rect in solid_rects:
			markers.draw_rect(rect,Color.LIME_GREEN,false,1)
		for prop in $World.get_children():
			if prop is Prop and prop.solid:
				markers.draw_rect(Rect2(prop.position-Vector2(prop.footprint.x/2,prop.footprint.y),prop.footprint),Color.LIME_GREEN,false,1)
	for i in layout.encounter_centers.size():
		var location := page_position(i)
		markers.draw_rect(Rect2(location-Vector2(13,4),Vector2(26,8)),Color("414f48"))
		if cleared.has(i) and not pages.has(i):
			var bob := sin(elapsed*4)*2
			markers.draw_circle(location-Vector2(0,12),18,Color(0.9,0.8,0.4,0.12))
			markers.draw_rect(Rect2(location+Vector2(-6,-24+bob),Vector2(12,18)),Color("f2df9f"))
			for y in [-19,-15,-11]:
				markers.draw_line(location+Vector2(-3,y+bob),location+Vector2(3,y+bob),Color("9a8452"),1)

func ability_status(id: String) -> String:
	if not player.attributes.owned.has(id+".unlock"): return "bloqueado"
	if id == "throw" and is_instance_valid(player.thrown_dagger): return "em voo"
	if id == "tracking" and player.tracker.remaining > 0: return "ativo %.1fs"%player.tracker.remaining
	var remaining: float = player.attributes.cooldowns[id]
	return "%.1fs"%remaining if remaining > 0 else "pronto"

func start_session() -> bool:
	if session_started or session_ui.active != &"menu":return false
	session_started = true
	session_ui.release(&"menu")
	player.input_guard_frames = 2
	return true
func new_game() -> void:
	player.cancel_skills()
	get_tree().paused = false
	get_tree().set_meta("atlas_autostart",true)
	get_tree().reload_current_scene()
func return_to_menu() -> void:
	player.cancel_skills()
	get_tree().paused = false
	if get_tree().has_meta("atlas_autostart"):get_tree().remove_meta("atlas_autostart")
	get_tree().reload_current_scene()

func interact() -> StringName:
	if not session_started or get_tree().paused or player.dead:return &"none"
	# A reachable, unlocked page has priority; never collect and speak on one E.
	if collect_page():return &"page"
	if active_encounter < 0 and ending == &"none" and companion.can_interact() and session_ui.claim(&"dialogue"):
		companion.state = &"interact"
		return &"dialogue"
	return &"none"
