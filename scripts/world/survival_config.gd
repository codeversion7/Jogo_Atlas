extends Resource
## Valores de protótipo; nenhuma penalidade letal ao chegar a fome zero.
@export_range(0.05,0.10,0.005) var meat_chance := 0.075
@export var hunger_per_second := 0.08
@export var meal_hunger := 35.0
@export var meal_heal := 25
@export var shared_player_fraction := 0.5
@export var companion_heal := 30
@export var revive_health := 50
@export var pickup_distance := 26.0
@export var camp_distance := 36.0
