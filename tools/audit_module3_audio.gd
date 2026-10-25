extends SceneTree
## Offline technical audit with the engine MP3 decoder. Does not claim human audition.
const Audio = preload("res://scripts/session_audio.gd")
const Settings = preload("res://scripts/session_settings.gd")
func _initialize() -> void:
	var rows: Array[Dictionary] = []
	var failures := 0
	for key in Audio.STREAMS:
		var stream: AudioStream = Audio.STREAMS[key]
		var playback := stream.instantiate_playback()
		playback.start()
		var rate := AudioServer.get_mix_rate()
		var duration: float = Audio.STEP_DURATION if key=="steps" else minf(stream.get_length(),2.0) if key!="page" else stream.get_length()
		var event_start: float = Audio.STARTS.get(key,0.0)
		var count := ceili(stream.get_length()*rate)
		var peak := 0.0
		var energy := 0.0
		var nonfinite := 0
		var clipped := 0
		var used := 0
		var event_peak := 0.0
		var window_peaks: Array[float] = []
		while used<count:
			var frames := playback.mix_audio(1.0,mini(4096,count-used))
			if frames.is_empty(): break
			for value in frames:
				if not is_finite(value.x) or not is_finite(value.y): nonfinite += 1
				var amplitude := maxf(absf(value.x),absf(value.y))
				peak = maxf(peak,amplitude)
				var window := int(used/(rate*0.1))
				if window>=window_peaks.size(): window_peaks.append(0.0)
				window_peaks[window] = maxf(window_peaks[window],amplitude)
				if used>=event_start*rate and used<(event_start+duration)*rate: event_peak = maxf(event_peak,amplitude)
				if amplitude>=1: clipped += 1
				energy += (value.x*value.x+value.y*value.y)*0.5
				used += 1
		playback.stop()
		# MP3 duration is a floating-point value; ceil can differ by one decoded frame.
		if peak<=0 or nonfinite>0 or used<count-1: failures += 1
		if key=="steps" and event_peak<peak*0.5: failures += 1
		var gain: float = db_to_linear(Audio.GAINS[key])*Settings.DEFAULTS.master*Settings.DEFAULTS.effects
		rows.append({"event":key,"source_peak":peak,"source_rms":sqrt(energy/maxi(used,1)),"source_frames_at_or_above_full_scale":clipped,"nonfinite_frames":nonfinite,"decoded_frames":used,"expected_frames_ceil":count,"sample_rate":rate,"source_peak_per_100ms":window_peaks,"event_duration_seconds":duration,"event_peak_default_gain":event_peak*gain,"eight_identical_voices_conservative_peak_bound":event_peak*gain*8,"audition":"human approval pending; numeric audit only"})
	var file := FileAccess.open("res://docs/atlas/evidencias/16_audio_audit.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"decoder":"Godot AudioStreamPlayback.mix_audio","rows":rows,"failures":failures,"note":"Bound assumes aligned identical peaks, excludes spatial attenuation. Not a measured live mix or subjective quality assessment."},"  "))
	print("ATLAS_AUDIO_AUDIT streams=",rows.size()," failures=",failures)
	quit(0 if failures==0 else 1)
