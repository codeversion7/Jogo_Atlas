extends SceneTree
const Settings = preload("res://scripts/session_settings.gd")
const Audio = preload("res://scripts/session_audio.gd")
var checks := 0
var failures := 0
var game
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures+=1; push_error(message)
func step(n: int = 1) -> void:
	for i in n:
		await physics_frame
		await process_frame
func key(code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await step()
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await step()
func run() -> void:
	var path := "user://atlas_settings_fixture.cfg"
	DirAccess.remove_absolute(path)
	var settings := Settings.new()
	settings.path = path
	root.add_child(settings)
	check(not settings.loaded and settings.values==Settings.DEFAULTS,"Missing file preserves defaults and custom window")
	check(settings.set_value("effects",0.25),"Preferences save succeeds")
	settings.set_value("mute",true)
	settings.load_preferences()
	check(settings.values.effects==0.25 and settings.values.mute,"Reopening settings restores saved volumes/mute")
	check(is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects"))),0.25) and AudioServer.is_bus_mute(0),"Mixer consumes preferences")
	settings.set_value("master",INF)
	check(settings.values.master==Settings.DEFAULTS.master,"Nonfinite volume uses safe default")
	settings.set_value("effects",15)
	check(settings.values.effects==1.0,"Out-of-range volume is clamped")
	settings.set_value("fullscreen",true)
	settings.set_value("window_scale",3)
	settings.load_preferences()
	check(settings.values.fullscreen and settings.values.window_scale==3,"Display preference persists separately from campaign")
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string("[broken=\"unterminated")
	file.close()
	settings.load_preferences()
	check(not settings.last_error.is_empty() and settings.values==Settings.DEFAULTS,"Corrupt file reports safe fallback")
	settings.path = "user://missing-directory/settings.cfg"
	check(not settings.save_preferences() and not settings.last_error.is_empty(),"Write failure is surfaced")
	settings.path = path
	settings.restore_defaults()
	settings.queue_free()
	DirAccess.remove_absolute(path)
	game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	check(game.session_ui.active==&"menu" and paused,"Real entry remains menu")
	game.session_ui.actions.get_child(1).pressed.emit()
	check(game.session_ui.active==&"settings" and paused,"Menu settings share panel ownership")
	await key(KEY_ESCAPE)
	check(game.session_ui.active==&"menu" and paused,"Esc returns to menu without unpausing world")
	game.start_session()
	await step(3)
	game.session_ui.claim(&"pause")
	game.session_ui.open_settings()
	await key(KEY_TAB)
	check(game.session_ui.active==&"settings" and not game.character_panel.opened,"Tree cannot open behind settings")
	await key(KEY_ESCAPE)
	check(game.session_ui.active==&"pause" and paused,"Pause settings return to paused parent")
	game.session_ui.close()
	await step(3)
	for item in JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/sources.json")):
		check(FileAccess.get_sha256("res://"+item.source)==FileAccess.get_sha256("res://"+item.runtime),"Audio copy preserves original bitstream")
	for key_name in Audio.STREAMS:
		check(Audio.STREAMS[key_name].get_length()>0 and Audio.STREAMS[key_name].instantiate_playback()!=null,"Imported stream decodes: "+key_name)
	Input.action_press("move_right")
	await step(4)
	var has_step := false
	for sound in game.audio.voices:
		if sound.get_meta("event")=="steps" and sound.playing: has_step = true
	check(has_step,"Actual walking emits a footstep voice")
	Input.action_release("move_right")
	await step(3)
	var lingering_step := false
	for sound in game.audio.voices:
		if sound.get_meta("event")=="steps" and sound.playing: lingering_step = true
	check(not lingering_step,"Stopping physical movement stops footsteps")
	var before: int = game.audio.events_played
	Audio.event(game.player,"dagger","same")
	Audio.event(game.player,"dagger","same")
	check(game.audio.events_played==before+1,"Repeated event in same physics frame is deduplicated")
	for i in 20:
		var emitter := Node2D.new()
		game.get_node("World").add_child(emitter)
		Audio.event(emitter,"cross",str(i))
	await step(3) # AudioStreamPlayer2D starts queued playback on its next physics frame.
	check(game.audio.voices.size()<=8,"Voice pool is bounded")
	if game.audio.voices.is_empty():
		game.queue_free()
		quit(1)
		return
	var voice = game.audio.voices[0]
	var age: float = voice.get_meta("age")
	game.session_ui.claim(&"map")
	await step(20)
	check(voice.get_meta("age")==age and voice.stream_paused,"Paused audio voice and native playback are both frozen")
	game.session_ui.close()
	await step(140)
	check(game.audio.voices.is_empty(),"Completed one-shots release voices")
	Audio.event(game.player,"parry")
	game.player.dead = true
	await step(2)
	check(game.audio.voices.is_empty(),"Death releases session sounds")
	game.queue_free()
	await step(2)
	check(get_nodes_in_group("atlas_audio").is_empty(),"Scene teardown leaves no audio service or duplicated soundtrack")
	print("ATLAS_MODULE3_AUDIO_SETTINGS checks=",checks," failures=",failures)
	quit(0 if failures==0 else 1)
