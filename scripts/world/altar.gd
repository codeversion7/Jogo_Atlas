extends Node2D
## Cenário local do final. Física original preservada; atores congelados antes da destruição visual.
@export var interact_distance := 32.0
@export var destruction_radius := 160.0
var game: Node2D
var destruction := 0.0
var affected: Array[Node2D] = []
func begin() -> void:
	for prop in get_parent().get_children():
		if prop.get_script()==preload("res://scripts/world_prop.gd") and prop.position.distance_to(position)<=destruction_radius:affected.append(prop)
func _process(_delta: float) -> void:
	visible = game.discovery.known(global_position)
	if game.ending!=&"none":
		destruction = clampf((game.book.elapsed-1.6)/2.0,0,1)
		for prop in affected:
			if is_instance_valid(prop):prop.modulate.a = 1.0-destruction
	queue_redraw()
func _draw() -> void:
	if destruction>0:
		draw_circle(Vector2.ZERO,destruction_radius*0.55,Color(0.08,0.11,0.1,destruction*0.8))
		for i in 12:
			var direction := Vector2.RIGHT.rotated(i*TAU/12+sin(i*3.1)*0.12)
			var start := direction*18
			var middle := direction.rotated(0.1*sin(i))*destruction_radius*0.45*destruction
			var end := direction*destruction_radius*destruction
			draw_line(start,middle,Color(0.025,0.03,0.035,destruction),2)
			draw_line(middle,end,Color(0.025,0.03,0.035,destruction),2)
			if destruction<1:draw_rect(Rect2(end+Vector2(0,-18*sin(destruction*PI)),Vector2(3,3)),Color(0.6,0.65,0.52,1-destruction))
	draw_rect(Rect2(-15,-4,30,12),Color("3b4b48"))
	draw_rect(Rect2(-18,-7,36,5),Color("8b9681"))
	draw_line(Vector2(-8,-8),Vector2(8,-8),Color("e5ce80"),2)
