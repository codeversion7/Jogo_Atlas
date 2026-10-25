extends CanvasLayer
## Sole owner of session panels and pause; no stacked menus or competing unpause.
var game: Node2D
var active: StringName = &""
var panel: ColorRect
var title: Label
var text: Label
var map_view: Control
var settings_parent: StringName = &"menu"
var actions: VBoxContainer
var menu_art: Node2D
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	panel = ColorRect.new()
	panel.color = Color("101c20")
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)
	menu_art = preload("res://scripts/ui/atlas_menu_art.gd").new()
	panel.add_child(menu_art)
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
	reset_presentation()
	actions.position = Vector2(28,190)
	actions.size.x = 270
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
			text.text = "WASD mover · mouse atacar/parry · Espaço esquiva\nQ adaga · Tab personagem · M mapa\nE interagir · R retornar após morte"
			button("Continuar · Esc",close)
			button("Voltar à tela inicial",game.return_to_menu)
			button("Configurações",open_settings)
		&"menu":
			entry_composition(false)
			button("Novo jogo · Enter",game.start_session)
			button("Configurações",open_settings)
			if not game.layout.credits.is_empty():button("Créditos",show_credits)
			button("Sair",quit_game)
		&"ending":
			entry_composition(true)
			button("Nova partida · Enter",game.new_game)
			button("Voltar à tela inicial",game.return_to_menu)
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
	control.custom_minimum_size = Vector2(0,28)
	control.add_theme_font_size_override("font_size",14)
	for state_name in ["normal","hover","pressed","focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("1b3032") if state_name!="pressed" else Color("344c48")
		if state_name in ["hover","focus"]:
			style.border_color = Color("d3b87a")
			style.set_border_width_all(1)
			if state_name=="focus": style.draw_center = false
		control.add_theme_stylebox_override(state_name,style)
	control.pressed.connect(callback)
	actions.add_child(control)
	if actions.get_child_count()==1:control.grab_focus()
func close() -> void:
	if active==&"ending": game.return_to_menu(); return
	if active==&"credits": return_to_menu_panel(); return
	if active == &"settings": close_settings(); return
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
	active = &"credits"
	reset_presentation()
	title.text = "CRÉDITOS"
	text.text = "\n".join(game.layout.credits)
	for child in actions.get_children():
		actions.remove_child(child)
		child.queue_free()
	actions.position = Vector2(28,290)
	button("Voltar · Esc",return_to_menu_panel)
func reset_presentation() -> void:
	menu_art.visible = false
	title.position = Vector2(24,20)
	title.size = Vector2(590,50)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size",24)
	text.position = Vector2(28,72)
	text.size = Vector2(584,110)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size",14)
func entry_composition(is_ending: bool) -> void:
	menu_art.configure(is_ending)
	title.position = Vector2(150,36)
	title.size = Vector2(340,72)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = "PRIMEIRA PARTE\nCONCLUÍDA" if is_ending else "ATLAS"
	title.add_theme_font_size_override("font_size",24 if is_ending else 52)
	text.position = Vector2(170,112)
	text.size = Vector2(300,40)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.text = "Cinco páginas reunidas.\nO livro desapareceu. Seu amigo está vivo." if is_ending else "PRIMEIRA PARTE\nExplore e encontre as cinco páginas."
	text.add_theme_font_size_override("font_size",12)
	actions.position = Vector2(220,190)
	actions.size.x = 200
func return_to_menu_panel() -> void:
	active = &""
	claim(&"menu")
func show_ending() -> bool:
	if game.ending!=&"complete" or game.pages.size()!=5 or game.companion.dead: return false
	game.audio.stop_all()
	return claim(&"ending")
func quit_game() -> void:
	get_tree().quit()
func open_settings() -> void:
	if active not in [&"menu",&"pause"]: return
	settings_parent = active
	active = &"settings"
	reset_presentation()
	for child in actions.get_children():
		actions.remove_child(child)
		child.queue_free()
	title.text = "CONFIGURAÇÕES · ATLAS"
	text.position = Vector2(28,326)
	text.text = game.settings.last_error if not game.settings.last_error.is_empty() else "Preferências locais · sem salvar a partida · Esc voltar"
	if not game.settings.device_status.is_empty(): text.text = game.settings.device_status
	actions.position = Vector2(28,74)
	actions.size.x = 500
	for pair in [["master","Volume geral"],["effects","Efeitos"],["music","Música · sem trilha"]]:
		var row := HBoxContainer.new()
		var caption := Label.new()
		caption.text = pair[1]
		caption.custom_minimum_size.x = 165
		row.add_child(caption)
		var slider := HSlider.new()
		slider.name = pair[0]
		slider.custom_minimum_size = Vector2(300,24)
		slider.min_value = 0
		slider.max_value = 100
		slider.step = 1
		slider.value = float(game.settings.values[pair[0]])*100
		slider.value_changed.connect(func(value: float): change_setting(pair[0],value/100))
		row.add_child(slider)
		actions.add_child(row)
		if pair[0]=="master": slider.grab_focus()
	var mute := CheckButton.new()
	mute.text = "Silenciar tudo"
	mute.button_pressed = game.settings.values.mute
	mute.toggled.connect(func(value: bool): change_setting("mute",value))
	actions.add_child(mute)
	var display := OptionButton.new()
	display.add_item("Janela")
	display.add_item("Tela cheia")
	display.selected = 1 if game.settings.values.fullscreen else 0
	display.item_selected.connect(func(index: int): change_setting("fullscreen",index==1))
	actions.add_child(display)
	var scale_choice := OptionButton.new()
	for value in ["Escala · janela personalizada","1× · 640 × 360","2× · 1280 × 720","3× · 1920 × 1080","4× · 2560 × 1440"]: scale_choice.add_item(value)
	scale_choice.selected = game.settings.values.window_scale
	scale_choice.item_selected.connect(func(index: int): change_setting("window_scale",index))
	actions.add_child(scale_choice)
	button("Restaurar padrões",func():
		game.settings.restore_defaults()
		active = settings_parent
		open_settings())
	button("Voltar · Esc",close_settings)
func change_setting(key: String, value: Variant) -> void:
	if not game.settings.set_value(key,value): text.text = game.settings.last_error
	else: text.text = "Preferências salvas · Esc voltar"
func show_campfire() -> void:
	if active != &"campfire": return
	game.food_generation += 1
	var generation: int = game.food_generation
	for child in actions.get_children():
		actions.remove_child(child)
		child.queue_free()
	title.text = "FOGUEIRA"
	text.position = Vector2(28,72)
	text.text = "Carne crua: %d · assada: %d\n"%[game.survival.raw,game.survival.cooked]
	text.text += "Amigo caído: uma porção assada permite resgatá-lo aqui." if game.companion.dead else "Dividir recupera seu amigo e soma 0,2 s à proteção."
	if game.survival.raw==0 and game.survival.cooked==0: text.text += "\nSem carne. Procure monstros; Esc permite pausar/reiniciar."
	elif not game.companion.dead and not game.companion.can_interact(): text.text += "\nSeu amigo precisa estar perto para dividir."
	actions.position = Vector2(28,158)
	button("Assar uma carne",func(): game.camp_action("cook",generation))
	actions.get_child(0).disabled = game.survival.raw<=0
	button("Comer sozinho",func(): game.camp_action("eat",generation))
	actions.get_child(1).disabled = game.survival.cooked<=0
	var mode := "revive" if game.companion.dead else "share"
	button("Reanimar e partilhar" if game.companion.dead else "Dividir com amigo",func(): game.camp_action(mode,generation))
	actions.get_child(2).disabled = game.survival.cooked<=0 or (not game.companion.dead and not game.companion.can_interact())
	button("Seguir viagem · Esc",close)
func close_settings() -> void:
	if active != &"settings": return
	active = &""
	actions.position = Vector2(28,190)
	actions.size.x = 270
	claim(settings_parent) # Mantém pausa/foco: não passa por release/unpause.
func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:return
	var viewport := get_viewport()
	if viewport==null: return
	if active in [&"menu",&"ending"]:
		if event.keycode == KEY_ENTER:
			if viewport.gui_get_focus_owner() is Button:return
			if active==&"ending": game.new_game()
			else: game.start_session()
		elif event.keycode == KEY_ESCAPE:
			if active==&"ending": game.return_to_menu()
			else: entry_composition(false)
		else:return # Let native focus navigation reach the menu buttons.
		viewport.set_input_as_handled()
		return
	if event.keycode == KEY_ESCAPE:
		if active != &"":close()
		else:claim(&"pause")
		viewport.set_input_as_handled()
	elif event.is_action_pressed("map"):
		if active == &"map":close()
		elif active == &"":claim(&"map")
		viewport.set_input_as_handled()
	elif event.is_action_pressed("skill_tree"):
		if active == &"tree":close()
		elif active == &"":game.character_panel.open()
		else:return
		viewport.set_input_as_handled()
	elif active == &"dialogue" and event.is_action_pressed("interact"):
		close()
		viewport.set_input_as_handled()
func _exit_tree() -> void:
	if active != &"" and is_inside_tree():get_tree().paused = false
