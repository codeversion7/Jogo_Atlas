extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void:run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:failures += 1;push_error(message)
func run() -> void:
	var game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.start_session()
	game.set_physics_process(false)
	game.player.set_physics_process(false)
	game.companion.set_physics_process(false)
	for bar in [game.health_bar,game.hunger_bar]:
		check(bar.mouse_filter==Control.MOUSE_FILTER_IGNORE and bar.focus_mode==Control.FOCUS_NONE,"Decoração não captura controles")
		var exterior: Vector2 = bar.size
		for percent in [0,1,50,100]:
			var points: PackedVector2Array = bar.fill_points(percent)
			check((percent!=0 or points.is_empty()) and bar.size==exterior,"Zero sem preenchimento e tamanho exterior estável")
			var inside := true
			var inner := Rect2(Vector2.ONE,bar.size-Vector2.ONE*2)
			var r := inner.size.y/2
			for point in points:
				var center_x := clampf(point.x,inner.position.x+r,inner.end.x-r)
				if Vector2(point.x-center_x,point.y-inner.get_center().y).length()>r+0.001 or point.x>inner.position.x+inner.size.x*percent/100+0.001:inside = false
			check(inside,"Preenchimento realmente recortado pela cápsula, inclusive1%")
	game.player.health = 100
	game.player.hunger = 100
	game._physics_process(0)
	game.health_bar.snap_to(100)
	game.hunger_bar.snap_to(100)
	game.player.health = 50
	game._physics_process(0)
	game.health_bar.advance_visual(0.03)
	check(game.player.health==50 and game.health_bar.value==50 and game.health_bar.displayed_value>50 and game.health_bar.displayed_value<100,"Transição suaviza só o exibido; vida real já é50")
	game.health_bar.advance_visual(1)
	check(game.health_bar.displayed_value==50,"Transição chega ao alvo sem tween acumulado")
	paused = true
	game.health_bar.advance_visual(1)
	check(game.health_bar.displayed_value==50,"Pausa não deixa transição pendurada")
	paused = false
	if "--render" in OS.get_cmdline_user_args():
		for percent in [100,50,1,0]:
			game.player.health = percent # Explicit visual fixtures; not a live-run balance change.
			game.player.hunger = percent
			game._physics_process(0)
			game.health_bar.snap_to(percent)
			game.hunger_bar.snap_to(percent)
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://docs/atlas/evidencias/17_capsule_"+str(percent)+".png")
	game.player.health = 30
	game.player.debit_life(999)
	game._physics_process(0)
	game.health_bar.advance_visual(0.001)
	check(game.health_bar.displayed_value==0,"Morte zera apresentação imediatamente")
	game.return_player()
	check(game.health_bar.value==50 and game.health_bar.displayed_value==50 and game.hunger_bar.displayed_value==25,"Retorno cancela transições e resolve50%/25% reais")
	game.return_to_menu()
	await process_frame
	await process_frame
	game = current_scene
	game.start_session()
	game._physics_process(0)
	game.health_bar.advance_visual(0.01)
	check(game.health_bar.displayed_value==100,"Nova sessão sem animação antiga")
	game.queue_free()
	await process_frame
	print("ATLAS_MODULE4_CAPSULES checks=",checks," failures=",failures)
	quit(0 if failures==0 else 1)
