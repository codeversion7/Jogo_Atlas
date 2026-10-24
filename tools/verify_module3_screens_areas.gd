extends SceneTree
var checks := 0
var failures := 0
var game
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(message)
func step(n: int = 1) -> void:
	for i in n:
		await physics_frame
		await process_frame
func key(code: int) -> void:
	for pressed in [true,false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()
		await step(2)
func mouse_click(point: Vector2) -> void:
	for pressed in [true,false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.global_position = point
		event.pressed = pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()
		await step(2)
func finish_fixture() -> void:
	# Fixture do gate; não representa páginas conquistadas em combate.
	game.pages = {0:true,1:true,2:true,3:true,4:true}
	check(game.start_ending(),"Live friend and five-page fixture enters actual sequence")
	await step(330)
func run() -> void:
	game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await step(2)
	check(game.layout.validate().is_empty() and game.layout.page_area_ids==PackedStringArray(["roots","ruins","lookout","grove","archive"]),"Five unique principal areas map to five stable pages")
	var original = game.layout.duplicate(true)
	original.page_area_ids[1] = original.page_area_ids[0]
	check(not original.validate().is_empty(),"Duplicate page-area association is rejected")
	check(game.session_ui.menu_art.visible and not game.session_ui.menu_art.ending and paused,"Original title composition is part of coordinated menu")
	check(game.session_ui.actions.position.x==220 and game.session_ui.actions.size.x==200,"Central action hierarchy is intentional")
	for child in game.session_ui.actions.get_children():
		check(child.get_global_rect().end.x<=640 and child.get_global_rect().end.y<=360,"Menu button fits native viewport")
	check(game.session_ui.actions.get_child_count()==3+(0 if game.layout.credits.is_empty() else 1),"Only real actions plus verified engine attribution")
	game.session_ui.actions.get_child(1).grab_focus()
	await key(KEY_ENTER)
	check(game.session_ui.active==&"settings" and paused,"Focused Enter opens functional settings, not a hidden new game")
	await key(KEY_ESCAPE)
	check(game.session_ui.active==&"menu" and paused,"Settings Esc restores original menu composition")
	await mouse_click(game.session_ui.actions.get_child(0).get_global_rect().get_center())
	check(game.session_started and not paused and game.player.state==&"ready","Real mouse click starts without accidental attack")
	check(get_nodes_in_group("atlas_companion").size()==1,"Decorative portrait sprites do not duplicate gameplay NPCs")
	await finish_fixture()
	check(game.session_ui.active==&"ending" and game.session_ui.menu_art.ending and paused,"Final uses adapted composition and shared pause owner")
	check(game.session_ui.text.text.contains("amigo está vivo") and game.session_ui.actions.get_child_count()==3,"Final shows true condition and real restart/menu/quit actions")
	var old = game
	await key(KEY_ENTER)
	game = current_scene
	check(not is_instance_valid(old) and game.session_started and game.pages.is_empty(),"Focused final Enter restarts a clean active session")
	await finish_fixture()
	await key(KEY_ESCAPE)
	game = current_scene
	check(game.session_ui.active==&"menu" and game.pages.is_empty() and get_nodes_in_group("atlas_companion").size()==1,"Final Esc returns to clean menu without duplicate actors")
	# Credits fixture only: no claim of actual author or license.
	game.layout = game.layout.duplicate(true)
	game.layout.credits = PackedStringArray(["Fixture isolada de atribuição · sem autor real"])
	game.session_ui.return_to_menu_panel()
	game.session_ui.actions.get_child(2).pressed.emit()
	check(game.session_ui.active==&"credits" and game.session_ui.text.text.contains("Fixture isolada"),"Provided credits render only explicit attribution data")
	await key(KEY_ESCAPE)
	check(game.session_ui.active==&"menu" and paused,"Credits close to menu without releasing gameplay")
	game.queue_free()
	await step(3)
	# Non-destructive expansion fixture, not a new canonical biome or sixth page.
	game = load("res://scenes/playable.tscn").instantiate()
	game.layout = game.layout.duplicate(true)
	game.layout.world_size = Vector2(2560,960)
	game.layout.region_ids.append("expansion_fixture")
	game.layout.region_names.append("Extensão de teste")
	game.layout.region_bounds.append(Rect2(2240,0,320,960))
	game.layout.region_colors.append(Color("273e3e"))
	game.layout.paths.append(Vector4(1960,210,2450,210))
	root.add_child(game)
	current_scene = game
	check(game.layout.validate().is_empty() and game.layout.region_ids.size()==8 and game.layout.page_area_ids.size()==5,"Eighth technical region is valid while pages stay five")
	check(game.player.get_node("Camera2D").limit_right==2560 and not game.navigation.path(game.layout.start,Vector2(2420,210)).is_empty(),"Expansion updates camera, physical limits and navigation from shared layout")
	game.start_session()
	await step(2)
	game.player.position = Vector2(2420,210) # Discovery fixture, never claimed as live traversal.
	await step(2)
	check(game.discovery.known(game.player.position) and not game.discovery.known(Vector2(1400,610)),"Expansion discovery remains local and hides unvisited original regions")
	game.queue_free()
	await step(2)
	print("ATLAS_MODULE3_SCREENS_AREAS checks=",checks," failures=",failures)
	quit(0 if failures==0 else 1)
