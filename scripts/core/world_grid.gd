class_name WorldGrid
extends RefCounted
## Authoritative STATIC grid. Units are deliberately not baked into A*:
## constantly rebuilding a grid for 200 moving blockers creates path thrashing.
## TrafficController owns dynamic occupancy; this class owns terrain/foundations.

const DIRECTIONS: Array[Vector2i] = [
	Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP
]
var size: Vector2i
var revision: int = 0
var astar: AStarGrid2D
var blockers: Dictionary = {} # cell -> owner ID; terrain uses -1
var _components: Dictionary = {}
var _component_revision: int = -1


func _init(dimensions: Vector2i = Vector2i(64, 40)) -> void:
	assert(dimensions.x > 0 and dimensions.y > 0)
	size = dimensions
	astar = AStarGrid2D.new()
	astar.region = Rect2i(Vector2i.ZERO, size)
	astar.cell_size = Vector2.ONE
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	# update() clears all solid flags. Call once, BEFORE adding obstacles.
	astar.update()


func contains(cell: Vector2i) -> bool:
	return Rect2i(Vector2i.ZERO, size).has_point(cell)


func walkable(cell: Vector2i) -> bool:
	return contains(cell) and not blockers.has(cell)


func set_blocked(cell: Vector2i, owner: int) -> void:
	assert(contains(cell))
	assert(not blockers.has(cell))
	blockers[cell] = owner
	astar.set_point_solid(cell, true)
	revision += 1


func release_owner(owner: int) -> void:
	for cell: Vector2i in blockers.keys():
		if blockers[cell] == owner:
			blockers.erase(cell)
			astar.set_point_solid(cell, false)
			revision += 1


func cells(rect: Rect2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			result.append(Vector2i(x, y))
	return result


func perimeter(rect: Rect2i) -> Array[Vector2i]:
	# Orthogonal interaction cells only: never gather through a diagonal wall.
	var result: Array[Vector2i] = []
	for x in range(rect.position.x, rect.end.x):
		for y in [rect.position.y - 1, rect.end.y]:
			var cell := Vector2i(x, y)
			if walkable(cell):
				result.append(cell)
	for y in range(rect.position.y, rect.end.y):
		for x in [rect.position.x - 1, rect.end.x]:
			var cell := Vector2i(x, y)
			if walkable(cell):
				result.append(cell)
	return result


func reachable_from(start: Vector2i, extra_blocked: Dictionary = {}) -> Dictionary:
	# Used for post-placement reachability and connected-component construction.
	var seen: Dictionary = {}
	if not walkable(start) or extra_blocked.has(start):
		return seen
	var queue: Array[Vector2i] = [start]
	seen[start] = true
	var head := 0
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		for direction in DIRECTIONS:
			var next := current + direction
			if walkable(next) and not seen.has(next) and not extra_blocked.has(next):
				seen[next] = true
				queue.append(next)
	return seen


func connected(a: Vector2i, b: Vector2i) -> bool:
	# Cache flood-fill labels by terrain revision. Reject impossible requests
	# before sending them to A*, rather than searching the whole map per unit.
	if _component_revision != revision:
		_components.clear()
		var component := 0
		for y in range(size.y):
			for x in range(size.x):
				var cell := Vector2i(x, y)
				if walkable(cell) and not _components.has(cell):
					for reachable: Vector2i in reachable_from(cell):
						_components[reachable] = component
					component += 1
		_component_revision = revision
	return _components.has(a) and _components.has(b) and _components[a] == _components[b]
