extends Node
const Geometry = preload("res://scripts/combat_geometry.gd")
var config: Resource = preload("res://resources/companion_support.tres")
var game: Node2D
var active := false
var armed := true
var remaining := 0.0
var resolved_duration := 0.0
var direction := Vector2.RIGHT
var activations := 0
var last_error := ""
func _ready() -> void:
	game.player.companion_support = self
	game.player.health_changed.connect(observe_health)
	game.companion.fallen.connect(cancel)
func valid_config() -> bool:
	if not is_finite(config.max_distance) or not is_finite(config.half_angle) or not is_finite(config.marker_radius) or config.max_distance<0 or config.half_angle<0 or config.half_angle>PI or config.marker_radius<=0:
		last_error = "Geometria de proteção inválida."
		return false
	last_error = ""
	return true
func eligible() -> bool:
	return valid_config() and not game.player.dead and not game.companion.dead and game.ending==&"none" and game.player.position.distance_to(game.companion.position)<=maxf(0,config.max_distance) and Geometry.clear_line(game.player,game.companion.combat_center())
func observe_health() -> void:
	if game.player.health>=game.player.max_health*0.25: armed = true
func covers(source: Node2D) -> bool:
	if not active or not eligible(): return false
	var incoming: Vector2 = game.player.combat_center().direction_to(source.combat_center())
	# Centro exato de uma área não comprova incidência frontal; não usa lançador distante.
	return not incoming.is_zero_approx() and absf(direction.angle_to(incoming))<=clampf(config.half_angle,0,PI) and Geometry.clear_line(game.player,source.combat_center())
func after_hit(source: Node2D) -> void:
	if active or not armed or not eligible() or game.player.health<=0 or game.player.health>=game.player.max_health*0.25: return
	var duration: float = 5.0+game.survival.shield_bonus_seconds()
	if not is_finite(duration) or duration<=0:
		last_error = "Duração de proteção inválida."
		return
	direction = game.player.combat_center().direction_to(source.combat_center())
	if direction.is_zero_approx(): direction = game.player.aim
	if direction.is_zero_approx(): direction = Vector2.RIGHT
	active = true
	armed = false
	remaining = duration
	resolved_duration = duration
	activations += 1
	update_visual()
func cancel() -> void:
	active = false
	remaining = 0
	if is_instance_valid(game.companion.visual): game.companion.visual.set_guard(false)
	if is_instance_valid(game.player): game.player.queue_redraw()
func update_visual() -> void:
	var facing := (2 if direction.x>0 else 1) if absf(direction.x)>absf(direction.y) else (0 if direction.y>0 else 3)
	game.companion.visual.set_guard(active and eligible(),facing)
	game.player.queue_redraw()
func _physics_process(delta: float) -> void:
	observe_health()
	if not active: return
	if game.player.dead or game.companion.dead or game.ending!=&"none": cancel(); return
	remaining = maxf(0,remaining-delta)
	if remaining<=0: cancel()
	else: update_visual()
