extends SceneTree
## Actual Godot viewport captures, not a reconstruction of the scene in an image tool.

func _initialize() -> void:
	render.call_deferred()

func render() -> void:
	var lab = load("res://scenes/animation_lab.tscn").instantiate()
	root.add_child(lab)
	await process_frame
	root.size = Vector2i(640, 360)
	root.content_scale_size = Vector2i(640, 360)
	for mode in ["normal", "lento"]:
		for sample in lab.samples:
			sample.speed_scale = 1.0 if mode == "normal" else 0.5
			sample.set_frame_and_progress(0, 0.0)
		for shot in range(16):
			for tick in range(8 if mode == "normal" else 16):
				await process_frame
			await RenderingServer.frame_post_draw
			var image := root.get_texture().get_image()
			var result := image.save_png("res://docs/atlas/animacoes/captura_%s_%02d.png" % [mode, shot])
			if result != OK:
				push_error("Could not save rendered frame")
				quit(1)
				return
	print("ATLAS_RENDER captures=32 size=640x360 modes=normal,lento")
	quit()
