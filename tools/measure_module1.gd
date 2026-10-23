extends SceneTree
## Rendered reproducible four-enemy workload; not a fixed-FPS headless benchmark.
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var start := Time.get_ticks_usec()
	var scene = load("res://scenes/playable.tscn")
	var load_us := Time.get_ticks_usec()-start
	start = Time.get_ticks_usec()
	var game = scene.instantiate()
	root.add_child(game)
	current_scene = game
	var ready_us := Time.get_ticks_usec()-start
	game.ending = &"benchmark"
	for kind in 4:
		var monster = load("res://scripts/test_monster.gd").new()
		monster.monster_kind = kind
		monster.max_health = 50000
		monster.target = game.player
		monster.position = game.player.position + Vector2(55,0).rotated(kind*TAU/4)
		game.get_node("World").add_child(monster)
	var frame_ms: Array[float] = []
	var script_ms: Array[float] = []
	var physics_ms: Array[float] = []
	var draw_calls := 0.0
	var last := Time.get_ticks_usec()
	for frame in 360:
		game.player.hurt_wait = 999.0
		if game.player.state == &"ready":
			game.player.try_attack(Vector2.RIGHT)
		await process_frame
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		if frame >= 60:
			frame_ms.append((now-last)/1000.0)
			script_ms.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000)
			physics_ms.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000)
			draw_calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		last = now
	frame_ms.sort()
	script_ms.sort()
	physics_ms.sort()
	var report := {"engine":Engine.get_version_info().string,"rendered":DisplayServer.get_name()!="headless","resolution":root.size,"viewport":root.content_scale_size,"enemies":4,"samples":300,"load_ms":load_us/1000.0,"ready_ms":ready_us/1000.0,"frame_median_ms":frame_ms[150],"frame_p95_ms":frame_ms[285],"process_median_ms":script_ms[150],"process_p95_ms":script_ms[285],"physics_median_ms":physics_ms[150],"physics_p95_ms":physics_ms[285],"draw_calls_mean":draw_calls/300,"static_memory_mib":Performance.get_monitor(Performance.MEMORY_STATIC)/1048576.0}
	var path := "res://docs/atlas/evidencias/12_perf_" + ("after" if "--after" in OS.get_cmdline_user_args() else "before") + ".json"
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"  "))
	print("ATLAS_PERF ",JSON.stringify(report))
	quit()
