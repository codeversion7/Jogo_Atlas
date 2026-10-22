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
var action_state: StringName = &""
var last_velocity := Vector2.ZERO

func _ready() -> void:
	sprite.sprite_frames = MOTION_FRAMES
	sprite.play(&"idle_down")

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
	if not ACTION_FRAMES.has_animation(clip):
		return
	action_state = pose
	sprite.sprite_frames = ACTION_FRAMES
	sprite.animation = clip
	sprite.pause()
	sprite.set_frame_and_progress(mini(int(clampf(progress, 0.0, 1.0) * 3.0), 2), 0.0)
	sprite.speed_scale = 1.0
