extends SceneTree
## Uses actual CombatWorld, SpriteFrames, pooled Nodes and AudioStreamPlayers.
## Headless verifies timing/state/resources; it does not certify perceived audio.

const T = CombatTypes.UnitType
const F = CombatTypes.Faction
var failures: Array[String] = []
var completed: Array[String] = []
var checks: int = 0
var metrics: Dictionary = {}
var profile: UnitAnimationSet
var bank: RtsAudioBank


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	profile = Stage4DemoAssets.animation_profile(0)
	bank = Stage4DemoAssets.audio_bank()
	var cases: Array[Callable] = [test_windup_and_marker, test_rate_changes_and_pause,
		test_stop_and_retarget, test_range_garrison_and_ownership, test_simultaneous_windup_deaths,
		test_animation_locomotion, test_animation_attack_and_death, test_profiles_and_directions,
		test_pool_reuse_and_bounds, test_music_distinct_threshold, test_music_viewport_and_permission,
		test_music_hysteresis_and_expiry, test_music_crossfade_pause_and_reverse,
		test_music_binding_and_shutdown, test_voice_router, test_voice_variations_and_rng,
		test_voice_throttling_and_subtitles, test_voice_missing_and_muted,
		test_asset_validation, test_threaded_asset_scope, test_mass_presentation_200,
		test_lab_scene_and_layout, test_f9_f6_scene_handoff]
	for test in cases:
		var before := failures.size()
		await test.call()
		if failures.size() == before:
			completed.append(test.get_method())
			print("PASS ", test.get_method())
		else:
			print("FAIL ", test.get_method())
	var report := {"passed": completed.size(), "total": cases.size(), "checks": checks,
		"failed_assertions": failures, "metrics": metrics, "engine": Engine.get_version_info()["string"]}
	DirAccess.make_dir_recursive_absolute("res://test-results")
	var file := FileAccess.open("res://test-results/stage4.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	# AudioServer releases stopped playback on its own mix boundary.
	await create_timer(0.12, true, false, true).timeout
	print("STAGE 4: %d / %d cases; %d checks; %d failures" % [completed.size(), cases.size(), checks, failures.size()])
	quit(0 if failures.is_empty() else 1)


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)


func near(actual: float, expected: float, message: String) -> void:
	check(absf(actual - expected) < 0.0001, "%s: got %.8f expected %.8f" % [message, actual, expected])


func battle() -> CombatWorld:
	var world := CombatWorld.new()
	world.add_player(0, 0, F.BUNDSCHUH, ResourceBank.new())
	world.add_player(1, 1, F.SWABIAN_LEAGUE, ResourceBank.new())
	return world


func pair(world: CombatWorld) -> Array[CombatUnit]:
	var a := world.spawn(T.PIKEMAN, 0, Vector2(2, 2))
	var b := world.spawn(T.ARMOURED_RITTER, 1, Vector2(2.8, 2))
	world.set_attack_timing(a.id, profile.impact_fraction)
	return [a, b]


func ticks(world: CombatWorld, count: int) -> void:
	for i in range(count):
		world.advance(0.05)


func test_windup_and_marker() -> void:
	var world := battle()
	var units := pair(world)
	var a := units[0]
	var b := units[1]
	var starts: Array[Dictionary] = []
	var hits: Array[Dictionary] = []
	world.attack_started.connect(func(event: Dictionary) -> void: starts.append(event))
	world.hit_resolved.connect(func(event: Dictionary) -> void: hits.append(event))
	world.command_attack(0, a.id, b.id)
	ticks(world, 1)
	check(starts.size() == 1 and hits.is_empty() and b.hp == b.max_hp, "Start event precedes damage while the weapon winds up")
	near(a.attack_impact_work, 1.125, "Frame 3/8 of the 3s Pike cycle")
	check(not world.set_attack_timing(a.id, 0.2), "Cannot retime an active swing")
	ticks(world, 22)
	check(hits.is_empty(), "No damage before the first 20Hz tick at/after marker")
	ticks(world, 1)
	check(hits.size() == 1 and b.hp == b.max_hp - 27 and hits[0]["tick"] == 24, "One damage at marker tick 24")
	check(hits[0]["serial"] == starts[0]["serial"], "Swing and damage share an event serial")
	ticks(world, 36)
	check(starts.size() == 1, "Wind-up is part of the existing attack period, not an extra cooldown")
	ticks(world, 1)
	check(starts.size() == 2, "Second cycle begins exactly 60 ticks after first start")
	check(not world.set_attack_timing(a.id, NAN) and not world.set_attack_timing(a.id, 1), "Invalid impact fractions rejected")


