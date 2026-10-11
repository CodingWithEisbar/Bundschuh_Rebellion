extends SceneTree
## Dependency-free integration tests executed by the real Godot runtime.
## These test observable behavior/invariants, not copies of production methods.

var failures: Array[String] = []
var completed: Array[String] = []
var metrics: Dictionary = {}
var checks: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var cases: Array[Callable] = [
		test_grid_and_static_revision,
		test_atomic_stockpile,
		test_path_budget_and_stale_orders,
		test_unreachable_order,
		test_opposing_corridor_traffic,
		test_opposing_groups,
		test_four_unit_cycle,
		test_idle_blocker_yields,
		test_all_resource_kinds_conserved,
		test_partial_cargo_survives_job_switch,
		test_missing_and_unfinished_dropoffs,
		test_destroyed_dropoff_reroutes,
		test_placement_validation_and_transaction,
		test_multi_worker_construction,
		test_dynamic_obstacle_repath,
		test_interrupted_job_releases_slot,
		test_200_unit_chokepoint,
		test_main_scene_and_hud
	]
	for test in cases:
		var before := failures.size()
		var label := test.get_method()
		var started := Time.get_ticks_usec()
		test.call()
		var duration := (Time.get_ticks_usec() - started) / 1000.0
		if failures.size() == before:
			completed.append(label)
			print("PASS %s (%.1f ms)" % [label, duration])
		else:
			print("FAIL %s" % label)
	var report := {"passed": completed.size(), "failed_assertions": failures,
		"checks": checks, "metrics": metrics, "engine": Engine.get_version_info()["string"]}
	DirAccess.make_dir_recursive_absolute("res://test-results")
	var file := FileAccess.open("res://test-results/stage1.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report, "\t"))
	print("RESULT: %d / %d cases passed; %d checks; %d failures" % [
		completed.size(), cases.size(), checks, failures.size()])
	quit(0 if failures.is_empty() else 1)


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)


func step_until(world: RtsSimulation, predicate: Callable, max_steps: int = 4000) -> bool:
	for i in range(max_steps):
		world.step()
		if predicate.call():
			return true
	return false


func step_for(world: RtsSimulation, seconds: float) -> void:
	for i in range(ceili(seconds / RtsSimulation.FIXED_DT)):
		world.step()


func ids(world: RtsSimulation) -> Array[int]:
	var result: Array[int] = []
	result.assign(world.agents.keys())
	return result


func agent(world: RtsSimulation, position: Vector2i) -> VillagerAgent:
	return world.add_agent(position, true)


func navigate(world: RtsSimulation, unit: VillagerAgent, goal: Vector2i) -> void:
	unit.state = VillagerAgent.State.MOVE
	world.navigate(unit, goal)


func all_settled(world: RtsSimulation) -> bool:
	for unit: VillagerAgent in world.agents.values():
		if not unit.path.is_empty() or unit.request_pending or unit.in_transit(world.motion_alpha()):
			return false
	return true


func motion_is_safe(world: RtsSimulation) -> bool:
	# Spatial buckets check rendered trajectories at intermediate times.
	# In addition to exclusive logical cells, bodies must not cross/overlap.
	var logical: Dictionary = {}
	for unit: VillagerAgent in world.agents.values():
		if logical.has(unit.cell) or not world.grid.walkable(unit.cell):
			return false
		logical[unit.cell] = true
	for alpha in [0.0, 0.25, 0.5, 0.75, 1.0]:
		var buckets: Dictionary = {}
		for unit: VillagerAgent in world.agents.values():
			var point := unit.display_position(alpha)
			var cell := Vector2i(floori(point.x), floori(point.y))
			# Four cardinal sweeps plus the cell suffice for radius < 0.25.
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					for other: Vector2 in buckets.get(cell + Vector2i(dx, dy), []):
						if point.distance_to(other) < 2.0 * VillagerAgent.RADIUS - 0.0001:
							return false
			if not world.grid.walkable(cell):
				return false
			if not buckets.has(cell):
				buckets[cell] = []
			buckets[cell].append(point)
	return true


func test_grid_and_static_revision() -> void:
	var grid := WorldGrid.new(Vector2i(8, 6))
	grid.set_blocked(Vector2i(3, 2), 99)
	var route := grid.astar.get_id_path(Vector2i(1, 2), Vector2i(6, 2))
	check(not route.has(Vector2i(3, 2)), "A* must avoid a static obstacle.")
	for i in range(1, route.size()):
		check(RtsSimulation._distance(route[i - 1], route[i]) == 1, "No diagonal corner cutting.")
	var old_revision := grid.revision
	grid.release_owner(99)
	check(grid.revision > old_revision and grid.walkable(Vector2i(3, 2)), "Obstacle release invalidates routes.")
	check(not grid.walkable(Vector2i(-1, 0)), "Map bounds are solid.")


