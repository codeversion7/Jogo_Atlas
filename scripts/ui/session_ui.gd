extends CanvasLayer
## Sole owner of session panels and pause; no stacked menus or competing unpause.
var game: Node2D
var active: StringName = &""
var panel: ColorRect
var title: Label
var text: Label
var map_view: Control
var actions: VBoxContainer
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	panel = ColorRect.new()
	panel.color = Color("101c20")
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)
	title = Label.new()
	title.position = Vector2(24,20)
	title.add_theme_font_size_override("font_size",24)
	panel.add_child(title)
	text = Label.new()
	text.position = Vector2(28,72)
	text.add_theme_font_size_override("font_size",14)
	text.add_theme_color_override("font_color",Color("e4dbbb"))
	panel.add_child(text)
	actions = VBoxContainer.new()
	actions.position = Vector2(28,190)
	actions.size.x = 270
	panel.add_child(actions)
	map_view = load("res://scripts/ui/discovered_map.gd").new()
	map_view.game = game
	panel.add_child(map_view)
	panel.visible = false
func claim(kind: StringName) -> bool:
	if active != &"" or (kind != &"menu" and not game.session_started):return false
	if kind in [&"map",&"tree",&"dialogue"] and (game.player.dead or game.ending != &"none"):return false
	active = kind
	get_tree().paused = true
	panel.visible = kind != &"tree"
	map_view.visible = kind == &"map"
	for child in actions.get_children():
		actions.remove_child(child)
		child.queue_free()
	text.text = ""
	match kind:
		&"map":
			title.text = "MAPA · apenas locais descobertos"
			text.text = "M / Esc fechar · ciano: você · ouro: marco observado"
			text.position = Vector2(28,322)
			map_view.queue_redraw()
		&"pause":
			title.text = "PAUSA"
			text.position = Vector2(28,72)
			text.text = "WASD mover · mouse atacar/parry · Espaço esquiva\nQ adaga · F rastreio · Tab personagem · M mapa\nE interagir · R retornar após morte"
			button("Continuar · Esc",close)
			button("Voltar à tela inicial",game.return_to_menu)
		&"menu":
			title.text = "ATLAS"
			text.position = Vector2(28,72)
			text.text = "PRIMEIRA PARTE\n\nExplore os caminhos e reúna cinco páginas."
			button("Novo jogo · Enter",game.start_session)
			if not game.layout.credits.is_empty():button("Créditos",show_credits)
			button("Sair",quit_game)
		&"dialogue":
			title.text = "ACOMPANHANTE · provisório"
			text.position = Vector2(28,82)
			text.text = "Vou seguir por perto.\nPodemos parar aqui por um instante."
			button("Encerrar conversa · E / Esc",close)
	return true
func button(caption: String, callback: Callable) -> void:
	var control := Button.new()
	control.text = caption
	control.custom_minimum_size = Vector2(270,32)
	control.pressed.connect(callback)
	actions.add_child(control)
	if actions.get_child_count()==1:control.grab_focus()
func close() -> void:
	if active == &"menu":return
	if active == &"tree":game.character_panel.close();return
	release(active)
func release(kind: StringName) -> void:
	if active != kind:return
	active = &""
	panel.visible = false
	game.player.input_guard_frames = 2
	get_tree().paused = false
func show_credits() -> void:
	if active != &"menu" or game.layout.credits.is_empty():return
	title.text = "CRÉDITOS"
	text.text = "\n".join(game.layout.credits)
func quit_game() -> void:
	get_tree().quit()
func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:return
	if active == &"menu":
		if event.keycode == KEY_ENTER:
			if get_viewport().gui_get_focus_owner() is Button:return
			game.start_session()
		elif event.keycode == KEY_ESCAPE:
			title.text = "ATLAS"
			text.text = "PRIMEIRA PARTE\n\nExplore os caminhos e reúna cinco páginas."
		else:return # Let native focus navigation reach the menu buttons.
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_ESCAPE:
		if active != &"":close()
		else:claim(&"pause")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("map"):
		if active == &"map":close()
		elif active == &"":claim(&"map")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("skill_tree"):
		if active == &"tree":close()
		elif active == &"":game.character_panel.open()
		else:return
		get_viewport().set_input_as_handled()
	elif active == &"dialogue" and event.is_action_pressed("interact"):
		close()
		get_viewport().set_input_as_handled()
func _exit_tree() -> void:
	if active != &"" and is_inside_tree():get_tree().paused = false
