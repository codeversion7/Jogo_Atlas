extends Node
## Harness exportado separado monta o PCK real; nenhum teste é incluído na entrega.
var checks := 0
var failures := 0
var game
@onready var root: Window = get_tree().root
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(message)
func step(n: int = 1) -> void:
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame
func run() -> void:
	var pack := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--game-pack="): pack = arg.trim_prefix("--game-pack=")
	if pack.is_empty() or not ProjectSettings.load_resource_pack(pack,true):
		check(false,"Actual exported PCK must be mounted")
		get_tree().quit(1)
		return
	print("ATLAS_EXPORT_TEST_USER_DIR ",ProjectSettings.globalize_path("user://"))
	check(FileAccess.get_file_as_bytes("res://project.binary").slice(0,4)==PackedByteArray([69,67,70,71]),"Primary game pack contains a valid binary project header")
	check(not FileAccess.file_exists("res://tools/verify_export_runtime.gd"),"Primary game pack excludes development tools")
	check(not OS.has_feature("editor"),"Runtime is the exported template, not editor binary")
	game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	get_tree().current_scene = game
	check(game.session_ui.active==&"menu" and get_tree().paused,"Export starts original menu")
	game.session_ui.actions.get_child(1).pressed.emit()
	check(game.session_ui.active==&"settings","Export settings are functional")
	check(game.settings.set_value("effects",0.25),"Export writes preferences into isolated user directory")
	game.session_ui.close_settings()
	game.session_ui.actions.get_child(0).pressed.emit()
	await step(3)
	check(game.session_started and game.companion.visual.body.mesh!=null,"Export starts game with real companion art")
	for key in game.audio.STREAMS:
		check(game.audio.STREAMS[key].get_length()>0,"Export contains decoded MP3: "+key)
	game.audio.play_event(game.player,"dagger")
	await step(12)
	check(not game.audio.voices.is_empty() and game.audio.voices[0].get_playback_position()>0,"Export audio playback advances")
	var before: Vector2 = game.player.position
	Input.action_press("move_right")
	await step(12)
	Input.action_release("move_right")
	check(game.player.position.x>before.x+5,"Export moves with normal physical controls")
	for kind in 4:
		var monster = load("res://scripts/test_monster.gd").new()
		monster.prepared_attacks = true
		monster.monster_kind = kind
		monster.target = game.player
		monster.position = game.player.position+Vector2(60,0).rotated(kind*TAU/4)
		game.get_node("World").add_child(monster)
		monster.set_physics_process(false) # Explicit resource fixture, not a horde won by the player.
		check(monster.attack_runtime.phases.size()>=3 and monster.attack_runtime.sprite.sprite_frames.get_frame_texture(&"attack_down",0)!=null,"Export contains monster attack profile/body: "+str(kind))
		if kind==2:
			var orb = load("res://scripts/monster_orb.gd").new()
			orb.caster = monster
			orb.target = game.player
			orb.settings = monster.attack_settings
			game.get_node("World").add_child(orb)
			orb.set_physics_process(false)
			check(orb.sprite.texture.atlas!=null,"Export orb uses production asset, not excluded reference source")
			orb.queue_free()
			await step(3)
			check(ResourceLoader.has_cached("res://assets/monstros/ataques_v1/spore_orb_source.png"),"Export retains orb art after projectile removal")
		monster.queue_free()
	game.survival.raw = 1 # Fixture to confirm settings persistence is not a campaign save.
	game.return_to_menu()
	await step(3)
	game = get_tree().current_scene
	check(game.settings.values.effects==0.25 and game.survival.raw==0,"Export reload persists only preferences and clears campaign")
	check(get_tree().get_nodes_in_group("atlas_audio").size()==1 and get_tree().get_nodes_in_group("atlas_companion").size()==1,"Export reload has no duplicate audio/NPC actors")
	print("ATLAS_EXPORT_SMOKE checks=",checks," failures=",failures," exported=",not OS.has_feature("editor"))
	if failures>0: get_tree().quit(1)
	else: game.session_ui.actions.get_child(game.session_ui.actions.get_child_count()-1).pressed.emit()
