extends Node2D
## Asset integration harness. Fixed duel positions isolate timing/mix tests from
## military pathfinding. Run is an explicitly labeled in-place animation preview.

const SCALE := 64.0
var world: CombatWorld
var pool := UnitViewPool.new()
var sound := SoundManager.new()
var feedback := UnitFeedbackBus.new()
var profiles: Dictionary = {}
var selected_owner: int = 0
var running: bool = false
var paused: bool = false
var boosted: bool = false
var accumulator: float = 0.0
var status: Label
var caption: Label
var _pairs: Array[Vector2i] = []
var _caption_left: float = 0.0
var _quitting: bool = false


func _ready() -> void:
	get_tree().auto_accept_quit = false
	profiles[0] = Stage4DemoAssets.animation_profile(0)
	profiles[1] = Stage4DemoAssets.animation_profile(1)
	add_child(pool)
	pool.prewarm(200)
	add_child(sound)
	assert(sound.prepare(Stage4DemoAssets.audio_bank()))
	feedback.cue_requested.connect(sound.on_voice_request)
	sound.subtitle_requested.connect(_on_subtitle)
	_build_hud()
	reset_arena()
	sound.start_music()


func reset_arena() -> void:
	running = false
	paused = false
	boosted = false
	accumulator = 0.0
	pool.clear()
	sound.reset_feedback()
	sound.set_game_paused(false)
	world = CombatWorld.new()
	world.add_player(0, 0, CombatTypes.Faction.BUNDSCHUH, ResourceBank.new())
	world.add_player(1, 1, CombatTypes.Faction.SWABIAN_LEAGUE, ResourceBank.new())
	sound.bind_combat(world)
	world.hit_resolved.connect(_on_hit)
	world.unit_died.connect(_on_death)
	_pairs.clear()
	for i in range(6):
		var point := Vector2(2.5 + (i % 3) * 5.5, 4.3 + floori(i / 3.0) * 3.4)
		var a := world.spawn(CombatTypes.UnitType.PIKEMAN, 0, point)
		var b := world.spawn(CombatTypes.UnitType.LANDSKNECHT, 1, point + Vector2(0.8, 0))
		_pairs.append(Vector2i(a.id, b.id))
		for unit in [a, b]:
			var profile: UnitAnimationSet = profiles[unit.faction]
			world.set_attack_timing(unit.id, profile.impact_fraction)
			pool.acquire(unit.id, profile, unit)
	sound.set_permitted_units(_all_known())
	caption.text = "Diagnostic tones + draft German captions. Replace with recorded voices and music."
	_caption_left = 0.0
	queue_redraw()


func _all_known() -> Dictionary:
	var result: Dictionary = {}
	for id: int in world.units:
		result[id] = true # This lab has no hidden/fogged actors.
	return result


func selected_ids() -> Array[int]:
	var ids: Array[int] = []
	for unit: CombatUnit in world.units.values():
		if unit.owner_id == selected_owner:
			ids.append(unit.id)
	return ids


func select_faction(owner: int) -> void:
	selected_owner = owner
	feedback.combat_selection(world, owner, &"selected", selected_ids())


func preview_run() -> void:
	if paused:
		return
	running = true
	for unit: CombatUnit in world.units.values():
		world.command_stop(unit.owner_id, unit.id)
	feedback.combat_selection(world, selected_owner, &"move", selected_ids())


func begin_combat() -> void:
	if paused:
		return
	running = false
	var accepted: Array[int] = []
	for pair in _pairs:
		if not world.units.has(pair.x) or not world.units.has(pair.y):
			continue
		for id in [pair.x, pair.y]:
			var unit: CombatUnit = world.units[id]
			if world.command_attack(unit.owner_id, id, pair.y if id == pair.x else pair.x) and unit.owner_id == selected_owner:
				accepted.append(id)
	feedback.combat_selection(world, selected_owner, &"attack", accepted)


func stop_combat() -> void:
	running = false
	for unit: CombatUnit in world.units.values():
		world.command_stop(unit.owner_id, unit.id)


func preview_die() -> void:
	if paused:
		return
	for id in selected_ids():
		# Explicit cosmetic/scenario preview. Real combat deaths use the same
		# visual state after CombatWorld removes the dead gameplay entity.
		var view: RtsUnitAnimator = pool.active.get(id)
		if view != null:
			view.die()
		world.remove_unit(id)


func toggle_boost() -> void:
	boosted = not boosted
	for unit: CombatUnit in world.units.values():
		if boosted:
			unit.modifiers.set_effect(&"lab_speed", 1.15, 1.15)
		else:
			unit.modifiers.remove_effect(&"lab_speed")


func toggle_pause() -> void:
	paused = not paused
	world.paused = paused
	sound.set_game_paused(paused)


func _physics_process(delta: float) -> void:
	if paused:
		return
	accumulator = minf(accumulator + delta, 0.25)
	while accumulator >= CombatWorld.FIXED_DT:
		world.advance(CombatWorld.FIXED_DT)
		sound.advance(CombatWorld.FIXED_DT, visible_battlefield())
		accumulator -= CombatWorld.FIXED_DT


