class_name RtsBuilding
extends RefCounted
## Construction work and current HP are explicit. The Stage 1 slice has no
## combat damage; a future damage system must not overwrite HP from progress.

signal completed(id: int)

var id: int
var key: String
var footprint: Rect2i
var max_hp: float
var hp: float = 0.0
var work_seconds: float = 0.0
var required_work: float
var finished: bool = false
var accepted_resources: Array = []
var housing: int = 0


func _init(entity_id: int, definition_key: String, origin: Vector2i, ready: bool = false) -> void:
	var data := BuildingCatalog.definition(definition_key)
	assert(not data.is_empty())
	id = entity_id
	key = definition_key
	footprint = Rect2i(origin, data["size"])
	max_hp = float(data["hp"])
	required_work = float(data["seconds"])
	accepted_resources = data["accepts"].duplicate()
	housing = int(data["housing"])
	if ready:
		work_seconds = required_work
		hp = max_hp
		finished = true


func progress() -> float:
	return work_seconds / required_work


func accepts(kind: int) -> bool:
	return finished and kind in accepted_resources


func apply_work(seconds: float) -> void:
	assert(seconds >= 0.0)
	if finished:
		return
	var applied := minf(seconds, required_work - work_seconds)
	work_seconds += applied
	hp = minf(max_hp, hp + applied / required_work * max_hp)
	if work_seconds >= required_work - 0.00001:
		work_seconds = required_work
		hp = max_hp
		finished = true
		completed.emit(id)
