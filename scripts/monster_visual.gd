extends Node2D
## Animação de malha 2D sobre a arte original. Não move corpo/colisores.
## Ciclos articulados provisórios; não são novos desenhos quadro a quadro.
const Catalog = preload("res://scripts/monster_animation_catalog.gd")
const CutoutShader = preload("res://assets/monstros/monster_cutout.gdshader")
const GRID := 24
const COUNTS := {&"idle":8, &"walk":12, &"run":12, &"hurt":5}
const FPS := {&"idle":6.0, &"walk":12.0, &"run":18.0, &"hurt":20.0}
## Amplitudes em pixels na escala real do jogo, independentes da velocidade da IA.
const IDLE_BOB := 1.8
const WALK_STRIDE := 6.5
const RUN_STRIDE := 9.0
const WALK_LIFT := 3.0
const RUN_LIFT := 4.5
const HURT_RECOIL := 4.5
const POSE_REVISION := 2 # Não reutilizar malhas antigas após recarregar o script no editor.
static var mesh_cache: Dictionary = {}
@export_enum("Fenda", "Carcaça", "Esporo", "Escavador") var monster_kind: int = 0
@export_range(0.25, 4.0, 0.05) var visual_scale: float = 1.0
@export var reference_speed: float = 40.0
@export var run_threshold: float = 1.45
@export var automatic: bool = true
var facing: StringName = &"down"
var animation: StringName = &"idle"
var elapsed := 0.0
var frame := -1
var hurt_remaining := 0.0
var last_motion := Vector2.ZERO
var recoil_direction := Vector2.LEFT
var body: MeshInstance2D
var material_instance: ShaderMaterial
var loaded_kind := -1
var motion_rate := 1.0
var fading := 1.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body = MeshInstance2D.new()
	body.name = "ArticulatedSprite"
	add_child(body)
	material_instance = ShaderMaterial.new()
	material_instance.shader = CutoutShader
	body.material = material_instance
	load_kind()
	sample(&"idle", &"down", 0)

func load_kind() -> void:
	monster_kind = clampi(monster_kind,0,3)
	if loaded_kind == monster_kind:
		return
	body.texture = load(Catalog.source_path(monster_kind))
	loaded_kind = monster_kind
	frame = -1

func _process(delta: float) -> void:
	if automatic:
		advance(delta)

func set_motion(motion: Vector2, running: bool = false) -> void:
	last_motion = motion
	if hurt_remaining > 0:
		return
	if motion.length_squared() > 0.1:
		if absf(motion.x) > absf(motion.y) + 0.01:
			facing = &"right" if motion.x > 0 else &"left"
		else:
			facing = &"down" if motion.y > 0 else &"up"
		set_animation(&"run" if running or motion.length() > reference_speed * run_threshold else &"walk")
		motion_rate = clampf(motion.length()/maxf(reference_speed,1.0),0.45,1.5)
	else:
		set_animation(&"idle")
		motion_rate = 1.0

func set_animation(value: StringName) -> void:
	if animation != value:
		animation = value
		elapsed = 0.0
		frame = -1

func play_hurt(from_direction: Vector2 = Vector2.RIGHT) -> void:
	recoil_direction = -from_direction.normalized()
	hurt_remaining = float(COUNTS[&"hurt"]) / FPS[&"hurt"]
	set_animation(&"hurt")
	elapsed = 0.0 # Um novo impacto reinicia o recuo mesmo durante a reação anterior.
	sample(&"hurt",facing,0)

func advance(delta: float) -> void:
	if hurt_remaining > 0:
		hurt_remaining = maxf(0,hurt_remaining-delta)
		if hurt_remaining <= 0:
			set_motion(last_motion)
	elapsed += delta * (motion_rate if animation in [&"walk",&"run"] else 1.0)
	var count: int = COUNTS[animation]
	var index := int(elapsed * float(FPS[animation]))
	index = mini(index,count-1) if animation == &"hurt" else index % count
	sample(animation,facing,index)

