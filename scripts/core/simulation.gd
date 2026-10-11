class_name RtsSimulation
extends RefCounted
## Composition root for the model layer. The same code runs in the interactive
## scene and headless regression tests; presentation never changes bank values.
##
## FIXED_DT is simulation time. Wall-clock time / Engine.time_scale is not read.
## Multiplayer lockstep is deliberately NOT claimed for this single-player slice.

signal notice(text: String)
signal building_finished(id: int)

const FIXED_DT := 0.05
const MOVE_PERIOD := 1.25 # 1 tile / 0.80 tiles per second, GDD villager base speed
const MAX_UNITS := 200
const BASE_GATHER_RATES: Array[float] = [0.40, 0.39, 0.38, 0.36]

var grid: WorldGrid
var bank := ResourceBank.new()
var paths: PathService
var traffic := TrafficController.new()
var combat: CombatWorld # Explicit opt-in backend; F6/F7 stay economy/nav fixtures.
var agents: Dictionary = {}
var resources: Dictionary = {}
var buildings: Dictionary = {}
var slot_claims: Dictionary = {}
var delivered: Dictionary = {0: 0, 1: 0, 2: 0, 3: 0}
var faction: String = "bundschuh"
var age: int = 1
var time: float = 0.0
var housing: int = 0
var _next_id: int = 1
var _move_elapsed: float = MOVE_PERIOD


func _init(dimensions: Vector2i = Vector2i(64, 40)) -> void:
	grid = WorldGrid.new(dimensions)
	paths = PathService.new(grid)


func _id() -> int:
	var value := _next_id
	_next_id += 1
	return value


func enable_combat(owner_id: int = 0, team_id: int = 0,
		payroll_enabled: bool = false, wage: int = MercenaryMaintenance.DEFAULT_WAGE) -> CombatWorld:
	## Bridge the fixed clock and this player's real bank into Stage 2. Combat
	## soldiers have their own registry; the Stage 1 villager crowd is not silently
	## repurposed as enemy/cavalry navigation. See the Stage 2 adapter contract.
	if combat != null:
		return combat
	var backend := CombatWorld.new()
	var side := CombatTypes.Faction.SWABIAN_LEAGUE if faction == "league" else CombatTypes.Faction.BUNDSCHUH
	if not backend.add_player(owner_id, team_id, side, bank, payroll_enabled, wage):
		return null
	combat = backend
	return combat


func motion_alpha() -> float:
	return clampf(_move_elapsed / MOVE_PERIOD, 0.0, 1.0)


func add_agent(cell: Vector2i, scenario_spawn: bool = false) -> VillagerAgent:
	if agents.size() >= MAX_UNITS or not grid.walkable(cell) or occupied_cells().has(cell):
		return null
	if not scenario_spawn and agents.size() >= housing:
		return null
	var agent := VillagerAgent.new(_id(), cell)
	agents[agent.id] = agent
	return agent


func add_resource(kind: int, rect: Rect2i, quantity: int) -> GatherableResource:
	assert(kind in ResourceKind.Type.values())
	for cell in grid.cells(rect):
		assert(grid.walkable(cell))
	var resource := GatherableResource.new(_id(), kind, rect, quantity)
	resources[resource.id] = resource
	for cell in grid.cells(rect):
		grid.set_blocked(cell, resource.id)
	resource.depleted.connect(_on_resource_depleted)
	return resource


func add_building(key: String, origin: Vector2i, finished: bool = false) -> RtsBuilding:
	var building := RtsBuilding.new(_id(), key, origin, finished)
	for cell in grid.cells(building.footprint):
		assert(grid.walkable(cell))
	buildings[building.id] = building
	for cell in grid.cells(building.footprint):
		grid.set_blocked(cell, building.id)
	building.completed.connect(_on_building_completed)
	if finished:
		housing += building.housing
	return building


func remove_building(id: int) -> void:
	var building: RtsBuilding = buildings.get(id)
	if building == null:
		return
	if building.finished:
		housing -= building.housing
	grid.release_owner(id)
	buildings.erase(id)
	# Workers detect missing IDs on their next fixed tick, preserving cargo.


func _on_resource_depleted(id: int) -> void:
	grid.release_owner(id)


func _on_building_completed(id: int) -> void:
	var building: RtsBuilding = buildings.get(id)
	if building != null:
		housing += building.housing
		building_finished.emit(id)
		notice.emit(BuildingCatalog.DEFINITIONS[building.key]["name"] + " completed")


func gather_rate(kind: int) -> float:
	var bonus := 1.10 if faction == "bundschuh" and kind in [0, 1] else 1.0
	return BASE_GATHER_RATES[kind] * bonus


func occupied_cells(include_transit: bool = true) -> Dictionary:
	var result: Dictionary = {}
	for agent: VillagerAgent in agents.values():
		result[agent.cell] = agent.id
		if include_transit and agent.in_transit(motion_alpha()):
			result[agent.from_cell] = agent.id
	return result