func test_atomic_stockpile() -> void:
	var bank := ResourceBank.new()
	bank.credit(1, 100)
	check(not bank.try_spend({1: 25, 2: 1}), "Insufficient multi-resource purchase must fail.")
	check(bank.amount(1) == 100, "Failure cannot partially debit stock.")
	check(not bank.try_spend({1: -1}), "Negative cost cannot mint resources.")
	check(bank.try_spend({1: 25}) and bank.amount(1) == 75, "Successful purchase debits once.")


func test_path_budget_and_stale_orders() -> void:
	var world := RtsSimulation.new(Vector2i(30, 20))
	for x in range(20):
		var unit := agent(world, Vector2i(x, 0))
		navigate(world, unit, Vector2i(x, 18))
		navigate(world, unit, Vector2i(x, 10))
	check(world.paths.pending_count() == world.agents.size(), "Repeated group orders must coalesce to one pending job per unit.")
	world.paths.process(world.agents)
	check(world.paths.queries_last_tick <= world.paths.max_queries_per_tick, "A* request budget exceeded.")
	step_for(world, 2)
	for unit: VillagerAgent in world.agents.values():
		check(unit.goal.y == 10, "Stale path result replaced a newer order.")
		if not unit.path.is_empty():
			check(unit.path.back().y == 10, "Route must end at latest command target.")


func test_unreachable_order() -> void:
	var world := RtsSimulation.new(Vector2i(10, 8))
	for y in range(8):
		world.grid.set_blocked(Vector2i(5, y), -1)
	var unit := agent(world, Vector2i(2, 3))
	world.command_move([unit.id], Vector2i(8, 3))
	step_for(world, 5)
	check(unit.cell == Vector2i(2, 3), "Impossible order must not teleport or silently move elsewhere.")
	check("unreachable" in unit.status, "Unreachable destination must be visible.")
	check(world.paths.queries_total == 0, "Disconnected regions should be rejected before A*.")


func corridor_world(width: int = 14) -> RtsSimulation:
	var world := RtsSimulation.new(Vector2i(width, 5))
	for x in range(width):
		for y in [0, 1, 3, 4]:
			world.grid.set_blocked(Vector2i(x, y), -1)
	return world


func test_opposing_corridor_traffic() -> void:
	var world := corridor_world()
	var left := agent(world, Vector2i(2, 2))
	var right := agent(world, Vector2i(11, 2))
	navigate(world, left, Vector2i(11, 2))
	navigate(world, right, Vector2i(2, 2))
	var safe := true
	for i in range(450):
		world.step()
		if world.motion_alpha() < 0.0001:
			safe = safe and motion_is_safe(world)
	check(left.cell.x == 11 and right.cell.x == 2, "Opposing units must pass in the one-cell corridor.")
	check(safe, "Opposing movement has a collision/terrain violation.")
	check(world.traffic.swaps_total > 0, "The passing case must actually exercise coordinated passing.")


func test_opposing_groups() -> void:
	var world := RtsSimulation.new(Vector2i(48, 24))
	for y in range(24):
		for x in range(22, 26):
			if y != 12:
				world.grid.set_blocked(Vector2i(x, y), -1)
	var west: Array[int] = []
	var east: Array[int] = []
	for y in range(4, 10):
		for x in range(3, 7):
			west.append(agent(world, Vector2i(x, y)).id)
			east.append(agent(world, Vector2i(41 + x - 3, y)).id)
	world.command_move(west, Vector2i(39, 16))
	world.command_move(east, Vector2i(8, 16))
	var finished := false
	var safe := true
	for i in range(6000):
		world.step()
		if world.motion_alpha() < 0.0001:
			safe = safe and motion_is_safe(world)
		if i % 25 == 0 and all_settled(world):
			finished = true
			for id in west:
				finished = finished and world.agents[id].cell.x > 26
			for id in east:
				finished = finished and world.agents[id].cell.x < 22
			if finished:
				break
	check(finished, "Two opposing 24-unit groups must clear the narrow pass.")
	check(safe, "Opposing groups must keep continuous bodies separated.")


