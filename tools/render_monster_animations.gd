extends SceneTree
const Visual = preload("res://scripts/monster_visual.gd")
const Catalog = preload("res://scripts/monster_animation_catalog.gd")
const MODES := [&"idle",&"walk",&"run",&"hurt"]
const OUT := "res://docs/arte/monstros/previas"
func _initialize() -> void:
	run.call_deferred()
func capture(path: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png(path)
	assert(result == OK)
func run() -> void:
	root.size = Vector2i(640,360)
	var lab = load("res://scenes/review/monster_animation_lab.tscn").instantiate()
	root.add_child(lab)
	current_scene = lab
	lab.set_process(false)
	DirAccess.make_dir_recursive_absolute(OUT)
	await capture(OUT+"/laboratorio.png")
	for child in lab.get_children():
		if child is Label and child.position.y == 56:
			child.text = ["FRENTE","ESQUERDA","DIREITA","COSTAS"][int((child.position.x-145)/128)]
	for mode in MODES:
		lab.info.text = "Estado: %s · todas as direções · arte original articulada" % mode
		var count: int = Visual.COUNTS[mode]
		for frame in count:
			for i in lab.actors.size():
				lab.actors[i].sample(mode,Catalog.DIRECTIONS[i%4],frame)
			await capture(OUT+"/%s_%02d.png" % [mode,frame])
	print("ATLAS_MONSTER_RENDER poses=592 captures=38")
	lab.queue_free()
	await process_frame
	quit()