func test_rate_changes_and_pause() -> void:
	var world := battle()
	var units := pair(world)
	var a := units[0]
	var b := units[1]
	world.command_attack(0, a.id, b.id)
	ticks(world, 11) # 0.5 base-work seconds after start
	near(a.attack_elapsed_work, 0.5, "Wind-up advances in base work")
	world.paused = true
	ticks(world, 20)
	near(a.attack_elapsed_work, 0.5, "Pause freezes weapon phase and damage")
	world.paused = false
	a.modifiers.set_effect(&"test_rate", 1.15, 1.15)
	ticks(world, 10)
	check(b.hp == b.max_hp, "Rate change accelerates remaining wind-up without granting an immediate hit")
	ticks(world, 1)
	check(b.hp == b.max_hp - 27, "Buffed work crosses the marker exactly once")
	near(a.attack_elapsed_work, 1.1325, "Animation and backend share the changed rate")


func test_stop_and_retarget() -> void:
	var world := battle()
	var units := pair(world)
	var a := units[0]
	var b := units[1]
	var c := world.spawn(T.ARMOURED_RITTER, 1, Vector2(2, 2.8))
	world.command_attack(0, a.id, b.id)
	ticks(world, 10)
	world.command_stop(0, a.id)
	check(a.swing_cancelled and not a.swing_pending and a.recovery_work > 0, "Stop cancels pending damage but preserves cooldown")
	world.command_attack(0, a.id, b.id)
	ticks(world, 14)
	check(b.hp == b.max_hp and a.attack_serial == 1, "Stop/Attack spam cannot bypass wind-up or recovery")
	ticks(world, 37)
	check(a.attack_serial == 2 and a.swing_pending, "Next full swing starts only after recovery")
	world.command_attack(0, a.id, c.id)
	check(a.swing_cancelled and not a.swing_pending, "Retarget cancels the old in-flight strike")
	ticks(world, 24)
	check(b.hp == b.max_hp and c.hp == c.max_hp, "A cancelled swing cannot land on either target")


func test_range_garrison_and_ownership() -> void:
	for change in ["range", "garrison", "owner", "despawn"]:
		var world := battle()
		var units := pair(world)
		var a := units[0]
		var b := units[1]
		world.command_attack(0, a.id, b.id)
		ticks(world, 4)
		match change:
			"range": world.set_position(b.id, Vector2(30, 30))
			"garrison": world.set_on_field(b.id, false)
			"owner": world.transfer_unit(b.id, 0)
			"despawn": world.remove_unit(b.id)
		ticks(world, 25)
		check(b.hp == b.max_hp and not a.swing_pending, "Pending hit cancelled after target " + change)


func test_simultaneous_windup_deaths() -> void:
	var world := battle()
	var a := world.spawn(T.PIKEMAN, 0, Vector2.ZERO)
	var b := world.spawn(T.PIKEMAN, 1, Vector2(0.8, 0))
	for unit in [a, b]:
		unit.hp = 1
		world.set_attack_timing(unit.id, 0.25)
	world.command_attack(0, a.id, b.id)
	world.command_attack(1, b.id, a.id)
	ticks(world, 16)
	check(world.units.is_empty() and a.hp == 0 and b.hp == 0, "Equal-tick wind-up impacts preserve simultaneous lethal trades")


