extends SceneTree
## Exercita entrada -> controlador -> física -> visual na cena principal real.

var failures := 0
var checks := 0
var player: CharacterBody2D

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	run.call_deferred()

func step(count: int = 2) -> void:
	for i in count:
		await physics_frame
		await process_frame

func release_all() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)

func reset_at(location: Vector2) -> void:
	release_all()
	player.position = location
	player.velocity = Vector2.ZERO
	await step()

func run() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	player = main.get_node("World/Player")
	await step()
	check(not main.has_node("World2"), "Only one playable world")
	check(player.motion_mode == CharacterBody2D.MOTION_MODE_FLOATING, "Top-down physics")
	check(player.visual.stable_pose, "Stable pose enabled by default")
	for key in {"move_up": KEY_W, "move_left": KEY_A, "move_down": KEY_S, "move_right": KEY_D}:
		var event := InputEventKey.new()
		event.physical_keycode = {"move_up": KEY_W, "move_left": KEY_A, "move_down": KEY_S, "move_right": KEY_D}[key]
		check(InputMap.event_is_action(event, key), "Physical key mapping: " + key)
	for action in {"move_up": Vector2.UP, "move_left": Vector2.LEFT, "move_down": Vector2.DOWN, "move_right": Vector2.RIGHT}:
		await reset_at(Vector2(320, 180))
		var start := player.position
		Input.action_press(action)
		await step(12)
		var direction: Vector2 = {"move_up": Vector2.UP, "move_left": Vector2.LEFT, "move_down": Vector2.DOWN, "move_right": Vector2.RIGHT}[action]
		check((player.position - start).dot(direction) > 5.0, "Cardinal movement: " + action)
		check(absf(player.get_real_velocity().length() - player.move_speed) < 0.01, "Cardinal speed")
		check(String(player.visual.motion_animation).begins_with("walk_"), "Walk starts")
		var facing = player.visual.facing
		release_all()
		await step()
		var stopped := player.position
		await step(5)
		check(player.position.is_equal_approx(stopped), "No drift after release")
		check(player.visual.motion_animation == StringName("idle_" + String(facing)), "Idle retains direction")
		check(player.visual.sprite.frame == 0 and not player.visual.sprite.is_playing(), "Stable frame does not jitter")
	# All four diagonals have the same speed, with a deterministic vertical tie.
	for horizontal in ["move_left", "move_right"]:
		for vertical in ["move_up", "move_down"]:
			await reset_at(Vector2(320, 180))
			Input.action_press(horizontal)
			Input.action_press(vertical)
			await step(6)
			check(is_equal_approx(player.get_real_velocity().length(), player.move_speed), "Diagonal normalized")
			check(absf(player.get_real_velocity().x) > 30 and absf(player.get_real_velocity().y) > 30, "Both diagonal axes move")
			check(player.visual.facing == (&"up" if vertical == "move_up" else &"down"), "Diagonal facing tie")
	await reset_at(Vector2(320, 180))
	Input.action_press("move_right")
	Input.action_press("move_left")
	await step(4)
	check(player.position.is_equal_approx(Vector2(320, 180)), "Opposite inputs cancel")
	Input.action_release("move_left")
	await step(4)
	check(player.visual.facing == &"right", "Release one opposite input resumes motion")
	Input.action_release("move_right")
	Input.action_press("move_up")
	await step(4)
	check(player.visual.motion_animation == &"walk_up", "Direction switches while moving")
	# Sustained pressure from all sides of the actual obstacle.
	for sample in [[Vector2(360, 180), "move_right", 0, 373.0, 1.0], [Vector2(440, 180), "move_left", 0, 427.0, -1.0], [Vector2(400, 140), "move_down", 1, 160.0, 1.0], [Vector2(400, 220), "move_up", 1, 208.0, -1.0]]:
		await reset_at(sample[0])
		Input.action_press(sample[1])
		await step(50)
		check(player.position[sample[2]] * sample[4] <= sample[3] * sample[4] + 0.2, "Obstacle blocks: " + sample[1])
		check(player.get_real_velocity().length() < 0.1, "No movement through obstacle")
		check(String(player.visual.motion_animation).begins_with("idle_"), "Blocked character idles")
	# Slide along the obstacle, then pass beyond its edge.
	await reset_at(Vector2(372, 180))
	Input.action_press("move_right")
	Input.action_press("move_down")
	await step(70)
	check(player.position.y > 215 and player.position.x > 375, "Diagonal slides and clears obstacle corner")
	for sample in [[Vector2(35, 180), "move_left", 0, 31.0, -1.0], [Vector2(605, 180), "move_right", 0, 609.0, 1.0], [Vector2(320, 100), "move_up", 1, 92.0, -1.0], [Vector2(320, 265), "move_down", 1, 276.0, 1.0]]:
		await reset_at(sample[0])
		Input.action_press(sample[1])
		await step(30)
		check(player.position[sample[2]] * sample[4] <= sample[3] * sample[4] + 0.2, "Floor boundary: " + sample[1])
	# Run real revision playback on the controller, then restore stable default.
	await reset_at(Vector2(320, 180))
	player.visual.stable_pose = false
	Input.action_press("move_left")
	await step(4)
	check(player.visual.sprite.animation == &"walk_left" and player.visual.sprite.is_playing(), "Preview walk plays")
	release_all()
	await step()
	check(player.visual.sprite.animation == &"idle_left", "Preview stops in matching idle")
	player.visual.stable_pose = true
	await step()
	var camera: Camera2D = player.get_node("Camera2D")
	check(camera.is_current(), "Player camera is active")
	check(camera.get_screen_center_position().distance_to(camera.global_position) < 0.1, "Camera follows player")
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/atlas/evidencias/02_movimento.png")
	print("ATLAS_PLAYER_TEST checks=", checks, " failures=", failures)
	main.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
