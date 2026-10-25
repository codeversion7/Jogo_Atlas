extends ProgressBar
## Value is authoritative; displayed_value is presentation only. Convex clipping keeps fill inside both rounded ends.
@export var tint := Color("cb705e")
@export_enum("life","food") var symbol := "life"
var displayed_value := 0.0
var previous_target := 0.0
var initialized := false
var flash := 0.0
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	show_percentage = false
	add_theme_stylebox_override("background",StyleBoxEmpty.new())
	add_theme_stylebox_override("fill",StyleBoxEmpty.new())
func snap_to(percent: float) -> void:
	value = percent
	displayed_value = value
	previous_target = value
	initialized = true
	flash = 0
	queue_redraw()
func _process(delta: float) -> void:advance_visual(delta)
func advance_visual(delta: float) -> void:
	if not initialized:snap_to(value);return
	if value<=0:
		if displayed_value!=0 or previous_target!=value or flash>0:snap_to(value)
		return
	if not is_equal_approx(previous_target,value):
		if absf(previous_target-value)>=1 or (previous_target>25 and value<=25):flash = 0.18
		previous_target = value
	var old := displayed_value
	displayed_value = move_toward(displayed_value,value,maxf(0,delta)*500)
	if flash>0:flash = maxf(0,flash-delta);queue_redraw()
	if old!=displayed_value:queue_redraw()
static func capsule(rect: Rect2) -> PackedVector2Array:
	var points := PackedVector2Array()
	var radius := minf(rect.size.y/2,rect.size.x/2)
	for side in 2:
		var center := Vector2(rect.position.x+radius if side==0 else rect.end.x-radius,rect.get_center().y)
		for i in 9:
			var angle := PI/2+i*PI/8 if side==0 else -PI/2+i*PI/8
			points.append(center+Vector2.RIGHT.rotated(angle)*radius)
	return points
func fill_points(percent: float) -> PackedVector2Array:
	var output := PackedVector2Array()
	if percent<=0:return output
	var inner := Rect2(Vector2.ONE,size-Vector2.ONE*2)
	var points := capsule(inner)
	var edge := inner.position.x+inner.size.x*clampf(percent/100,0,1)
	var previous := points[-1]
	for current in points:
		if (previous.x<=edge)!=(current.x<=edge):output.append(previous.lerp(current,(edge-previous.x)/(current.x-previous.x)))
		if current.x<=edge:output.append(current)
		previous = current
	return output
func _draw() -> void:
	if size.x<4 or size.y<4:return
	draw_colored_polygon(capsule(Rect2(Vector2(0,2),size)),Color(0,0,0,0.35))
	draw_colored_polygon(capsule(Rect2(Vector2.ZERO,size)),Color("68716a").lightened(flash*0.8))
	draw_colored_polygon(capsule(Rect2(Vector2.ONE,size-Vector2.ONE*2)),Color("162321"))
	var fill := fill_points(displayed_value)
	if fill.size()>=3:draw_colored_polygon(fill,tint.lightened(flash*0.5))
	var center := Vector2(11,size.y/2)
	if symbol=="life":
		draw_line(center-Vector2(3,0),center+Vector2(3,0),Color("f9eadd"),2)
		draw_line(center-Vector2(0,3),center+Vector2(0,3),Color("f9eadd"),2)
	else:
		draw_colored_polygon(PackedVector2Array([center+Vector2(-4,1),center+Vector2(-1,-4),center+Vector2(4,-1),center+Vector2(1,4)]),Color("f9eadd"))
