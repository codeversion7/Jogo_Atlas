extends SceneTree
## Fixtures isoladas de posição/vida para verificar dano, não o percurso real.
const Monster = preload("res://scripts/test_monster.gd")
const Orb = preload("res://scripts/monster_orb.gd")
var game
var player
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func step(count: int = 1) -> void:
	for i in count:
		await physics_frame
		await process_frame
func fixture(kind: int, offset := Vector2(24,0)):
	player.global_position = Vector2(180,220)
	player.health = player.max_health
	player.shield = 0
	player.hurt_wait = 0
	player.dead = false
	player.state = &"ready"
	var monster := Monster.new()
	monster.monster_kind = kind
	monster.prepared_attacks = true
	monster.move_speed = 0 # Só nesta fixture; o percurso testa perseguição real.
	monster.position = player.position-offset
	monster.target = player
	game.get_node("World").add_child(monster)
	return monster
func clean(monster) -> void:
	if is_instance_valid(monster): monster.queue_free()
	await step(2)
	for node in get_nodes_in_group("atlas_monster_projectiles"): node.queue_free()
	await step(2)
func wall_at(point: Vector2) -> StaticBody2D:
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(4,60)
	collision.shape = shape
	wall.add_child(collision)
	wall.position = point
	game.get_node("World").add_child(wall)
	return wall
