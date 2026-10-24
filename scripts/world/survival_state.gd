extends RefCounted
## Estado exclusivo da partida. RNG injetável; transações e mortes idempotentes.
signal portion_shared(bonus_seconds: float)
var config: Resource = preload("res://resources/survival.tres")
var rng := RandomNumberGenerator.new()
var misses := 0
var deaths: Dictionary = {}
var pickups: Dictionary = {}
var operations: Dictionary = {}
var raw := 0
var cooked := 0
var shares := 0
func _init() -> void: rng.randomize()
func record_death(identity: int, position: Vector2, injected_roll: float = -1.0) -> bool:
	if identity<=0 or deaths.has(identity) or not position.is_finite(): return false
	deaths[identity] = true
	var roll := rng.randf() if injected_roll<0 else injected_roll
	var chance := clampf(config.meat_chance,0.05,0.10)
	var drops := misses>=4 or (is_finite(roll) and roll>=0 and roll<chance)
	if drops:
		misses = 0
		pickups[identity] = position
	else: misses += 1
	return drops
func collect(identity: int) -> bool:
	if not pickups.has(identity): return false
	pickups.erase(identity)
	raw += 1
	return true
func cook(identity: int) -> bool:
	if raw<=0 or operations.has(identity): return false
	operations[identity] = true
	raw -= 1
	cooked += 1 # Assar imediato: operação atômica, nenhum timer parado pelo próprio painel.
	return true
func consume(mode: String, identity: int, player: Node, companion: Node, rescue_position: Vector2 = Vector2.INF) -> bool:
	if cooked<=0 or operations.has(identity) or player.dead: return false
	if mode not in ["eat","share","revive"]: return false
	if mode=="share" and companion.dead: return false
	if mode=="revive" and (not companion.dead or not rescue_position.is_finite()): return false
	operations[identity] = true
	cooked -= 1
	var fraction := clampf(config.shared_player_fraction,0,1) if mode!="eat" else 1.0
	player.attributes.hunger += maxf(0,config.meal_hunger)*fraction
	player.attributes.health += maxi(0,ceili(config.meal_heal*fraction))
	player.health_changed.emit()
	if mode!="eat":
		if mode=="revive": companion.revive_at(rescue_position,maxi(1,config.revive_health))
		else: companion.heal(maxi(0,config.companion_heal))
		shares += 1
		portion_shared.emit(0.2)
	return true
func shield_bonus_seconds() -> float: return shares*0.2