func test_animation_locomotion() -> void:
	var view := RtsUnitAnimator.new()
	root.add_child(view)
	view.activate(1, profile)
	check(view.state == RtsUnitAnimator.State.IDLE and not view.is_processing(), "Unit has no individual process callback")
	view.set_motion(Vector2(100, 100), Vector2(0.8, 0))
	view.advance(0.25)
	check(view.state == RtsUnitAnimator.State.RUN and view.frame_index == 2, "Authored Run rate at reference movement speed")
	view.activate(2, profile)
	view.set_motion(Vector2.ZERO, Vector2(1.6, 0))
	view.advance(0.25)
	check(view.frame_index == 4, "Double actual speed doubles Run phase")
	var before := view.frame_index
	view.advance(0)
	check(view.frame_index == before, "Paused host does not advance locomotion")
	view.set_motion(Vector2.ZERO, Vector2.ZERO)
	view.advance(0.05)
	check(view.state == RtsUnitAnimator.State.IDLE, "Blocked/stopped movement returns to Idle")
	near(view.get_child(0).modulate.a + view.get_child(1).modulate.a, 1, "Crossfade preserves summed opacity")
	view.free()


func test_animation_attack_and_death() -> void:
	var world := battle()
	var units := pair(world)
	var a := units[0]
	var view := RtsUnitAnimator.new()
	root.add_child(view)
	view.activate(a.id, profile, a)
	world.hit_resolved.connect(func(event: Dictionary) -> void: view.confirm_impact(event["serial"]))
	world.command_attack(0, a.id, units[1].id)
	ticks(world, 1)
	view.advance(0.05)
	check(view.state == RtsUnitAnimator.State.ATTACK and view.frame_index == 0, "Animator starts with authoritative cycle")
	ticks(world, 22)
	view.advance(0.05)
	check(view.frame_index < profile.impact_frame, "Weapon has not shown impact before damage")
	ticks(world, 1)
	view.advance(0.05)
	check(view.frame_index == profile.impact_frame, "Committed damage selects the authored contact frame")
	view.die()
	view.set_motion(Vector2.ZERO, Vector2(10, 0))
	view.advance(0.25)
	check(view.state == RtsUnitAnimator.State.DIE, "Die overrides Run and Attack")
	view.confirm_impact(999)
	for i in range(12): view.advance(0.25)
	check(view.death_finished and view.frame_index == 7, "Death is nonlooping and releases after corpse lifetime")
	view.free()


func test_profiles_and_directions() -> void:
	var broken := UnitAnimationSet.new()
	check(not broken.compile().is_empty(), "Missing assets rejected during loading")
	broken.frames = profile.frames
	broken.impact_frame = 999
	check(not broken.compile().is_empty() and broken.clips.is_empty(), "Invalid marker cannot reach runtime")
	var eight := UnitAnimationSet.new()
	eight.frames = profile.frames.duplicate(true)
	eight.directions = PackedStringArray(["e", "se", "s", "sw", "w", "nw", "n", "ne"])
	for state in ["idle", "run", "attack", "die"]:
		for direction in eight.directions:
			if direction != "s": eight.frames.duplicate_animation(state + "_s", state + "_" + direction)
	check(eight.compile().is_empty(), "Eight authored directions compile with matching markers")
	check(eight.key("run", Vector2.LEFT) == &"run_w" and eight.key("run", Vector2.UP) == &"run_n", "Facing resolves exact authored directions without mirroring")
	eight.frames.set_frame(&"attack_e", 0, eight.frames.get_frame_texture(&"attack_e", 0), 3.0)
	check(not eight.compile().is_empty(), "Unequal normalized impact markers across directions rejected")


func test_pool_reuse_and_bounds() -> void:
	var pool := UnitViewPool.new()
	root.add_child(pool)
	check(pool.prewarm(2) and not pool.prewarm(2), "Prewarm exactly once")
	var first := pool.acquire(1, profile)
	pool.acquire(2, profile)
	check(pool.acquire(3, profile) == null and pool.misses == 1, "Exhaustion drops cosmetic request without allocating")
	first.die()
	first.selected = true
	pool.release(1)
	var recycled := pool.acquire(4, profile)
	check(recycled == first and not recycled.death_finished and recycled.state == RtsUnitAnimator.State.IDLE and not recycled.selected, "Recycled view resets death, selection, identity and state")
	check(pool.get_child_count() == 2, "Pool node count is constant")
	recycled.die()
	check(pool.acquire(5, profile) == recycled and pool.corpse_reclaims == 1,
		"A new live view reclaims cosmetic corpse capacity before dropping a spawn")
	pool.clear()
	check(pool.active.is_empty() and recycled.profile == null and recycled.unit == null, "Release clears strong model/asset references")
	pool.free()