func visible_battlefield() -> Rect2:
	# Exclude the opaque header/footer, not just the full application window.
	var viewport := get_viewport_rect()
	return Rect2(Vector2(0, 185) / SCALE, Vector2(viewport.size.x, maxf(0, viewport.size.y - 265)) / SCALE)


func _process(delta: float) -> void:
	var game_delta := 0.0 if paused else minf(delta, 0.25)
	for view: RtsUnitAnimator in pool.active.values():
		var unit := view.unit
		if unit == null:
			continue
		var velocity := Vector2.RIGHT * unit.movement_speed() if running and unit.on_field else Vector2.ZERO
		view.set_motion(unit.position * SCALE, velocity)
		view.selected = unit.owner_id == selected_owner
	pool.advance(game_delta)
	status.text = "%s  |  Fighting in view: %d  |  Combat mix: %d%%  |  Views: %d/%d  |  Rate: %s" % [
		"PAUSED" if paused else ("RUN PREVIEW (in place)" if running else "LIVE DUELS"),
		sound.director.visible_fighters, roundi(sound.mix * 100), pool.active.size(), pool.capacity,
		"1.15x" if boosted else "1.00x"]
	if _caption_left > 0:
		_caption_left -= game_delta
		if _caption_left <= 0:
			caption.text = "Diagnostic audio; no actor recordings included. F6 returns to the RTS sandbox."
	queue_redraw()


func _on_hit(event: Dictionary) -> void:
	var view: RtsUnitAnimator = pool.active.get(int(event["attacker_id"]))
	if view != null:
		view.confirm_impact(int(event["serial"]))


func _on_death(event: Dictionary) -> void:
	var view: RtsUnitAnimator = pool.active.get(int(event["unit_id"]))
	if view != null:
		view.die()


func _on_subtitle(event: Dictionary) -> void:
	caption.text = "%s: %s  —  %s" % ["Bundschuh" if event["faction"] == 0 else "League", event["text_de"], event["subtitle_vi"]]
	_caption_left = 3.0


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			toggle_pause()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F6:
			get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")
			get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and not _quitting:
		_quitting = true
		set_process(false)
		set_physics_process(false)
		await sound.shutdown_and_drain()
		get_tree().quit()


func _exit_tree() -> void:
	get_tree().auto_accept_quit = true


func _draw() -> void:
	draw_rect(get_viewport_rect(), Color("#26382f"))
	for i in range(6):
		var point := Vector2(2.5 + (i % 3) * 5.5, 4.3 + floori(i / 3.0) * 3.4) * SCALE
		draw_line(point + Vector2(-40, 8), point + Vector2(105, 8), Color("#58705a"), 1)
	for view: RtsUnitAnimator in pool.active.values():
		var unit := view.unit
		if unit != null and unit.alive() and unit.on_field:
			var bar := Rect2(view.position + Vector2(-18, -65), Vector2(36, 4))
			draw_rect(bar, Color("#1d2325"))
			bar.size.x *= float(unit.hp) / unit.max_hp
			draw_rect(bar, Color("#bad5a0"))


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(20, 15)
	panel.size = Vector2(1120, 160)
	layer.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var title := Label.new()
	title.text = "BUNDSCHUH / STAGE 4 — ANIMATION & AUDIO LAB"
	title.add_theme_font_size_override("font_size", 22)
	column.add_child(title)
	var controls := HBoxContainer.new()
	column.add_child(controls)
	for item in [["Select Bundschuh", func() -> void: select_faction(0)], ["Select League", func() -> void: select_faction(1)],
		["Preview Run", preview_run], ["Attack", begin_combat], ["Idle", stop_combat], ["Preview Die", preview_die],
		["Rate +15%", toggle_boost], ["Reset", reset_arena]]:
		var button := Button.new()
		button.text = item[0]
		button.pressed.connect(item[1])
		controls.add_child(button)
	var audio := HBoxContainer.new()
	column.add_child(audio)
	for bus in ["Music", "Voices"]:
		var toggle := CheckButton.new()
		toggle.text = bus
		toggle.button_pressed = not AudioServer.is_bus_mute(AudioServer.get_bus_index(bus))
		toggle.toggled.connect(func(enabled: bool) -> void: AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), not enabled))
		audio.add_child(toggle)
	var pause := Button.new()
	pause.text = "Pause [Space]"
	pause.pressed.connect(toggle_pause)
	audio.add_child(pause)
	var back := Button.new()
	back.text = "RTS sandbox [F6]"
	back.pressed.connect(func() -> void: get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn"))
	audio.add_child(back)
	status = Label.new()
	column.add_child(status)
	caption = Label.new()
	caption.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	caption.offset_top = -64
	caption.offset_left = 24
	caption.offset_right = -24
	caption.add_theme_font_size_override("font_size", 18)
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layer.add_child(caption)
