class_name VillagerAI
extends RefCounted
## Explicit job FSM. All state transitions happen on the fixed simulation tick.
## Interaction slots are claimed BEFORE pathfinding and released on every job
## change. Waiting never deletes cargo or credits un-delivered resources.


static func reset_job(world: RtsSimulation, agent: VillagerAgent) -> void:
	world.release_slot(agent)
	world.paths.stop(agent)
	agent.resource_id = -1
	agent.building_id = -1
	agent.gather_accumulator = 0.0
	agent.state = VillagerAgent.State.IDLE
	agent.status = "Idle"
	agent.retry_at = 0.0


static func tick(world: RtsSimulation, agent: VillagerAgent, delta: float) -> void:
	# Logical endpoints are reserved at the beginning of a movement segment.
	# Work must wait for the visible body to physically finish that segment.
	if agent.in_transit(world.motion_alpha()):
		return
	match agent.state:
		VillagerAgent.State.IDLE:
			pass
		VillagerAgent.State.MOVE:
			if agent.nav_status == "arrived":
				agent.state = VillagerAgent.State.IDLE
				agent.status = "Idle"
			elif agent.nav_status == "unreachable":
				agent.status = "Destination unreachable"
		VillagerAgent.State.WAIT_RESOURCE:
			if world.time >= agent.retry_at:
				_seek_resource(world, agent)
		VillagerAgent.State.MOVE_TO_RESOURCE:
			if agent.nav_status == "arrived":
				agent.state = VillagerAgent.State.GATHER
				agent.status = "Gathering"
			elif agent.nav_status == "unreachable":
				_wait(world, agent, VillagerAgent.State.WAIT_RESOURCE, "Waiting for resource access")
		VillagerAgent.State.GATHER:
			_gather(world, agent, delta)
		VillagerAgent.State.WAIT_DROPOFF:
			if world.time >= agent.retry_at:
				_seek_dropoff(world, agent)
		VillagerAgent.State.RETURN_TO_DROPOFF:
			_return_cargo(world, agent)
		VillagerAgent.State.WAIT_BUILD:
			if world.time >= agent.retry_at:
				_seek_building(world, agent)
		VillagerAgent.State.MOVE_TO_BUILD:
			if agent.nav_status == "arrived":
				agent.state = VillagerAgent.State.BUILD
				agent.status = "Building"
			elif agent.nav_status == "unreachable":
				_wait(world, agent, VillagerAgent.State.WAIT_BUILD, "Waiting for build access")
		VillagerAgent.State.BUILD:
			_build(world, agent, delta)


static func _seek_resource(world: RtsSimulation, agent: VillagerAgent) -> void:
	var resource: GatherableResource = world.resources.get(agent.resource_id)
	if resource == null:
		_finish_or_return(world, agent)
		return
	if resource.remaining == 0:
		var replacement := world.nearest_resource(resource.kind, agent.cell)
		if replacement == null:
			_finish_or_return(world, agent)
			return
		agent.resource_id = replacement.id
		resource = replacement
	if agent.cargo >= agent.capacity or (agent.cargo > 0 and agent.cargo_kind != resource.kind):
		_seek_dropoff(world, agent)
		return
	if not world.claim_slot(agent, resource.footprint):
		_wait(world, agent, VillagerAgent.State.WAIT_RESOURCE, "Resource slots busy / unreachable")
		return
	agent.state = VillagerAgent.State.MOVE_TO_RESOURCE
	agent.status = "To " + ResourceKind.NAMES[resource.kind]


static func _gather(world: RtsSimulation, agent: VillagerAgent, delta: float) -> void:
	var resource: GatherableResource = world.resources.get(agent.resource_id)
	if resource == null or resource.remaining == 0:
		world.release_slot(agent)
		_seek_resource(world, agent)
		return
	if not world.grid.perimeter(resource.footprint).has(agent.cell):
		_wait(world, agent, VillagerAgent.State.WAIT_RESOURCE, "Repositioning")
		return
	agent.gather_accumulator += world.gather_rate(resource.kind) * delta
	var whole_units := int(floor(agent.gather_accumulator))
	var amount := resource.take(mini(whole_units, agent.capacity - agent.cargo))
	agent.gather_accumulator -= amount
	if amount > 0:
		agent.cargo_kind = resource.kind
		agent.cargo += amount
	if agent.cargo >= agent.capacity or resource.remaining == 0:
		agent.gather_accumulator = 0.0
		world.release_slot(agent)
		# Even a partial final load must be delivered.
		if agent.cargo > 0:
			_seek_dropoff(world, agent)
		else:
			_seek_resource(world, agent)


