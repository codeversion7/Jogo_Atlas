extends SceneTree
func _initialize() -> void:
	var destination := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): destination = arg.trim_prefix("--out=")
	if destination.is_empty(): quit(1); return
	var file := FileAccess.open(destination,FileAccess.WRITE)
	if file==null: quit(1); return
	file.store_string("Godot Engine "+Engine.get_version_info().string+"\n\n"+Engine.get_license_text())
	file.store_string("\n\nThird-party copyright notices from this engine binary:\n"+JSON.stringify(Engine.get_copyright_info(),"  "))
	file.store_string("\n\nThird-party license texts from this engine binary:\n"+JSON.stringify(Engine.get_license_info(),"  "))
	print("ATLAS_ENGINE_NOTICES saved=true")
	quit()