func crowd(count: int = 12) -> CombatWorld:
	var world := battle()
	for i in range(count): world.spawn(T.PIKEMAN, i % 2, Vector2(i, 2))
	return world


func known(world: CombatWorld) -> Dictionary:
	var ids: Dictionary = {}
	for id: int in world.units: ids[id] = true
	return ids


func observe_all(director: CombatMusicDirector, ids: Dictionary) -> void:
	for id: int in ids:
		director.observe({"attacker_id": id, "target_id": id}, ids)


func test_music_distinct_threshold() -> void:
	var world := crowd(12)
	var director := CombatMusicDirector.new()
	var ids := known(world)
	for i in range(100): director.observe({"attacker_id": 1, "target_id": 2}, ids)
	director.advance(0.25, world, Rect2(0, 0, 30, 10), ids)
	check(director.visible_fighters == 2 and not director.combat_active, "Hundreds of hit events between two soldiers are still two fighters")
	for id in range(3, 11): director.observe({"attacker_id": id}, ids)
	director.advance(0.25, world, Rect2(0, 0, 30, 10), ids)
	check(director.visible_fighters == 10 and not director.combat_active, "Exactly ten is below the requested trigger")
	director.observe({"attacker_id": 11}, ids)
	director.advance(0.25, world, Rect2(0, 0, 30, 10), ids)
	check(director.visible_fighters == 11 and director.combat_active, "Eleven distinct participants enables Combat")


func test_music_viewport_and_permission() -> void:
	var world := crowd()
	var director := CombatMusicDirector.new()
	var ids := known(world)
	var hidden := ids.duplicate()
	hidden.erase(12)
	director.observe({"attacker_id": 12}, hidden)
	observe_all(director, hidden)
	director.advance(0.25, world, Rect2(0, 0, 5, 10), ids)
	check(director.visible_fighters == 5 and not director.combat_active, "Off-camera fighting does not meet viewport threshold")
	director.advance(0.25, world, Rect2(0, 0, 30, 10), ids)
	check(director.visible_fighters == 11, "An event hidden when it occurred is not replayed when visibility expands")
	world.set_on_field(1, false)
	world.remove_unit(2)
	director.advance(0.25, world, Rect2(0, 0, 30, 10), ids)
	check(director.visible_fighters == 9, "Dead/despawned/garrisoned bodies cannot sustain music counts")


func test_music_hysteresis_and_expiry() -> void:
	var world := crowd()
	var director := CombatMusicDirector.new()
	var ids := known(world)
	observe_all(director, ids)
	director.advance(0.25, world, Rect2(0, 0, 30, 10), ids)
	for i in range(16): director.advance(0.25, world, Rect2(0, 0, 30, 10), ids)
	check(director.visible_fighters == 0 and director.combat_active, "Expired fights enter a quiet hold rather than an abrupt music exit")
	for i in range(18): director.advance(0.25, world, Rect2(0, 0, 30, 10), ids)
	check(director.combat_active, "Quiet hold is not shortened by render frames")
	director.advance(0.25, world, Rect2(0, 0, 30, 10), ids)
	check(not director.combat_active and director.polls == 36, "Five quiet seconds returns to Eco at 4Hz")
	director.reset()
	check(director.elapsed == 0 and director.visible_fighters == 0, "New match clears old ID sightings")


func manager() -> SoundManager:
	var sound := SoundManager.new()
	root.add_child(sound)
	check(sound.prepare(bank), "Validated bank prepares the real audio players")
	return sound


