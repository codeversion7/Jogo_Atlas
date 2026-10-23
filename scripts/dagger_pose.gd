extends RefCounted
## Shared authored pose for rendering and blade contact. No trail damage.
const BODY = preload("res://assets/personagem/ataque_adaga_v1/atlas_attack_body.tres")
const DAGGER = preload("res://assets/personagem/ataque_adaga_v1/atlas_attack_dagger.tres")
const TRAIL = preload("res://assets/personagem/ataque_adaga_v1/atlas_attack_trail.tres")
const PIVOT := Vector2(40, 62)
static var manifest: Dictionary = {}
static var body_masks: Dictionary = {}

static func facing(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y) + 0.01:
		return "right" if direction.x > 0 else "left"
	return "down" if direction.y >= 0 else "up"

static func cardinal(view: String) -> Vector2:
	return {"right":Vector2.RIGHT,"left":Vector2.LEFT,"up":Vector2.UP,"down":Vector2.DOWN}[view]

static func frame_at(frames: SpriteFrames, clip: StringName, progress: float) -> int:
	var total := 0.0
	var count := frames.get_frame_count(clip)
	for i in count:
		total += frames.get_frame_duration(clip, i)
	var time := clampf(progress, 0.0, 1.0) * total
	for i in count:
		time -= frames.get_frame_duration(clip, i)
		if time < 0.0:
			return i
	return count - 1

static func sample(phase: StringName, direction: Vector2, progress: float) -> Dictionary:
	if manifest.is_empty():
		manifest = JSON.parse_string(FileAccess.get_file_as_string("res://assets/personagem/ataque_adaga_v1/manifesto.json"))
	var view := facing(direction)
	var clip := StringName(String(phase) + "_" + view)
	var frame := frame_at(BODY, clip, progress)
	var index: int = frame + {&"attack_windup":0,&"attack_active":2,&"attack_recovery":6}[phase]
	var item: Dictionary = manifest.frames[manifest.directions.find(view) * 12 + index]
	var hand := Vector2(item.hand_px[0], item.hand_px[1])
	var tip := Vector2(item.tip_px[0], item.tip_px[1])
	var angle := cardinal(view).angle_to(direction)
	var blade := (tip - hand).rotated(angle)
	return {"clip":clip,"frame":frame,"index":index,"hand_px":hand,"hand":hand-PIVOT,
		"tip":hand-PIVOT+blade,"base":hand-PIVOT+blade.normalized()*2.0,"rotation":angle,"behind":item.dagger_behind_body}

static func visible_blade(pose: Dictionary) -> PackedVector2Array:
	var points := PackedVector2Array()
	var mask: Image
	if pose.behind:
		var key := String(pose.clip) + str(pose.frame)
		if not body_masks.has(key):
			body_masks[key] = BODY.get_frame_texture(pose.clip,pose.frame).get_image()
		mask = body_masks[key]
	# One-pixel sampling of the visible metal, not handle, body or trail.
	var steps := ceili(Vector2(pose.base).distance_to(pose.tip))
	for i in range(steps+1):
		var point: Vector2 = Vector2(pose.base).lerp(pose.tip,float(i)/steps)
		var pixel := Vector2i((point+PIVOT).floor())
		if mask == null or pixel.x < 0 or pixel.y < 0 or pixel.x >= 80 or pixel.y >= 80 or mask.get_pixelv(pixel).a < 0.1:
			points.append(point)
	return points
