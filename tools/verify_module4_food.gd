extends SceneTree
const Food = preload("res://scripts/world/survival_state.gd")
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
	var player = game.player
	var friend = game.companion
	for count in [0,1,2,3,4]:
		var food := Food.new()
		food.cooked = count
		food.steal_roll_override = func():return 0.0
		friend.attributes.hunger = 0
		player.health = 50
		player.hunger = 10
		if count==0:check(not food.consume("eat",1,player,friend),"Zero porções não permite consumo")
		elif count==1:
			check(food.consume("eat",1,player,friend) and food.cooked==0,"Uma porção pode ser roubada")
			check(player.health==50 and player.hunger==10 and friend.attributes.hunger==35 and food.shares==0,"Roubo não alimenta jogador nem cura/bonifica partilha")
			check(not food.consume("eat",1,player,friend) and food.shares==0,"Roubo idempotente")
		else:
			check(not food.consume("eat",1,player,friend),"Lote exige reserva antes de comer")
			var quota := ceili(count/2.0)
			for i in quota:check(food.consume("share",10+i,player,friend),"Pagar parcela da cota")
			check(food.cooked==count-quota and food.shares==quota,"Cota correta 2/3/4 sem recalcular restos")
			for i in count-quota:check(food.consume("eat",30+i,player,friend),"Parte atribuída ao jogador não vira novo roubo unitário")
			check(food.cooked==0,"Lote termina sem porção duplicada")
	var food := Food.new()
	food.cooked = 1
	var steal_boundary: float = food.config.steal_chance
	food.steal_roll_override = func():return steal_boundary
	friend.attributes.hunger = 0
	player.health = 50
	check(food.consume("eat",1,player,friend) and player.health==75,"Fronteira20% não rouba")
	food = Food.new()
	food.cooked = 4
	friend.attributes.hunger = friend.attributes.hunger_max()
	for i in 4:check(food.consume("eat",i+1,player,friend),"Amigo saciado dispensa reserva")
	food = Food.new()
	food.cooked = 3
	friend.attributes.hunger = 0
	food.consume("share",1,player,friend)
	friend.attributes.hunger = 100
	check(food.consume("eat",2,player,friend),"Saciar antes da cota libera restante")
	food = Food.new()
	food.cooked = 2
	friend.attributes.hunger = 0
	food.consume("share",1,player,friend)
	food.raw = 2
	food.cook(2)
	food.cook(3)
	check(food.consume("eat",4,player,friend),"Lote antigo quitado mantém sua parte")
	friend.attributes.hunger = 0
	check(not food.consume("eat",5,player,friend),"Novas porções formam nova cota, sem apagar ledger antigo")
	friend.dead = true
	check(not food.consume("eat",6,player,friend) and not food.consume("share",7,player,friend),"Caído prioriza resgate, sem roubo/consumo egoísta")
	check(food.consume("revive",8,player,friend,game.layout.companion_start) and not friend.dead,"Resgate preserva porção/vida/partilha")
	# Visible, known and reachable drop: fixture of ignored food, not inferred intent.
	game.player.position = Vector2(180,220)
	friend.dead = true
	game.survival.raw = 0
	game.survival.cooked = 0
	game.survival.pickups[999] = player.position+Vector2(20,0)
	game.discovery.observe(player,true)
	await process_frame
	await physics_frame
	player.health = 50
	player.attributes.owned["parry.guard"] = true
	player.shield = 20
	player.state = &"parry"
	game.revenge.tick(9.9)
	check(player.health==50 and game.revenge.elapsed>9.8,"Aviso antes de10s, sem dano antecipado")
	game.revenge.tick(0.1)
	check(player.health==45 and player.shield==20,"10s debita5 vida ignorando escudo/parry")
	game.survival.pickups[1000] = player.position+Vector2(25,0)
	game.revenge.tick(10)
	check(player.health==40,"Dois drops não dobram dano")
	paused = true
	game.revenge.tick(100)
	check(player.health==40,"Pausa não acumula dívida")
	paused = false
	game.survival.collect(999)
	game.revenge.tick(10)
	check(player.health==40 and game.revenge.elapsed==0,"Carne obtida suspende punição e prioriza fogueira")
	game.survival.raw = 0
	game.discovery.cells.clear()
	game.revenge.tick(10)
	check(player.health==40,"Drop desconhecido não pune")
	var point: Vector2 = game.survival.pickups[1000]
	game.discovery.cells[game.discovery.cell_at(point)] = true
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(3,50)
	collision.shape = rect
	wall.add_child(collision)
	wall.position = player.combat_center()+Vector2(10,0)
	game.get_node("World").add_child(wall)
	await physics_frame
	await physics_frame
	game.revenge.tick(10)
	check(player.health==40,"Carne atrás de parede não é visível/elegível")
	wall.queue_free()
	await physics_frame
	await physics_frame
	var center_cell: Vector2i = game.navigation.nearest(point)
	var saved: Dictionary = {}
	for y in range(-3,4):
		for x in range(-3,4):
			var cell := center_cell+Vector2i(x,y)
			if not game.navigation.grid.is_in_boundsv(cell):continue
			saved[cell] = game.navigation.grid.is_point_solid(cell)
			game.navigation.grid.set_point_solid(cell,true)
	game.revenge.tick(10)
	check(player.health==40,"Sem caminho navegável não pune")
	for cell in saved:game.navigation.grid.set_point_solid(cell,saved[cell])
	game.survival.pickups.clear()
	game.revenge.tick(10)
	check(player.health==40,"Sem carne acessível não pune")
	friend.dead = false
	friend.attributes.hunger = 80
	player.hunger = 70
	game.set_physics_process(true)
	for i in 5:await physics_frame
	check(friend.attributes.hunger<80 and player.hunger<70,"Fome independente avança para os dois atores vivos")
	game.session_ui.claim(&"map")
	var hunger: float = friend.attributes.hunger
	for i in 5:await physics_frame
	check(friend.attributes.hunger==hunger,"Mapa pausa fome do NPC")
	game.session_ui.close()
	friend.dead = true
	for i in 5:await physics_frame
	check(friend.attributes.hunger==hunger,"NPC caído não consome fome")
	game.set_physics_process(false)
	if "--render" in OS.get_cmdline_user_args():
		game.survival.pickups[2000] = player.position+Vector2(20,0)
		game.discovery.observe(player,true)
		game.revenge.elapsed = 3
		game._physics_process(0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/atlas/evidencias/17_revenge.png")
		friend.dead = false
		friend.attributes.hunger = 0
		player.position = game.layout.campfires[0]
		friend.position = player.position+Vector2(-24,0)
		game.survival.cooked = 3
		game.survival.lots.clear()
		game.camp_index = 0
		game.session_ui.claim(&"campfire")
		game.session_ui.show_campfire()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/atlas/evidencias/17_camp_lot.png")
		game.session_ui.close()
	game.audio.stop_all()
	game.queue_free()
	await process_frame
	print("ATLAS_MODULE4_FOOD checks=",checks," failures=",failures)
	quit(0 if failures==0 else 1)
