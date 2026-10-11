class_name ResourceBank
extends RefCounted
## The UI subscribes to changed. Harvesting changes cargo, NOT this stockpile.
## Integer transactions keep resources conserved and prevent rounding exploits.

signal changed(snapshot: Dictionary)

var _amounts: Dictionary = {0: 0, 1: 0, 2: 0, 3: 0}


func snapshot() -> Dictionary:
	return _amounts.duplicate()


func amount(kind: int) -> int:
	return int(_amounts.get(kind, 0))


func credit(kind: int, quantity: int) -> void:
	assert(kind in _amounts and quantity >= 0)
	if quantity == 0:
		return
	_amounts[kind] += quantity
	changed.emit(snapshot())


func can_afford(cost: Dictionary) -> bool:
	for kind: int in cost:
		if kind not in _amounts or int(cost[kind]) < 0 or amount(kind) < int(cost[kind]):
			return false
	return true


func try_spend(cost: Dictionary) -> bool:
	# Validate the WHOLE transaction first; no partial deduction on failure.
	if not can_afford(cost):
		return false
	for kind: int in cost:
		_amounts[kind] -= int(cost[kind])
	changed.emit(snapshot())
	return true