func test_music_crossfade_pause_and_reverse() -> void:
	var sound := manager()
	var world := crowd()
	var ids := known(world)
	sound.bind_combat(world)
	sound.set_permitted_units(ids)
	observe_all(sound.director, ids)
	for i in range(4): sound.advance(0.25, Rect2(0, 0, 30, 10))
	near(sound.mix, 0.5, "Two-second crossfade reaches halfway in one second")
	var stream := sound.music_player.stream as AudioStreamSynchronized
	var eco := db_to_linear(stream.get_sync_stream_volume(0))
	var combat := db_to_linear(stream.get_sync_stream_volume(1))
	near(eco * eco + combat * combat, 1.0, "Equal-power gains are continuous at the midpoint")
	sound.start_music()
	sound.set_game_paused(true)
	sound.advance(0.5, Rect2())
	near(sound.mix, 0.5, "Pause freezes fades")
	check(sound.music_player.stream_paused, "Pause reaches the actual audio player")
	sound.set_game_paused(false)
	sound.director.exit_hold_seconds = 0.25
	sound.advance(0.25, Rect2(100, 100, 1, 1))
	near(sound.mix, 0.375, "Reversal fades from current gain without restart or volume jump")
	check(sound.music_player.stream == stream and stream.stream_count == 2, "A crossfade reuses two synchronized stems")
	sound.shutdown()
	sound.free()


func test_music_binding_and_shutdown() -> void:
	var sound := manager()
	var first := battle()
	var units := pair(first)
	sound.bind_combat(first)
	sound.set_permitted_units(known(first))
	first.command_attack(0, units[0].id, units[1].id)
	ticks(first, 1)
	sound.advance(0.25, Rect2(0, 0, 10, 10))
	check(sound.director.visible_fighters == 2, "Real attack-start events feed the music director")
	var second := crowd()
	sound.bind_combat(second)
	check(not first.attack_started.is_connected(sound._on_combat) and second.attack_started.is_connected(sound._on_combat), "Rebinding disconnects the old world")
	var node_count := sound.get_child_count()
	sound.shutdown()
	check(sound.music_player.stream == null and not sound.prepared, "Shutdown releases music/voice resource ownership")
	check(sound.prepare(bank) and sound.get_child_count() == node_count, "Reprepare reuses the fixed voice pool without node growth")
	sound.free()


func test_voice_router() -> void:
	var world := crowd(12)
	var bus := UnitFeedbackBus.new()
	var events: Array[Dictionary] = []
	bus.cue_requested.connect(func(event: Dictionary) -> void: events.append(event))
	var all: Array[int] = []
	all.assign(world.units.keys())
	check(bus.combat_selection(world, 0, &"selected", all), "Mixed selection chooses an owned speaker")
	check(events.size() == 1 and events[0]["speaker_id"] == 1 and events[0]["faction"] == F.BUNDSCHUH, "One deterministic representative per group")
	check(not bus.combat_selection(world, 0, &"attack", [2]) and not bus.combat_selection(world, -1, &"move", all), "Enemy/mutineer selections cannot acknowledge player orders")
	world.set_on_field(1, false)
	bus.combat_selection(world, 0, &"move", all)
	check(events[1]["speaker_id"] == 3, "Garrisoned speaker excluded")
	var sim := RtsSimulation.new()
	var worker := sim.add_agent(Vector2i(1, 1), true)
	check(bus.villager_selection(sim, &"move", [worker.id]), "Stage 1 navigation can use the same feedback bus")
	check(not bus.villager_selection(sim, &"attack", [worker.id]), "Villagers do not speak Attack for a gathering order")


func test_voice_variations_and_rng() -> void:
	var selector := VoiceSelector.new()
	selector.configure(bank, 5)
	seed(100)
	var expected := randi()
	seed(100)
	for faction in [0, 1]:
		for action in [&"selected", &"move", &"attack"]:
			var recent: Array[StringName] = []
			for i in range(6):
				var line := selector.choose(faction, action)
				check(line != null and line.faction == faction and line.action == str(action) and line.id not in recent, "Correct faction/action with no repetition of previous two takes")
				recent.append(line.id)
				if recent.size() > 2: recent.pop_front()
	check(randi() == expected, "Voice variation does not perturb simulation RNG")
	check(selector.choose(3, &"attack") == null and selector.choose(0, &"gather") == null, "Missing voice sets fail gracefully")


