extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
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
	var center: Vector2 = game.layout.encounter_centers[2]
	game.player.position = center+Vector2(-30,0)
	game.companion.position = center
	game.cleared[2] = true # Fixture: completed original area, no synthetic reward/page.
	game.revisits.note_completed(2)
	game.revisits.roll_override = func():return 0.0
	game.revisits.tick()
	check(game.revisits.rolls==0,"Vitória dentro do local não gera nova visita")
	game.companion.position = center+Vector2(150,0)
	game.revisits.tick()
	game.companion.position = center+Vector2(99,0)
	game.revisits.roll_override = func():return game.revisits.config.chance
	game.revisits.tick()
	check(game.active_encounter<0 and game.revisits.rolls==1,"Fronteira de10% não reativa")
	for i in 30:game.revisits.tick()
	check(game.revisits.rolls==1,"Uma rolagem por visita, sem rerrolar por frame")
	game.companion.position = center+Vector2(110,0)
	game.revisits.tick()
	game.companion.position = center+Vector2(99,0)
	game.revisits.tick()
	check(game.revisits.rolls==1,"Histerese impede oscilação na borda")
	game.companion.position = center+Vector2(150,0)
	game.revisits.tick()
	game.revisits.roll_override = func():return 0.0
	game.companion.position = center+Vector2(99,0)
	game.revisits.tick()
	check(game.reactivated_encounter and game.active_encounter==2,"Reentrada legítima pode reativar horda")
	check(not game.begin_encounter(2,true),"Não sobrepõe duas hordas")
	check(game.cleared.has(2) and game.pages.is_empty() and game.player.attributes.points==0,"Progresso original intacto")
	var before: Vector2 = game.companion.position
	game.companion._physics_process(1.0/60)
	check(game.companion.position.distance_to(before)<=2.01 and game.companion.position!=before,"Companheiro anda pela navegação, sem teleporte ao centro")
	for wave in 3:
		if game.encounter==&"between":game.spawn_wave()
		for enemy in game.enemies.duplicate():enemy.take_damage(9999)
	check(game.active_encounter<0 and not game.reactivated_encounter and game.companion.stay_at==Vector2.INF,"Terminar reativação libera NPC e encontro")
	check(game.pages.is_empty() and game.player.attributes.points==0 and game.player.attributes.rewarded.is_empty(),"Reativação não paga vitória/ponto/página")
	check(game.survival.deaths.size()>0,"Mortes reais passam pelo sistema normal de drops")
	game.companion.position = center+Vector2(150,0)
	game.revisits.tick()
	game.companion.dead = true
	game.companion.position = center
	game.revisits.tick()
	check(not game.reactivated_encounter,"NPC caído não reativa")
	game.companion.dead = false
	game.revisits.inside[2] = false
	paused = true
	var rolls: int = game.revisits.rolls
	game.revisits.tick()
	check(game.revisits.rolls==rolls,"Pausa congela visitas e RNG")
	paused = false
	game.revisits.tick()
	check(game.reactivated_encounter,"Nova visita elegível de fixture inicia")
	game.on_player_died()
	check(game.enemies.is_empty() and game.companion.stay_at==Vector2.INF and not game.reactivated_encounter,"Morte cancela horda/timer e libera acompanhante")
	game.audio.stop_all()
	game.queue_free()
	await process_frame
	print("ATLAS_MODULE4_REVISITS checks=",checks," failures=",failures)
	quit(0 if failures==0 else 1)
