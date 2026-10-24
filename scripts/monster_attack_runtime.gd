extends Node2D
## Corpo preparado, sem FX embutidos duplicados. Geometria desenhada e dano compartilham dados.
const Orb = preload("res://scripts/monster_orb.gd")
const Geometry = preload("res://scripts/combat_geometry.gd")
const BASE := "res://assets/monstros/ataques_v1/"
var actor: CharacterBody2D
var settings: Resource
var phases: Array
var phase_index := -1
var phase: StringName = &""
var phase_time := 0.0
var duration := 0.0
var playing := false
var locked_point := Vector2.ZERO
var locked_direction := Vector2.RIGHT
var attempted := false
var hit_ids: Dictionary = {}
var sprite: AnimatedSprite2D
var orb: Node2D

func _ready() -> void:
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASE+"profiles.json"))
	var profile: Dictionary = catalog.attacks[actor.monster_kind]
	phases = profile.phases
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = load(BASE+profile.id+"_body.tres")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	visible = false

func begin() -> void:
	locked_point = actor.target.global_position # Marca no chão, capturada uma única vez.
	locked_direction = actor.combat_center().direction_to(actor.target.combat_center())
	if locked_direction.is_zero_approx(): locked_direction = Vector2.RIGHT
	actor.attack_direction = locked_direction
	phase_index = -1
	attempted = false
	hit_ids.clear()
	playing = true
	visible = true
	actor.visual.visible = false
	next_phase()

func cancel() -> void:
	playing = false
	visible = false
	if is_instance_valid(orb):
		orb.cancelled = true
		orb.queue_free()
	if is_instance_valid(actor.visual): actor.visual.visible = not actor.dead
	queue_redraw()

func next_phase() -> void:
	phase_index += 1
	if phase_index >= phases.size():
		playing = false
		visible = false
		actor.visual.visible = true
		actor.state = &"chase"
		return
	phase = StringName(phases[phase_index].name)
	duration = maxf(0.02,float(phases[phase_index].duration)*maxf(0.1,settings.timing_scale))
	phase_time = 0.0
	actor.remaining = duration
	actor.state = &"windup" if phase in [&"windup",&"warning"] else &"recovery" if phase == &"recovery" else &"attack"
	if actor.monster_kind == 3 and phase == &"breakthrough":
		# Corpo e colisão emergem juntos na marca. Nunca atravessa/entra em sólidos.
		if not safe_emergence():
			cancel()
			actor.state = &"recovery"
			actor.remaining = 0.65 * maxf(0.1,settings.timing_scale)
			return
		actor.global_position = locked_point
	if actor.monster_kind == 2 and phase == &"launch":
		orb = Orb.new()
		orb.caster = actor
		orb.target = actor.target
		orb.settings = settings
		orb.direction = locked_direction
		orb.damage = actor.damage
		actor.get_parent().add_child(orb)
		orb.global_position = actor.combat_center()
	var sound := ""
	if actor.monster_kind == 0 and phase == &"active": sound = "cross"
	elif actor.monster_kind == 2 and phase == &"launch": sound = "orb"
	elif actor.monster_kind == 3:
		if phase == &"warning": sound = "burrow_warning"
		elif phase == &"impact": sound = "burrow_impact"
	if not sound.is_empty(): preload("res://scripts/session_audio.gd").event(actor,sound)
	sample_body()

func safe_emergence() -> bool:
	if not Geometry.clear_line(actor,locked_point+actor.COMBAT_OFFSET): return false
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = actor.feet_radius
	query.shape = circle
	query.transform = Transform2D(0,locked_point+Vector2(0,-3))
	query.collision_mask = 1 | 4
	query.exclude = [actor.get_rid()]
	return actor.get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()

func advance(delta: float) -> void:
	if not playing: return
	phase_time += delta
	if phase_time >= duration:
		next_phase()
		if not playing: return
	actor.remaining = maxf(0,duration-phase_time)
	sample_body()
	if (actor.monster_kind in [0,1] and phase == &"active") or (actor.monster_kind == 3 and phase == &"impact"):
		var recipients: Array = [actor.target]
		for companion in get_tree().get_nodes_in_group("atlas_companion"):
			if companion.player==actor.target: recipients.append(companion)
		for recipient in recipients:
			if recipient.dead or hit_ids.has(recipient.get_instance_id()): continue
			if touches(recipient.combat_center(),recipient.hurt_radius) and Geometry.clear_line(actor,recipient.combat_center()):
				hit_ids[recipient.get_instance_id()] = true
				attempted = true
				actor.hit_target = true
				recipient.receive_attack(actor.damage,actor)
				if not playing: break # Parry interrompe o golpe inteiro.
	queue_redraw()

func sample_body() -> void:
	var clip := StringName(String(phase)+"_down")
	sprite.animation = clip
	var count := sprite.sprite_frames.get_frame_count(clip)
	sprite.frame = mini(count-1,int(clampf(phase_time/duration,0,1)*count))

func effect_center() -> Vector2:
	if actor.monster_kind == 3: return to_local(locked_point+actor.COMBAT_OFFSET)
	var forward: float = settings.cross_forward if actor.monster_kind == 0 else settings.slam_forward
	return actor.COMBAT_OFFSET+locked_direction*forward

func cross_segments() -> PackedVector2Array:
	var center := effect_center()
	var along: Vector2 = locked_direction*settings.cross_length
	var across := along.orthogonal()
	return PackedVector2Array([center-along-across,center+along+across,center-along+across,center+along-across])

func touches(point: Vector2, radius: float) -> bool:
	var local := to_local(point)
	if actor.monster_kind == 0:
		var lines := cross_segments()
		for i in [0,2]:
			if Geometry2D.get_closest_point_to_segment(local,lines[i],lines[i+1]).distance_to(local) <= radius+settings.cross_half_width: return true
		return false
	var reach: float = settings.burrow_radius if actor.monster_kind == 3 else settings.slam_radius
	return local.distance_to(effect_center()) <= radius+reach

func _draw() -> void:
	if not playing: return
	var live: bool = phase == &"active" or (actor.monster_kind == 3 and phase == &"impact")
	var color := Color(1,0.85,0.45,0.95) if live else Color(1,0.55,0.2,0.5)
	if actor.monster_kind == 0:
		var lines := cross_segments()
		for i in [0,2]: draw_line(lines[i],lines[i+1],color,settings.cross_half_width*2 if live else 1.0)
	elif actor.monster_kind in [1,3]:
		var radius: float = settings.slam_radius if actor.monster_kind == 1 else settings.burrow_radius
		if live: draw_circle(effect_center(),radius,Color(color,0.3))
		draw_arc(effect_center(),radius,0,TAU,32,color,1)
		if actor.monster_kind == 3:
			draw_line(effect_center()-Vector2(4,0),effect_center()+Vector2(4,0),color,1)
			draw_line(effect_center()-Vector2(0,4),effect_center()+Vector2(0,4),color,1)
	elif phase == &"windup":
		draw_line(actor.COMBAT_OFFSET,actor.COMBAT_OFFSET+locked_direction*28,Color(0.5,1,0.25,0.6),1)
