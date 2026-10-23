extends SceneTree
const Visual = preload("res://scripts/monster_attack_visual.gd")
const BASE := "res://assets/monstros/ataques_v1/"
const OUT := "res://docs/arte/monstros/ataques_v1/previas/"
func _initialize() -> void:
	run.call_deferred()

func capture(viewport: Viewport) -> Image:
	await process_frame
	await RenderingServer.frame_post_draw
	return viewport.get_texture().get_image()

func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var lab = load("res://scenes/review/monster_attack_lab.tscn").instantiate()
	root.add_child(lab)
	current_scene = lab
	lab.set_process(false)
	for i in 50:
		lab.show_time(i/20.0)
		var screen := await capture(root)
		assert(screen.save_png(OUT+"ataques_%02d.png" % i) == OK)
	lab.queue_free()
	await process_frame
	var viewport := SubViewport.new()
	viewport.size = Vector2i(128,128)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASE+"profiles.json"))
	var total_frames := 0
	for kind in 4:
		var actor := Visual.new()
		actor.monster_kind = kind
		actor.automatic = false
		actor.position = Vector2(64,64)
		viewport.add_child(actor)
		actor.play(Vector2(0,28) if kind == 2 else Vector2.ZERO)
		var profile: Dictionary = catalog.attacks[kind]
		var count := 0
		for item in profile.phases:
			count += int(item.frames)
		var sheets: Dictionary = {}
		for layer in ["body","effects","combined"]:
			sheets[layer] = Image.create(128*count,128,false,Image.FORMAT_RGBA8)
		var frame := 0
		var cursor := 0.0
		var timeline: Array = []
		for item in profile.phases:
			for i in int(item.frames):
				var frame_duration := float(item.duration)/int(item.frames)
				actor.sample(cursor+(i+0.5)*frame_duration)
				timeline.append({"phase":item.name,"duration":frame_duration})
				for layer in ["body","effects","combined"]:
					actor.body.visible = layer != "effects"
					actor.fx.visible = layer != "body"
					var image := await capture(viewport)
					sheets[layer].blit_rect(image,Rect2i(0,0,128,128),Vector2i(frame*128,0))
				frame += 1
			cursor += float(item.duration)
		for layer in sheets:
			var prefix := "%s_%s" % [profile.id,layer]
			assert(sheets[layer].save_png(BASE+prefix+".png") == OK)
			write_resource(prefix,timeline)
		total_frames += frame
		actor.queue_free()
		await process_frame
	viewport.queue_free()
	await process_frame
	print("ATLAS_MONSTER_ATTACK_RENDER captures=50 frames=",total_frames," sheets=12 resources=12")
	quit()

func write_resource(prefix: String, timeline: Array) -> void:
	var result := "[gd_resource type=\"SpriteFrames\" load_steps=%d format=3]\n\n" % [timeline.size()+2]
	result += "[ext_resource type=\"Texture2D\" path=\"%s%s.png\" id=\"1\"]\n\n" % [BASE,prefix]
	for i in timeline.size():
		result += "[sub_resource type=\"AtlasTexture\" id=\"Frame%d\"]\natlas = ExtResource(\"1\")\nregion = Rect2(%d, 0, 128, 128)\n\n" % [i,i*128]
	result += "[resource]\nanimations = [\n"
	var phases := ["attack"]
	for item in timeline:
		if item.phase not in phases:
			phases.append(item.phase)
	for phase in phases:
		result += "{\"name\": &\"%s_down\", \"loop\": false, \"speed\": 1.0, \"frames\": [" % phase
		for i in timeline.size():
			if phase == "attack" or timeline[i].phase == phase:
				result += "{\"duration\": %s, \"texture\": SubResource(\"Frame%d\")}," % [str(timeline[i].duration),i]
		result += "]},\n"
	result += "]\n"
	var file := FileAccess.open(BASE+prefix+".tres",FileAccess.WRITE)
	file.store_string(result)
