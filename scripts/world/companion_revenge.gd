extends RefCounted
var game: Node2D
var elapsed := 0.0
func reset() -> void:elapsed = 0
func eligible() -> bool:
	if not game.companion.dead or game.player.dead or game.ending!=&"none" or game.survival.raw+game.survival.cooked>0:return false
	for point in game.survival.pickups.values():
		if not game.discovery.known(point):continue
		var screen: Vector2 = game.player.get_canvas_transform()*point
		if not game.get_viewport_rect().has_point(screen):continue
		if not game.reachable(point,INF):continue
		if not game.navigation.path(game.player.position,point).is_empty():return true
	return false
func tick(delta: float) -> void:
	if not game.session_started or game.get_tree().paused:return
	if not eligible():reset();return
	elapsed += maxf(0,delta)
	if elapsed+0.00001>=game.survival.config.revenge_interval:
		elapsed = fmod(elapsed,maxf(0.1,game.survival.config.revenge_interval))
		game.player.debit_life(game.survival.config.revenge_damage)
