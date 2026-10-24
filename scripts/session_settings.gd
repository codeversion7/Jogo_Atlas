extends Node
## Preferências locais; nunca contém estado da campanha.
const DEFAULTS := {"master":0.8,"effects":0.7,"music":0.6,"mute":false,"fullscreen":false,"window_scale":0}
var values: Dictionary = DEFAULTS.duplicate()
var path := "user://atlas_settings.cfg"
var last_error := ""
var initial_window := Vector2i.ZERO
var loaded := false
var device_status := ""
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	initial_window = DisplayServer.window_get_size()
	if AudioServer.get_output_device_list().is_empty(): device_status = "Sem dispositivo de áudio disponível; verifique a saída do sistema."
	ensure_buses()
	load_preferences()
func ensure_buses() -> void:
	for name in ["Effects","Music"]:
		if AudioServer.get_bus_index(name)<0:
			AudioServer.add_bus()
			var index := AudioServer.bus_count-1
			AudioServer.set_bus_name(index,name)
			AudioServer.set_bus_send(index,"Master")
func load_preferences() -> void:
	values = DEFAULTS.duplicate()
	last_error = ""
	var config := ConfigFile.new()
	var error := config.load(path)
	loaded = error == OK
	if error != OK and error != ERR_FILE_NOT_FOUND: last_error = "Configuração inválida; padrões aplicados: "+error_string(error)
	if loaded:
		for key in DEFAULTS:
			var value = config.get_value("settings",key,DEFAULTS[key])
			values[key] = sanitize(key,value)
	apply(loaded)
func sanitize(key: String, value: Variant) -> Variant:
	if key in ["master","effects","music"]:
		if not (value is float or value is int) or not is_finite(float(value)): return DEFAULTS[key]
		return clampf(float(value),0,1)
	if key == "window_scale": return clampi(value,0,4) if value is int else 0
	return value if value is bool else DEFAULTS[key]
func set_value(key: String, value: Variant) -> bool:
	if not DEFAULTS.has(key): return false
	values[key] = sanitize(key,value)
	apply(key in ["fullscreen","window_scale"])
	return save_preferences()
func apply(window: bool = false) -> void:
	for pair in [["Master","master"],["Effects","effects"],["Music","music"]]:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(pair[0]),linear_to_db(maxf(0.00001,values[pair[1]])))
	AudioServer.set_bus_mute(0,values.mute)
	if not window or DisplayServer.get_name()=="headless": return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if values.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	if not values.fullscreen and values.window_scale>0:
		DisplayServer.window_set_size(Vector2i(640,360)*values.window_scale)
func save_preferences() -> bool:
	var config := ConfigFile.new()
	for key in values: config.set_value("settings",key,values[key])
	var error := config.save(path)
	last_error = "" if error==OK else "Não foi possível salvar: "+error_string(error)
	return error==OK
func restore_defaults() -> void:
	values = DEFAULTS.duplicate()
	apply(true)
	if DisplayServer.get_name()!="headless" and initial_window.x>0: DisplayServer.window_set_size(initial_window)
	save_preferences()
