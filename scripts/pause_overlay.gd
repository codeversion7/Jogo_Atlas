extends CanvasLayer

var panel: ColorRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 12
	panel = ColorRect.new()
	panel.color = Color(0.02,0.04,0.05,0.9)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.visible = false
	add_child(panel)
	var label := Label.new()
	label.text = "PAUSA\n\nEsc para continuar\n\nWASD · mover    Mouse · mirar\nEsquerdo · adaga    Direito · parry\nEspaço · esquiva    E · recolher\nR · retornar após morte    F3 · áreas de combate\n\nCinco páginas. Progresso mantido ao retornar nesta partida."
	label.position = Vector2(56,42)
	label.add_theme_font_size_override("font_size",16)
	panel.add_child(label)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_tree().paused = not get_tree().paused
		panel.visible = get_tree().paused
		get_viewport().set_input_as_handled()