func test_four_unit_cycle() -> void:
	var world := RtsSimulation.new(Vector2i(4, 4))
	var positions: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2), Vector2i(1, 2)]
	var units: Array[VillagerAgent] = []
	for cell in positions:
		units.append(agent(world, cell))
	for i in range(4):
		units[i].path = [positions[(i + 1) % 4]]
	world.traffic.advance(world.agents, world.grid)
	check(world.traffic.moves_last_step == 4, "A fully occupied four-cell cycle must not deadlock.")
	check(motion_is_safe(world), "Atomic cycle motion must keep continuous bodies separated.")


func test_idle_blocker_yields() -> void:
	var world := corridor_world()
	var moving := agent(world, Vector2i(1, 2))
	var resting := agent(world, Vector2i(6, 2))
	resting.cargo_kind = 1
	resting.cargo = 3
	navigate(world, moving, Vector2i(11, 2))
	check(step_until(world, func() -> bool: return moving.cell.x == 11 and all_settled(world), 700),
		"An idle friendly unit must not permanently plug a corridor.")
	check(resting.cargo == 3, "Yielding must preserve cargo.")


func test_all_resource_kinds_conserved() -> void:
	var world := RtsSimulation.new(Vector2i(18, 14))
	world.add_building("town_center", Vector2i(2, 5), true)
	for kind in range(4):
		var resource := world.add_resource(kind, Rect2i(Vector2i(11, 2 + kind * 3), Vector2i.ONE), 13)
		var first := agent(world, Vector2i(7, 2 + kind * 3))
		var second := agent(world, Vector2i(8, 2 + kind * 3))
		world.command_gather([first.id, second.id], resource.id)
	var conserved := true
	var finished := false
	for i in range(6000):
		world.step()
		for kind in range(4):
			var total := world.bank.amount(kind)
			for resource: GatherableResource in world.resources.values():
				if resource.kind == kind:
					total += resource.remaining
			for unit: VillagerAgent in world.agents.values():
				if unit.cargo_kind == kind:
					total += unit.cargo
			conserved = conserved and total == 13
		finished = true
		for kind in range(4):
			finished = finished and world.bank.amount(kind) == 13
		if finished:
			break
	if not finished:
		print("ECONOMY DIAGNOSTIC bank=",world.bank.snapshot(), " claims=",world.slot_claims)
		for unit: VillagerAgent in world.agents.values():
			print({"id":unit.id,"cell":str(unit.cell),"goal":str(unit.goal),"state":unit.state,"nav":unit.nav_status,"wait":unit.wait_steps,"path":unit.path,"cargo":unit.cargo,"resource":unit.resource_id,"building":unit.building_id})
	check(finished, "All four resource types must finish their gather/return/deposit loop.")
	check(conserved, "Remaining + carried + deposited resources must stay constant every tick.")
	check(is_equal_approx(world.gather_rate(1), 0.429), "Bundschuh Wood bonus applies to work rate once.")


func test_partial_cargo_survives_job_switch() -> void:
	var world := RtsSimulation.new(Vector2i(16, 10))
	world.add_building("town_center", Vector2i(1, 3), true)
	var food := world.add_resource(0, Rect2i(9, 2, 1, 1), 20)
	var wood := world.add_resource(1, Rect2i(9, 7, 1, 1), 7)
	var worker := agent(world, Vector2i(7, 2))
	world.command_gather([worker.id], food.id)
	check(step_until(world, func() -> bool: return worker.cargo == 2), "Worker should acquire a partial load.")
	var harvested_food := 20 - food.remaining
	check(world.bank.amount(0) == 0, "Gathering alone cannot increment global stock.")
	world.command_gather([worker.id], wood.id)
	check(step_until(world, func() -> bool: return world.bank.amount(1) == 7, 3500),
		"Worker must finish the replacement job.")
	check(world.bank.amount(0) == harvested_food, "Switching kind must deliver old cargo first.")
	check(worker.cargo == 0, "Final partial load must not remain stranded.")


func test_missing_and_unfinished_dropoffs() -> void:
	var world := RtsSimulation.new(Vector2i(14, 10))
	var resource := world.add_resource(2, Rect2i(9, 5, 1, 1), 13)
	var worker := agent(world, Vector2i(7, 5))
	world.command_gather([worker.id], resource.id)
	step_for(world, 50)
	check(worker.cargo == 10 and world.bank.amount(2) == 0, "No drop-off: retain full cargo and wait.")
	var building := world.add_building("mining_camp", Vector2i(2, 4), false)
	step_for(world, 20)
	check(worker.cargo == 10 and world.bank.amount(2) == 0, "Unfinished camp must not accept cargo.")
	building.apply_work(building.required_work)
	check(step_until(world, func() -> bool: return world.bank.amount(2) == 13, 2500),
		"Waiting workers must resume when a compatible drop-off completes.")


