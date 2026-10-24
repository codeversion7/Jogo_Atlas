extends SceneTree
const Visual = preload("res://scripts/companion_visual.gd")
var checks := 0
var failures := 0
var finishes := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func run() -> void:
	var actor := Visual.new()
	actor.automatic = false
	root.add_child(actor)
	for direction in 4:
		for state in Visual.TIMES:
			actor.play(state,direction)
			var first: ArrayMesh
			for i in 12:
				actor.sample(float(Visual.TIMES[state])*i/12.0)
				check(actor.body.mesh != null,"Missing body")
				check(actor.position == Vector2.ZERO,"Visual moved root")
				check(actor.direction == direction,"Facing changed")
				check(actor.shield != actor.body,"Effects mixed with body")
				if i==0:first=actor.body.mesh
				if state == "walk" and i==7:check(actor.body.mesh != first,"Walk frame frozen")
		actor.play("shield",direction)
		actor.sample(0.08)
		check(actor.phase=="prepare" and not actor.shield.visible,"Shield appeared before pull")
		actor.sample(0.28)
		check(actor.phase=="deploy" and actor.opening>0 and actor.opening<1,"Shield does not unfold")
		check(actor.arm_lift==1,"Arm does not raise")
		actor.sample(0.6)
		check(actor.phase=="hold" and actor.opening==1,"Shield hold missing")
		check((actor.shield.z_index<actor.body.z_index)==(direction==3),"Back occlusion wrong")
		actor.sample(1.12)
		check(not actor.shield.visible and actor.arm_lift==0,"Shield not retracted")
	actor.animation_finished.connect(func(): finishes += 1)
	actor.play("shield",2)
	actor.advance(1.2)
	actor.advance(0.1)
	check(finishes==1 and actor.state=="idle","Action did not return once to idle")
	for pair in [[Vector2.DOWN,0],[Vector2.LEFT,1],[Vector2.RIGHT,2],[Vector2.UP,3]]:
		actor.set_motion(pair[0]*120)
		check(actor.state=="walk" and actor.direction==pair[1],"Motion facing incorrect")
	actor.set_motion(Vector2.ZERO)
	check(actor.state=="idle","Motion did not stop")
	var sources: Array = JSON.parse_string(FileAccess.get_file_as_string(Visual.BASE+"sources.json"))
	for item in sources:
		check(FileAccess.get_sha256(Visual.BASE+item.file)==item.sha256,"Production source changed")
		check(FileAccess.get_sha256("res://NPC_Personagem/assets/npcs/companheiro/pixel_v2/"+item.file)==item.sha256,"Original changed")
	var counts := {"idle":8,"walk":8,"run":8,"hurt":6,"shield":24}
	for direction in Visual.DIRECTIONS:
		for layer in ["body","effects","combined"]:
			var frames := load("res://assets/npcs/companheiro/animacoes_v1/"+direction+"_"+layer+".tres") as SpriteFrames
			check(frames!=null,"Exported SpriteFrames not loadable")
			if frames==null:continue
			for state in counts:
				var clip := StringName(state+"_"+direction)
				check(frames.get_frame_count(clip)==int(counts[state]),"Exported frame count wrong")
				check(frames.get_animation_loop(clip)==(state not in ["shield","hurt"]),"Exported action loops")
				check(absf(frames.get_frame_count(clip)/frames.get_animation_speed(clip)-float(Visual.TIMES[state]))<0.0001,"Exported duration changed")
				for i in frames.get_frame_count(clip):
					check(frames.get_frame_texture(clip,i).get_size()==Vector2(64,64),"Export grid wrong")
	actor.queue_free()
	await process_frame
	print("ATLAS_COMPANION_VISUAL checks=",checks," failures=",failures)
	quit(0 if failures==0 else 1)
