extends SceneTree
const BASE := "res://assets/personagem/ataque_adaga_v1/"
var checks := 0
var failures := 0
func _initialize() -> void:
	run.call_deferred()
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func run() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASE+"manifesto.json"))
	# Use esta guarda somente na preparaÃ§Ã£o de arte; a integraÃ§Ã£o futura modifica esses scripts.
	if "--assets-only" in OS.get_cmdline_user_args():
		for path in manifest.unchanged_runtime_sha256:
			check(FileAccess.get_sha256("res://"+path) == manifest.unchanged_runtime_sha256[path],"Existing gameplay and animation resources unchanged: "+path)
	check(manifest.frames.size() == 48,"48 directional poses")
	for layer in ["body","dagger","trail","combined"]:
		var frames: SpriteFrames = load(BASE+"atlas_attack_"+layer+".tres")
		check(frames.get_animation_names().size() == 16,"All four directions and phases exist")
		for direction in ["down","left","right","up"]:
			var clip := StringName("attack_"+direction)
			check(frames.get_frame_count(clip) == 12 and not frames.get_animation_loop(clip),"Single non-looping 12-frame attack")
			var total := 0.0
			var original_feet: Image
			for i in 12:
				var image := frames.get_frame_texture(clip,i).get_image()
				check(image.get_size() == Vector2i(80,80),"Uniform transparent canvas")
				var bounds := image.get_used_rect()
				if not bounds.has_area():
					check(layer == "trail","Only an inactive trail may be empty")
				else:
					check(bounds.position.x > 0 and bounds.position.y > 0 and bounds.end.x < 80 and bounds.end.y < 80,"Pose and dagger are not clipped")
				total += frames.get_frame_duration(clip,i)/frames.get_animation_speed(clip)
				if layer == "body":
					# Somente as solas: a regiÃ£o acima inclui cachecol/mÃ£os em movimento.
					var feet := image.get_region(Rect2i(32,60,20,2))
					if i == 0:
						original_feet = feet
					var stable := true
					for y in feet.get_height():
						for x in feet.get_width():
							var pixel := feet.get_pixel(x,y)
							var original := original_feet.get_pixel(x,y)
							# O importador SVG preenche RGB invisÃ­vel fora da silhueta.
							if pixel.a != original.a or (pixel.a > 0 and pixel != original):
								stable = false
					check(stable,"Planted feet retain pivot across all phases")
			check(absf(total-0.4)<0.0001,"Full attack lasts 0.4 seconds")
			for phase in {"attack_windup":2,"attack_active":4,"attack_recovery":6}:
				check(frames.get_frame_count(StringName(phase+"_"+direction)) == {"attack_windup":2,"attack_active":4,"attack_recovery":6}[phase],"Phase exposes its own variable frame count")
	for item in manifest.frames:
		check(item.damage_phase == (item.index >= 2 and item.index <= 5),"Damage phase is explicit for future integration")
		var hand := Vector2(item.hand_px[0],item.hand_px[1])
		var tip := Vector2(item.tip_px[0],item.tip_px[1])
		check(absf(hand.distance_to(tip)-12) < 1.0,"Short blade length remains consistent")
	var review = load("res://scenes/review/dagger_attack_review.tscn").instantiate()
	root.add_child(review)
	review.set_process(false)
	for index in [0,2,5,6,11]:
		review.display_frame(index)
		check(review.sprites[0].frame == index,"Review can inspect preparation, hit and recovery frames")
	review.queue_free()
	await process_frame
	if "--assets-only" not in OS.get_cmdline_user_args():
		await gameplay()
	print("ATLAS_DAGGER_ASSET_TEST checks=",checks," failures=",failures)
	quit(0 if failures == 0 else 1)

