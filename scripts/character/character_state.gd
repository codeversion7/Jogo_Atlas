extends RefCounted
signal changed
const DEFAULT = preload("res://resources/character/default_character.tres")
const BRANCHES := ["throw", "reach", "parry"]
const NODES := {
	"throw.unlock":{"branch":"throw","label":"Adaga de retorno","requires":"","unlock":true},
	"throw.edge":{"branch":"throw","label":"Fio preciso","requires":"throw.unlock","unlock":false},
	"reach.first":{"branch":"reach","label":"Onda curta","requires":"","unlock":true},
	"reach.second":{"branch":"reach","label":"Onda ampliada","requires":"reach.first","unlock":false},
	"parry.focus":{"branch":"parry","label":"Foco","requires":"","unlock":false},
	"parry.guard":{"branch":"parry","label":"Guarda","requires":"parry.focus","unlock":false}}
var config: Resource = DEFAULT
var overrides: Dictionary = {}
var owned: Dictionary = {}
var spent_costs: Dictionary = {}
var rewarded: Dictionary = {}
var points: int = 0
var cooldowns := {"dodge":0.0,"throw":0.0}
var health: int = 100:
	set(value): health = clampi(value,0,health_max())
var hunger: float = 100.0:
	set(value): hunger = clampf(value,0,hunger_max())
var shield: int = 0:
	set(value): shield = clampi(value,0,shield_max())

func value(key: String) -> Variant:
	return overrides.get(key,config.get(key))
func health_max() -> int: return clampi(int(value("health_max")),1,99999)
func hunger_max() -> float: return clampf(float(value("hunger_max")),1.0,99999.0)
func damage() -> int: return clampi(int(value("melee_damage")) + (config.edge_damage_bonus if owned.has("throw.edge") else 0),0,99999)
func resistance() -> float: return clampf(float(value("resistance"))+(config.guard_resistance_bonus if owned.has("parry.guard") else 0),0,0.8)
func shield_max() -> int: return clampi(int(value("shield_max"))+(config.guard_shield_bonus if owned.has("parry.guard") else 0),0,99999)
func dodge_distance() -> float: return clampf(float(value("dodge_distance")),0,1000)
func dodge_duration() -> float: return clampf(float(value("dodge_duration")),0.01,10)
func dodge_cooldown() -> float: return clampf(float(value("dodge_cooldown")),0.01,120)
func parry_window() -> float: return clampf(float(value("parry_window"))+(config.focus_window_bonus if owned.has("parry.focus") else 0),0.01,2)
func parry_recovery() -> float: return clampf(float(value("parry_recovery")),0.01,10)
func throw_damage() -> int: return clampi(int(config.throw_damage)+(config.edge_damage_bonus if owned.has("throw.edge") else 0),0,99999)
func melee_level() -> int: return 2 if owned.has("reach.second") and owned.has("reach.first") else 1 if owned.has("reach.first") else 0
func retire_tracking() -> void:
	var removed := false
	for id in ["tracking.unlock","tracking.stride"]:
		if not owned.has(id):continue
		owned.erase(id)
		points += maxi(0,int(spent_costs.get(id,0)))
		spent_costs.erase(id)
		removed = true
	cooldowns.erase("tracking")
	if removed:changed.emit()
func cost(id: String) -> int:
	if not NODES.has(id): return 0
	return maxi(1,config.unlock_cost if NODES[id].unlock else config.upgrade_cost)
func can_buy(id: String) -> bool:
	return NODES.has(id) and not owned.has(id) and points >= cost(id) and (NODES[id].requires == "" or owned.has(NODES[id].requires))
func buy(id: String) -> bool:
	if not can_buy(id): return false
	spent_costs[id] = cost(id)
	points -= spent_costs[id]
	owned[id] = true
	if id == "parry.guard": shield = shield_max() # Acquisition grants this shield once; no regeneration.
	changed.emit()
	return true
func reward_encounter(id: int) -> bool:
	if rewarded.has(id) or id < 0 or id >= 5: return false
	rewarded[id] = true
	points += clampi(config.points_per_encounter,0,99)
	changed.emit()
	return true
func tick(delta: float) -> void:
	for id in cooldowns: cooldowns[id] = maxf(0,float(cooldowns[id])-maxf(0,delta))
func consume_hunger(delta: float, rate: float) -> void:
	if is_finite(delta) and is_finite(rate): hunger -= maxf(0,delta)*maxf(0,rate)
	# Zero permanece zero: sem dano/fome letal ou alteração de dash oculta.
func absorb_damage(amount: int) -> int:
	# Clamp input, mitigate with ceil, consume shield, then subtract health.
	if amount <= 0: return 0
	var incoming := maxi(0,ceili(amount*(1.0-resistance())))
	var absorbed := mini(shield,incoming)
	shield -= absorbed
	incoming -= absorbed
	health -= incoming
	changed.emit()
	return incoming
