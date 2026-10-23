extends CanvasLayer
## Single in-game status/tree; pauses simulation while purchasing.
var player: Node2D
var game: Node2D
var panel: ColorRect
var heading: Label
var status: Label
var buttons: Dictionary = {}
var notice: Label
var timer := 0.0
var opened := false
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 14
	panel = ColorRect.new()
	panel.color = Color("101c20")
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.visible = false
	add_child(panel)
	heading = label("",Vector2(14,10),17)
	status = label("",Vector2(14,38),11)
	for index in 3:
		var branch: String = player.Attributes.BRANCHES[index]
		var x := 14+index*207
		label({"throw":"ADAGA DE RETORNO","tracking":"RASTREIO","parry":"PARRY"}[branch],Vector2(x,102),13)
		label("Base disponível · botão direito" if branch == "parry" else "Habilidade adquirível",Vector2(x,124),10)
		var row := 0
		for id in player.Attributes.NODES:
			if player.Attributes.NODES[id].branch != branch: continue
			var button := Button.new()
			button.position = Vector2(x,146+row*66)
			button.size = Vector2(196,58)
			button.add_theme_font_size_override("font_size",11)
			button.add_theme_color_override("font_disabled_color",Color("b3c0bd"))
			button.pressed.connect(purchase.bind(id))
			panel.add_child(button)
			buttons[id] = button
			row += 1
	notice = label("",Vector2(14,282),11)
	label("+%d ponto(s) por encontro, uma vez · aquisições duram nesta partida"%player.character_config.points_per_encounter,Vector2(14,306),11)
	label("Tab / Esc fechar · Q arremessar · F rastrear · Direito parry · Espaço esquiva",Vector2(14,333),11)
	player.attributes.changed.connect(refresh)
	refresh()
func label(text: String, position: Vector2, size: int) -> Label:
	var node := Label.new()
	node.text = text
	node.position = position
	node.add_theme_font_size_override("font_size",size)
	node.add_theme_color_override("font_color",Color("e6ddbb"))
	panel.add_child(node)
	return node
func effect(id: String) -> String:
	var config = player.character_config
	match id:
		"throw.unlock": return "Q · ida e retorno · %.1f s recarga"%config.throw_cooldown
		"throw.edge": return "Dano da adaga +%d"%config.edge_damage_bonus
		"tracking.unlock": return "F · %.0f px · %.1f s ativo"%[config.tracking_radius,config.tracking_duration]
		"tracking.stride": return "Distância da esquiva +%.2f px"%config.stride_distance_bonus
		"parry.focus": return "Janela de parry +%.2f s"%config.focus_window_bonus
		"parry.guard": return "Resistência +%.0f%% · escudo +%d"%[config.guard_resistance_bonus*100,config.guard_shield_bonus]
	return ""
func refresh() -> void:
	if not is_instance_valid(player): return
	var data = player.attributes
	heading.text = "PERSONAGEM · %d ponto(s) · três ramos"%data.points
	status.text = "Vida %d/%d   Fome %.0f/%.0f   Escudo %d/%d   Dano %d   Resistência %.0f%%\nEsquiva %.2f px / %.2f s · recarga %.2f s   Parry %.2f s\nRecargas: Q %.1f s · F %.1f s · Espaço %.1f s"%[player.health,player.max_health,player.hunger,player.max_hunger,player.shield,player.max_shield,player.dagger_damage,player.resistance*100,player.dodge_distance,player.dodge_duration,player.dodge_cooldown,player.parry_window,data.cooldowns.throw,data.cooldowns.tracking,data.cooldowns.dodge]
	for id in buttons:
		var owned: bool = data.owned.has(id)
		var state := "ADQUIRIDO" if owned else "Custo %d ponto(s)"%data.cost(id)
		var required: String = player.Attributes.NODES[id].requires
		if not owned and required != "" and not data.owned.has(required): state = "Bloqueado · adquira o anterior"
		buttons[id].text = player.Attributes.NODES[id].label+"\n"+effect(id)+"\n"+state
		buttons[id].disabled = not data.can_buy(id)
func purchase(id: String) -> void:
	if not opened or player.dead: return
	if player.attributes.buy(id):
		notice.text = "Adquirido: "+player.Attributes.NODES[id].label
		player.skills_changed.emit()
	else:
		notice.text = "Compra indisponível: confira pontos e requisito."
	refresh()
func open() -> bool:
	if opened or get_tree().paused or player.dead or game.ending != &"none": return false
	opened = true
	panel.visible = true
	get_tree().paused = true
	notice.text = "Parry já disponível; compras não gastam páginas."
	refresh()
	return true
func close() -> void:
	if not opened: return
	opened = false
	panel.visible = false
	player.input_guard_frames = 2
	get_tree().paused = false
func _process(delta: float) -> void:
	if not opened: return
	timer += delta
	if timer >= 0.1:
		timer = 0
		refresh()
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.is_action_pressed("skill_tree") or (opened and event.keycode == KEY_ESCAPE):
			if opened: close()
			else: open()
			get_viewport().set_input_as_handled()
func _exit_tree() -> void:
	if opened and is_inside_tree(): get_tree().paused = false
