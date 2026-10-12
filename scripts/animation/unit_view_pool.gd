class_name UnitViewPool
extends Node2D
## Fixed capacity, prewarmed before play. Corpses consume cosmetic slots until
## released; exhaustion returns null rather than allocating during a battle.

var capacity: int = 0
var active: Dictionary = {}
var _free: Array[RtsUnitAnimator] = []
var acquisitions: int = 0
var misses: int = 0
var corpse_reclaims: int = 0


func prewarm(count: int = 200) -> bool:
	if capacity != 0 or count < 1 or count > 256:
		return false
	capacity = count
	for i in range(count):
		var view := RtsUnitAnimator.new()
		add_child(view)
		view.release()
		_free.append(view)
	return true


func acquire(id: int, profile: UnitAnimationSet, unit: CombatUnit = null) -> RtsUnitAnimator:
	if id < 0 or profile == null or profile.clips.is_empty() or active.has(id):
		return null
	if _free.is_empty():
		# A reinforcement gets priority over a cosmetic corpse. Gameplay death
		# already removed occupancy; do not leave a live unit invisible for 3s.
		for old_id: int in active:
			if active[old_id].is_dying():
				release(old_id)
				corpse_reclaims += 1
				break
	if _free.is_empty():
		misses += 1
		return null
	var view := _free.pop_back() as RtsUnitAnimator
	view.activate(id, profile, unit)
	active[id] = view
	acquisitions += 1
	return view


func release(id: int) -> void:
	var view: RtsUnitAnimator = active.get(id)
	if view != null:
		active.erase(id)
		view.release()
		_free.append(view)


func clear() -> void:
	for id: int in active.keys():
		release(id)


func advance(game_delta: float) -> void:
	for id: int in active.keys():
		var view: RtsUnitAnimator = active[id]
		view.advance(game_delta)
		if view.death_finished:
			release(id)
