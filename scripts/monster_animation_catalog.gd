extends RefCounted
## Recortes medidos no MANIFESTO v2; ordem: baixo, esquerda, direita, cima.
## Cada zona de membro: centro X, meia largura, altura da articulação, fase.
const DIRECTIONS := [&"down", &"left", &"right", &"up"]
const IDS := ["b1_fenda", "b2_carcaca", "b3_esporo", "b4_escavador"]
const NAMES := ["Fenda", "Carcaça", "Esporo", "Escavador"]
const REGIONS := [
	[Rect2(97,115,494,454), Rect2(693,135,455,455), Rect2(97,702,463,435), Rect2(675,676,482,461)],
	[Rect2(29,72,641,474), Rect2(670,91,620,465), Rect2(41,669,549,463), Rect2(670,627,653,484)],
	[Rect2(63,32,545,526), Rect2(711,109,590,444), Rect2(36,668,599,458), Rect2(724,641,572,470)],
	[Rect2(49,131,552,419), Rect2(712,153,494,426), Rect2(49,725,492,432), Rect2(656,708,560,400)]
]
const HEIGHTS := [38.0, 34.0, 34.0, 34.0]

static func source_path(kind: int) -> String:
	var id: String = IDS[clampi(kind,0,3)]
	return "res://assets/monstros/%s/pixel_v2/%s_quatro_direcoes.png" % [id,id]

static func legs(kind: int, direction: int) -> Array[Vector4]:
	var side := direction in [1,2]
	match kind:
		0:
			if side:
				return [Vector4(0.40,0.19,0.58,0),Vector4(0.66,0.17,0.62,PI)]
			return [Vector4(0.36,0.15,0.61,0),Vector4(0.65,0.15,0.61,PI)]
		1:
			if side:
				var flip := -1.0 if direction == 2 else 1.0
				return [Vector4(0.5+0.04*flip,0.11,0.72,0),Vector4(0.5+0.23*flip,0.12,0.73,PI)]
			return [Vector4(0.42,0.11,0.76,0),Vector4(0.61,0.11,0.76,PI)]
		2:
			if side:
				return [Vector4(0.25,0.14,0.62,0),Vector4(0.48,0.14,0.63,PI),Vector4(0.73,0.16,0.65,0)]
			return [Vector4(0.14,0.14,0.57,0),Vector4(0.28,0.10,0.70,PI),Vector4(0.72,0.10,0.70,0),Vector4(0.86,0.14,0.57,PI)]
		_:
			if side:
				return [Vector4(0.29,0.22,0.56,0),Vector4(0.73,0.17,0.58,PI),Vector4(0.50,0.10,0.80,PI)]
			return [Vector4(0.20,0.19,0.51,0),Vector4(0.80,0.19,0.51,PI),Vector4(0.41,0.09,0.79,PI),Vector4(0.61,0.09,0.79,0)]