func test_destroyed_dropoff_reroutes() -> void:
	var world := RtsSimulation.new(Vector2i(20, 10))
	var original := world.add_building("mining_camp", Vector2i(1, 4), true)
	var resource := world.add_resource(3, Rect2i(10, 5, 1, 1), 5)
	var worker := agent(world, Vector2i(8, 5))
	world.command_gather([worker.id], resource.id)
	check(step_until(world, func() -> bool:
		return worker.state == VillagerAgent.State.RETURN_TO_DROPOFF), "Worker enters return state.")
	world.remove_building(original.id)
	world.add_building("mining_camp", Vector2i(16, 4), true)
	check(step_until(world, func() -> bool: return world.bank.amount(3) == 5, 2000),
		"Destroyed destination must retarget without duplicating/deleting cargo.")


func test_placement_validation_and_transaction() -> void:
	var world := RtsSimulation.new(Vector2i(16, 12))
	world.bank.credit(1, 100)
	var worker := agent(world, Vector2i(3, 4))
	world.add_resource(1, Rect2i(8, 8, 1, 1), 10)
	check(not world.validate_placement("house", Vector2i(-1, 0), [worker.id])["ok"], "Reject out-of-bounds footprint.")
	check(not world.validate_placement("house", worker.cell, [worker.id])["ok"], "Reject occupied footprint.")
	check(not world.validate_placement("house", Vector2i(8, 8), [worker.id])["ok"], "Reject resource obstruction.")
	check(not world.validate_placement("house", Vector2i(10, 3), [])["ok"], "Require an accessible builder.")
	for i in range(20):
		world.validate_placement("house", Vector2i(10, 3), [worker.id])
	check(world.bank.amount(1) == 100, "Preview cannot spend resources.")
	var building := world.place_building("house", Vector2i(10, 3), [worker.id])
	check(building != null and building.hp == 0.0, "New foundation starts at zero HP.")
	check(world.bank.amount(1) == 75, "Placing a House debits 25 Wood once.")
	check(world.place_building("house", Vector2i(10, 3), [worker.id]) == null, "Duplicate placement must fail.")
	check(world.bank.amount(1) == 75, "Rejected placement cannot debit again.")
	navigate(world, worker, Vector2i(4, 4))
	world.step()
	# Covers a unit between two cells, including its OLD cell.
	check(not world.validate_placement("house", worker.from_cell, [worker.id])["ok"],
		"Placement must reserve swept origin as well as logical destination.")


func test_multi_worker_construction() -> void:
	var world := RtsSimulation.new(Vector2i(16, 12))
	world.bank.credit(1, 100)
	var a := agent(world, Vector2i(5, 3))
	var b := agent(world, Vector2i(5, 4))
	var building := world.place_building("house", Vector2i(8, 3), [a.id, b.id])
	var events := [0]
	world.building_finished.connect(func(_id: int) -> void: events[0] += 1)
	var previous_hp := 0.0
	var monotonic := true
	var worked_together := false
	for i in range(1600):
		world.step()
		monotonic = monotonic and building.hp >= previous_hp and building.hp <= building.max_hp
		previous_hp = building.hp
		worked_together = worked_together or (a.state == VillagerAgent.State.BUILD and b.state == VillagerAgent.State.BUILD)
		if building.finished:
			break
	check(building.finished and building.hp == building.max_hp, "Builders must finish at MaxHP.")
	check(monotonic and worked_together, "Multiple adjacent builders must contribute monotonic work.")
	check(world.time < 25.0, "Two builders should finish before one worker's 25s work requirement plus travel.")
	step_for(world, 3)
	check(events[0] == 1 and world.housing == 5, "Completion/housing effect fires exactly once.")


func test_dynamic_obstacle_repath() -> void:
	var world := RtsSimulation.new(Vector2i(22, 10))
	world.bank.credit(1, 100)
	var walker := agent(world, Vector2i(1, 4))
	var builder := agent(world, Vector2i(9, 8))
	navigate(world, walker, Vector2i(19, 4))
	step_for(world, 2)
	var foundation := world.place_building("house", Vector2i(9, 4), [builder.id])
	check(foundation != null, "Test must add a new obstacle on an existing route.")
	var safe := true
	for i in range(1200):
		world.step()
		safe = safe and world.grid.walkable(walker.cell)
		if walker.cell == Vector2i(19, 4) and not walker.in_transit(world.motion_alpha()):
			break
	check(walker.cell == Vector2i(19, 4) and safe, "Existing route must detour around a new foundation.")


