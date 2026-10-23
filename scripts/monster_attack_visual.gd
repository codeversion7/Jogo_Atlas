extends Node2D
## Animação de revisão. Sem dano, IA, teleporte, colisores ou integração ao combate.
signal finished
const ShaderSource = preload("res://assets/monstros/ataques_v1/attack_cutout.gdshader")
const IDS := ["b1_fenda","b2_carcaca","b3_esporo","b4_escavador"]
@export_enum("Fenda","Carcaça","Esporo","Escavador") var monster_kind := 0
@export var automatic := true
var profile: Dictionary
var body: MeshInstance2D
var projectile: Sprite2D
var fx: Node2D
var phase: StringName = &"windup"
var phase_progress := 0.0
var elapsed := 0.0
var playing := false
var target_point := Vector2(0,30)
var launch_point := Vector2(0,-10)
var source_pose := 0
var finished_emitted := false
var mesh_cache: Dictionary = {}

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/monstros/ataques_v1/profiles.json"))
	profile = catalog.attacks[clampi(monster_kind,0,3)]
	body = MeshInstance2D.new()
	body.name = "Body"
	body.texture = load("res://"+profile.body_source)
	var material := ShaderMaterial.new()
	material.shader = ShaderSource
	body.material = material
	add_child(body)
	fx = Node2D.new()
	fx.name = "AttackEffects"
	fx.draw.connect(draw_effects)
	add_child(fx)
	projectile = Sprite2D.new()
	projectile.name = "SporeProjectileVisual"
	var orb := AtlasTexture.new()
	orb.atlas = load("res://referencias/monstros/ataques_v1/b3_esporo_ataque_estudo.png")
	orb.region = Rect2(946,511,88,88)
	projectile.texture = orb
	projectile.scale = Vector2.ONE*0.085
	var orb_material := ShaderMaterial.new()
	orb_material.shader = ShaderSource
	projectile.material = orb_material
	fx.add_child(projectile)
	sample(0)

func duration() -> float:
	var value := 0.0
	for item in profile.phases:
		value += float(item.duration)
	return value

func play(target: Vector2 = Vector2(0,30)) -> void:
	target_point = target # Capturado uma vez. Aviso do Escavador não persegue o alvo.
	elapsed = 0
	playing = true
	finished_emitted = false
	sample(0)

func advance(delta: float) -> void:
	if not playing:
		return
	elapsed = minf(duration(),elapsed+maxf(0,delta))
	sample(elapsed)
	if elapsed >= duration():
		playing = false
		if not finished_emitted:
			finished_emitted = true
			finished.emit()

func _process(delta: float) -> void:
	if automatic:
		advance(delta)

func sample(time: float) -> void:
	var cursor := 0.0
	for item in profile.phases:
		phase = StringName(item.name)
		phase_progress = clampf((time-cursor)/float(item.duration),0,1)
		if time < cursor+float(item.duration):
			break
		cursor += float(item.duration)
	source_pose = 0
	match monster_kind:
		0: source_pose = (2 if phase_progress < 0.12 else 0) if phase == &"windup" else 1 if phase == &"active" else 2
		1: source_pose = (0 if phase_progress < 0.35 else 1) if phase == &"windup" else 2
		2: source_pose = 1 if phase == &"launch" else 0
	var frame := mini(11,int(phase_progress*12))
	var key := "%d/%s/%d" % [source_pose,phase,frame]
	if not mesh_cache.has(key):
		mesh_cache[key] = build_mesh(source_pose,phase,(frame+0.5)/12.0)
	body.mesh = mesh_cache[key]
	body.position = Vector2.ZERO
	body.material.set_shader_parameter("clip_floor",1000.0)
	if monster_kind == 3:
		var emerge := 0.0 if phase == &"warning" else phase_progress if phase == &"breakthrough" else 1.0
		body.position = target_point+Vector2(0,(1-emerge)*36)
		body.material.set_shader_parameter("clip_floor",-body.position.y+target_point.y)
	projectile.visible = monster_kind == 2 and phase in [&"launch",&"flight"]
	projectile.position = launch_point
	if phase == &"launch":
		projectile.position += Vector2(0,4)*phase_progress
	elif phase == &"flight":
		projectile.position = (launch_point+Vector2(0,4)).lerp(target_point,phase_progress)
	fx.queue_redraw()