func cue(sequence: int = 1, faction: int = 0, action: StringName = &"selected") -> Dictionary:
	return {"sequence": sequence, "faction": faction, "action": action, "speaker_id": 1}


func test_voice_throttling_and_subtitles() -> void:
	var sound := manager()
	var captions: Array[Dictionary] = []
	sound.subtitle_requested.connect(func(event: Dictionary) -> void: captions.append(event))
	check(sound.on_voice_request(cue()), "Voice request starts a prepared clip")
	check(sound.voice_players[0].playing and sound.voice_starts == 1, "An actual pooled AudioStreamPlayer plays the assigned stream")
	check(not sound.on_voice_request(cue()), "Duplicate event cannot replay the same voice")
	for i in range(2, 202): sound.on_voice_request(cue(i, 0, &"move"))
	check(sound.voice_starts == 1 and sound.voice_drops == 200 and captions.size() == 1, "Command spam is dropped without a queued chorus")
	sound.stop_voices()
	for i in range(4): sound.advance(0.25, Rect2())
	check(sound.on_voice_request(cue(202, 1, &"attack")), "Cooldown expiry permits a new faction-specific clip")
	check(captions[-1]["faction"] == 1 and not str(captions[-1]["subtitle_vi"]).is_empty(), "Caption includes faction, German draft and Vietnamese meaning")
	sound.free()


func test_voice_missing_and_muted() -> void:
	var missing := bank.duplicate(true) as RtsAudioBank
	for line in missing.voices: line.stream = null
	var sound := SoundManager.new()
	root.add_child(sound)
	sound.prepare(missing)
	var captions: Array[Dictionary] = []
	sound.subtitle_requested.connect(func(event: Dictionary) -> void: captions.append(event))
	check(sound.on_voice_request(cue()) and sound.voice_starts == 0, "Missing recording has subtitle-only fallback")
	check(captions.size() == 1 and not captions[0]["audio_available"], "Missing asset is explicit in feedback metadata")
	sound.free()
	sound = manager()
	var index := AudioServer.get_bus_index("Voices")
	var prior := AudioServer.is_bus_mute(index)
	AudioServer.set_bus_mute(index, true)
	check(sound.on_voice_request(cue()), "Muted voice still dispatches the caption path")
	AudioServer.set_bus_mute(index, prior)
	sound.set_game_paused(true)
	check(not sound.on_voice_request(cue(2)), "Paused scene does not acknowledge new gameplay commands")
	sound.free()