func release_slot(agent: VillagerAgent) -> void:
	if slot_claims.get(agent.work_cell) == agent.id:
		slot_claims.erase(agent.work_cell)
	agent.work_cell = VillagerAgent.INVALID_CELL


func claim_slot(agent: VillagerAgent, footprint: Rect2i) -> bool:
	var candidates := grid.perimeter(footprint)
	if agent.work_cell in candidates and slot_claims.get(agent.work_cell) == agent.id:
		return true
	release_slot(agent)
	var occupied := occupied_cells()
	candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return _distance(agent.cell, a) < _distance(agent.cell, b))
	for cell in candidates:
		if slot_claims.has(cell):
			continue
		if occupied.has(cell) and int(occupied[cell]) != agent.id:
			continue
		if not grid.connected(agent.cell, cell):
			continue
		slot_claims[cell] = agent.id
		agent.work_cell = cell
		navigate(agent, cell)
		return true
	return false


func navigate(agent: VillagerAgent, destination: Vector2i) -> void:
	if agent.cell == destination:
		paths.stop(agent)
		agent.goal = destination
		agent.nav_status = "arrived"
		agent.path_revision = grid.revision
	else:
		paths.request(agent, destination)


func nearest_resource(kind: int, origin: Vector2i) -> GatherableResource:
	var best: GatherableResource = null
	var best_distance := 1000000
	for resource: GatherableResource in resources.values():
		if resource.kind != kind or resource.remaining <= 0:
			continue
		for cell in grid.perimeter(resource.footprint):
			if grid.connected(origin, cell):
				var distance := _distance(origin, cell)
				if distance < best_distance:
					best_distance = distance
					best = resource
				break
	return best


func dropoffs_for(kind: int, origin: Vector2i) -> Array[RtsBuilding]:
	var result: Array[RtsBuilding] = []
	for building: RtsBuilding in buildings.values():
		if building.accepts(kind):
			result.append(building)
	result.sort_custom(func(a: RtsBuilding, b: RtsBuilding) -> bool:
		return _distance(origin, a.footprint.position) < _distance(origin, b.footprint.position))
	return result


func command_stop(ids: Array[int]) -> void:
	for id in ids:
		var agent: VillagerAgent = agents.get(id)
		if agent != null:
			VillagerAI.reset_job(self, agent)


func command_gather(ids: Array[int], resource_id: int) -> void:
	var resource: GatherableResource = resources.get(resource_id)
	if resource == null or resource.remaining <= 0:
		notice.emit("That resource is depleted.")
		return
	for id in ids:
		var agent: VillagerAgent = agents.get(id)
		if agent == null:
			continue
		VillagerAI.reset_job(self, agent)
		agent.resource_id = resource_id
		agent.state = VillagerAgent.State.WAIT_DROPOFF if agent.cargo > 0 else VillagerAgent.State.WAIT_RESOURCE


func command_build(ids: Array[int], building_id: int) -> void:
	var building: RtsBuilding = buildings.get(building_id)
	if building == null or building.finished:
		return
	for id in ids:
		var agent: VillagerAgent = agents.get(id)
		if agent != null:
			VillagerAI.reset_job(self, agent)
			agent.building_id = building_id
			agent.state = VillagerAgent.State.WAIT_BUILD


func command_deliver(ids: Array[int]) -> void:
	for id in ids:
		var agent: VillagerAgent = agents.get(id)
		if agent != null and agent.cargo > 0:
			release_slot(agent)
			paths.stop(agent)
			agent.state = VillagerAgent.State.WAIT_DROPOFF
			agent.retry_at = time


func command_move(ids: Array[int], destination: Vector2i) -> void:
	# Assign distinct arrival cells. A group command never sends 200 bodies
	# to the exact same point. Existing nonselected destinations are respected.
	var chosen: Array[VillagerAgent] = []
	for id in ids:
		var agent: VillagerAgent = agents.get(id)
		if agent != null:
			VillagerAI.reset_job(self, agent)
			chosen.append(agent)
	if chosen.is_empty():
		return
	var unavailable: Dictionary = slot_claims.duplicate()
	for agent: VillagerAgent in agents.values():
		if agent.id not in ids:
			unavailable[agent.cell] = true
			if agent.goal != VillagerAgent.INVALID_CELL:
				unavailable[agent.goal] = true
	var candidates: Array[Vector2i] = []
	for y in range(grid.size.y):
		for x in range(grid.size.x):
			var cell := Vector2i(x, y)
			if grid.walkable(cell) and not unavailable.has(cell):
				candidates.append(cell)
	candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var da := _distance(a, destination)
		var db := _distance(b, destination)
		return da < db if da != db else (a.y < b.y if a.y != b.y else a.x < b.x))
	# Fill the far side of the formation first. Parking the first arrivals at
	# its entrance forces every following unit to push through settled units.
	var formation: Array[Vector2i] = []
	formation.assign(candidates.slice(0, chosen.size()))
	var center := Vector2.ZERO
	for unit in chosen:
		center += Vector2(unit.cell)
	center /= chosen.size()
	formation.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return Vector2(a).distance_squared_to(center) > Vector2(b).distance_squared_to(center))
	chosen.sort_custom(func(a: VillagerAgent, b: VillagerAgent) -> bool:
		var da := _distance(a.cell, destination)
		var db := _distance(b.cell, destination)
		return da < db if da != db else a.id < b.id)
	var used: Dictionary = {}
	for agent in chosen:
		var found := false
		for cell in formation:
			if used.has(cell) or not grid.connected(agent.cell, cell):
				continue
			# Clicking an inaccessible island must fail visibly rather than
			# silently selecting an arbitrary spot beside the issuing unit.
			if grid.walkable(destination) and not grid.connected(destination, cell):
				continue
			used[cell] = true
			navigate(agent, cell)
			agent.state = VillagerAgent.State.MOVE
			agent.status = "Moving"
			found = true
			break
		if not found:
			agent.status = "Destination unreachable / no free slots"
			notice.emit(agent.status)


