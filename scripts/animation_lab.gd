extends Node2D
## Laboratório isolado. A cena principal e seus placeholders permanecem intactos.

const VISUAL = preload("res://scenes/atlas_visual_revisao.tscn")
const FRAMES = preload("res://assets/personagem/revisao/atlas_rascunho.tres")
const DIRECTIONS = ["down", "left", "right", "up"]
@export var test_speed: float = 48.0
var pilot: Node2D
var samples: Array[AnimatedSprite2D] = []
var slow := false

func label_at(value: String, location: Vector2, font_size: int = 12) -> Label:
	var label := Label.new()
	label.text = value
	label.position = location
	label.add_theme_font_size_override("font_size", font_size)
	add_child(label)
	return label

func _ready() -> void:
	label_at("ATLAS / REVISÃO DAS ANIMAÇÕES", Vector2(24, 12), 20)
	label_at("RASCUNHOS — passagem dos pés e respiração ainda pendentes", Vector2(24, 43))
	for row in range(2):
		for col in range(4):
			var sample := AnimatedSprite2D.new()
			sample.name = ("Idle" if row == 0 else "Walk") + DIRECTIONS[col].capitalize()
			sample.sprite_frames = FRAMES
			sample.centered = false
			sample.offset = Vector2(-20, -46)
			sample.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sample.position = Vector2(64 + col * 72, 138 + row * 108)
			add_child(sample)
			sample.play(StringName(("idle_" if row == 0 else "walk_") + DIRECTIONS[col]))
			samples.append(sample)
			label_at(("idle_" if row == 0 else "walk_") + DIRECTIONS[col], Vector2(38 + col * 72, 147 + row * 108), 10)
	var ground := Polygon2D.new()
	ground.color = Color(0.106, 0.165, 0.18, 1)
	ground.polygon = PackedVector2Array([Vector2(336, 84), Vector2(616, 84), Vector2(616, 276), Vector2(336, 276)])
	add_child(ground)
	label_at("Tamanho nativo no piso da fundação", Vector2(340, 87), 11)
	pilot = VISUAL.instantiate()
	pilot.name = "Pilot"
	pilot.position = Vector2(476, 190)
	add_child(pilot)
	label_at("WASD: mover no piso · Espaço: normal/lento (½)", Vector2(24, 294))
	label_at("40 × 48 px · pivô nos pés · 4 FPS espera / 8 FPS caminhada", Vector2(24, 316))

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		slow = not slow
		for sample in samples:
			sample.speed_scale = 0.5 if slow else 1.0

func _physics_process(delta: float) -> void:
	if not is_instance_valid(pilot):
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var before := pilot.position
	pilot.position += direction * test_speed * delta * (0.5 if slow else 1.0)
	pilot.position.x = clampf(pilot.position.x, 356.0, 596.0)
	pilot.position.y = clampf(pilot.position.y, 140.0, 268.0)
	pilot.playback_multiplier = 1.0
	pilot.set_motion((pilot.position - before) / delta)
