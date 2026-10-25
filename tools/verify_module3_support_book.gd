extends SceneTree
## Atores/vida/páginas são fixtures de contrato; o percurso real permanece na suíte integrada.
const Monster = preload("res://scripts/test_monster.gd")
const Orb = preload("res://scripts/monster_orb.gd")
var game
var player
var friend
var support
var source
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(message)
func step(n: int = 1) -> void:
	for i in n:
		await physics_frame
		await process_frame
func fresh(health: int = 100) -> void:
	support.cancel()
	support.armed = true
	player.health = health
	player.hurt_wait = 0
	player.dead = false
	player.state = &"ready"
	player.attributes.overrides.resistance = 0.0
	player.shield = 0
	friend.position = Vector2(150,235)
	if friend.dead: friend.revive_at(friend.position,100)
func hit(amount: int) -> StringName:
	player.hurt_wait = 0
	return player.receive_attack(amount,source)
func wall_at(point: Vector2) -> StaticBody2D:
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(4,60)
	shape.shape = rectangle
	wall.add_child(shape)
	wall.position = point
	game.get_node("World").add_child(wall)
	return wall
func run() -> void:
	game = load("res://scenes/playable.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.start_session()
	player = game.player
	friend = game.companion
	support = game.support
	player.set_physics_process(false)
	friend.set_physics_process(false)
	player.position = Vector2(180,220)
	source = Monster.new()
	source.target = player
	source.position = Vector2(204,220)
	game.get_node("World").add_child(source)
	source.set_physics_process(false)
	await step(3)
	fresh()
	support.config = support.config.duplicate(true)
	support.config.half_angle = NAN
	hit(76)
	check(not support.active and not support.last_error.is_empty(),"Nonfinite geometry is rejected without global protection")
	support.config.half_angle = PI/3
	fresh()
	hit(74)
	check(player.health==26 and not support.active,"Above 25% never activates")
	fresh()
	hit(75)
	check(player.health==25 and not support.active,"Exactly 25% never activates")
	fresh()
	hit(76)
	check(player.health==24 and support.active and support.remaining==5.0,"Threshold-crossing hit is fully applied before five-second support")
	check(source.health==source.max_health,"Protection never reflects damage")
	var activations: int = support.activations
	hit(10)
	check(player.health==19 and support.activations==activations and support.remaining==5.0,"Low-health hits are halved without refreshing activation")
	var clock: float = support.remaining
	game.session_ui.claim(&"map")
	var paused_health: int = player.health
	check(hit(999)==&"ignored" and player.health==paused_health,"Paused direct damage API is ignored")
	await step(20)
	check(support.remaining==clock,"Paused panel freezes mechanical shield duration")
	game.session_ui.close()
	await step(100)
	check(friend.visual.state=="shield" and friend.visual.opening==1 and friend.visual.guard_held,"Prepared animation holds beyond 1.12 seconds without restarting")
	await step(230)
	check(not support.active and not friend.visual.guard_held and not friend.visual.shield.visible,"Expiry retracts presentation without lingering effect")
	hit(1)
	check(not support.active,"Staying below threshold does not rearm")
	player.health = 25
	player.health_changed.emit()
	hit(2)
	check(support.active,"Healing to exactly 25% rearms a subsequent drop")
	player.health = 100
	hit(20)
	check(player.health==90,"Front damage reduced by exactly half")
	player.health = 100
	source.position = Vector2(156,220)
	hit(20)
	check(player.health==80,"Rear hit is not reduced")
	player.health = 100
	source.position = Vector2(180,196)
	hit(20)
	check(player.health==80,"Lateral hit outside configured arc is not reduced")
	source.position = Vector2(204,220)
	friend.position = Vector2(150,220)
	var wall := wall_at(Vector2(165,212))
	await step(2)
	player.health = 100
	hit(20)
	check(player.health==80,"Wall between companion and player prevents remote protection")
	wall.queue_free()
	await step(2)
	friend.position = Vector2(500,500)
	player.health = 100
	hit(20)
	check(player.health==80,"Distant companion cannot protect globally")
	friend.position = Vector2(150,235)
	player.health = 100
	source.position = player.position
	hit(20)
	check(player.health==80,"Area impact centered on body has no inferred frontal direction")
	source.position = Vector2(204,220)
	player.health = 100
	player.attributes.overrides.resistance = 0.1
	player.max_shield = 5
	player.shield = 5
	hit(20)
	check(player.health==96 and player.shield==0,"Pipeline: half damage, resistance, reserve absorption, health")
	player.attributes.overrides.resistance = 0.0
	player.state = &"parry"
	player.locked_direction = Vector2.RIGHT
	check(hit(20)==&"parried" and source.remaining==0.5,"Protected successful parry uses explicit 0.5-second stagger")
	player.locked_direction = Vector2.LEFT
	player.health = 100
	source.state = &"chase"
	source.remaining = 0
	check(hit(10)==&"hit" and source.state==&"chase","Failed parry does not stagger even during protection")
	player.locked_direction = Vector2.RIGHT
	support.cancel()
	check(hit(20)==&"parried" and source.remaining==source.stagger_duration,"Ordinary parry retains original stagger duration")
	fresh()
	player.state = &"dodge"
	hit(999)
	check(player.health==100 and not support.active,"Ignored dodge damage never activates support")
	fresh()
	hit(100)
	check(player.dead and not support.active,"Lethal hit is never rescued by activation")
	fresh()
	game.survival.shares = 2
	hit(76)
	check(is_equal_approx(support.resolved_duration,5.4),"Two completed shares resolve 5.4 seconds at activation")
	game.survival.cooked = 1
	game.survival.consume("share",9999,player,friend)
	check(is_equal_approx(support.resolved_duration,5.4) and support.armed,"Sharing rearms through healing but never extends active shield")
	activations = support.activations
	hit(30)
	check(support.activations==activations,"Healing/rearm cannot create second shield during active one")
	support.cancel()
	player.health = 24
	hit(1)
	check(is_equal_approx(support.resolved_duration,5.6),"Next activation includes later share exactly once")
	# Projectile origin lies on the right while its caster stands on the left.
	source.position = Vector2(100,220)
	var projectile := Orb.new()
	projectile.caster = source
	projectile.target = player
	projectile.settings = source.attack_settings
	game.get_node("World").add_child(projectile)
	projectile.position = player.combat_center()+Vector2(12,0)
	projectile.set_physics_process(false)
	player.state = &"parry"
	player.locked_direction = Vector2.RIGHT
	player.hurt_wait = 0
	check(player.receive_attack(20,projectile)==&"parried" and source.remaining==0.5,"Protected projectile parry uses actual impact origin, not caster position")
	source.position = Vector2(204,220)
	friend.hurt_wait = 0
	friend.receive_attack(9999,source)
	check(friend.dead and not support.active,"Fallen companion cancels protection immediately")
	player.state = &"ready"
	player.health = 24
	support.armed = true
	hit(1)
	check(not support.active,"Fallen companion cannot activate protection")
	friend.revive_at(Vector2(150,235),100)
	game.pages = {0:true,1:true,2:true,3:true}
	check(not game.start_ending(),"Four pages cannot start book")
	friend.hurt_wait = 0
	friend.receive_attack(9999,source)
	game.pages[4] = true
	check(not game.start_ending() and game.pages.size()==5 and game.ending==&"none","Five pages with fallen friend remain intact while book waits")
	player.position = game.layout.campfires[0]
	game.camp_index = 0
	game.survival.cooked = 1 # Explicit food fixture; actual drop/cooking tested in phase 03.
	game.session_ui.claim(&"campfire")
	game.session_ui.show_campfire()
	check(game.camp_action("revive",game.food_generation),"Cooked portion revives friend before final gate")
	check(not game.start_ending(),"Book transition waits until paused camp UI closes")
	game.session_ui.close()
	await step(3)
	check(game.ending==&"none" and game.pages.size()==5,"Revival preserves pages but does not auto-start final")
	game.record_first_victory(0) # Explicit altar fixture; real victory event tested separately.
	player.position = game.altar.position
	player.feedback_wait = 0
	player.state = &"ready"
	check(game.interact()==&"altar" and not friend.is_physics_processing(),"Manual altar interaction starts unique final after rescue")
	check(not game.start_ending() and game.ending_phases.size()==1,"Final transition cannot trigger twice")
	var hunger: float = player.hunger
	await step(330)
	check(game.ending==&"complete" and game.ending_phases==[&"flipping",&"light",&"vanishing",&"complete"],"Canonical book sequence remains intact")
	check(player.hunger==hunger,"Finished/ending session does not consume hunger")
	game.return_to_menu()
	await step(3)
	game = current_scene
	check(not game.support.active and game.support.armed and game.survival.shares==0,"New session cleans support and bonus")
	game.queue_free()
	await step(2)
	print("ATLAS_MODULE3_SUPPORT_BOOK checks=",checks," failures=",failures)
	quit(0 if failures==0 else 1)