static func _seek_dropoff(world: RtsSimulation, agent: VillagerAgent) -> void:
	world.release_slot(agent)
	world.paths.stop(agent)
	if agent.cargo == 0:
		_resume_gather_or_idle(world, agent)
		return
	for building: RtsBuilding in world.dropoffs_for(agent.cargo_kind, agent.cell):
		if world.claim_slot(agent, building.footprint):
			agent.building_id = building.id
			agent.state = VillagerAgent.State.RETURN_TO_DROPOFF
			agent.status = "Returning " + ResourceKind.NAMES[agent.cargo_kind]
			return
	_wait(world, agent, VillagerAgent.State.WAIT_DROPOFF, "No reachable completed drop-off")


static func _return_cargo(world: RtsSimulation, agent: VillagerAgent) -> void:
	var building: RtsBuilding = world.buildings.get(agent.building_id)
	if building == null or not building.accepts(agent.cargo_kind):
		_seek_dropoff(world, agent)
		return
	if agent.nav_status == "unreachable":
		_wait(world, agent, VillagerAgent.State.WAIT_DROPOFF, "Drop-off route blocked")
		return
	if agent.nav_status != "arrived":
		return
	if not world.grid.perimeter(building.footprint).has(agent.cell):
		_seek_dropoff(world, agent)
		return
	# Clear cargo before emitting the stockpile signal; UI callbacks cannot
	# observe the same load both in the bank and on the worker.
	var delivered := agent.cargo
	var kind := agent.cargo_kind
	agent.cargo = 0
	agent.cargo_kind = -1
	world.delivered[kind] += delivered
	world.bank.credit(kind, delivered)
	_resume_gather_or_idle(world, agent)


static func _resume_gather_or_idle(world: RtsSimulation, agent: VillagerAgent) -> void:
	world.release_slot(agent)
	world.paths.stop(agent)
	agent.building_id = -1
	if world.resources.has(agent.resource_id):
		agent.state = VillagerAgent.State.WAIT_RESOURCE
		agent.retry_at = world.time
	else:
		agent.state = VillagerAgent.State.IDLE
		agent.status = "Idle"


static func _finish_or_return(world: RtsSimulation, agent: VillagerAgent) -> void:
	agent.resource_id = -1
	if agent.cargo > 0:
		_seek_dropoff(world, agent)
	else:
		reset_job(world, agent)
		agent.status = "Resource depleted"


static func _seek_building(world: RtsSimulation, agent: VillagerAgent) -> void:
	var building: RtsBuilding = world.buildings.get(agent.building_id)
	if building == null or building.finished:
		reset_job(world, agent)
		return
	if world.claim_slot(agent, building.footprint):
		agent.state = VillagerAgent.State.MOVE_TO_BUILD
		agent.status = "To construction"
	else:
		_wait(world, agent, VillagerAgent.State.WAIT_BUILD, "Waiting for build access")


static func _build(world: RtsSimulation, agent: VillagerAgent, delta: float) -> void:
	var building: RtsBuilding = world.buildings.get(agent.building_id)
	if building == null or building.finished:
		reset_job(world, agent)
		agent.status = "Construction complete" if building != null else "Construction removed"
		return
	if not world.grid.perimeter(building.footprint).has(agent.cell):
		_wait(world, agent, VillagerAgent.State.WAIT_BUILD, "Repositioning")
		return
	# Stage 1 rule: each adjacent worker contributes 1 work-second/second.
	# Linear cooperation is explicit tuning, not an undocumented AoE2 formula.
	building.apply_work(delta)


static func _wait(world: RtsSimulation, agent: VillagerAgent, state: VillagerAgent.State, text: String) -> void:
	world.release_slot(agent)
	world.paths.stop(agent)
	agent.state = state
	agent.status = text
	agent.retry_at = world.time + 1.0
