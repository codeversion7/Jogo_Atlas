extends RefCounted
var config: Resource = preload("res://resources/revisits.tres")
var game: Node2D
var inside: Dictionary = {}
var visits: Dictionary = {}
var rolls := 0
var rng := RandomNumberGenerator.new()
var roll_override: Callable
func _init() -> void:rng.randomize()
func note_completed(index: int) -> void:
	inside[index] = game.companion.position.distance_to(game.layout.encounter_centers[index])<config.enter_radius+config.exit_margin
func tick() -> void:
	if game.get_tree().paused or not game.session_started:return
	for i in game.layout.encounter_centers.size():
		var distance: float = game.companion.position.distance_to(game.layout.encounter_centers[i])
		if distance>=config.enter_radius+config.exit_margin:inside[i] = false
		if distance>config.enter_radius or inside.get(i,false):continue
		inside[i] = true
		visits[i] = int(visits.get(i,0))+1
		if not game.cleared.has(i) or game.player.dead or game.companion.dead or game.ending!=&"none" or game.active_encounter>=0 or game.player.state!=&"ready" or game.player.feedback_wait>0:continue
		if game.navigation.path(game.companion.position,game.layout.encounter_centers[i]).is_empty():continue
		rolls += 1
		var roll: float = roll_override.call() if roll_override.is_valid() else rng.randf()
		if roll<clampf(config.chance,0,1):game.begin_encounter(i,true)
func release() -> void:
	game.companion.stay_at = Vector2.INF
	game.companion.route.clear()
	game.companion.remaining = 0
	game.reactivated_encounter = false
