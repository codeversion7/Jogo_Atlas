extends SceneTree
const BASE := "res://assets/personagem/ataque_adaga_v1/"
const OUT := "res://docs/arte/ataque_adaga/previas/"
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	DirAccess.make_dir_recursive_absolute(BASE+"png")
	var review = load("res://scenes/review/dagger_attack_review.tscn").instantiate()
	root.add_child(review)
	current_scene = review
	review.set_process(false)
	for frame in 12:
		review.display_frame(frame)
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(OUT+"ataque_%02d.png" % frame) == OK)
	for layer in ["body","dagger","trail","combined"]:
		var sheet := Image.create(960,320,false,Image.FORMAT_RGBA8)
		for direction in 4:
			for frame in 12:
				var name: String = "%s_%s_%02d" % [layer,review.DIRECTIONS[direction],frame]
				var texture: Texture2D = load(BASE+name+".svg")
				var image := texture.get_image()
				assert(image.save_png(BASE+"png/"+name+".png") == OK)
				sheet.blit_rect(image,Rect2i(0,0,80,80),Vector2i(frame*80,direction*80))
		assert(sheet.save_png(BASE+layer+"_spritesheet.png") == OK)
	print("ATLAS_DAGGER_RENDER captures=12 png_frames=192 sheets=4")
	review.queue_free()
	await process_frame
	quit()
