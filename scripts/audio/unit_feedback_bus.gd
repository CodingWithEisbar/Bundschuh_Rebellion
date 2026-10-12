class_name UnitFeedbackBus
extends RefCounted
## One acknowledgement per accepted group interaction. This is presentation,
## never a second command executor. Host calls only after validating the order.

signal cue_requested(event: Dictionary)
var sequence: int = 0


func combat_selection(world: CombatWorld, owner: int, action: StringName, ids: Array[int]) -> bool:
	if world == null or owner < 0 or action not in [&"selected", &"move", &"attack"]:
		return false
	var speaker: CombatUnit = null
	for id in ids:
		var unit: CombatUnit = world.units.get(id)
		if unit != null and unit.owner_id == owner and unit.alive() and unit.on_field and (speaker == null or unit.id < speaker.id):
			speaker = unit
	if speaker == null:
		return false
	_emit(action, speaker.id, speaker.faction)
	return true


func villager_selection(world: RtsSimulation, action: StringName, ids: Array[int]) -> bool:
	# Stage 1 villagers have no Attack order. Never play that line for gathering.
	if world == null or action not in [&"selected", &"move"]:
		return false
	var speaker := -1
	for id in ids:
		if world.agents.has(id) and (speaker < 0 or id < speaker):
			speaker = id
	if speaker < 0:
		return false
	_emit(action, speaker, CombatTypes.Faction.SWABIAN_LEAGUE if world.faction == "league" else CombatTypes.Faction.BUNDSCHUH)
	return true


func _emit(action: StringName, speaker: int, faction: int) -> void:
	sequence += 1
	cue_requested.emit({"sequence": sequence, "action": action, "speaker_id": speaker, "faction": faction})