func sample(mode: StringName, direction: StringName, index: int) -> void:
	if not COUNTS.has(mode) or direction not in Catalog.DIRECTIONS:
		return
	load_kind()
	index = clampi(index,0,int(COUNTS[mode])-1)
	var direction_index: int = Catalog.DIRECTIONS.find(direction)
	var key := "%d/%d/%s/%s/%d" % [POSE_REVISION,monster_kind,direction,mode,index]
	if not mesh_cache.has(key):
		mesh_cache[key] = make_mesh(monster_kind,direction_index,mode,index)
	body.mesh = mesh_cache[key]
	body.scale = Vector2.ONE * visual_scale
	frame = index
	animation = mode
	facing = direction
	var phase := float(index)/maxf(1.0,float(COUNTS[mode])-1)
	material_instance.set_shader_parameter("damage_flash",(1.0-phase) if mode == &"hurt" else 0.0)
	material_instance.set_shader_parameter("fade",fading)
	body.position = recoil_direction * sin(phase * PI) * HURT_RECOIL if mode == &"hurt" else Vector2.ZERO

static func deform(point: Vector2, kind: int, direction: int, mode: StringName, phase: float) -> Vector2:
	var size := Vector2(1,1) # Normalized coordinates; output is in display pixels.
	var height: float = Catalog.HEIGHTS[kind]
	var region: Rect2 = Catalog.REGIONS[kind][direction]
	size = Vector2(region.size.x/region.size.y*height,height)
	var original := Vector2((point.x-0.5)*size.x,(point.y-1.0)*size.y)
	if mode == &"idle":
		# O pedido de espera é apenas subir/descer: nenhuma perna ou escala muda.
		return original + Vector2(0,sin(phase*TAU)*IDLE_BOB)
	if mode == &"hurt":
		var recoil := sin(phase*PI)
		return Vector2(original.x*(1.0+0.07*recoil),original.y*(1.0-0.11*recoil))
	var stride := WALK_STRIDE if mode == &"walk" else RUN_STRIDE
	var lift := WALK_LIFT if mode == &"walk" else RUN_LIFT
	var offset := Vector2.ZERO
	var largest_weight := 0.0
	var total_weight := 0.0
	for zone in Catalog.legs(kind,direction):
		# Centro largo e influência completa antes da ponta: os pixels visíveis
		# da pata também participam, em vez de só a margem transparente inferior.
		var x_weight := 1.0-smoothstep(zone.y*0.35,zone.y,absf(point.x-zone.x))
		var y_weight := smoothstep(zone.z,minf(0.98,zone.z+0.17),point.y)
		var weight := x_weight * y_weight
		var cycle := phase*TAU + zone.w
		var step := sin(cycle)
		var raised := maxf(0,cos(cycle))
		if direction in [1,2]:
			offset += Vector2(step*stride,-raised*lift)*weight
		else:
			offset += Vector2(step*0.8,step*stride*0.75-raised*lift)*weight
		largest_weight = maxf(largest_weight,weight)
		total_weight += weight
	# Zonas vizinhas não somam uma deformação descontrolada na mesma articulação.
	offset /= maxf(1.0,total_weight)
	# O tronco acompanha o apoio; os membros têm movimentos independentes.
	var torso_weight := (1.0-largest_weight)*(1.0-smoothstep(0.35,0.95,point.y))
	var torso_bob := 1.3 if mode == &"walk" else 2.0
	offset.y -= absf(sin(phase*TAU))*torso_bob*(1.0-largest_weight)
	offset.x += sin(phase*TAU)*(0.7 if mode == &"walk" else 1.1)*torso_weight
	if mode == &"run":
		offset.x += (1.8 if direction == 2 else -1.8 if direction == 1 else 0.0)*(1.0-point.y)
	return original + offset

static func make_mesh(kind: int, direction: int, mode: StringName, index: int) -> ArrayMesh:
	var region: Rect2 = Catalog.REGIONS[kind][direction]
	var texture: Texture2D = load(Catalog.source_path(kind))
	var phase := float(index)/float(COUNTS[mode] if mode != &"hurt" else COUNTS[mode]-1)
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for y in GRID+1:
		for x in GRID+1:
			var uv := Vector2(float(x)/GRID,float(y)/GRID)
			var point := deform(uv,kind,direction,mode,phase)
			vertices.append(Vector3(point.x,point.y,0))
			# Meio texel evita amostrar a célula vizinha em recortes que tocam a borda.
			uvs.append((region.position+Vector2(0.5,0.5)+uv*(region.size-Vector2.ONE))/Vector2(texture.get_size()))
	for y in GRID:
		for x in GRID:
			var a := y*(GRID+1)+x
			indices.append_array(PackedInt32Array([a,a+1,a+GRID+1,a+1,a+GRID+2,a+GRID+1]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return mesh
