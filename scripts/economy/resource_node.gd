class_name GatherableResource
extends RefCounted
## Named GatherableResource to avoid shadowing Godot's built-in Resource class.

signal depleted(id: int)

var id: int
var kind: int
var footprint: Rect2i
var remaining: int
var initial_amount: int


func _init(entity_id: int, resource_kind: int, rect: Rect2i, quantity: int) -> void:
	assert(quantity > 0)
	id = entity_id
	kind = resource_kind
	footprint = rect
	remaining = quantity
	initial_amount = quantity


func take(requested: int) -> int:
	# Every worker goes through this transaction on the simulation thread.
	# The last two workers cannot both take the same final resource.
	assert(requested >= 0)
	var taken := mini(requested, remaining)
	remaining -= taken
	if taken > 0 and remaining == 0:
		depleted.emit(id)
	return taken
