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
var lots: Array[Dictionary] = []
var last_result := ""
var steal_roll_override: Callable
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
func friend_full(companion: Node) -> bool:
	return not companion.dead and companion.attributes.hunger>=companion.attributes.hunger_max()
func pending_portions() -> int:
	var assigned := 0
	for lot in lots:assigned += lot.remaining
	return maxi(0,cooked-assigned)
func reserve_lots(companion: Node) -> void:
	var pending := pending_portions()
	if pending>0:lots.append({"initial":pending,"remaining":pending,"reserved":ceili(pending/2.0) if pending>=2 and not friend_full(companion) else 0,"single_risk":pending==1 and not friend_full(companion)})
	if friend_full(companion):
		for lot in lots:lot.reserved = 0;lot.single_risk = false
func meal_status(companion: Node) -> String:
	if companion.dead:return "Prioridade: assar e reanimar. Comer sozinho indisponível."
	var due := 0
	if not friend_full(companion):
		for lot in lots:due += lot.reserved
		var pending := pending_portions()
		if pending>=2:due += ceili(pending/2.0)
	return "Amigo: fome %.0f/%.0f · reserva %d porção(ões)."%[companion.attributes.hunger,companion.attributes.hunger_max(),due]
func consume(mode: String, identity: int, player: Node, companion: Node, rescue_position: Vector2 = Vector2.INF) -> bool:
	last_result = ""
	if cooked<=0 or operations.has(identity) or player.dead:return false
	if mode not in ["eat","share","revive"]:return false
	if companion.dead and mode!="revive":last_result = "Reanime seu amigo antes de consumir a porção.";return false
	if mode=="revive" and (not companion.dead or not rescue_position.is_finite()):return false
	reserve_lots(companion)
	var current: Dictionary = {}
	for lot in lots:
		if lot.remaining>0:current = lot;break
	if current.is_empty():return false
	if mode=="eat" and current.reserved>0:last_result = "Divida a reserva deste lote antes de comer sozinho.";return false
	operations[identity] = true
	cooked -= 1
	current.remaining -= 1
	if mode!="eat":current.reserved = maxi(0,current.reserved-1)
	if mode=="eat" and current.single_risk and not friend_full(companion):
		var roll: float = steal_roll_override.call() if steal_roll_override.is_valid() else rng.randf()
		if roll<config.steal_chance:
			companion.attributes.hunger += maxf(0,config.companion_meal_hunger)
			last_result = "Seu amigo roubou a porção. Nenhuma refeição para você."
			return true
	var fraction := clampf(config.shared_player_fraction,0,1) if mode!="eat" else 1.0
	player.attributes.hunger += maxf(0,config.meal_hunger)*fraction
	player.attributes.health += maxi(0,ceili(config.meal_heal*fraction))
	player.health_changed.emit()
	if mode!="eat":
		if mode=="revive":companion.revive_at(rescue_position,maxi(1,config.revive_health))
		else:companion.heal(maxi(0,config.companion_heal))
		companion.attributes.hunger += maxf(0,config.companion_meal_hunger)
		shares += 1
		portion_shared.emit(0.2)
	last_result = "Porção consumida." if mode=="eat" else "Porção partilhada."
	return true
func shield_bonus_seconds() -> float: return shares*0.2
