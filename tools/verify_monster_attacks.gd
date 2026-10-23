extends SceneTree
const Visual = preload("res://scripts/monster_attack_visual.gd")
const BASE := "res://assets/monstros/ataques_v1/"
var checks := 0
var failures := 0
var finishes := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASE+"profiles.json"))
	for source in catalog.sources:
		check(FileAccess.get_sha256("res://"+source.path) == source.sha256,"Original alterado: "+source.path)
	for kind in 4:
		var actor := Visual.new()
		actor.monster_kind = kind
		actor.automatic = false
		root.add_child(actor)
		actor.play(Vector2(11,28))
		var origin := actor.position
		var target := actor.target_point
		var cursor := 0.0
		var expected_count := 0
		for item in actor.profile.phases:
			actor.sample(cursor+float(item.duration)*0.5)
			check(actor.phase == StringName(item.name),"Fase incorreta")
			check(is_equal_approx(actor.phase_progress,0.5),"Progresso incorreto")
			check(actor.position == origin,"Animação moveu a raiz")
			check(actor.target_point == target,"Alvo não permaneceu fixo")
			check(actor.body.mesh != null,"Corpo sem malha")
			check(actor.fx != actor.body and actor.projectile.get_parent() == actor.fx,"Camadas misturadas")
			if kind == 2:
				check(actor.projectile.visible == (item.name in ["launch","flight"]),"Projétil fora da fase")
			if kind == 3 and item.name == "warning":
				check(actor.body.position.y >= target.y+35,"Escavador visível antes da saída")
			cursor += float(item.duration)
			expected_count += int(item.frames)
		if kind == 2:
			actor.sample(0.63)
			var start := actor.projectile.position
			actor.sample(1.10)
			check(actor.projectile.position.distance_to(target) < start.distance_to(target),"Esfera não avança até o impacto")
		if kind == 3:
			actor.sample(0.90)
			check(actor.body.position == target,"Emergência fora da marca")
		actor.finished.connect(func(): finishes += 1)
		actor.play(target)
		actor.advance(cursor+1)
		actor.advance(1)
		check(finishes == kind+1 and not actor.playing,"Fim deve emitir uma vez")
		for layer in ["body","effects","combined"]:
			var frames := load(BASE+actor.profile.id+"_"+layer+".tres") as SpriteFrames
			check(frames != null,"SpriteFrames ausente")
			if frames == null:
				continue
			check(frames.get_frame_count(&"attack_down") == expected_count,"Quantidade de quadros incorreta")
			check(not frames.get_animation_loop(&"attack_down"),"Ataque não deve repetir automaticamente")
			var total := 0.0
			for i in expected_count:
				total += frames.get_frame_duration(&"attack_down",i)/frames.get_animation_speed(&"attack_down")
				check(frames.get_frame_texture(&"attack_down",i).get_size() == Vector2(128,128),"Grade incorreta")
			check(absf(total-cursor) < 0.0001,"Tempo exportado diverge do ciclo")
			for item in actor.profile.phases:
				check(frames.get_frame_count(StringName(item.name+"_down")) == int(item.frames),"Clip de fase incorreto")
		actor.queue_free()
		await process_frame
	print("ATLAS_MONSTER_ATTACK_TEST checks=",checks," failures=",failures)
	quit(0 if failures == 0 else 1)
