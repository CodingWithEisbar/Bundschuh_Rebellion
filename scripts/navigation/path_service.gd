class_name PathService
extends RefCounted
## Bounded request scheduler around native AStarGrid2D. Routes are reused until
## a command, geometry change or sustained blockage requires a new path.
## Godot's A* object is main-thread confined, not used concurrently.

var grid: WorldGrid
var requests: Array[Dictionary] = []
var _head: int = 0
var _pending_by_id: Dictionary = {}
var queries_last_tick: int = 0
var queries_total: int = 0
var max_queries_per_tick: int = 12
var _cache: Dictionary = {}
var _cache_order: Array[String] = []
const CACHE_LIMIT := 256


func _init(world_grid: WorldGrid) -> void:
	grid = world_grid


func stop(agent: VillagerAgent) -> void:
	agent.request_generation += 1
	agent.request_pending = false
	agent.path.clear()
	agent.goal = VillagerAgent.INVALID_CELL
	agent.nav_status = "stopped"


func request(agent: VillagerAgent, destination: Vector2i, avoid: Array[Vector2i] = [], congestion: Array[Vector2i] = []) -> void:
	agent.request_generation += 1
	agent.request_pending = true
	agent.goal = destination
	agent.path.clear()
	agent.nav_status = "queued"
	# Coalesce repeated commands in the existing queue slot. A user issuing
	# group orders faster than the query budget cannot grow memory unbounded.
	var job: Dictionary
	if _pending_by_id.has(agent.id):
		job = _pending_by_id[agent.id]
		job.clear()
	else:
		job = {}
		requests.append(job)
		_pending_by_id[agent.id] = job
	job.merge({"id": agent.id, "generation": agent.request_generation,
		"goal": destination, "avoid": avoid.duplicate(), "congestion": congestion.duplicate()})


func pending_count() -> int:
	return requests.size() - _head


func process(agents: Dictionary) -> void:
	queries_last_tick = 0
	# Also bound stale-request scanning after repeated drag/right-click input.
	var scanned := 0
	while _head < requests.size() and queries_last_tick < max_queries_per_tick and scanned < 64:
		var job: Dictionary = requests[_head]
		_head += 1
		_pending_by_id.erase(job["id"])
		scanned += 1
		var agent: VillagerAgent = agents.get(job["id"])
		if agent == null or agent.request_generation != int(job["generation"]):
			continue
		agent.request_pending = false
		agent.path_revision = grid.revision
		var destination: Vector2i = job["goal"]
		if not grid.connected(agent.cell, destination):
			agent.nav_status = "unreachable"
			continue
		var avoid: Array[Vector2i] = []
		for cell: Vector2i in job["avoid"]:
			if cell != agent.cell and cell != destination and grid.walkable(cell):
				avoid.append(cell)
		var key := "%s:%s:%s" % [grid.revision, agent.cell, destination]
		var route: Array[Vector2i] = []
		var congestion: Array[Vector2i] = []
		for cell: Vector2i in job["congestion"]:
			if cell != agent.cell and cell != destination and grid.walkable(cell):
				congestion.append(cell)
		var cacheable := avoid.is_empty() and congestion.is_empty()
		if cacheable and _cache.has(key):
			route.assign(_cache[key])
		else:
			# Temporary dynamic exclusions never increment static revision.
			for cell in avoid:
				grid.astar.set_point_solid(cell, true)
			# Soft penalties spread queues around settled formations without
			# turning temporary traffic into disconnected static terrain.
			for cell in congestion:
				grid.astar.set_point_weight_scale(cell, 4.0)
			route = grid.astar.get_id_path(agent.cell, destination, false)
			for cell in avoid:
				grid.astar.set_point_solid(cell, false)
			for cell in congestion:
				grid.astar.set_point_weight_scale(cell, 1.0)
			queries_last_tick += 1
			queries_total += 1
			if cacheable:
				_cache[key] = route.duplicate()
				_cache_order.append(key)
				if _cache_order.size() > CACHE_LIMIT:
					_cache.erase(_cache_order.pop_front())
		if route.is_empty() and not avoid.is_empty():
			# A transient worker can temporarily seal a corridor. Retry the
			# static route through the SAME bounded queue; do not permanently
			# mark geometry unreachable because of dynamic occupancy.
			request(agent, destination)
			continue
		if not route.is_empty():
			route.pop_front() # current cell is not a future step
		agent.path = route
		agent.nav_status = "arrived" if agent.cell == destination else (
			"moving" if not route.is_empty() else "unreachable")
	if _head >= requests.size():
		requests.clear()
		_head = 0
	elif _head > 512:
		requests = requests.slice(_head)
		_head = 0
