extends SceneTree
var checks := 0
var failures := 0
var game
func _initialize() -> void:run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:failures += 1;push_error(message)
func win(index: int) -> void:
	check(game.begin_encounter(index),"Fixture inicia encontro original")
	for wave in 3:
		if game.encounter==&"between":game.spawn_wave()
		for enemy in game.enemies.duplicate():enemy.take_damage(9999)
func run() -> void:
	game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.start_session()
	game.set_physics_process(false)
	game.player.set_physics_process(false)
	game.companion.set_physics_process(false)
	await win(2)
	check(game.first_victory_id==game.layout.encounter_ids[2] and game.altar.position.distance_to(game.layout.encounter_centers[2])<=48,"Primeira vitória fora da ordem cria altar correto")
	check(not game.altar.visible,"Altar não revela posição ainda desconhecida da fixture")
	await win(0)
	check(game.first_victory_id==game.layout.encounter_ids[2],"Vitória posterior não troca altar")
	check(not game.record_first_victory(1),"Registro único por partida")
	game.pages = {0:true,1:true,2:true,4:true}
	game.cleared[3] = true # Fixture of fifth-page availability, separate from live run.
	game.player.position = game.page_position(3)
	check(game.collect_page() and game.pages.size()==5 and game.ending==&"none","Quinta página longe não inicia automaticamente")
	check(not game.start_ending(),"Longe do altar não inicia")
	game.player.position = game.altar.position+Vector2(-26,0)
	game.discovery.observe(game.player,true)
	game.pages.erase(3)
	check(game.interact()==&"altar_locked" and game.ending==&"none","4/5 bloqueia E do altar")
	game.pages[3] = true
	game.companion.dead = true
	check(game.interact()==&"altar_locked","Amigo caído bloqueia livro")
	game.companion.dead = false
	game.active_encounter = 0
	check(not game.start_ending(),"Horda ativa bloqueia livro")
	game.active_encounter = -1
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(3,36)
	shape.shape = rect
	wall.add_child(shape)
	wall.position = game.altar.position+Vector2(-13,-4)
	game.get_node("World").add_child(wall)
	await physics_frame
	await physics_frame
	check(not game.start_ending(),"Parede bloqueia colocação")
	wall.queue_free()
	await physics_frame
	await physics_frame
	var health: int = game.player.health
	var friend_health: int = game.companion.attributes.health
	check(game.interact()==&"altar" and game.ending==&"playing","E com requisitos coloca livro")
	check(game.book.position==game.altar.position and not game.player.is_physics_processing() and not game.companion.is_physics_processing(),"Livro no altar, atores protegidos")
	check(game.interact()==&"none" and game.ending_phases.size()==1,"E repetido não duplica final/ação")
	for i in 135:game._physics_process(1.0/60)
	await process_frame
	check(game.book.phase==&"light","Folhear precede luz")
	if "--render" in OS.get_cmdline_user_args():
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/atlas/evidencias/17_altar_light.png")
	check(game.altar.destruction>0,"Rachaduras/destruição coordenadas à luz")
	for prop in game.altar.affected:check(prop.position.distance_to(game.altar.position)<=game.altar.destruction_radius,"Destruição delimitada ao entorno")
	for i in 200:game._physics_process(1.0/60)
	check(game.ending==&"complete" and game.ending_phases==[&"flipping",&"light",&"vanishing",&"complete"],"Sequência canônica completa uma vez")
	check(game.player.health==health and game.companion.attributes.health==friend_health,"Destruição não mata atores")
	game.return_to_menu()
	await process_frame
	await process_frame
	game = current_scene
	check(game.first_victory_id=="" and game.altar==null and game.book.phase==&"hidden","Nova cena limpa altar/efeitos/progresso")
	game.queue_free()
	await process_frame
	print("ATLAS_MODULE4_ALTAR checks=",checks," failures=",failures)
	quit(0 if failures==0 else 1)