func run() -> void:
	game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.start_session()
	game.set_physics_process(false)
	player = game.player
	player.set_physics_process(false)
	await step(3)
	for kind in 4:
		var monster = fixture(kind)
		await step(2)
		var runtime = monster.attack_runtime
		check(runtime.playing and not monster.visual.visible and runtime.visible,"Ataque usa um só corpo preparado")
		check(runtime.sprite.rotation == 0 and runtime.sprite.position == Vector2.ZERO,"Pivô de 64/64 sem rotação do corpo")
		var before: int = player.health
		await step(20)
		check(player.health == before,"Aviso sem dano antecipado")
		var elapsed: float = runtime.phase_time
		paused = true
		await step(5)
		check(runtime.phase_time == elapsed,"Pausa congela fase do ataque")
		paused = false
		var budget := 150
		while runtime.playing and budget>0:
			await step()
			budget -= 1
		check(budget>0,"Ataque termina")
		check(player.health == before-monster.damage,"Cada mecânica causa um impacto de dano configurado")
		monster.set_physics_process(false)
		check(monster.health == monster.max_health,"Animação não altera vida do monstro")
		await clean(monster)
		monster = fixture(kind)
		await step(2)
		var locked: Vector2 = monster.attack_runtime.locked_point
		player.position += Vector2(0,75)
		before = player.health
		var evade_budget := 150
		while monster.attack_runtime.playing and evade_budget>0:
			await step()
			evade_budget -= 1
		check(player.health == before,"Movimento para fora do ataque evita dano")
		if kind == 3:
			check(monster.attack_runtime.locked_point == locked,"Marca permanece fixa após jogador se mover")
			check(monster.global_position == locked,"Emergência e corpo físico coincidem com a marca")
		await clean(monster)
		monster = fixture(kind)
		await step(2)
		monster.stagger()
		check(not monster.attack_runtime.playing and monster.visual.visible,"Parry cancela corpo de ataque e restaura locomoção")
		before = player.health
		await step(40)
		check(player.health == before,"Ataque cancelado não deixa dano pendente")
		await clean(monster)
		monster = fixture(kind)
		await step(2)
		monster.take_damage(999)
		check(not monster.attack_runtime.playing and not monster.attack_runtime.visible,"Morte cancela ataque")
		await step(40)
		check(get_nodes_in_group("atlas_monster_projectiles").is_empty(),"Morte não deixa esfera órfã")
		await clean(monster)
	# Defesa real e parede adicionada durante o aviso; sem flexibilizar a lâmina do herói.
	for kind in [0,1,3]:
		for mode in ["parry","dodge","wall"]:
			var monster = fixture(kind)
			await step(2)
			var blocker: StaticBody2D
			if mode == "parry":
				player.state = &"parry"
				player.locked_direction = Vector2.LEFT
			if mode == "dodge": player.state = &"dodge"
			if mode == "wall": blocker = wall_at(player.combat_center()-Vector2(12,0))
			var before: int = player.health
			var budget := 150
			while monster.attack_runtime.playing and budget>0:
				await step()
				budget -= 1
			check(player.health == before,"Defesa "+mode+" monstro "+str(kind))
			if mode == "parry": check(monster.state == &"stagger","Parry interrompe impacto")
			if is_instance_valid(blocker): blocker.queue_free()
			await clean(monster)
	# Geometria cruzada não usa um setor invisível preenchido.
	var fenda = fixture(0)
	await step(2)
	var center: Vector2 = fenda.attack_runtime.to_global(fenda.attack_runtime.effect_center())
	check(fenda.attack_runtime.touches(center,0),"Centro da cruz recebe acerto")
	check(not fenda.attack_runtime.touches(center+Vector2(13,0),0),"Vazio entre cortes não recebe acerto")
	await clean(fenda)
	# Obstrução e emergência inválida: parede adicionada após capturar alvo.
	var burrow = fixture(3,Vector2(60,0))
	await step(2)
	var origin: Vector2 = burrow.position
	var wall := wall_at(player.position+Vector2(0,-3))
	await step(85)
	check(burrow.position == origin and player.health == player.max_health,"Marca bloqueada cancela emergência sem atravessar parede")
	wall.queue_free()
	await clean(burrow)
	# Projétil real, parede, parry e esquiva usam a mesma API do personagem.
	for mode in ["wall","parry","dodge","hit"]:
		var caster = fixture(2,Vector2(80,0))
		caster.set_physics_process(false)
		var projectile := Orb.new()
		projectile.caster = caster
		projectile.target = player
		projectile.settings = caster.attack_settings
		projectile.direction = Vector2.RIGHT
		game.get_node("World").add_child(projectile)
		projectile.global_position = caster.combat_center()
		if mode == "wall": wall = wall_at(player.combat_center()-Vector2(10,0))
		if mode == "parry":
			player.state = &"parry"
			player.locked_direction = Vector2.LEFT
		if mode == "dodge": player.state = &"dodge"
		var before: int = player.health
		await step(50)
		check(player.health == (before-caster.damage if mode == "hit" else before),"Esfera: "+mode)
		if mode == "parry": check(caster.state == &"stagger","Parry da esfera atordoa emissor")
		check(not is_instance_valid(projectile),"Esfera termina sem órfão: "+mode)
		if mode == "wall": wall.queue_free()
		await clean(caster)
	# Repeated projectile lifetimes must not evict/reload the heavy immutable art.
	var resource_caster = fixture(2,Vector2(80,0))
	resource_caster.set_physics_process(false)
	var texture_id := 0
	var shader_id := 0
	var material_ids: Array[int] = []
	for emission in 3:
		var projectile := Orb.new()
		projectile.caster = resource_caster
		projectile.target = player
		projectile.settings = resource_caster.attack_settings
		game.get_node("World").add_child(projectile)
		projectile.set_physics_process(false)
		var next_texture_id: int = projectile.sprite.texture.atlas.get_instance_id()
		var next_shader_id: int = projectile.sprite.material.shader.get_instance_id()
		if emission>0:
			check(next_texture_id==texture_id and next_shader_id==shader_id,"Esferas sucessivas reutilizam arte após liberar a anterior")
		check(not projectile.sprite.material.get_instance_id() in material_ids,"Esferas mantêm material individual")
		material_ids.append(projectile.sprite.material.get_instance_id())
		texture_id = next_texture_id
		shader_id = next_shader_id
		projectile.queue_free()
		await step(3)
	await clean(resource_caster)
	game.queue_free()
	await process_frame
	print("ATLAS_MONSTER_RUNTIME checks=",checks," failures=",failures)
	quit(0 if failures == 0 else 1)