func build_mesh(pose: int, state: StringName, progress: float) -> ArrayMesh:
	var data: Dictionary = profile.poses[pose]
	var region := Rect2(data.region[0],data.region[1],data.region[2],data.region[3])
	var anchor := Vector2(data.anchor[0],data.anchor[1])
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var grid := 20
	for y in grid+1:
		for x in grid+1:
			var uv := Vector2(float(x)/grid,float(y)/grid)
			var point := (uv*region.size-anchor)*float(data.source_scale)
			var upper := 1.0-smoothstep(0.68,0.98,uv.y)
			var arm := smoothstep(0.15,0.35,absf(uv.x-0.5))*upper
			if monster_kind == 0:
				var side := -1.0 if uv.x < 0.5 else 1.0
				var swing := sin(progress*PI)
				point.x += side*swing*arm*(2.0 if state == &"windup" else -3.0 if state == &"active" else 1.0)
				point.y += upper*(progress*1.5 if state == &"windup" else sin(progress*PI)*1.5)
			elif monster_kind == 1:
				point.y -= arm*sin(progress*PI)*3 if state == &"windup" else 0.0
				if state == &"active":
					point.y *= 1.0-0.14*sin(progress*PI)
			elif monster_kind == 2:
				var neck := (1.0-smoothstep(0.10,0.30,absf(uv.x-0.5)))*smoothstep(0.55,0.90,uv.y)
				point.y += neck*(3*sin(progress*PI) if state == &"launch" else -1.5*sin(progress*PI) if state == &"windup" else 0.0)
			vertices.append(Vector3(point.x,point.y,0))
			uvs.append((region.position+Vector2.ONE*0.5+uv*(region.size-Vector2.ONE))/body.texture.get_size())
	for y in grid:
		for x in grid:
			var a := y*(grid+1)+x
			indices.append_array(PackedInt32Array([a,a+1,a+grid+1,a+1,a+grid+2,a+grid+1]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return mesh

func draw_effects() -> void:
	if monster_kind == 0 and phase == &"active":
		var p := phase_progress
		for side in [-1,1]:
			var angle: float = lerpf(-2.7,-0.4,p) if side == 1 else lerpf(-0.4,-2.7,p)
			fx.draw_arc(Vector2(0,7),23,angle,angle+0.65,9,Color(1,0.70,0.28,1-p*0.4),1.5)
	elif monster_kind == 1 and phase in [&"active",&"recovery"]:
		var p := phase_progress if phase == &"active" else 1+phase_progress*2
		soil(Vector2(0,3),p/3.0,18)
	elif monster_kind == 2 and phase == &"impact":
		var p := phase_progress
		for i in 10:
			var offset := Vector2.from_angle(i*TAU/10)*(3+p*14)
			fx.draw_rect(Rect2(target_point+offset-Vector2.ONE,Vector2.ONE*(3-p*2)),Color(0.7,1,0.12,1-p))
	elif monster_kind == 3:
		var at := target_point
		if phase == &"warning":
			for i in 8:
				fx.draw_arc(at,14,i*TAU/8.0,i*TAU/8.0+0.40,3,Color(0.86,0.53,0.27),1.5)
			fx.draw_rect(Rect2(at-Vector2(5,2),Vector2(10,3)),Color("755036"))
		elif phase in [&"breakthrough",&"impact",&"recovery"]:
			var p := phase_progress*0.4 if phase == &"breakthrough" else 0.4+phase_progress*0.3 if phase == &"impact" else 0.7+phase_progress*0.3
			soil(at,p,21)

func soil(at: Vector2, progress: float, radius: float) -> void:
	for i in 12:
		var direction := Vector2.from_angle(i*TAU/12)
		var offset := direction*(5+progress*radius)
		offset.y -= sin(progress*PI)*(3+i%3)
		fx.draw_rect(Rect2(at+offset-Vector2.ONE,Vector2(3+i%2,2+i%3)),Color(0.48,0.30,0.18,1-progress))
