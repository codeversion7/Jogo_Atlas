extends CharacterBody2D
## Base de locomoção. Velocidade provisória em pixels por segundo.

@export_range(1.0, 300.0, 1.0) var move_speed: float = 48.0
@export var preview_animations: bool = false
@onready var visual: Node2D = $Visual

func _ready() -> void:
	visual.stable_pose = not preview_animations
	visual.reference_speed = move_speed
	visual.set_motion(Vector2.ZERO)

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()
	# Deslocamento real: contra uma parede, não caminhar parado.
	visual.set_motion(get_real_velocity())
