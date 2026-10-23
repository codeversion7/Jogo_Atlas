extends Node2D
## Authored provisional pixel animation; gameplay owns motion.
@export var reference_speed: float = 48.0
@export var stable_pose: bool = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var facing: StringName = &"down"
var motion_animation: StringName = &"idle_down"
var playback_multiplier: float = 1.0
const MOTION_FRAMES = preload("res://assets/personagem/provisorio/atlas_motion.tres")
const ACTION_FRAMES = preload("res://assets/personagem/provisorio/atlas_actions.tres")
const Dagger = preload("res://scripts/dagger_pose.gd")
var weapon_in_flight := false
var weapon: Sprite2D
var trail: Sprite2D
var action_state: StringName = &""
var last_velocity := Vector2.ZERO

func _ready() -> void:
	sprite.sprite_frames = MOTION_FRAMES
	sprite.play(&"idle_down")
	weapon = Sprite2D.new()
	weapon.name = "Dagger"
	weapon.centered = false
	add_child(weapon)
	trail = Sprite2D.new()
	trail.name = "DaggerTrail"
	trail.centered = false
	add_child(trail)
	sprite.frame_changed.connect(_held_weapon)
	_held_weapon()

func _face(direction: Vector2) -> void:
	if direction.length_squared() <= 0.01:
		return
	if absf(direction.x) > absf(direction.y) + 0.01:
		facing = &"right" if direction.x > 0.0 else &"left"
	else:
		facing = &"down" if direction.y > 0.0 else &"up"

func set_motion(actual_velocity: Vector2) -> void:
	last_velocity = actual_velocity
	if not action_state.is_empty():
		return
	sprite.offset = Vector2(-20, -46)
	var moving := actual_velocity.length_squared() > 0.01
	if moving:
		_face(actual_velocity)
	motion_animation = StringName(("walk_" if moving else "idle_") + String(facing))
	var target := StringName("idle_" + String(facing)) if stable_pose else motion_animation
	if sprite.sprite_frames != MOTION_FRAMES:
		sprite.sprite_frames = MOTION_FRAMES
	if sprite.animation != target:
		# Turning retains the same supporting leg during the stride.
		var preserve_stride := String(sprite.animation).begins_with("walk_") and moving and not stable_pose
		var phase := sprite.frame
		var fraction := sprite.frame_progress
		sprite.play(target)
		if preserve_stride:
			sprite.set_frame_and_progress(phase, fraction)
	var rate := actual_velocity.length() / maxf(reference_speed, 0.01) if moving else 1.0
	sprite.speed_scale = rate * playback_multiplier
	if stable_pose:
		sprite.pause()
		sprite.set_frame_and_progress(0, 0.0)
	elif not sprite.is_playing():
		sprite.play()
	_held_weapon()

## Empty/idle/move/walk clears the override. Combat owns action timing.
## States: attack_windup, attack_active, attack_recovery, parry, dodge, hurt, dead.
func set_action(state: StringName, direction: Vector2, progress: float = 0.0) -> void:
	if state in [&"", &"idle", &"move", &"walk"]:
		action_state = &""
		set_motion(last_velocity)
		return
	var aliases := {&"windup": &"attack_windup", &"active": &"attack_active", &"recovery": &"attack_recovery", &"attack": &"attack_active", &"damage": &"hurt", &"death": &"dead"}
	var pose: StringName = aliases.get(state, state)
	_face(direction)
	var clip := StringName(String(pose) + "_" + String(facing))
	if String(pose).begins_with("attack_"):
		action_state = pose
		var sample := Dagger.sample(pose, direction, progress)
		sprite.sprite_frames = Dagger.BODY
		sprite.offset = -Dagger.PIVOT
		sprite.animation = sample.clip
		sprite.pause()
		sprite.set_frame_and_progress(sample.frame, 0.0)
		sprite.speed_scale = 1.0
		for layer in [weapon, trail]:
			layer.visible = not weapon_in_flight
			layer.position = sample.hand
			layer.offset = -sample.hand_px
			layer.rotation = sample.rotation
		_order_weapon(sample.behind)
		weapon.texture = Dagger.DAGGER.get_frame_texture(sample.clip, sample.frame)
		trail.texture = Dagger.TRAIL.get_frame_texture(sample.clip, sample.frame)
		return
	if not ACTION_FRAMES.has_animation(clip):
		return
	action_state = pose
	sprite.offset = Vector2(-20, -46)
	sprite.sprite_frames = ACTION_FRAMES
	sprite.animation = clip
	sprite.pause()
	sprite.set_frame_and_progress(Dagger.frame_at(ACTION_FRAMES, clip, progress), 0.0)
	sprite.speed_scale = 1.0

	_held_weapon()

func _held_weapon() -> void:
	if weapon == null or String(action_state).begins_with("attack_"):
		return
	trail.visible = false
	weapon.visible = action_state != &"dead" and not weapon_in_flight
	var i := sprite.frame
	var walking := String(sprite.animation).begins_with("walk_")
	var phase: int = [-3,-1,2,3,1,-2][i % 6] if walking else 0
	var bob := 1 if walking and i % 3 == 1 else 0
	var hand := Vector2(27, 31 - int(phase / 2.0))
	if facing in [&"left", &"right"]:
		hand = Vector2(24 + floori(phase / 2.0), 31)
	elif facing == &"up":
		hand = Vector2(12, 31 + int(phase / 2.0))
	var lean := 0
	var crouch := 0
	match action_state:
		&"parry": hand = Vector2(27,24)
		&"dodge":
			hand = Vector2(30,27)
			lean = 3 + i - 1
			crouch = 5
		&"hurt":
			hand = Vector2(30,31)
			lean = -2 + i - 1
			crouch = 2
	hand += Vector2(lean, bob + crouch)
	if facing == &"left":
		hand.x = 40 - hand.x
	var rest := Dagger.sample(&"attack_recovery", Dagger.cardinal(String(facing)), 1.0)
	weapon.texture = Dagger.DAGGER.get_frame_texture(rest.clip, rest.frame)
	weapon.position = hand - Vector2(20,46)
	weapon.offset = -rest.hand_px
	weapon.rotation = 0.0
	_order_weapon(facing == &"up")

func _order_weapon(behind: bool) -> void:
	# Sibling order keeps all layers inside the actor's world Y-sort plane.
	# Global z offsets would force the body above unrelated scenery/actors.
	if behind:
		move_child(weapon,0)
		move_child(trail,1)
		move_child(sprite,2)
	else:
		move_child(sprite,0)
		move_child(weapon,1)
		move_child(trail,2)

func set_weapon_in_flight(value: bool) -> void:
	weapon_in_flight = value
	if value:
		weapon.visible = false
		trail.visible = false
	else:
		_held_weapon()
