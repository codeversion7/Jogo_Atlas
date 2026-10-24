extends Node2D
## Projétil físico varrido contra mundo/jogador. Explode uma vez, sem dano por frame.
var caster: CharacterBody2D
var target: CharacterBody2D
var settings: Resource
var direction := Vector2.RIGHT
var damage := 20
var age := 0.0
var exploding := false
var attempted := false
var cancelled := false
var sprite: Sprite2D

func _ready() -> void:
	add_to_group("atlas_monster_projectiles")
	sprite = Sprite2D.new()
	var texture := AtlasTexture.new()
	texture.atlas = load("res://assets/monstros/ataques_v1/spore_orb_source.png")
	texture.region = Rect2(946,511,88,88)
	sprite.texture = texture
	sprite.scale = Vector2.ONE * 0.085
	var material_instance := ShaderMaterial.new()
	material_instance.shader = load("res://assets/monstros/ataques_v1/attack_cutout.gdshader")
	sprite.material = material_instance
	add_child(sprite)
	queue_redraw()

func combat_center() -> Vector2: return global_position
func stagger(duration_override: float = -1.0) -> void:
	cancelled = true
	if is_instance_valid(caster): caster.stagger(duration_override)
	queue_free()

func _physics_process(delta: float) -> void:
	if cancelled or not is_instance_valid(caster) or caster.dead or not is_instance_valid(target) or target.dead:
		queue_free()
		return
	age += delta
	if exploding:
		if age >= settings.explosion_duration: queue_free()
		queue_redraw()
		return
	var start := global_position
	var destination: Vector2 = start + direction * settings.orb_speed * delta
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = settings.orb_radius
	query.shape = circle
	query.transform = Transform2D(0,start)
	query.motion = destination-start
	query.collision_mask = 1
	var fraction := get_world_2d().direct_space_state.cast_motion(query)
	var wall_hit: bool = fraction[0] < 1.0
	if wall_hit: destination = start + query.motion * fraction[0]
	var hit := false
	var impact := destination
	var distance := INF
	for recipient in recipients():
		if recipient.dead: continue
		var closest := Geometry2D.get_closest_point_to_segment(recipient.combat_center(),start,destination)
		if closest.distance_to(recipient.combat_center()) <= settings.orb_radius+recipient.hurt_radius and start.distance_to(closest)<distance:
			distance = start.distance_to(closest)
			impact = closest
			hit = true
	global_position = impact
	if hit or wall_hit or age >= settings.orb_lifetime:
		explode()
	queue_redraw()

func explode() -> void:
	if exploding: return
	exploding = true
	age = 0.0
	sprite.visible = false
	for recipient in recipients():
		if cancelled: break
		if not recipient.dead and global_position.distance_to(recipient.combat_center())<=settings.explosion_radius+recipient.hurt_radius:
			attempted = true
			recipient.receive_attack(damage,self)
	queue_redraw()

func recipients() -> Array:
	var result: Array = [target]
	for companion in get_tree().get_nodes_in_group("atlas_companion"):
		if companion.player==target: result.append(companion)
	return result
func _draw() -> void:
	if exploding:
		draw_circle(Vector2.ZERO,settings.explosion_radius,Color(0.4,0.9,0.15,0.25))
		draw_arc(Vector2.ZERO,settings.explosion_radius,0,TAU,32,Color(0.65,1,0.3),1)
	else:
		draw_arc(Vector2.ZERO,settings.orb_radius,0,TAU,16,Color(0.6,1,0.3),1)
