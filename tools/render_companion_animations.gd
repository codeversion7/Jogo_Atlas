extends SceneTree
const Visual = preload("res://scripts/companion_visual.gd")
const OUT := "res://docs/arte/npc/previas/"
const BASE := "res://assets/npcs/companheiro/animacoes_v1/"
const COUNTS := {"idle":8,"walk":8,"run":8,"hurt":6,"shield":24}
func _initialize() -> void: run.call_deferred()
func capture(viewport: Viewport) -> Image:
	await process_frame
	await RenderingServer.frame_post_draw
	return viewport.get_texture().get_image()
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	DirAccess.make_dir_recursive_absolute(BASE)
	var lab = load("res://scenes/review/companion_animation_lab.tscn").instantiate()
	root.add_child(lab)
	lab.set_process(false)
	for i in 40:
		lab.show_time(i/25.0)
		var image := await capture(root)
		assert(image.save_png(OUT+"npc_%02d.png" % i)==OK)
	lab.queue_free()
	await process_frame
	var viewport := SubViewport.new()
	viewport.size = Vector2i(64,64)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var actor := Visual.new()
	actor.automatic = false
	actor.position = Vector2(32,52)
	viewport.add_child(actor)
	for direction in 4:
		var resources: Dictionary = {}
		for layer in ["body","effects","combined"]:
			resources[layer] = SpriteFrames.new()
			resources[layer].remove_animation(&"default")
		for state in COUNTS:
			var count := int(COUNTS[state])
			var sheets: Dictionary = {}
			for layer in resources:
				sheets[layer] = Image.create(count*64,64,false,Image.FORMAT_RGBA8)
			actor.play(state,direction)
			for i in count:
				actor.sample(float(Visual.TIMES[state])*i/count)
				for layer in resources:
					actor.body.visible = layer != "effects"
					actor.shield.visible = layer != "body" and actor.opening>0
					var image := await capture(viewport)
					sheets[layer].blit_rect(image,Rect2i(0,0,64,64),Vector2i(i*64,0))
			for layer in resources:
				var name := "%s_%s_%s" % [state,Visual.DIRECTIONS[direction],layer]
				var path := BASE+name+".png"
				assert(sheets[layer].save_png(path)==OK)
				var texture := ImageTexture.create_from_image(sheets[layer])
				texture.resource_path = path
				var frames: SpriteFrames = resources[layer]
				var clip := StringName(state+"_"+Visual.DIRECTIONS[direction])
				frames.add_animation(clip)
				frames.set_animation_loop(clip,state not in ["shield","hurt"])
				frames.set_animation_speed(clip,count/float(Visual.TIMES[state]))
				for i in count:
					var frame := AtlasTexture.new()
					frame.atlas = texture
					frame.region = Rect2(i*64,0,64,64)
					frames.add_frame(clip,frame)
		for layer in resources:
			assert(ResourceSaver.save(resources[layer],BASE+Visual.DIRECTIONS[direction]+"_"+layer+".tres")==OK)
	viewport.queue_free()
	await process_frame
	print("ATLAS_COMPANION_RENDER: 40 captures; 216 poses; 60 sheets; 12 SpriteFrames")
	quit()
