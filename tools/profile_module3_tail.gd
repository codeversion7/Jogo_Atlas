extends SceneTree
## Diagnostic fixture only. No production rules changed; timestamps exclude debugger monitor semantics.
class PhysicsEnd:
	extends Node
	var probe: SceneTree
	func _physics_process(_delta: float) -> void:
		probe.physics_end()

var physics_start_us := 0
var physics_total_us := 0
var physics_ticks := 0
var draw_start_us := 0
var draw_us := 0
var samples: Array[Dictionary] = []
var pinned_resources: Array[Resource] = []

func _initialize() -> void: run.call_deferred()
func physics_begin() -> void: physics_start_us = Time.get_ticks_usec()
func physics_end() -> void:
	physics_total_us += Time.get_ticks_usec()-physics_start_us
	physics_ticks += 1
func draw_begin() -> void: draw_start_us = Time.get_ticks_usec()
func draw_end() -> void: draw_us = Time.get_ticks_usec()-draw_start_us

func run() -> void:
	var args := OS.get_cmdline_user_args()
	var mode := "idle" if "--idle" in args else "combat"
	if "--retain-orb-resources" in args:
		pinned_resources.append(load("res://assets/monstros/ataques_v1/spore_orb_source.png"))
		pinned_resources.append(load("res://assets/monstros/ataques_v1/attack_cutout.gdshader"))
	var game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.start_session()
	game.ending = &"benchmark" # Explicit performance fixture; not a real playthrough.
	if mode=="combat":
		for kind in 4:
			var monster = load("res://scripts/test_monster.gd").new()
			monster.monster_kind = kind
			monster.max_health = 50000
			monster.prepared_attacks = true
			monster.attack_settings = game.layout.monster_attack_settings
			monster.target = game.player
			monster.position = game.player.position+Vector2(55,0).rotated(kind*TAU/4)
			game.get_node("World").add_child(monster)
	var sentinel := PhysicsEnd.new()
	sentinel.probe = self
	# High priority executes after actors; property is available in this project's engine.
	sentinel.process_physics_priority = 1000000
	root.add_child(sentinel)
	physics_frame.connect(physics_begin)
	RenderingServer.frame_pre_draw.connect(draw_begin)
	RenderingServer.frame_post_draw.connect(draw_end)
	var warmup := Time.get_ticks_msec()
	while Time.get_ticks_msec()-warmup<5000:
		game.player.hurt_wait = 999
		if mode=="combat" and game.player.state==&"ready": game.player.try_attack(Vector2.RIGHT)
		await process_frame
		await RenderingServer.frame_post_draw
	var last := Time.get_ticks_usec()
	physics_total_us = 0
	physics_ticks = 0
	for frame in 1200:
		game.player.hurt_wait = 999
		if mode=="combat" and game.player.state==&"ready": game.player.try_attack(Vector2.RIGHT)
		await process_frame
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		samples.append({"frame":frame,"wall_ms":(now-last)/1000.0,"physics_callbacks_ms":physics_total_us/1000.0,"physics_ticks":physics_ticks,"draw_signal_span_ms":draw_us/1000.0,"native_physics_window_max_ms":Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000})
		last = now
		physics_total_us = 0
		physics_ticks = 0
	var report := {"mode":mode,"fixture":true,"engine":Engine.get_version_info().string,"driver":AudioServer.get_driver_name(),"rendered":DisplayServer.get_name()!="headless","resolution":root.size,"viewport":root.content_scale_size,"samples":samples,"notes":"Physics callbacks wall span: physics_frame to last priority node. Draw signal span includes native rendering/presentation; attribution requires controlled comparison. Neither is per-function CPU profiler."}
	var suffix := "dummy" if AudioServer.get_driver_name()=="Dummy" else "normal"
	if not pinned_resources.is_empty(): suffix += "_retained"
	if "--after" in args: suffix += "_after"
	var file := FileAccess.open("res://docs/atlas/evidencias/16_profile_"+mode+"_"+suffix+".json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"  "))
	print("ATLAS_TAIL_PROFILE mode=",mode," driver=",AudioServer.get_driver_name()," samples=",samples.size())
	game.audio.stop_all()
	game.queue_free()
	await process_frame
	quit()