const Pose = preload("res://scripts/dagger_pose.gd")
func gameplay() -> void:
	var arena = load("res://scenes/combat_arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var player = arena.player
	player.set_physics_process(false)
	var visual = player.visual
	visual.stable_pose = false
	var a = load("res://scripts/test_monster.gd").new()
	var b = load("res://scripts/test_monster.gd").new()
	for target in [a,b]:
		arena.get_node("World").add_child(target)
		target.set_physics_process(false)
		target.hurt_radius = 1.0
	for direction in [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP,Vector2(1,1).normalized(),Vector2(-1,1).normalized(),Vector2(-1,-1).normalized(),Vector2(1,-1).normalized()]:
		player.state = &"ready"
		player.feedback_wait = 0.0
		check(player.try_attack(direction), "Cardinal/diagonal manual attack starts")
		check(not player.try_attack(-direction), "Repeated input cannot redirect locked swing")
		for phase in [&"attack_windup",&"attack_active",&"attack_recovery"]:
			var count: int = {&"attack_windup":2,&"attack_active":4,&"attack_recovery":6}[phase]
			for frame in count:
				var progress := (frame + 0.5) / count
				var pose := Pose.sample(phase,direction,progress)
				visual.set_action(phase,direction,progress)
				check(visual.sprite.frame == frame, "Every authored phase frame is reachable")
				check(visual.sprite.offset == Vector2(-40,-62) and visual.rotation == 0, "Attack pivot fixed; body never rotates for aim")
				check(visual.weapon.position.is_equal_approx(pose.hand), "Weapon grip anchored at authored hand")
				var transformed_tip: Vector2 = visual.weapon.transform * (Vector2(Pose.manifest.frames[Pose.manifest.directions.find(Pose.facing(direction))*12+pose.index].tip_px[0],Pose.manifest.frames[Pose.manifest.directions.find(Pose.facing(direction))*12+pose.index].tip_px[1]) + visual.weapon.offset)
				check(transformed_tip.is_equal_approx(pose.tip), "Rendered blade endpoint agrees with contact geometry")
				player.state = {&"attack_windup":&"windup",&"attack_active":&"attack",&"attack_recovery":&"recovery"}[phase]
				player.remaining = (1-progress)*{&"attack_windup":player.attack_windup,&"attack_active":player.attack_duration,&"attack_recovery":player.attack_recovery}[phase]
				player.struck.clear()
				for target in [a,b]:
					target.health = 50
					target.position = player.position + pose.tip - target.COMBAT_OFFSET
				player.strike_targets()
				check(a.health == (25 if phase == &"attack_active" else 50) and b.health == a.health, "Visible blade hits multiple targets only during active phase")
				player.strike_targets()
				check(a.health >= 25 and b.health == a.health, "Each target receives at most one damage per swing")
				# Same angular sector, beyond this direction's visible blade.
				player.struck.clear()
				a.position = player.position + pose.tip + direction*16 - a.COMBAT_OFFSET
				b.position = a.position
				a.health = 50
				b.health = 50
				player.strike_targets()
				check(a.health == 50, "No damage beyond visible blade")
		visual.set_action(&"",direction)
		visual.set_motion(direction*player.move_speed)
		check(visual.sprite.offset == Vector2(-20,-46) and visual.sprite.sprite_frames == visual.MOTION_FRAMES and not visual.trail.visible, "Locomotion resource and pivot restored")
		for frame in 6:
			visual.sprite.set_frame_and_progress(frame,0)
			check(visual.weapon.visible, "One held blade follows locomotion frames")
	# Hidden portions of a rear-layer blade cannot produce invisible damage.
	for progress in [0.125,0.375,0.625,0.875]:
		var rear := Pose.sample(&"attack_active",Vector2.UP,progress)
		var exposed := Pose.visible_blade(rear)
		for i in 11:
			var hidden: Vector2 = Vector2(rear.base).lerp(rear.tip,i/10.0)
			var separation := INF
			for point in exposed:
				separation = minf(separation,hidden.distance_to(point))
			if separation > 2.5:
				player.state = &"attack"
				player.locked_direction = Vector2.UP
				player.remaining = (1-progress)*player.attack_duration
				player.struck.clear()
				a.health = 50
				a.position = player.position + hidden - a.COMBAT_OFFSET
				b.position = a.position + Vector2(100,100)
				player.strike_targets()
				check(a.health == 50,"Body-occluded blade pixels cannot hurt targets")
	# Test wall through actual physics query at the visible contact.
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	wall.position = player.position + Vector2(12,-8)
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(4,80)
	shape.shape = rectangle
	wall.add_child(shape)
	arena.get_node("World").add_child(wall)
	await physics_frame
	await process_frame
	player.state = &"attack"
	player.locked_direction = Vector2.RIGHT
	player.remaining = player.attack_duration*0.375
	player.struck.clear()
	var pose := Pose.sample(&"attack_active",Vector2.RIGHT,0.625)
	a.health = 50
	a.position = player.position + pose.tip - a.COMBAT_OFFSET
	player.strike_targets()
	check(a.health == 50, "Solid obstacle blocks visible blade contact")
	wall.queue_free()
	player.feedback_wait = 0.18
	player.update_visual()
	check(visual.action_state == &"hurt" and visual.sprite.offset == Vector2(-20,-46) and not visual.trail.visible, "Hurt replaces attack and restores old pivot")
	player.strike_targets()
	check(a.health == 50,"No invisible attack while hurt pose replaces blade")
	player.dead = true
	player.state = &"dead"
	player.update_visual()
	check(visual.action_state == &"dead" and not visual.weapon.visible and not visual.trail.visible,"Death hides blade and trail")
	player.return_after_death(Vector2(120,180))
	check(visual.sprite.sprite_frames == visual.MOTION_FRAMES and visual.weapon.visible and visual.sprite.offset == Vector2(-20,-46),"Return restores living locomotion and one dagger")
	for state in [&"parry",&"dodge"]:
		visual.set_action(state,Vector2.LEFT,0.5)
		check(visual.weapon.visible and not visual.trail.visible and visual.sprite.offset == Vector2(-20,-46),"Parry/dodge use held blade and original pivot")
	player.state = &"ready"
	player.try_attack(Vector2.UP)
	player.advance_action(player.attack_windup)
	check(player.state == &"attack" and is_equal_approx(player.remaining,player.attack_duration),"Exported windup enters active timing")
	player.advance_action(player.attack_duration)
	check(player.state == &"recovery" and is_equal_approx(player.remaining,player.attack_recovery),"Exported active enters recovery timing")
	player.advance_action(player.attack_recovery)
	check(player.state == &"ready","Recovery ends without attack chaining")
	# Empty swing and real diagonal movement remain possible during windup.
	a.position = player.position + Vector2(200,200)
	b.position = a.position
	player.feedback_wait = 0.0
	player.try_attack(Vector2.RIGHT)
	player.state = &"attack"
	player.remaining = player.attack_duration*0.5
	player.strike_targets()
	check(player.struck.is_empty(),"Swing in empty space produces no contacts")
	player.state = &"ready"
	player.try_attack(Vector2.RIGHT)
	var before: Vector2 = player.position
	Input.action_press("move_right")
	Input.action_press("move_down")
	player.set_physics_process(true)
	for i in 3:
		await physics_frame
		await process_frame
	Input.action_release("move_right")
	Input.action_release("move_down")
	player.set_physics_process(false)
	check(player.position.x > before.x and player.position.y > before.y,"Diagonal movement is not frozen during attack")
	check(player.get_real_velocity().length() <= player.move_speed + 0.1,"Attack keeps normalized diagonal speed")
	check(player.locked_direction == Vector2.RIGHT,"Movement and mouse aim cannot redirect committed attack")
	player.state = &"ready"
	player.attack_windup = 0.16
	player.attack_duration = 0.24
	player.attack_recovery = 0.4
	player.try_attack(Vector2.LEFT)
	player.advance_action(0.08)
	check(player.state == &"windup" and is_equal_approx(player.action_progress(),0.5),"Timing scales with exported windup")
	player.advance_action(0.08)
	check(player.state == &"attack" and is_equal_approx(player.remaining,0.24),"Exported active duration is respected")
	arena.queue_free()
	await process_frame
