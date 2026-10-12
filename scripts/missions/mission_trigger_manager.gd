class_name MissionTriggerManager
extends RefCounted
## Event-fed LOS union + one central clock. No scan of guards or scene nodes.
## A detection is a FULL exposure episode, not each collider/physics callback.
## Re-entering before all guards lose sight and the meter drains cannot farm
## detections. Terminal results latch once; create a new model to retry.

signal changed(snapshot: Dictionary)
signal detection_confirmed(event: Dictionary)
signal mission_failed(event: Dictionary)
signal mission_completed(event: Dictionary)

enum State { ACTIVE, FAILED, COMPLETED }
var state: State = State.ACTIVE
var meter: float = 0.0
var detections: int = 0
var armed: bool = true
var paused: bool = false
var elapsed: float = 0.0
var _unseen_seconds: float = 0.0
var _config: StealthMissionConfig
var _guards: Dictionary = {} # stable guard ID -> {team, enabled}
var _visible: Dictionary = {} # set, not a callback count
var _busy: bool = false


func _init(config: StealthMissionConfig = null) -> void:
	_config = (config.duplicate(true) if config != null else StealthMissionConfig.new()) as StealthMissionConfig
	assert(_config.validate().is_empty(), "Invalid stealth mission configuration")


func protagonist_id() -> StringName:
	return _config.protagonist_id


func register_guard(id: StringName, team: int) -> bool:
	if _busy or state != State.ACTIVE or id == &"" or team < 0 or _guards.has(id):
		return false
	_guards[id] = {"team": team, "enabled": true}
	return true


func unregister_guard(id: StringName) -> bool:
	if _busy or not _guards.has(id):
		return false
	_guards.erase(id)
	_visible.erase(id)
	_notify_changed()
	return true


func set_guard_enabled(id: StringName, enabled: bool) -> bool:
	if _busy or state != State.ACTIVE or not _guards.has(id):
		return false
	_guards[id]["enabled"] = enabled
	if not enabled:
		_visible.erase(id)
	_notify_changed()
	return true


func report_los(guard_id: StringName, actor_id: StringName, visible: bool) -> bool:
	if _busy or state != State.ACTIVE or actor_id != _config.protagonist_id or not _guards.has(guard_id):
		return false
	var guard: Dictionary = _guards[guard_id]
	if int(guard["team"]) == _config.protagonist_team or not bool(guard["enabled"]):
		return false
	if visible:
		_visible[guard_id] = true
		_unseen_seconds = 0.0
	else:
		_visible.erase(guard_id)
	_notify_changed()
	return true


func snapshot() -> Dictionary:
	return {"state": state, "meter": meter, "detections": detections,
		"limit": _config.detection_limit, "armed": armed,
		"visible_guards": _visible.size(), "elapsed": elapsed,
		"protagonist_id": _config.protagonist_id}


func advance(delta: float) -> void:
	assert(is_finite(delta) and delta >= 0.0 and delta <= 0.25)
	assert(not _busy, "Mission advance is not reentrant; defer observer commands")
	if paused or state != State.ACTIVE or delta == 0.0:
		return
	_busy = true
	elapsed += delta
	var previous_meter := meter
	var previous_armed := armed
	var detected := false
	if not _visible.is_empty():
		_unseen_seconds = 0.0
		if armed:
			meter = minf(100.0, meter + 100.0 * delta / _config.exposure_seconds)
			if meter >= 100.0 - 0.000001:
				meter = 100.0
				armed = false
				detections += 1
				detected = true
				if detections >= _config.detection_limit:
					state = State.FAILED
	else:
		_unseen_seconds += delta
		meter = maxf(0.0, meter - _config.decay_per_second * delta)
		if meter <= 0.000001:
			meter = 0.0
			if _unseen_seconds >= _config.rearm_unseen_seconds - 0.000001:
				armed = true
	# Commit the entire transition BEFORE emitting. Subscribers queue mutations
	# for after advance(); callback order cannot cancel the third detection.
	if previous_meter != meter or previous_armed != armed or detected:
		changed.emit(snapshot())
	if detected:
		detection_confirmed.emit(snapshot())
		if state == State.FAILED:
			mission_failed.emit(snapshot())
	_busy = false


func complete() -> bool:
	if _busy or state != State.ACTIVE:
		return false
	state = State.COMPLETED
	_busy = true
	changed.emit(snapshot())
	mission_completed.emit(snapshot())
	_busy = false
	return true


func _notify_changed() -> void:
	_busy = true
	changed.emit(snapshot())
	_busy = false