func test_asset_validation() -> void:
	check(bank.validate().is_empty() and bank.voices.size() == 18, "Diagnostic bank contains all six faction/action sets with three takes")
	var bad := bank.duplicate(true) as RtsAudioBank
	bad.eco_layer = null
	check(not bad.validate().is_empty(), "Incomplete music pair is rejected at preparation")
	bad = bank.duplicate(true) as RtsAudioBank
	(bad.combat_layer as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_DISABLED
	check(not bad.validate().is_empty(), "One-shot music cannot silently end adaptive playback")
	bad = bank.duplicate(true) as RtsAudioBank
	bad.voices[1].id = bad.voices[0].id
	check(not bad.validate().is_empty(), "Duplicate line IDs rejected before play")


func test_threaded_asset_scope() -> void:
	var scope := PresentationAssetScope.new()
	check(not scope.request("res://does_not_exist.tres"), "Missing asset fails without invoking a blocking load")
	check(scope.request("res://data/presentation/voice_casting_bank.tres"), "Threaded request accepted")
	check(not scope.release(), "Cannot pretend an in-flight engine request has been cancelled")
	for i in range(120):
		if scope.poll() != PresentationAssetScope.State.LOADING: break
		await process_frame
	check(scope.state == PresentationAssetScope.State.READY and scope.resource is RtsAudioBank, "Poll obtains the resource only after LOADED")
	check(scope.release() and scope.resource == null, "Scope releases its retained asset reference")


func test_mass_presentation_200() -> void:
	var pool := UnitViewPool.new()
	root.add_child(pool)
	pool.prewarm(200)
	for id in range(200):
		var view := pool.acquire(id, profile)
		view.set_motion(Vector2(id % 20, floori(id / 20.0)) * 32, Vector2(0.92, 0))
	var count := pool.get_child_count()
	var samples: Array[float] = []
	for tick in range(300):
		var start := Time.get_ticks_usec()
		pool.advance(0.05)
		samples.append((Time.get_ticks_usec() - start) / 1000.0)
	samples.sort()
	check(count == 200 and pool.get_child_count() == count and pool.active.size() == 200 and pool.misses == 0, "200 views retain a fixed Node budget during animation")
	check(pool.active[0].profile == pool.active[199].profile, "All units share the same compiled atlas/frame assets")
	metrics["presentation_200"] = {"views": 200, "sprite_nodes": 400, "samples": 300,
		"update_ms_p50": samples[150], "update_ms_p95": samples[285], "update_ms_max": samples[-1],
		"rendering": "excluded / headless", "cpu": OS.get_processor_name()}
	pool.free()


func test_lab_scene_and_layout() -> void:
	var scene := load("res://scenes/stage4_lab.tscn") as PackedScene
	var lab = scene.instantiate()
	root.add_child(lab)
	lab.set_physics_process(false)
	lab.set_process(false)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	for size in [Vector2i(1280, 720), Vector2i(1440, 900), Vector2i(1920, 1080)]:
		root.size = size
		await process_frame
		await process_frame
		var controls: Array[Control] = []
		collect_controls(lab, controls)
		var valid := true
		for control in controls:
			if control is Button or control is Label:
				var rect := control.get_global_rect()
				valid = valid and rect.position.x >= -1 and rect.position.y >= -1 and rect.end.x <= size.x + 1 and rect.end.y <= size.y + 1
		check(valid, "Lab controls fit " + str(size))
	lab.select_faction(1)
	lab.begin_combat()
	for i in range(50):
		lab._physics_process(0.05)
		lab._process(0.05)
	check(lab.world.attacks_resolved >= 12 and lab.sound.mix > 0.99, "Real lab scene resolves swing damage and reaches Combat music with twelve visible fighters")
	lab.preview_run()
	lab._process(0.1)
	check(lab.pool.active[1].state == RtsUnitAnimator.State.RUN, "Lab Move preview uses the same animator controller")
	lab.toggle_pause()
	var time: float = lab.world.seconds()
	lab._physics_process(0.25)
	near(lab.world.seconds(), time, "Lab pause freezes simulation and audio director")
	await lab.sound.shutdown_and_drain()
	lab.free()
	for i in range(8): await process_frame


func collect_controls(node: Node, output: Array[Control]) -> void:
	if node is Control: output.append(node)
	for child in node.get_children(): collect_controls(child, output)


func test_f9_f6_scene_handoff() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	main.seed_input.grab_focus()
	var key := InputEventKey.new()
	key.keycode = KEY_F9
	key.pressed = true
	Input.parse_input_event(key)
	for i in range(6): await process_frame
	var lab = current_scene
	check(lab != null and lab.get_script().resource_path.ends_with("stage4_lab.gd"), "F9 from focused seed opens the real lab scene without accessing a removed viewport")
	if lab == null or not lab.get_script().resource_path.ends_with("stage4_lab.gd"):
		return
	lab.set_process(false)
	lab.set_physics_process(false)
	await lab.sound.shutdown_and_drain()
	key = InputEventKey.new()
	key.keycode = KEY_F6
	key.pressed = true
	Input.parse_input_event(key)
	for i in range(6): await process_frame
	check(current_scene != null and current_scene.get_script().resource_path.ends_with("main.gd"), "F6 returns from lab to the actual sandbox scene")
	check(auto_accept_quit, "Lab restores normal window close behavior on leaving")
	current_scene.free()
	current_scene = null
