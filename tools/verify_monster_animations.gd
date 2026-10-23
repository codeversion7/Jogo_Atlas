extends SceneTree
const Visual = preload("res://scripts/monster_visual.gd")
const Catalog = preload("res://scripts/monster_animation_catalog.gd")
var checks := 0
var failures := 0
func _initialize() -> void:
	run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func run() -> void:
	for kind in 4:
		var visual := Visual.new()
		visual.monster_kind = kind
		visual.automatic = false
		root.add_child(visual)
		check(visual.body.texture != null,"Original source loads")
		for direction in 4:
			var region: Rect2 = Catalog.REGIONS[kind][direction]
			check(Rect2(Vector2.ZERO,visual.body.texture.get_size()).encloses(region),"Measured source crop is in bounds")
			for mode in Visual.COUNTS:
				for frame in int(Visual.COUNTS[mode]):
					visual.sample(mode,Catalog.DIRECTIONS[direction],frame)
					check(visual.body.mesh.get_surface_count() == 1,"Every pose has a mesh")
					check(visual.body.mesh.get_aabb().size.x < 80 and visual.body.mesh.get_aabb().size.y < 55,"Pose remains within game scale")
				var a := Visual.deform(Vector2(0.35,0.90),kind,direction,mode,0.0)
				var b := Visual.deform(Vector2(0.35,0.90),kind,direction,mode,1.0)
				check(a.distance_to(b) < 0.001,"Cycle closes or hurt returns to neutral")
			var idle_a := Visual.deform(Vector2(0.2,0.8),kind,direction,&"idle",0.25)
			var idle_b := Visual.deform(Vector2(0.8,0.2),kind,direction,&"idle",0.25)
			var zero_a := Visual.deform(Vector2(0.2,0.8),kind,direction,&"idle",0.0)
			var zero_b := Visual.deform(Vector2(0.8,0.2),kind,direction,&"idle",0.0)
			check((idle_a-zero_a).is_equal_approx(idle_b-zero_b),"Idle only translates vertically")
			var zone: Vector4 = Catalog.legs(kind,direction)[0]
			var foot := Vector2(zone.x,0.98)
			var walk := Visual.deform(foot,kind,direction,&"walk",0.25)
			var run_pose := Visual.deform(foot,kind,direction,&"run",0.25)
			check(walk.distance_to(run_pose) > 0.3,"Running has a distinct stride, not only faster playback")
			# A passada precisa ser legível na escala nativa, não só existir na malha.
			var first := Visual.deform(foot,kind,direction,&"walk",0.25)
			var opposite := Visual.deform(foot,kind,direction,&"walk",0.75)
			check(first.distance_to(opposite) >= 6.0,"Visible foot travels at least six native pixels per stride")
			var top := Vector2(0.5,0.1)
			var idle_peak := Visual.deform(top,kind,direction,&"idle",0.25)
			var idle_low := Visual.deform(top,kind,direction,&"idle",0.75)
			check(idle_peak.distance_to(idle_low) >= 3.0,"Idle vertical movement remains visible at native scale")
		visual.set_motion(Vector2.LEFT*40)
		visual.advance(0.1)
		check(visual.animation == &"walk" and visual.facing == &"left","Motion selects directional walk")
		visual.set_motion(Vector2.RIGHT*70)
		visual.advance(0.1)
		check(visual.animation == &"run" and visual.facing == &"right","Speed selects run")
		visual.play_hurt(Vector2.LEFT)
		visual.sample(&"hurt",visual.facing,2)
		check(visual.body.position.length() >= 4.0,"Hurt recoil is visible without moving physics")
		visual.set_motion(Vector2.ZERO)
		check(visual.animation == &"hurt","Hurt takes precedence over motion")
		visual.advance(0.10)
		visual.play_hurt(Vector2.LEFT)
		visual.advance(0.05)
		check(visual.frame == 1 and visual.hurt_remaining > 0.19,"Repeated damage restarts the visible recoil")
		visual.advance(0.3)
		check(visual.animation == &"idle","Hurt returns to current movement state")
		check(visual.position == Vector2.ZERO,"Visual never moves the character root")
		visual.queue_free()
		await process_frame
		var monster = load("res://scripts/test_monster.gd").new()
		monster.monster_kind = kind
		root.add_child(monster)
		check(monster.visual.monster_kind == kind,"Enemy uses its configured art")
		monster.take_damage(1)
		check(monster.visual.animation == &"hurt","Gameplay damage starts visual recoil")
		check(monster.health == monster.max_health-1,"Animation preserves damage amount")
		monster.queue_free()
		await process_frame
	var lab = load("res://scenes/review/monster_animation_lab.tscn").instantiate()
	root.add_child(lab)
	check(lab.actors.size() == 16,"Review shows all four creatures and states")
	check(root.get_camera_2d() == null,"Reference character cannot move the review camera")
	lab.queue_free()
	await process_frame
	print("ATLAS_MONSTER_ANIMATION_TEST checks=",checks," failures=",failures)
	quit(0 if failures == 0 else 1)
