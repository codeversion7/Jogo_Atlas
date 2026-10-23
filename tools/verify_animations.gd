extends SceneTree
## Integration assertions; does not certify artistic quality or planted-foot motion.
var failures := 0
var loop_count := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var frames = load("res://assets/personagem/revisao/atlas_rascunho.tres") as SpriteFrames
	check(frames != null, "SpriteFrames must load")
	if frames == null:
		quit(1)
		return
	check(frames.get_animation_names().size() == 8, "Eight directional clips required")
	for direction in ["down", "left", "right", "up"]:
		for kind in ["idle", "walk"]:
			var name := StringName(kind + "_" + direction)
			check(frames.has_animation(name), "Missing clip: " + name)
			check(frames.get_frame_count(name) == (4 if kind == "idle" else 6), "Wrong frame count")
			check(frames.get_animation_speed(name) == (4.0 if kind == "idle" else 8.0), "Wrong frame rate")
			check(frames.get_animation_loop(name), "Clip must loop")
			for index in frames.get_frame_count(name):
				var texture := frames.get_frame_texture(name, index)
				check(texture.get_size() == Vector2(40, 48), "Wrong frame dimensions")
	var actor = load("res://scenes/atlas_visual_revisao.tscn").instantiate()
	root.add_child(actor)
	await process_frame
	var sprite: AnimatedSprite2D = actor.get_node("AnimatedSprite2D")
	check(sprite.offset == Vector2(-20, -46) and not sprite.centered, "Feet pivot mismatch")
	for direction in [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]:
		actor.set_motion(direction * 48)
		check(String(sprite.animation).begins_with("walk_"), "Motion should walk")
		var old_direction = actor.facing
		actor.set_motion(Vector2.ZERO)
		check(actor.facing == old_direction, "Stop must retain facing")
		check(String(sprite.animation) == "idle_" + String(old_direction), "Stop should use matching idle")
	sprite.animation_looped.connect(func(): loop_count += 1)
	var initial_position: Vector2 = actor.position
	for clip in frames.get_animation_names():
		sprite.play(clip)
		sprite.speed_scale = 1.0
		var loops_before := loop_count
		var duration := float(frames.get_frame_count(clip)) / frames.get_animation_speed(clip)
		await create_timer(duration + 0.08).timeout
		check(loop_count > loops_before, "Playback did not loop: " + clip)
	actor.set_motion(Vector2(48, 0))
	var loops_before := loop_count
	for i in range(60):
		actor.set_motion(Vector2(48, 0))
		await create_timer(1.0 / 60.0).timeout
	check(loop_count > loops_before, "Motion updates restarted the animation clock")
	check(actor.position == initial_position, "Visual component must never move its parent")
	actor.set_motion(Vector2(24, 0))
	check(is_equal_approx(sprite.speed_scale, 0.5), "Half velocity should halve walk rate")
	actor.set_motion(Vector2.ZERO)
	check(is_equal_approx(sprite.speed_scale, 1.0), "Idle must restore clock rate")
	actor.queue_free()
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	check(main.get_node("World/Player") is CharacterBody2D, "Main scene must contain the playable character")
	main.queue_free()
	var lab = load("res://scenes/review/animation_lab.tscn").instantiate()
	root.add_child(lab)
	await process_frame
	check(lab.samples.size() == 8 and is_instance_valid(lab.pilot), "Lab failed to assemble")
	var pilot_start: Vector2 = lab.pilot.position
	Input.action_press("move_right")
	await create_timer(0.1).timeout
	Input.action_release("move_right")
	check(lab.pilot.position.x > pilot_start.x, "WASD mapped action failed in laboratory")
	await create_timer(0.05).timeout
	check(lab.pilot.get_node("AnimatedSprite2D").animation == &"idle_right", "Laboratory stop must retain last facing")
	lab.queue_free()
	print("ATLAS_ANIMATION_TEST failures=", failures, " observed_walk_loops=", loop_count)
	quit(0 if failures == 0 else 1)
