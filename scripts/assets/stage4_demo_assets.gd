class_name Stage4DemoAssets
extends RefCounted
## Original code-native diagnostic assets, created ONCE on the loading screen.
## These tones are not lute/brass/chorale recordings or spoken historical German.
## Replace the bank/profile with imported production Resources without changing
## combat, animator, music logic or command routing.

const BUND_ATLAS = preload("res://assets/placeholder/bundschuh_unit.svg")
const LEAGUE_ATLAS = preload("res://assets/placeholder/league_unit.svg")
const CASTING = preload("res://data/presentation/voice_casting_bank.tres")
const RATE := 22050


static func animation_profile(faction: int) -> UnitAnimationSet:
	var atlas: Texture2D = BUND_ATLAS if faction == CombatTypes.Faction.BUNDSCHUH else LEAGUE_ATLAS
	var profile := UnitAnimationSet.new()
	profile.frames = SpriteFrames.new()
	profile.frames.remove_animation(&"default")
	for row in range(4):
		var name := StringName(["idle_s", "run_s", "attack_s", "die_s"][row])
		profile.frames.add_animation(name)
		profile.frames.set_animation_speed(name, 6 if row == 0 else 8)
		profile.frames.set_animation_loop(name, row < 2)
		for frame in range(8):
			var texture := AtlasTexture.new()
			texture.atlas = atlas
			texture.region = Rect2(frame * 64, row * 64, 64, 64)
			profile.frames.add_frame(name, texture)
	assert(profile.compile().is_empty())
	return profile


static func audio_bank() -> RtsAudioBank:
	var bank := CASTING.duplicate(true) as RtsAudioBank
	bank.diagnostic_audio = true
	bank.eco_layer = _music(false)
	bank.combat_layer = _music(true)
	for line in bank.voices:
		line.stream = _tone(300.0 + line.faction * 180.0 + (line.action.hash() % 5) * 32.0 + (str(line.id).unicode_at(str(line.id).length() - 1) - 48) * 18.0)
		line.provenance = "Original synthesized diagnostic tone; NOT a VO recording"
	return bank


static func _music(combat: bool) -> AudioStreamWAV:
	var count := RATE * 8
	var data := PackedByteArray()
	data.resize(count * 2)
	var notes := [146.832, 174.614, 195.998, 220.0, 195.998, 174.614, 130.813, 146.832]
	for i in range(count):
		var t := i / float(RATE)
		var beat := fmod(t, 0.5 if combat else 1.0)
		var frequency: float = notes[int(t)]
		var envelope := exp(-beat * (12.0 if combat else 5.0))
		var sample := sin(TAU * frequency * t) * envelope * 0.13
		if combat:
			sample += sin(TAU * (65.0 * beat + 15.0 * (1.0 - exp(-beat * 15.0)))) * exp(-beat * 18.0) * 0.13
		else:
			sample += sin(TAU * 73.416 * t) * 0.025
		# Short boundary fades prevent discontinuities in this diagnostic loop.
		sample *= minf(1.0, minf(t, 8.0 - t) / 0.02)
		data.encode_s16(i * 2, roundi(sample * 32767))
	return _wave(data, true)


static func _tone(frequency: float) -> AudioStreamWAV:
	var count := int(RATE * 0.22)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t := i / float(RATE)
		var envelope := sin(PI * i / float(count))
		data.encode_s16(i * 2, roundi(sin(TAU * frequency * t) * envelope * 0.14 * 32767))
	return _wave(data, false)


static func _wave(data: PackedByteArray, looped: bool) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if looped else AudioStreamWAV.LOOP_DISABLED
	stream.loop_begin = 0
	stream.loop_end = data.size() / 2
	return stream
