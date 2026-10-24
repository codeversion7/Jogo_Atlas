extends SceneTree
## Inventory only: read MPEG bytes through Godot MP3 decoder, without modifying originals.
func _initialize() -> void:
	var rows: Array = []
	for name in DirAccess.get_files_at("res://SONS"):
		if not name.ends_with(".mpeg"): continue
		var path := "res://SONS/"+name
		var bytes := FileAccess.get_file_as_bytes(path)
		var stream := AudioStreamMP3.new()
		stream.data = bytes
		var playback := stream.instantiate_playback()
		rows.append({"path":path,"bytes":bytes.size(),"sha256":FileAccess.get_sha256(path),"decoder":"Godot AudioStreamMP3","length_seconds":stream.get_length(),"playback_created":playback != null,"audition":"pending"})
	var file := FileAccess.open("res://docs/atlas/evidencias/15_audio_inventory.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(rows,"  "))
	print("ATLAS_AUDIO_INVENTORY entries=",rows.size())
	quit(0 if rows.size()==8 else 1)
