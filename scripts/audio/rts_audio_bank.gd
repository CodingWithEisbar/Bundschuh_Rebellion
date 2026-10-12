class_name RtsAudioBank
extends Resource
## Music stems must share tempo/key, full loop length and matching loop boundaries.
## Imported WAV/OGG/MP3 Resources are held once per level, not once per soldier.

@export var eco_layer: AudioStream
@export var combat_layer: AudioStream
@export var voices: Array[RtsVoiceLine] = []
@export var crossfade_seconds: float = 2.0
@export var voice_cooldown: float = 1.0
@export var diagnostic_audio: bool = false


func validate() -> Array[String]:
	var errors: Array[String] = []
	if eco_layer == null or combat_layer == null:
		errors.append("Both music stems are required.")
	elif eco_layer.get_length() <= 0 or absf(eco_layer.get_length() - combat_layer.get_length()) > 0.001:
		errors.append("Music stems must have the same positive duration.")
	elif not _full_loop(eco_layer) or not _full_loop(combat_layer):
		errors.append("Music must use WAV/OGG/MP3 looping over the full matching duration.")
	if not is_finite(crossfade_seconds) or crossfade_seconds < 0.1 or crossfade_seconds > 20 or not is_finite(voice_cooldown) or voice_cooldown < 0.1:
		errors.append("Invalid crossfade/cooldown tuning.")
	var ids: Dictionary = {}
	for line in voices:
		if line == null or line.id == &"" or ids.has(line.id):
			errors.append("Voice lines require unique nonempty IDs.")
			continue
		ids[line.id] = true
		if line.faction not in CombatTypes.Faction.values() or line.action not in ["selected", "move", "attack"]:
			errors.append("Invalid faction/action for voice " + str(line.id))
	return errors


static func _full_loop(stream: AudioStream) -> bool:
	if stream is AudioStreamWAV:
		return stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and stream.loop_begin == 0 \
			and absf(stream.loop_end / float(stream.mix_rate) - stream.get_length()) < 0.001
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		return stream.loop and is_zero_approx(stream.loop_offset)
	return false