func test_interrupted_job_releases_slot() -> void:
	var world := RtsSimulation.new(Vector2i(10, 10))
	var resource := world.add_resource(1, Rect2i(6, 6, 1, 1), 10)
	var worker := agent(world, Vector2i(4, 6))
	world.command_gather([worker.id], resource.id)
	world.step()
	check(not world.slot_claims.is_empty(), "Gather command claims an interaction cell.")
	world.command_stop([worker.id])
	check(world.slot_claims.is_empty(), "Stopping must release interaction claims.")
	step_for(world, 2)
	check(worker.state == VillagerAgent.State.IDLE and worker.path.is_empty(), "Stale requests cannot restart a stopped job.")


func test_200_unit_chokepoint() -> void:
	var world := RtsSimulation.new(Vector2i(60, 30))
	for y in range(30):
		for x in range(25, 30):
			if y != 15:
				world.grid.set_blocked(Vector2i(x, y), -1)
	for y in range(10):
		for x in range(20):
			agent(world, Vector2i(x, y))
	check(world.agents.size() == 200, "Stress fixture must contain 200 actual simulation units.")
	check(agent(world, Vector2i(1, 20)) == null, "Stage 1 hard cap must reject unit 201.")
	world.command_move(ids(world), Vector2i(47, 15))
	var safe := true
	var complete := false
	var max_queries := 0
	var step_ms: Array[float] = []
	for i in range(12000):
		var before := Time.get_ticks_usec()
		world.step()
		step_ms.append((Time.get_ticks_usec() - before) / 1000.0)
		max_queries = maxi(max_queries, world.paths.queries_last_tick)
		if world.motion_alpha() < 0.0001:
			safe = safe and motion_is_safe(world)
		if i % 25 == 0 and all_settled(world):
			complete = true
			for unit: VillagerAgent in world.agents.values():
				complete = complete and unit.cell.x > 30 and unit.cell == unit.goal
			if complete:
				break
	step_ms.sort()
	metrics["chokepoint_200"] = {
		"units": world.agents.size(), "map": "60x30", "pass_width_cells": 1,
		"completed": complete, "simulated_seconds": world.time, "safe_motion": safe,
		"step_ms_p50": step_ms[int(step_ms.size() * 0.50)],
		"step_ms_p95": step_ms[int(step_ms.size() * 0.95)],
		"step_ms_max": step_ms.back(), "max_astar_queries_per_tick": max_queries,
		"cpu": OS.get_processor_name(), "rendering": "excluded / headless"}
	if not complete:
		var west: Array = []
		for unit: VillagerAgent in world.agents.values():
			if unit.cell.x <= 30 or not unit.path.is_empty() or unit.request_pending:
				west.append({"id":unit.id,"cell":str(unit.cell),"goal":str(unit.goal),"state":unit.state,"nav":unit.nav_status,"wait":unit.wait_steps,"path":unit.path.size()})
		print("STRESS DIAGNOSTIC ", JSON.stringify(west.slice(0, 25)))
	check(complete, "All 200 villagers must cross and settle within 600 simulated seconds.")
	check(safe, "200-unit traffic must preserve cell and continuous-body separation.")
	check(max_queries <= world.paths.max_queries_per_tick, "Stress case must respect A* budget.")


func test_main_scene_and_hud() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	var main = scene.instantiate()
	root.add_child(main)
	check(main.world.agents.size() == 16, "F5 main scene should create the default demo.")
	var old_wood: int = main.world.bank.amount(1)
	main.world.bank.credit(1, 7)
	check(str(old_wood + 7) in main.stock_labels[1].text, "Global HUD must react to bank signal.")
	main._select_all()
	check(main.selected.size() == 16, "Select-all should select actual model units.")
	main._begin_placement("house")
	check(main.placing == "house", "Construction button should enter placement mode.")
	main._toggle_pause()
	check(main.paused, "Pause control should stop advancing simulation.")
	main._reset(true)
	check(main.world.agents.size() == 200 and main.selected.size() == 200, "Stress button resets to the 200-unit fixture.")
	main.free()
