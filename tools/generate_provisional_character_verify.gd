extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var actor = load("res://scenes/atlas_visual_revisao.tscn").instantiate()
	root.add_child(actor)
	await process_frame
	var frames: SpriteFrames = actor.sprite.sprite_frames
	check(frames.get_animation_names().size() == 8, "Eight motion clips")
	check(actor.sprite.offset == Vector2(-20, -46), "Fixed feet origin")
	for direction in [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]:
		actor.set_motion(direction * 48.0)
		var clip: StringName = actor.sprite.animation
		check(String(clip).begins_with("walk_"), "Walk visible")
		check(frames.get_frame_count(clip) == 6, "Six articulated walk frames")
		var hashes := {}
		for frame in 6:
			var im: Image = frames.get_frame_texture(clip, frame).get_image()
			check(im.get_size() == Vector2i(40,48), "Native dimensions")
			check(im.get_pixel(0,0).a == 0.0, "Transparent corners")
			hashes[hash(im.get_data())] = true
		check(hashes.size() == 6, "Six distinct limb phases")
		var before: int = actor.sprite.frame
		for i in 20:
			actor.set_motion(direction * 48.0)
			await create_timer(0.02).timeout
		check(actor.sprite.frame != before, "Clock progresses under repeated movement calls")
		actor.set_motion(Vector2.ZERO)
		check(actor.sprite.animation == StringName("idle_" + String(actor.facing)), "Idle transition retains facing")
		for state in [&"attack_windup", &"attack_active", &"attack_recovery", &"parry", &"dodge", &"hurt", &"dead"]:
			actor.set_action(state,direction,0.8)
			check(String(actor.sprite.animation).begins_with(String(state)), "Action pose " + state)
			var expected: int = {&"attack_windup":1,&"attack_active":3,&"attack_recovery":4}.get(state,2)
			check(actor.sprite.frame == expected, "Action progress selects actual 2/4/6 or legacy 3-frame pose")
		actor.set_action(&"",direction)
		check(actor.sprite.sprite_frames == frames and actor.sprite.is_playing(), "Action resumes motion resource")
	actor.stable_pose = true
	actor.set_motion(Vector2.RIGHT * 48)
	check(not actor.sprite.is_playing() and actor.sprite.frame == 0, "Laboratory stable pose remains")
	var sheet: Texture2D = load("res://assets/personagem/provisorio/walk_contact_sheet.svg")
	check(sheet.get_image().save_png("res://assets/personagem/provisorio/walk_contact_sheet.png") == OK,"Save review contact sheet")
	print("ATLAS_PROVISIONAL_VISUAL checks=",checks," failures=",failures)
	quit(0 if failures == 0 else 1)
