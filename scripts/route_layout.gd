extends Resource
class_name AtlasRouteLayout
## Stable IDs and editable geometry shared by gameplay, discovery, camera and navigation.
@export var world_size := Vector2(2240,960)
@export var start := Vector2(180,220)
@export var campfires: PackedVector2Array = [Vector2(280,300),Vector2(280,740)]
@export var support_config: Resource = preload("res://resources/companion_support.tres")
@export var survival_config: Resource = preload("res://resources/survival.tres")
@export var companion_start := Vector2(125,235)
@export var region_ids: PackedStringArray = ["wreck","roots","ruins","lookout","shelter","grove","archive"]
@export var region_names: PackedStringArray = ["Destroços","Trilha das raízes","Pátio das ruínas","Mirante partido","Abrigo esquecido","Bosque profundo","Arquivo de pedra"]
@export var region_bounds: Array[Rect2] = [Rect2(0,0,560,400),Rect2(560,0,560,400),Rect2(1120,0,560,400),Rect2(1680,0,560,400),Rect2(0,400,560,560),Rect2(560,400,560,560),Rect2(1120,400,560,560)]
@export var region_colors: PackedColorArray = [Color("243a36"),Color("243b32"),Color("343e38"),Color("353d3c"),Color("213a35"),Color("23382f"),Color("3d4339")]
@export var water: Array[Rect2] = [Rect2(1680,400,560,560)]
@export var paths: Array[Vector4] = [Vector4(120,220,530,210),Vector4(530,210,1960,210),Vector4(280,220,280,850),Vector4(840,210,840,850),Vector4(1400,210,1400,850),Vector4(280,610,1400,610),Vector4(280,850,1400,850)]
@export var path_width := 50.0
@export var barriers: Array[Rect2] = default_barriers()
@export var page_area_ids: PackedStringArray = ["roots","ruins","lookout","grove","archive"]
@export var encounter_ids: PackedStringArray = ["roots_page","ruins_page","lookout_page","grove_page","archive_page"]
@export var encounter_centers: PackedVector2Array = [Vector2(840,210),Vector2(1400,210),Vector2(1960,210),Vector2(840,610),Vector2(1400,610)]
@export var page_offsets: PackedVector2Array = [Vector2(40,20),Vector2(40,20),Vector2(40,20),Vector2(40,20),Vector2(40,20)]
@export var encounter_marker_offset := Vector2(-130,-65)
@export var encounter_radius := 145.0
@export var wave_sizes: PackedInt32Array = [1,2,3]
@export var wave_overrides: Array[Vector3i] = []
@export var wave_interval := 1.2
@export var monster_attack_settings: Resource = preload("res://resources/monster_attacks.tres")
@export var monster_lineups: Array[Vector4i] = [Vector4i(0,2,0,2),Vector4i(1,0,1,0),Vector4i(3,1,3,1),Vector4i(2,3,2,3),Vector4i(0,1,2,3)]
@export var spawn_radii: PackedFloat32Array = [115,85,140]
@export var spawn_player_clearance := 60.0
@export var discovery_cell_size := 40.0
@export var discovery_radius := 96.0
@export var scenery: Array[Dictionary] = default_scenery()
@export var credits: PackedStringArray = ["Godot Engine", "Godot Engine contributors · licença MIT", "https://godotengine.org/license/"] # Verified engine attribution; no invented art authors.

func region_at(point: Vector2) -> int:
	for i in region_bounds.size():
		if region_bounds[i].has_point(point): return i
	return -1
func page_position(index: int) -> Vector2: return encounter_centers[index]+page_offsets[index]
func monster_kind(index: int, ordinal: int) -> int: return clampi(monster_lineups[index][ordinal%4],0,3)
func wave_count(index: int, wave: int) -> int:
	return clampi(wave_overrides[index][wave] if index < wave_overrides.size() else wave_sizes[wave],1,12)
