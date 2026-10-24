extends Node2D
## Visual apenas: não concede escudo, bloqueio ou dano. Raiz alinhada aos pés.
signal animation_finished
const BASE := "res://assets/npcs/companheiro/pixel_v2/"
const DIRECTIONS := ["down","left","right","up"]
const TIMES := {"idle":1.2,"walk":0.56,"run":0.36,"hurt":0.24,"shield":1.12}
const BRACELET := [Vector2(33,39),Vector2(28,40),Vector2(21,40),Vector2(16,39)]
@export var art_scale := 0.7
@export var automatic := true
var guard_held := false
var state := "idle"
var direction := 0
var elapsed := 0.0
var body: MeshInstance2D
var shield: Node2D
var cache: Dictionary = {}
var opening := 0.0
var arm_lift := 0.0
var phase := "idle"
var idle_texture: Texture2D
var walk_texture: Texture2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	idle_texture = load(BASE+"companheiro_idle_48x64.png")
	walk_texture = load(BASE+"companheiro_walk_48x64.png")
	body = MeshInstance2D.new()
	body.name = "Body"
	body.z_index = 1
	add_child(body)
	shield = Node2D.new()
	shield.name = "ShieldVisualOnly"
	shield.draw.connect(draw_shield)
	add_child(shield)
	sample(0)

func play(animation: String, facing: int = -1) -> void:
	if not TIMES.has(animation):
		return
	if facing >= 0:
		direction = clampi(facing,0,3)
	state = animation
	elapsed = 0
	sample(0)

func set_motion(motion: Vector2) -> void:
	# Não interromper os clipes de ação até seu término.
	if state in ["shield","hurt"]:
		return
	if motion.length() > 0.1:
		direction = (2 if motion.x > 0 else 1) if absf(motion.x)>absf(motion.y) else (0 if motion.y>0 else 3)
	var next := "idle" if motion.length()<0.1 else "walk"
	if next != state:
		play(next)

func set_guard(value: bool, facing: int = -1) -> void:
	if value:
		if facing>=0: direction = clampi(facing,0,3)
		if not guard_held or state not in ["shield","hurt"]:
			guard_held = true
			play("shield",facing)
	elif guard_held:
		guard_held = false
		if state=="shield": elapsed = 0.88; sample(elapsed)
func advance(delta: float) -> void:
	elapsed += maxf(0,delta)
	if guard_held and state=="shield": elapsed = minf(elapsed,0.6)
	if state in ["shield","hurt"] and elapsed >= float(TIMES[state]):
		play("idle")
		animation_finished.emit()
	else:
		sample(elapsed)

func _process(delta: float) -> void:
	if automatic:
		advance(delta)

func sample(time: float) -> void:
	var duration := float(TIMES[state])
	var p := clampf(time/duration,0,1) if state in ["shield","hurt"] else fposmod(time/duration,1)
	phase = state
	opening = 0
	arm_lift = 0
	if state == "shield":
		if time < 0.16:
			phase = "prepare"
			arm_lift = smoothstep(0,0.16,time)
		elif time < 0.40:
			phase = "deploy"
			arm_lift = 1
			opening = smoothstep(0.16,0.40,time)
		elif time < 0.88:
			phase = "hold"
			arm_lift = 1
			opening = 1
		else:
			phase = "retract"
			opening = 1-smoothstep(0.88,1.12,time)
			arm_lift = opening
	if guard_held and state=="hurt": opening = 1; arm_lift = 1
	var moving := state in ["walk","run"]
	var frame := mini(3,int(p*4)) if moving else 0
	var region := Rect2(frame*48,direction*64,48,64) if moving else Rect2(direction*48,0,48,64)
	body.texture = walk_texture if moving else idle_texture
	var step := mini(15,int(p*16))
	var key := "%s/%d/%d/%s" % [state,direction,step,str(art_scale)]
	if not cache.has(key):
		cache[key] = make_mesh(region,p)
	body.mesh = cache[key]
	body.position = Vector2.ZERO
	body.modulate = Color.WHITE
	if moving:
		body.position.y = -absf(sin(p*TAU))*(1.2 if state == "run" else 0.45)
	elif state == "hurt":
		body.position = Vector2(-2.5*sin(p*PI),0)
		body.modulate = Color(1,0.65,0.55) if p<0.5 else Color.WHITE
	shield.z_index = 0 if direction == 3 else 2
	shield.visible = opening > 0.001
	shield.queue_redraw()

func make_mesh(region: Rect2, p: float) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var grid := 16
	for y in grid+1:
		for x in grid+1:
			var uv := Vector2(float(x)/grid,float(y)/grid)
			var source := uv*Vector2(48,64)
			var point := (source-Vector2(24,60))*art_scale
			if state == "idle":
				point.y -= sin(p*TAU)*0.65*(1-smoothstep(44,56,source.y))
			if state == "shield":
				var mask := 1-smoothstep(3,10,source.distance_to(BRACELET[direction]))
				var reach := -3.0 if direction == 1 else 3.0 if direction == 2 else 0.0
				point += Vector2(reach,-7)*arm_lift*mask*art_scale
			elif state == "run":
				point.x += (1-uv.y)*(1.5 if direction==2 else -1.5 if direction==1 else 0.0)
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

func draw_shield() -> void:
	if opening <= 0:
		return
	var at: Vector2 = (BRACELET[direction]-Vector2(24,60)+Vector2(0,-7)*arm_lift)*art_scale
	var forward: Vector2 = [Vector2(0,5),Vector2(-8,0),Vector2(8,0),Vector2(0,-4)][direction]
	var center: Vector2 = at+forward*opening
	var width := (5.0 if direction in [1,2] else 11.0)*opening
	var height := 14.0*opening
	# Contorno em degraus de um pixel, adequado ao material de origem.
	for y in range(-14,15):
		if absf(y)>height:
			continue
		var extent := maxi(1,int(width*sqrt(maxf(0,1-pow(float(y)/maxf(height,0.01),2)))))
		shield.draw_rect(Rect2(center+Vector2(-extent,y),Vector2(extent*2,1)),Color(0.17,0.70,0.75,0.22*opening))
		for side in [-1,1]:
			shield.draw_rect(Rect2((center+Vector2(side*extent,y)).round(),Vector2(1,1)),Color(0.45,0.95,0.91,opening))
	shield.draw_rect(Rect2(at.round()-Vector2.ONE,Vector2(3,3)),Color(1,0.69,0.29,opening))
