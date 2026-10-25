extends Resource
## Immutable shared base tuning; current values and purchases live per instance.
@export var health_max: int = 100
@export var hunger_max: float = 100.0
@export var melee_damage: int = 25
@export_range(0,0.8,0.01) var resistance: float = 0.0
@export var shield_max: int = 0
@export var dodge_distance: float = 30.4
@export var dodge_duration: float = 0.16
@export var dodge_cooldown: float = 0.65
@export var parry_window: float = 0.16
@export var parry_recovery: float = 0.35
@export var throw_damage: int = 25
@export var throw_speed: float = 220.0
@export var throw_range: float = 120.0
@export var throw_cooldown: float = 3.0
@export var return_timeout: float = 2.0
@export var points_per_encounter: int = 1
@export var unlock_cost: int = 1
@export var upgrade_cost: int = 1
@export var edge_damage_bonus: int = 5
@export var focus_window_bonus: float = 0.04
@export var guard_resistance_bonus: float = 0.10
@export var guard_shield_bonus: int = 20