func all_walls() -> Array[Rect2]:
	var walls: Array[Rect2] = [Rect2(-24,-24,world_size.x+48,24),Rect2(-24,world_size.y,world_size.x+48,24),Rect2(-24,0,24,world_size.y),Rect2(world_size.x,0,24,world_size.y)]
	walls.append_array(barriers)
	walls.append_array(water)
	return walls
func default_barriers() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for x in [560,1120,1680]:
		result.append(Rect2(x-12,0,24,138))
		result.append(Rect2(x-12,280,24,120))
	result.append_array([Rect2(0,390,210,20),Rect2(350,390,410,20),Rect2(920,390,390,20),Rect2(1490,390,190,20)])
	return result
func default_scenery() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for bounds in region_bounds:
		var base := bounds.position
		for offset in [Vector2(60,100),Vector2(65,350),Vector2(490,350),Vector2(506,105)]:
			result.append({"kind":"tree","position":base+offset,"size":Vector2(24,18),"solid":true})
		for offset in [Vector2(150,75),Vector2(425,345)]:
			result.append({"kind":"rock","position":base+offset,"size":Vector2(46,24),"solid":true})
	for entry in [["wreck",Vector2(180,154),Vector2(146,48),true],["wreck",Vector2(370,320),Vector2(72,22),true],["crate",Vector2(98,258),Vector2(28,24),true],["rock",Vector2(300,282),Vector2(34,24),true],["beacon",Vector2(290,190),Vector2(14,10),false]]:
		result.append({"kind":entry[0],"position":entry[1],"size":entry[2],"solid":entry[3]})
	for x in [560,1120,1680]:
		for y in [90,132,310,370]: result.append({"kind":"rock","position":Vector2(x,y),"size":Vector2(32,24),"solid":true})
	for rect in default_barriers():
		if rect.size.x <= 24: continue
		for x in range(int(rect.position.x)+20,int(rect.end.x),48): result.append({"kind":"rock","position":Vector2(x,412),"size":Vector2(38,26),"solid":true})
	for center in [Vector2(1400,210),Vector2(1960,210),Vector2(1400,610)]:
		for offset in [Vector2(-160,-75),Vector2(160,-75),Vector2(-160,125),Vector2(160,125)]:result.append({"kind":"pillar","position":center+offset,"size":Vector2(26,18),"solid":true})
	for point in [Vector2(230,580),Vector2(350,570),Vector2(380,640),Vector2(180,825),Vector2(380,885)]:result.append({"kind":"crate","position":point,"size":Vector2(28,22),"solid":true})
	return result

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if region_ids.is_empty() or region_names.size()!=region_ids.size() or region_bounds.size()!=region_ids.size() or region_colors.size()!=region_ids.size():errors.append("Expected aligned region records")
	if page_area_ids.size()!=5 or encounter_ids.size()!=5 or encounter_centers.size()!=5 or page_offsets.size()!=5 or monster_lineups.size()!=5:errors.append("Expected five aligned encounter/page records")
	if wave_sizes.size()!=3:errors.append("Each encounter needs exactly three waves")
	if world_size.x<=0 or world_size.y<=0 or region_at(start)<0 or region_at(companion_start)<0:errors.append("Invalid world size or safe start")
	var ids: Dictionary = {}
	for id in region_ids:
		if ids.has(id) or id.is_empty():errors.append("Region IDs must be unique and stable")
		ids[id] = true
	ids.clear()
	for id in encounter_ids:
		if ids.has(id) or id.is_empty():errors.append("Encounter IDs must be unique and stable")
		ids[id] = true
	var linked: Dictionary = {}
	for i in page_area_ids.size():
		var area: String = page_area_ids[i]
		if not region_ids.has(area) or linked.has(area): errors.append("Page areas must be five unique existing IDs")
		linked[area] = true
		if i<encounter_centers.size():
			var region := region_at(encounter_centers[i])
			if region>=0 and region_ids[region]!=area: errors.append("Encounter center must match its page area")
	for center in encounter_centers:
		if region_at(center)<0:errors.append("Encounter outside walkable regions")
	return errors
