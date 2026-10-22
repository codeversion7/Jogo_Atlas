extends Node2D
## Trecho de teste da locomoção; demais sistemas permanecem pendentes.

@export var status_text: String = "WASD · colisão nos pés · câmera acompanha o personagem"

@onready var status_label: Label = $Interface/Status

func _ready() -> void:
	status_label.text = status_text
	print("ATLAS: trecho de movimentação carregado.")
