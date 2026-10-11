class_name TrafficController
extends RefCounted
## A* finds routes, not collision-free crowd motion. This second layer selects
## one intent per destination, then commits compatible chains/cycles atomically.
## Waiting age makes arbitration fair. No two units own the same cell.
##
## This Stage 1 uses uniform friendly foot units (radius 0.18 cells). Opposite
## pairs visibly pass on opposite sides. Large siege/cavalry need a future
## clearance/portal model; do not silently increase the radius here.

var swaps_total: int = 0
var moves_last_step: int = 0


func advance(agents: Dictionary, grid: WorldGrid) -> void:
	var occupancy: Dictionary = {}
	var ordered: Array[VillagerAgent] = []
	for agent: VillagerAgent in agents.values():
		agent.from_cell = agent.cell
		agent.passing = false
		assert(not occupancy.has(agent.cell), "Overlapping logical unit positions")
		occupancy[agent.cell] = agent.id
		ordered.append(agent)
	ordered.sort_custom(func(a: VillagerAgent, b: VillagerAgent) -> bool:
		if a.wait_steps != b.wait_steps:
			return a.wait_steps > b.wait_steps
		if a.path.size() != b.path.size():
			return a.path.size() < b.path.size()
		return a.id < b.id)

	var intents: Dictionary = {} # unit ID -> destination
	var claimed: Dictionary = {} # destination -> winning unit ID
	var desired: Dictionary = {}
	for agent in ordered:
		if not agent.path.is_empty() and not agent.request_pending:
			var next: Vector2i = agent.path[0]
			if grid.walkable(next) and _adjacent(agent.cell, next):
				desired[agent.id] = next
	# Protect genuine head-on pairs BEFORE destination arbitration. Otherwise
	# both followers can repeatedly win the opposite leaders' origin cells,
	# breaking the pair and deadlocking two otherwise passable columns.
	for agent in ordered:
		if not desired.has(agent.id) or intents.has(agent.id):
			continue
		var opposite: int = int(occupancy.get(desired[agent.id], -1))
		if opposite >= 0 and desired.get(opposite) == agent.cell:
			intents[agent.id] = desired[agent.id]
			intents[opposite] = agent.cell
			claimed[desired[agent.id]] = agent.id
			claimed[agent.cell] = opposite
	for agent in ordered:
		if not desired.has(agent.id) or intents.has(agent.id):
			continue
		var next: Vector2i = desired[agent.id]
		if not claimed.has(next):
			intents[agent.id] = next
			claimed[next] = agent.id

	# An idle friendly blocker may yield to the requester's old cell. Both
	# trajectories are evaluated as a coordinated passing pair below.
	for agent in ordered:
		if not intents.has(agent.id) or agent.wait_steps < 2:
			continue
		var blocker_id: int = int(occupancy.get(intents[agent.id], -1))
		if blocker_id < 0 or intents.has(blocker_id):
			continue
		var blocker: VillagerAgent = agents[blocker_id]
		if blocker.can_yield():
			# A following unit often requests the leader's origin. Pause that
			# follower for this step to make room for the yielding pair; without
			# this, a dense queue can never pass even a single idle blocker.
			var follower: int = int(claimed.get(agent.cell, -1))
			if follower >= 0:
				intents.erase(follower)
			intents[blocker_id] = agent.cell
			claimed[agent.cell] = blocker_id

	var allowed: Dictionary = {}
	for unit_id: int in intents:
		if allowed.has(unit_id):
			continue
		var chain: Array[int] = []
		var visiting: Dictionary = {}
		var current := unit_id
		var can_move := false
		while true:
			if allowed.has(current):
				can_move = bool(allowed[current])
				break
			if visiting.has(current):
				can_move = true # a closed cycle with exclusive endpoints
				break
			if not intents.has(current):
				break # chain terminates at an anchored/stationary blocker
			visiting[current] = true
			chain.append(current)
			var occupant: int = int(occupancy.get(intents[current], -1))
			if occupant < 0:
				can_move = true
				break
			current = occupant
		for member in chain:
			allowed[member] = can_move

	moves_last_step = 0
	for agent in ordered:
		if not bool(allowed.get(agent.id, false)):
			if not agent.path.is_empty():
				agent.wait_steps += 1
			continue
		var destination: Vector2i = intents[agent.id]
		var other_id: int = int(occupancy.get(destination, -1))
		agent.passing = other_id >= 0 and intents.get(other_id) == agent.cell
		if agent.passing and agent.id < other_id:
			swaps_total += 1
		var followed_path := not agent.path.is_empty() and agent.path[0] == destination
		agent.cell = destination
		agent.wait_steps = 0
		moves_last_step += 1
		if followed_path:
			agent.path.pop_front()
			agent.nav_status = "arrived" if agent.path.is_empty() else "moving"
		else:
			# Yielded idle/waiting workers retain cargo/job but relinquish a
			# stale route. Their FSM will reacquire a valid interaction slot.
			agent.path.clear()
			if agent.state == VillagerAgent.State.IDLE and agent.goal != VillagerAgent.INVALID_CELL:
				# A settled formation member returns to its assigned arrival
				# slot after yielding. Otherwise each newcomer pushes it one
				# cell farther back, potentially across the whole chokepoint.
				agent.state = VillagerAgent.State.MOVE
				agent.status = "Reforming"
				agent.path_revision = -1
				agent.nav_status = "queued"
			else:
				agent.goal = VillagerAgent.INVALID_CELL
				agent.nav_status = "stopped"
			agent.request_generation += 1
			agent.request_pending = false


static func _adjacent(a: Vector2i, b: Vector2i) -> bool:
	return absi(a.x - b.x) + absi(a.y - b.y) == 1
