class_name SoundManager
extends Node
## One host clock drives music logic, fades and VO throttling. AudioServer owns
## actual playback. All nodes/streams are prepared BEFORE play; no load/instantiate
## on command or hit. Full voice pools drop requests, never queue a stale speech.

signal subtitle_requested(event: Dictionary)
signal voice_started(event: Dictionary)
var director := CombatMusicDirector.new()
var music_player := AudioStreamPlayer.new()
var voice_players: Array[AudioStreamPlayer] = []
var mix: float = 0.0
var voice_starts: int = 0
var voice_drops: int = 0
var prepared: bool = false
var paused: bool = false
var _music: AudioStreamSynchronized
var _bank: RtsAudioBank
var _selector := VoiceSelector.new()
var _combat: CombatWorld
var _permitted: Dictionary = {}
var _clock: float = 0.0
var _next_voice_at: float = 0.0
var _last_sequence: int = 0
var _duck: float = 0.0


func _init() -> void:
	set_process(false)
	set_physics_process(false)
	add_child(music_player)
	music_player.bus = &"Music"


func prepare(bank: RtsAudioBank, pool_size: int = 2, seed_value: int = 1524) -> bool:
	if prepared or bank == null or not bank.validate().is_empty() or pool_size < 1 or pool_size > 8:
		return false
	if not voice_players.is_empty() and voice_players.size() != pool_size:
		return false # A warmed pool has fixed capacity throughout its lifetime.
	_bank = bank
	_selector.configure(bank, seed_value)
	_music = AudioStreamSynchronized.new() # Mutable mix instance, shared stems.
	_music.stream_count = 2
	_music.set_sync_stream(0, bank.eco_layer)
	_music.set_sync_stream(1, bank.combat_layer)
	_music.set_sync_stream_volume(0, 0.0)
	_music.set_sync_stream_volume(1, -80.0)
	music_player.stream = _music
	music_player.volume_db = -12.0
	for i in range(voice_players.size(), pool_size):
		var player := AudioStreamPlayer.new()
		player.bus = &"Voices"
		player.max_polyphony = 1
		add_child(player)
		player.finished.connect(_on_voice_finished.bind(i))
		voice_players.append(player)
	prepared = true
	return true


func start_music() -> void:
	if prepared and not music_player.playing:
		music_player.play()
		music_player.stream_paused = paused


func bind_combat(world: CombatWorld) -> void:
	if _combat != null:
		_combat.attack_started.disconnect(_on_combat)
		_combat.hit_resolved.disconnect(_on_combat)
	_combat = world
	director.reset()
	_permitted.clear()
	if _combat != null:
		_combat.attack_started.connect(_on_combat)
		_combat.hit_resolved.connect(_on_combat)


func set_permitted_units(ids: Dictionary) -> void:
	_permitted = ids # Host provides a read-only visibility snapshot.


func _on_combat(event: Dictionary) -> void:
	director.observe(event, _permitted)


func set_game_paused(value: bool) -> void:
	paused = value
	music_player.stream_paused = value
	for player in voice_players:
		player.stream_paused = value


func advance(game_delta: float, viewport_tiles: Rect2) -> void:
	assert(is_finite(game_delta) and game_delta >= 0 and game_delta <= 0.5)
	if not prepared or paused:
		return
	_clock += game_delta
	director.advance(game_delta, _combat, viewport_tiles, _permitted)
	mix = move_toward(mix, 1.0 if director.combat_active else 0.0, game_delta / _bank.crossfade_seconds)
	# Equal-power crossfade: cos² + sin² = 1. Both stems run continuously and
	# AudioStreamSynchronized starts them together, so changes never restart them.
	_music.set_sync_stream_volume(0, _gain_db(cos(mix * PI * 0.5)))
	_music.set_sync_stream_volume(1, _gain_db(sin(mix * PI * 0.5)))
	var speaking := false
	for player in voice_players:
		speaking = speaking or player.playing
	_duck = move_toward(_duck, 3.0 if speaking else 0.0, game_delta * 12.0)
	music_player.volume_db = -12.0 - _duck


func on_voice_request(event: Dictionary) -> bool:
	if not prepared or paused or int(event.get("sequence", 0)) <= _last_sequence:
		return false
	_last_sequence = int(event["sequence"])
	if _clock < _next_voice_at:
		voice_drops += 1
		return false
	var available: AudioStreamPlayer = null
	for player in voice_players:
		# One group acknowledgement at a time. No 200-soldier chorus or backlog.
		if player.playing:
			voice_drops += 1
			return false
		if available == null:
			available = player
	var line := _selector.choose(int(event.get("faction", -1)), StringName(event.get("action", "")))
	if line == null or available == null:
		return false
	_next_voice_at = _clock + _bank.voice_cooldown
	var payload := event.duplicate()
	payload["line_id"] = line.id
	payload["text_de"] = line.text_de
	payload["subtitle_vi"] = line.subtitle_vi
	payload["audio_available"] = line.stream != null
	payload["diagnostic_audio"] = _bank.diagnostic_audio
	subtitle_requested.emit(payload.duplicate())
	if line.stream == null:
		return true # Text fallback, no fake pronunciation or blocking disk access.
	available.stream = line.stream
	available.volume_db = -4.0
	available.play()
	voice_starts += 1
	voice_started.emit(payload)
	return true


func stop_voices() -> void:
	for player in voice_players:
		player.stop()
		player.stream = null


func reset_feedback() -> void:
	stop_voices()
	_next_voice_at = 0.0
	_last_sequence = 0
	_clock = 0.0


func shutdown() -> void:
	bind_combat(null)
	stop_voices()
	music_player.stop()
	music_player.stream = null
	_music = null
	_bank = null
	_selector = VoiceSelector.new()
	prepared = false
	mix = 0.0
	_duck = 0.0
	reset_feedback()


func _exit_tree() -> void:
	shutdown()


func shutdown_and_drain() -> void:
	## Use for an orderly application quit/test runner. AudioServer disposes
	## stopped playbacks on its mix thread, not at the Node.free() instruction.
	if is_inside_tree():
		# Let play() requests from this same scene callback reach the server
		# before stop(). Immediate play+quit can retain pending playback in 4.5.
		await get_tree().process_frame
	shutdown()
	if is_inside_tree():
		await get_tree().create_timer(0.12, true, false, true).timeout


func _on_voice_finished(index: int) -> void:
	voice_players[index].stream = null


static func _gain_db(gain: float) -> float:
	return linear_to_db(maxf(gain, 0.0001))
