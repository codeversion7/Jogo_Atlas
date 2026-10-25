extends Node2D
## Percurso compacto completo. Não há persistência em disco nem regras de alimentação.

const Monster = preload("res://scripts/test_monster.gd")
const Prop = preload("res://scripts/world_prop.gd")
const Ground = preload("res://scripts/world_ground.gd")
const Book = preload("res://scripts/book_sequence.gd")
const VitalCapsule = preload("res://scripts/ui/vital_capsule.gd")
const CharacterPanel = preload("res://scenes/ui/skill_tree.tscn")
var character_panel: CanvasLayer
var skills_bar: Label
const SessionUI = preload("res://scripts/ui/session_ui.gd")
const CompanionScene = preload("res://scenes/companion.tscn")
const PathGrid = preload("res://scripts/world/path_grid.gd")
var companion: CharacterBody2D
var navigation = PathGrid.new()
var revisits = preload("res://scripts/world/revisits.gd").new()
var reactivated_encounter := false
var revenge = preload("res://scripts/world/companion_revenge.gd").new()
var revenge_bar: ProgressBar
var revenge_label: Label
var first_victory_id := ""
var altar: Node2D
const Discovery = preload("res://scripts/world/discovery.gd")
var session_ui: CanvasLayer
var settings: Node
var audio: Node
var support: Node
var survival = preload("res://scripts/world/survival_state.gd").new()
var camp_index := -1
var food_generation := 0
var health_bar: ProgressBar
var hunger_text: Label
var hunger_bar: ProgressBar
var companion_status: Label
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
	survival.config = layout.survival_config
	for error in layout.validate():push_error(error)
	install_inputs()
	player_spawn = layout.start
	player.position = player_spawn
	build_world()
	navigation.build(layout.world_size,solid_rects)
	companion = CompanionScene.instantiate()
	companion.player = player
	companion.navigation = navigation
	revisits.game = self
	revenge.game = self
	companion.position = layout.companion_start
	$World.add_child(companion)
	support = preload("res://scripts/world/companion_support.gd").new()
	support.game = self
	support.config = layout.support_config
	add_child(support)
	discovery.layout = layout
	settings = preload("res://scripts/session_settings.gd").new()
	settings.name = "SessionSettings"
	add_child(settings)
	audio = preload("res://scripts/session_audio.gd").new()
	audio.game = self
	audio.name = "SessionAudio"
	add_child(audio)
	build_interface()
	player.died.connect(on_player_died)
	session_ui.claim(&"menu")
	if get_tree().has_meta("atlas_autostart"):
		get_tree().remove_meta("atlas_autostart")
		start_session()
	print("ATLAS_PLAYABLE ready pages=0/5 regions=",layout.region_ids.size()," waves=3 menu=",not session_started)

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
	health_bar = VitalCapsule.new()
	health_bar.position = Vector2(16,249)
	health_bar.tint = Color("cb705e")
	hud.add_child(health_bar)
	health_bar.size = Vector2(156,18)
	hunger_bar = VitalCapsule.new()
	hunger_bar.position = Vector2(16,276)
	hunger_bar.tint = Color("b89951")
	hunger_bar.symbol = "food"
	hud.add_child(hunger_bar)
	hunger_bar.size = Vector2(156,18)
	stats = make_label("",Vector2(38,250),10)
	hunger_text = make_label("",Vector2(38,277),10)
	companion_status = make_label("",Vector2(350,8),10)
	revenge_bar = ProgressBar.new()
	revenge_bar.position = Vector2(180,284)
	revenge_bar.show_percentage = false
	for style_name in ["background","fill"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("bd6b55") if style_name=="fill" else Color("28312f")
		for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:style.set_content_margin(side,0)
		revenge_bar.add_theme_stylebox_override(style_name,style)
	hud.add_child(revenge_bar)
	revenge_bar.size = Vector2(140,5)
	revenge_bar.visible = false
	revenge_label = make_label("",Vector2(180,266),10)
	objective = make_label("",Vector2(16,28),11)
	var bottom := ColorRect.new()
	bottom.position = Vector2(0,317)
	bottom.size = Vector2(640,43)
	bottom.color = Color(0.025,0.045,0.05,0.92)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(bottom)
	hint = make_label("",Vector2(16,320),12)
	help = make_label("WASD mover · Mouse atacar/parry · Espaço esquiva · Q adaga · Tab árvore · Esc pausa",Vector2(16,342),10)
	modal = ColorRect.new()
	modal.position = Vector2(72,75)
	modal.size = Vector2(496,205)
	modal.color = Color(0.025,0.045,0.05,0.96)
	modal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal.visible = false
	hud.add_child(modal)
	modal_text = make_label("",Vector2(26,28),17,modal)
	character_panel = CharacterPanel.instantiate()
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
	if not player.dead and ending==&"none":
		player.attributes.consume_hunger(delta,survival.config.hunger_per_second)
		if not companion.dead:companion.attributes.consume_hunger(delta,survival.config.companion_hunger_per_second)
		revenge.tick(delta)
	revenge_bar.visible = revenge.elapsed>0
	revenge_bar.value = revenge.elapsed/maxf(0.1,survival.config.revenge_interval)*100
	revenge_label.text = "Carne visível: recolha · %.1f/10s · -5 vida"%revenge.elapsed if revenge.elapsed>0 else ""
	hunger_bar.value = player.hunger/player.max_hunger*100
	health_bar.value = 100.0*player.health/player.max_health
	hunger_text.text = "Fome %.0f/%.0f"%[player.hunger,player.max_hunger]
	companion_status.text = ("Amigo caído" if companion.dead else "Amigo %d/%d"%[companion.attributes.health,companion.attributes.health_max()])+" F%.0f · crua%d/assada%d"%[companion.attributes.hunger,survival.raw,survival.cooked]
	markers.z_index = 20 if player.debug_areas else -1
	markers.queue_redraw()
	var region := maxi(0,region_at(player.position))
	visited[region] = true
	title.text = "ATLAS / " + layout.region_names[region].to_upper()
	stats.text = "Vida %d/%d · E%d"%[player.health,player.max_health,player.shield]
	skills_bar.text = "Q adaga: %s · Onda %d · Tab árvore · %d ponto(s)"%[ability_status("throw"),player.reach_level,player.attributes.points]
	if ending != &"none":
		if ending == &"playing":
			book.advance(delta)
			if ending_phases.is_empty() or ending_phases.back() != book.phase:
				ending_phases.append(book.phase)
			if book.phase == &"complete":
				ending = &"complete"
				modal.visible = false
				session_ui.show_ending()
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
	revisits.tick()
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
		objective.text = ("Reativação · " if reactivated_encounter else "")+"Horda %d · onda %d/3 · inimigos %d" % [active_encounter+1,wave_index+1,enemies.size()]
		hint.text = "Ataque, recue, retorne · laranja anuncia o golpe · ciano indica parry"
	else:
		objective.text = "Encontre as cinco páginas · progresso mantido entre retornos"
		hint.text = "Siga os caminhos e os faróis até as clareiras"
		if region == 0:
			hint.text = "WASD para explorar · treine adaga, parry e esquiva antes de seguir à direita"
		elif region == 4:
			hint.text = "Abrigo opcional · suprimentos cenográficos, sem coleta"
	var nearby_hint := interaction_hint()
	if not nearby_hint.is_empty(): hint.text = nearby_hint
	if player.hunger<=0: hint.text += " · Fome vazia: procure carne e fogueira"
	if pages.size()==5 and not companion.dead:objective.text = "5/5 páginas · volte ao altar do primeiro encontro vencido · E"
	if pages.size()==5 and companion.dead:
		objective.text = "5/5 páginas · reanime seu amigo na fogueira para abrir o livro"
		if survival.raw==0 and survival.cooked==0 and survival.pickups.is_empty(): hint.text = "Sem carne restante · Esc → tela inicial permite reiniciar"

	if player.debug_areas:
		help.text = "F3 · ocultar áreas | Verde: física · Magenta: vulnerável · Ouro: adaga · Ciano: parry"
	else:
		help.text = "WASD mover · Mouse atacar/parry · Espaço esquiva · Q adaga · Tab árvore · Esc pausa"

func begin_encounter(index: int, repeated: bool = false) -> bool:
	if not session_started or index < 0 or index >= 5 or player.dead or active_encounter >= 0 or cleared.has(index)!=repeated or ending!=&"none" or get_tree().paused:
		return false
	var area: int = layout.region_at(layout.encounter_centers[index])
	if area<0 or layout.region_ids[area]!=layout.page_area_ids[index]: return false
	if repeated and companion.dead:return false
	reactivated_encounter = repeated
	if repeated:
		companion.stay_at = layout.encounter_centers[index]
		companion.route.clear()
		companion.remaining = 0
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
	if monster.dead and monster.health==0: survival.record_death(monster.get_instance_id(),monster.position)
	enemies.erase(monster)
	if enemies.is_empty() and encounter == &"fighting":
		if wave_index+1 == layout.wave_sizes.size():
			if not reactivated_encounter:
				player.attributes.reward_encounter(active_encounter)
				record_first_victory(active_encounter)
				cleared[active_encounter] = true
				revisits.note_completed(active_encounter)
			revisits.release()
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
			audio.play_event(player,"page")
			return true
	return false

func on_player_died() -> void:
	revenge.reset()
	revisits.release()
	support.cancel()
	audio.stop_all()
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
	support.cancel()
	player.return_after_death(player_spawn)
	health_bar.snap_to(100.0*player.health/player.max_health)
	hunger_bar.snap_to(100.0*player.hunger/player.max_hunger)
	companion.reset_at(layout.companion_start)
	discovery.last_cell = Vector2i(-999,-999)
	modal.visible = false
	encounter = &"explore"
	return true

func record_first_victory(index: int) -> bool:
	if first_victory_id!="" or index<0 or index>=layout.encounter_ids.size():return false
	if reactivated_encounter:return false
	first_victory_id = layout.encounter_ids[index]
	var center: Vector2 = layout.encounter_centers[index]
	var point := Vector2.INF
	for offset in [Vector2.ZERO,Vector2(24,0),Vector2(-24,0),Vector2(0,24),Vector2(0,-24),Vector2(48,0),Vector2(-48,0)]:
		var candidate: Vector2 = center+offset
		var query := PhysicsShapeQueryParameters2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 10
		query.shape = circle
		query.transform = Transform2D(0,candidate)
		query.collision_mask = 1
		if get_world_2d().direct_space_state.intersect_shape(query,1).is_empty() and not navigation.path(player.position,candidate).is_empty():point = candidate;break
	if not point.is_finite():push_error("Sem ponto livre para altar no primeiro encontro");return false
	altar = preload("res://scripts/world/altar.gd").new()
	altar.game = self
	altar.position = point
	altar.visible = discovery.known(point)
	$World.add_child(altar)
	return true
func altar_hint() -> String:
	if pages.size()!=5:return "Altar · reúna as cinco páginas (%d/5)"%pages.size()
	if companion.dead:return "Altar · reanime seu amigo na fogueira"
	if active_encounter>=0 or not enemies.is_empty():return "Altar · termine o confronto antes do livro"
	return "E · colocar o livro no altar"

func start_ending() -> bool:
	if pages.size()!=5 or companion.dead or player.dead or ending!=&"none" or get_tree().paused:return false
	if not is_instance_valid(altar) or active_encounter>=0 or not enemies.is_empty() or player.state!=&"ready" or player.feedback_wait>0:return false
	if not reachable(altar.position,altar.interact_distance):return false
	# Transição atômica: revalida amigo e encerra fontes de dano antes da animação.
	support.cancel()
	for monster in enemies:
		if is_instance_valid(monster):
			monster.set_physics_process(false)
			if monster.attack_runtime!=null: monster.attack_runtime.cancel()
			monster.queue_free()
	enemies.clear()
	for projectile in get_tree().get_nodes_in_group("atlas_monster_projectiles"):
		projectile.set_physics_process(false)
		projectile.queue_free()
	companion.set_physics_process(false)
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
	book.position = altar.position
	altar.begin()
	book.elapsed = 0.0
	book.phase = &"flipping"
	ending_phases.append(&"flipping")
	return true

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and ending == &"complete" and event.keycode == KEY_ENTER:
		new_game()

func draw_markers() -> void:
	for point in layout.campfires:
		markers.draw_circle(point,10,Color("514837"))
		markers.draw_line(point+Vector2(-6,2),point+Vector2(6,-2),Color("9f7250"),3)
		markers.draw_line(point+Vector2(6,2),point+Vector2(-6,-2),Color("9f7250"),3)
		markers.draw_colored_polygon(PackedVector2Array([point+Vector2(-4,-2),point+Vector2(0,-14),point+Vector2(5,-2)]),Color("edab5b"))
	for point in survival.pickups.values():
		markers.draw_rect(Rect2(point-Vector2(4,6),Vector2(8,5)),Color("c28379"))
		markers.draw_line(point-Vector2(2,5),point+Vector2(2,-3),Color("f2d6b2"),1)
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
	if player.dead or ending!=&"none" or get_tree().paused:return &"none"
	if not player.dead and ending==&"none" and is_instance_valid(altar) and reachable(altar.position,altar.interact_distance):
		return &"altar" if start_ending() else &"altar_locked"
	if not session_started or get_tree().paused or player.dead:return &"none"
	# Prioridade: página > ingrediente > fogueira > conversa. Uma única ação por E.
	if collect_page():return &"page"
	for identity in survival.pickups:
		if reachable(survival.pickups[identity],survival.config.pickup_distance) and survival.collect(identity): return &"meat"
	for i in layout.campfires.size():
		if ending==&"none" and reachable(layout.campfires[i],survival.config.camp_distance) and session_ui.claim(&"campfire"):
			camp_index = i
			session_ui.show_campfire()
			return &"campfire"
	if active_encounter < 0 and ending == &"none" and companion.can_interact() and session_ui.claim(&"dialogue"):
		companion.state = &"interact"
		return &"dialogue"
	return &"none"

func reachable(point: Vector2, distance: float) -> bool:
	return player.position.distance_to(point)<=distance and preload("res://scripts/combat_geometry.gd").clear_line(player,point)
func interaction_hint() -> String:
	if is_instance_valid(altar) and reachable(altar.position,altar.interact_distance):return altar_hint()
	for i in layout.encounter_centers.size():
		if cleared.has(i) and not pages.has(i) and reachable(page_position(i),30): return "E · recolher página %d — horda vencida"%[i+1]
	for point in survival.pickups.values():
		if reachable(point,survival.config.pickup_distance): return "E · recolher carne crua · leve à fogueira"
	for point in layout.campfires:
		if reachable(point,survival.config.camp_distance): return "E · fogueira: assar, comer, dividir ou reanimar"
	if active_encounter<0 and companion.can_interact(): return "E · conversar com acompanhante"
	return ""
func safe_rescue_point() -> Vector2:
	if camp_index<0 or camp_index>=layout.campfires.size(): return Vector2.INF
	for offset in [Vector2(-24,0),Vector2(24,0),Vector2(0,24),Vector2(0,-24)]:
		var point: Vector2 = layout.campfires[camp_index]+offset
		var query := PhysicsShapeQueryParameters2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 6
		query.shape = circle
		query.transform = Transform2D(0,point+Vector2(0,-3))
		query.collision_mask = 1|4
		if get_world_2d().direct_space_state.intersect_shape(query,1).is_empty() and not navigation.path(point,layout.campfires[camp_index]).is_empty(): return point
	return Vector2.INF
func camp_action(mode: String, generation: int) -> bool:
	if session_ui.active!=&"campfire" or generation!=food_generation or player.dead or ending!=&"none" or camp_index<0: return false
	if not reachable(layout.campfires[camp_index],survival.config.camp_distance): return false
	if mode=="share" and not companion.can_interact(): return false
	var success: bool = survival.cook(generation) if mode=="cook" else survival.consume(mode,generation,player,companion,safe_rescue_point() if mode=="revive" else Vector2.INF)
	if success or not survival.last_result.is_empty(): session_ui.show_campfire()
	return success
