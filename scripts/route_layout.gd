extends Resource
## Coordenadas editáveis do percurso provisório; unidades em pixels.
class_name AtlasRouteLayout

@export var world_size := Vector2(2240, 800)
@export var start := Vector2(180, 220)
@export var encounter_centers: PackedVector2Array = PackedVector2Array([
	Vector2(840, 210), Vector2(1400, 210), Vector2(1960, 210),
	Vector2(840, 610), Vector2(1400, 610)])
@export var encounter_radius: float = 145.0
@export var region_names: PackedStringArray = ["Destroços", "Trilha das raízes", "Pátio das ruínas", "Mirante partido", "Abrigo esquecido", "Bosque profundo", "Arquivo de pedra"]
@export var wave_sizes: PackedInt32Array = PackedInt32Array([1, 2, 3])
@export var wave_interval: float = 1.2
