class_name CombatSpatialHash
extends RefCounted
## Rebuilt once per aura scan from living on-field units. Six-tile buckets make
## a radius-six query inspect at most nine buckets, including negative positions.
## Candidate checks are instrumented; exact circles use squared distance.

const CELL_SIZE := 6.0
var _buckets: Dictionary = {}
var candidate_checks: int = 0
var builds: int = 0


func rebuild(units: Dictionary) -> void:
	_buckets.clear()
	candidate_checks = 0
	builds += 1
	for unit: CombatUnit in units.values():
		if not unit.alive() or not unit.on_field:
			continue
		var cell := _cell(unit.position)
		if not _buckets.has(cell):
			_buckets[cell] = []
		_buckets[cell].append(unit)


func query_circle(center: Vector2, radius: float) -> Array[CombatUnit]:
	assert(radius >= 0.0 and is_finite(radius))
	var result: Array[CombatUnit] = []
	var lo := _cell(center - Vector2.ONE * radius)
	var hi := _cell(center + Vector2.ONE * radius)
	var radius_squared := radius * radius
	for y in range(lo.y, hi.y + 1):
		for x in range(lo.x, hi.x + 1):
			for unit: CombatUnit in _buckets.get(Vector2i(x, y), []):
				candidate_checks += 1
				if unit.position.distance_squared_to(center) <= radius_squared:
					result.append(unit)
	return result


func clear() -> void:
	# Release references immediately when the owning world is reset/discarded.
	_buckets.clear()


static func _cell(point: Vector2) -> Vector2i:
	return Vector2i(floori(point.x / CELL_SIZE), floori(point.y / CELL_SIZE))
