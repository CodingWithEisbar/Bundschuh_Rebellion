class_name RtsUnitAnimator
extends Node2D
## Pooled presentation only. A single host calls advance(); no per-unit process,
## timers, resource loading, animation-finished damage or gameplay ownership.
## Two fixed Sprite2Ds crossfade poses; frame textures are shared atlas regions.

enum State { IDLE, RUN, ATTACK, DIE }
const NAMES := ["idle", "run", "attack", "die"]
var state: State = State.IDLE
var entity_id: int = -1
var profile: UnitAnimationSet
var unit: CombatUnit
var facing := Vector2.RIGHT
var actual_speed: float = 0.0
var frame_index: int = 0
var death_finished: bool = false
var selected: bool = false
var _current := Sprite2D.new()
var _previous := Sprite2D.new()
var _phase: float = 0.0
var _blend: float = 1.0
var _death_elapsed: float = 0.0
var _dead: bool = false
var _clip: StringName
var _last_serial: int = 0
var _impact_serial: int = 0
var _impact_hold: bool = false


func _init() -> void:
	add_child(_previous)
	add_child(_current)
	_current.centered = false
	_previous.centered = false
	set_process(false)
	set_physics_process(false)


func activate(id: int, assets: UnitAnimationSet, combat_unit: CombatUnit = null) -> void:
	assert(not assets.clips.is_empty(), "Compile the shared profile during loading")
	entity_id = id
	profile = assets
	unit = combat_unit
	state = State.IDLE
	_phase = 0.0
	_blend = 1.0
	_death_elapsed = 0.0
	_dead = false
	death_finished = false
	selected = false
	actual_speed = 0.0
	facing = Vector2.RIGHT
	_last_serial = 0
	_impact_serial = 0
	_impact_hold = false
	_clip = &""
	_current.position = -profile.pivot
	_previous.position = -profile.pivot
	_current.texture = null
	_previous.texture = null
	_previous.modulate.a = 0.0
	_current.modulate.a = 1.0
	modulate = Color.WHITE
	visible = true
	advance(0.0)


func release() -> void:
	visible = false
	entity_id = -1
	profile = null
	unit = null
	_current.texture = null
	_previous.texture = null
	selected = false
	queue_redraw()


func set_motion(world_position: Vector2, velocity_in_tiles: Vector2) -> void:
	position = world_position
	actual_speed = velocity_in_tiles.length()
	if actual_speed > 0.001:
		facing = velocity_in_tiles.normalized()


func confirm_impact(serial: int) -> void:
	# Cosmetic marker only. Damage is already committed by CombatWorld.
	# Preserve one render of the impact pose if a host catch-up spans frames.
	if not _dead and serial > _impact_serial:
		_impact_serial = serial
		_impact_hold = true


func die() -> void:
	if not _dead:
		_dead = true
		_death_elapsed = 0.0
		_impact_hold = false


func is_dying() -> bool:
	return _dead


func advance(game_delta: float) -> void:
	if profile == null or entity_id < 0:
		return
	assert(is_finite(game_delta) and game_delta >= 0.0 and game_delta <= 0.5)
	if unit != null and not unit.alive():
		die()
	var next: State = State.IDLE
	if _dead:
		next = State.DIE
	elif unit != null and not unit.swing_cancelled and unit.attack_serial > 0 and unit.attack_elapsed_work < unit.attack_cycle_work:
		next = State.ATTACK
	elif actual_speed > 0.001:
		next = State.RUN
	var next_clip := profile.key(NAMES[next], facing)
	var new_swing := unit != null and unit.attack_serial != _last_serial
	if next != state or next_clip != _clip or (next == State.ATTACK and new_swing):
		_previous.texture = _current.texture
		_previous.modulate = _current.modulate
		_blend = 0.0 if _previous.texture != null and profile.blend_seconds > 0 else 1.0
		# Preserve run phase when only direction changes, to avoid foot resets.
		if next != state or (next == State.ATTACK and new_swing):
			_phase = 0.0
		state = next
		_clip = next_clip
	if unit != null:
		_last_serial = unit.attack_serial
	var clip: Dictionary = profile.clips[_clip]
	var duration: float = clip["duration"]
	match state:
		State.IDLE:
			_phase = fmod(_phase + game_delta, duration)
		State.RUN:
			# Actual displacement speed avoids moonwalking in blocked traffic.
			# Navigation already incorporates unit.movement_speed()/aura stats.
			_phase = fmod(_phase + game_delta * actual_speed / profile.reference_run_speed, duration)
		State.ATTACK:
			_phase = duration * clampf(unit.attack_elapsed_work / unit.attack_cycle_work, 0.0, 1.0)
		State.DIE:
			_death_elapsed += game_delta
			_phase = minf(_death_elapsed, duration)
			death_finished = _death_elapsed >= duration + profile.corpse_seconds
	frame_index = profile.frame_index(_clip, _phase)
	if _impact_hold and state == State.ATTACK and _impact_serial == _last_serial:
		frame_index = profile.impact_frame
		_impact_hold = false
		_blend = 1.0 # Weapon contact is unambiguous at the committed hit.
	_current.texture = clip["textures"][frame_index]
	if profile.blend_seconds > 0:
		_blend = minf(1.0, _blend + game_delta / profile.blend_seconds)
	_current.modulate.a = _blend
	_previous.modulate.a = 1.0 - _blend
	queue_redraw()


func _draw() -> void:
	if selected and not _dead:
		draw_arc(Vector2.ZERO, 10, 0, TAU, 24, Color("#c2e4ba"), 1.5)
