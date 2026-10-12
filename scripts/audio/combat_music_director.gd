class_name CombatMusicDirector
extends RefCounted
## Counts DISTINCT, recently fighting, living units inside the visible viewport.
## Caller supplies permitted/known IDs; camera visibility is not fog-of-war.
## Fixed 4Hz membership checks avoid a per-soldier/frame overlap scan.

var recent_seconds: float = 4.0
var exit_hold_seconds: float = 5.0
var enter_count: int = 11 # "more than 10", not >= 10
var exit_count: int = 6
var combat_active: bool = false
var visible_fighters: int = 0
var elapsed: float = 0.0
var polls: int = 0
var _recent: Dictionary = {} # unit ID -> last observed game second
var _poll_elapsed: float = 0.0
var _quiet_elapsed: float = 0.0


func observe(event: Dictionary, permitted_ids: Dictionary) -> void:
	for field in ["attacker_id", "target_id"]:
		var id := int(event.get(field, -1))
		if id >= 0 and permitted_ids.has(id):
			_recent[id] = elapsed


func advance(delta: float, world: CombatWorld, viewport_tiles: Rect2, permitted_ids: Dictionary) -> void:
	assert(is_finite(delta) and delta >= 0 and delta <= 0.5)
	elapsed += delta
	_poll_elapsed += delta
	if _poll_elapsed < 0.25 - 0.000001:
		return
	var interval := _poll_elapsed
	_poll_elapsed = 0.0
	polls += 1
	visible_fighters = 0
	for id: int in _recent.keys():
		var unit: CombatUnit = world.units.get(id) if world != null else null
		if elapsed - float(_recent[id]) > recent_seconds or unit == null or not unit.alive() or not unit.on_field:
			_recent.erase(id)
			continue
		if permitted_ids.has(id) and viewport_tiles.has_point(unit.position):
			visible_fighters += 1
	if visible_fighters >= enter_count:
		combat_active = true
		_quiet_elapsed = 0.0
	elif combat_active and visible_fighters <= exit_count:
		_quiet_elapsed += interval
		if _quiet_elapsed >= exit_hold_seconds - 0.000001:
			combat_active = false
			_quiet_elapsed = 0.0
	else:
		_quiet_elapsed = 0.0


func reset() -> void:
	_recent.clear()
	elapsed = 0.0
	_poll_elapsed = 0.0
	_quiet_elapsed = 0.0
	visible_fighters = 0
	combat_active = false
	polls = 0