func validate_placement(key: String, origin: Vector2i, builders: Array[int]) -> Dictionary:
	if key not in BuildingCatalog.PLACEABLE:
		return {"ok": false, "reason": "Building is not unlocked in Stage 1."}
	var data := BuildingCatalog.definition(key)
	if not bank.can_afford(data["cost"]):
		return {"ok": false, "reason": "Not enough resources."}
	var footprint := Rect2i(origin, data["size"])
	var occupied := occupied_cells()
	var future: Dictionary = {}
	for agent: VillagerAgent in agents.values():
		if agent.goal != VillagerAgent.INVALID_CELL:
			future[agent.goal] = true
	var blocked: Dictionary = {}
	for cell in grid.cells(footprint):
		if not grid.walkable(cell):
			return {"ok": false, "reason": "Terrain, resource, building or map edge."}
		if occupied.has(cell) or slot_claims.has(cell) or future.has(cell):
			return {"ok": false, "reason": "A unit or reserved destination occupies the footprint."}
		blocked[cell] = true
	var slots := grid.perimeter(footprint)
	for id in builders:
		var agent: VillagerAgent = agents.get(id)
		if agent == null:
			continue
		# Evaluate access AFTER blocking the proposed footprint. A builder
		# standing on the wrong side of a newly sealed pass is not valid.
		var reachable := grid.reachable_from(agent.cell, blocked)
		for slot in slots:
			if reachable.has(slot):
				return {"ok": true, "reason": "Buildable — click to place."}
	return {"ok": false, "reason": "Select a villager with access to the building edge."}


func place_building(key: String, origin: Vector2i, builders: Array[int]) -> RtsBuilding:
	# Confirmation repeats preview validation. Cost/occupancy may have changed
	# while the cursor stayed still; never trust a previously green ghost.
	var validation := validate_placement(key, origin, builders)
	if not bool(validation["ok"]):
		notice.emit(validation["reason"])
		return null
	var data := BuildingCatalog.definition(key)
	if not bank.try_spend(data["cost"]):
		return null
	var building := add_building(key, origin, false)
	command_build(builders, building.id)
	return building


func step(delta: float = FIXED_DT) -> void:
	assert(delta > 0.0 and delta <= 0.25)
	time += delta
	# Payroll precedes this tick's gathering/deposits. Time advances only when
	# the host steps the simulation, so pause and speed controls remain coherent.
	if combat != null:
		combat.advance(delta)
	_move_elapsed = minf(MOVE_PERIOD, _move_elapsed + delta)
	for agent: VillagerAgent in agents.values():
		agent.capacity = 10 + (3 if faction == "league" and age >= 3 else 0)
		VillagerAI.tick(self, agent, delta)

	for agent: VillagerAgent in agents.values():
		if agent.goal == VillagerAgent.INVALID_CELL or agent.request_pending:
			continue
		if agent.path_revision != grid.revision and agent.nav_status != "stopped":
			paths.request(agent, agent.goal)
		elif agent.wait_steps >= 3 and time >= agent.repath_at and not agent.path.is_empty():
			var avoid: Array[Vector2i] = []
			var congestion: Array[Vector2i] = []
			for other: VillagerAgent in agents.values():
				if other.id != agent.id:
					congestion.append(other.cell)
				# Only actual workers are anchored. A queued route is NOT an
				# immovable obstacle; treating it as one can strand an army.
				if other.id != agent.id and other.state in [VillagerAgent.State.GATHER, VillagerAgent.State.BUILD]:
					avoid.append(other.cell)
			paths.request(agent, agent.goal, avoid, congestion)
			agent.repath_at = time + 3.0
	paths.process(agents)
	if _move_elapsed >= MOVE_PERIOD - 0.000001:
		traffic.advance(agents, grid)
		_move_elapsed = 0.0


static func _distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)
