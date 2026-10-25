extends Node
## Vozes locais à sessão. Sem loop, trilha inventada ou estado persistente.
const STREAMS := {"steps":preload("res://assets/audio/steps.mp3"),"dagger":preload("res://assets/audio/dagger.mp3"),"parry":preload("res://assets/audio/parry.mp3"),"page":preload("res://assets/audio/page.mp3"),"cross":preload("res://assets/audio/cross.mp3"),"orb":preload("res://assets/audio/orb.mp3"),"burrow_warning":preload("res://assets/audio/burrow_warning.mp3"),"burrow_impact":preload("res://assets/audio/burrow_impact.mp3")}
const GAINS := {"steps":-17.0,"dagger":-10.0,"parry":-7.0,"page":-12.0,"cross":-12.0,"orb":-12.0,"burrow_warning":-14.0,"burrow_impact":-12.0}
# A fonte de grama concentra o passo em 0,2–0,4 s; não tocar só a introdução baixa.
const STARTS := {"steps":0.16}
const STEP_DURATION := 0.24
var game: Node2D
var voices: Array[Node] = []
var recent: Dictionary = {}
var footsteps := 0.0
var max_voices := 8
var events_played := 0
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("atlas_audio")
static func event(actor: Node, key: String, tag: String = "") -> void:
	if not actor.is_inside_tree(): return
	for service in actor.get_tree().get_nodes_in_group("atlas_audio"):
		if service.game.is_ancestor_of(actor):
			service.play_event(actor,key,tag)
			return
func play_event(actor: Node, key: String, tag: String = "") -> void:
	if not STREAMS.has(key) or get_tree().paused or not game.session_started or game.player.dead: return
	var identity := "%d/%s/%s"%[actor.get_instance_id(),key,tag]
	var frame := Engine.get_physics_frames()
	if recent.get(identity,-1)==frame: return
	recent[identity] = frame
	if recent.size()>128:
		for item in recent.keys():
			if int(recent[item])<frame-2: recent.erase(item)
	# Uma voz por emissor/evento; impacto encerra o aviso anterior do Escavador.
	for existing in voices:
		if is_instance_valid(existing) and existing.get_meta("emitter").get_ref()==actor:
			if existing.get_meta("event")==key or (key=="burrow_impact" and existing.get_meta("event")=="burrow_warning"): existing.stop()
	clean_finished()
	if voices.size()>=max_voices: return
	var voice := AudioStreamPlayer2D.new()
	voice.process_mode = Node.PROCESS_MODE_PAUSABLE
	voice.bus = "Effects"
	voice.stream = STREAMS[key]
	voice.volume_db = GAINS[key]
	voice.max_distance = 400
	voice.attenuation = 1.2
	voice.set_meta("event",key)
	voice.set_meta("emitter",weakref(actor))
	voice.set_meta("age",0.0)
	voice.set_meta("limit",STEP_DURATION if key=="steps" else minf(voice.stream.get_length(),2.0) if key!="page" else voice.stream.get_length())
	add_child(voice)
	voice.global_position = actor.global_position if actor is Node2D else game.player.global_position
	voices.append(voice)
	voice.play(STARTS.get(key,0.0))
	events_played += 1
func clean_finished() -> void:
	for voice in voices.duplicate():
		if not is_instance_valid(voice) or not voice.playing:
			voices.erase(voice)
			if is_instance_valid(voice): voice.stream = null; voice.queue_free()
func stop_all() -> void:
	for voice in voices:
		if is_instance_valid(voice): voice.stop(); voice.stream = null; voice.queue_free()
	voices.clear()
func _physics_process(delta: float) -> void:
	if game.player.dead or not game.session_started:
		stop_all()
		return
	for voice in voices:
		if not is_instance_valid(voice): continue
		var emitter = voice.get_meta("emitter").get_ref()
		if not is_instance_valid(emitter) or ("dead" in emitter and emitter.dead):
			voice.stop()
			continue
		var age: float = voice.get_meta("age")+delta
		voice.set_meta("age",age)
		if age>=float(voice.get_meta("limit")): voice.stop()
	clean_finished()
	footsteps -= delta
	if game.player.get_real_velocity().length()>5 and game.player.state!=&"dodge" and footsteps<=0:
		play_event(game.player,"steps")
		footsteps = 0.32
	if game.player.get_real_velocity().length()<=5:
		for voice in voices:
			if voice.get_meta("event")=="steps": voice.stop()
