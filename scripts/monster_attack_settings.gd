extends Resource
## Parâmetros provisórios compartilhados pelos encontros; não alteram vida/dano do módulo 1.
class_name AtlasMonsterAttackSettings
@export var trigger_ranges: PackedFloat32Array = [28,30,120,96]
@export var timing_scale: float = 1.0
@export var cross_forward: float = 17.0
@export var cross_length: float = 14.0
@export var cross_half_width: float = 2.0
@export var slam_forward: float = 12.0
@export var slam_radius: float = 20.0
@export var burrow_radius: float = 18.0
@export var orb_speed: float = 160.0
@export var orb_lifetime: float = 0.8
@export var orb_radius: float = 4.0
@export var explosion_radius: float = 18.0
@export var explosion_duration: float = 0.2
