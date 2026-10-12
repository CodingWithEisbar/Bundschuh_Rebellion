extends SceneTree
## Real generator, combat, economy and physics callbacks. No mocked LOS signals.

const T = CombatTypes.UnitType
const F = CombatTypes.Faction
const TILE = GeneratedMap.Tile
var failures: Array[String] = []
var completed: Array[String] = []
var checks: int = 0
var metrics: Dictionary = {}
var default_map: GeneratedMap


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var cases: Array[Callable] = [test_seed_reproduction, test_rng_isolation,
		test_map_seed_sweep, test_corridor_widths, test_invalid_recipes,
		test_bounded_failure, test_large_map, test_runtime_resource_adapter,
		test_runtime_gather_and_travel, test_height_damage_order,
		test_equal_lower_and_rounding, test_bound_terrain_and_actual_center,
		test_explicit_height_and_bounds, test_flat_building_placement,
		test_partial_exposure_and_filters, test_overlapping_guards,
		test_rearm_and_three_detections, test_guard_cleanup_and_pause,
		test_config_snapshot_and_completion, test_simulation_clock_bridge,
		test_real_los_colliders]
	for test in cases:
		var before := failures.size()
		await test.call()
		if failures.size() == before:
			completed.append(test.get_method())
			print("PASS ", test.get_method())
		else:
			print("FAIL ", test.get_method())
	var report := {"passed": completed.size(), "total": cases.size(), "checks": checks,
		"failed_assertions": failures, "metrics": metrics,
		"engine": Engine.get_version_info()["string"]}
	DirAccess.make_dir_recursive_absolute("res://test-results")
	var file := FileAccess.open("res://test-results/stage3.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	print("STAGE 3: %d / %d cases; %d checks; %d failures" % [completed.size(), cases.size(), checks, failures.size()])
	quit(0 if failures.is_empty() else 1)


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)


func near(actual: float, expected: float, message: String) -> void:
	check(absf(actual - expected) < 0.00001, "%s: %.8f != %.8f" % [message, actual, expected])


func advance(mission: MissionTriggerManager, seconds: float, chunk: float = 0.05) -> void:
	var remaining := seconds
	while remaining > 0.0000001:
		var delta := minf(chunk, remaining)
		mission.advance(delta)
		remaining -= delta


func recipe(seed_value: int = 1524) -> BlackForestConfig:
	var config := BlackForestConfig.new()
	config.seed_value = seed_value
	return config


func test_seed_reproduction() -> void:
	var config := load("res://data/maps/black_forest_default.tres") as BlackForestConfig
	default_map = BlackForestGenerator.generate(config)
	var again := BlackForestGenerator.generate(config)
	check(default_map.valid(), "Default recipe yields a valid map")
	check(default_map.signature() == again.signature(), "Identical recipe reproduces cells, heights, spawns and deposits")
	check(default_map.signature() == "09b54894c0bf28c16aeb94d23bdff881d2e0c4acf75054e1aa84b5b1ebed6022", "Pinned Godot/generator version fingerprint")
	check(default_map.signature() != BlackForestGenerator.generate(recipe(1525)).signature(), "A different seed changes the map")
	var mutable := recipe()
	var snapshot := BlackForestGenerator.generate(mutable)
	mutable.wood_per_tree = 777
	check(snapshot.recipe.wood_per_tree == 100, "Generated resource yields snapshot editor configuration")
	metrics["default_map"] = default_map.statistics()


func test_rng_isolation() -> void:
	seed(831)
	var expected := randi()
	seed(831)
	BlackForestGenerator.generate(recipe())
	check(randi() == expected, "Generation leaves global gameplay RNG untouched")
	randf()
	check(default_map.signature() == BlackForestGenerator.generate(recipe()).signature(), "Global random draws do not change seeded maps")


func test_map_seed_sweep() -> void:
	var timings: Array[float] = []
	for value in [0, 1, 2, 17, 42, 1524, 1525, -17, 991, 999999]:
		var started := Time.get_ticks_usec()
		var map := BlackForestGenerator.generate(recipe(value))
		timings.append((Time.get_ticks_usec() - started) / 1000.0)
		check(map.valid(), "Seed %d produces a reachable map: %s" % [value, map.errors])
		if not map.valid():
			continue
		var seen := map.reachable(map.spawns[0])
		check(seen[map.index(map.spawns[1])] == 1, "Both spawn clearings connect")
		check(BlackForestGenerator.validate_map(map).is_empty(), "All ground/mines are accessible and requested veins exist")
		var stats := map.statistics()
		check(stats["forest_fraction"] >= 0.45 and stats["forest_fraction"] <= 0.75, "Tested default seeds produce dense forest")
		check(stats["gold_tiles"] >= 12 and stats["gold_tiles"] <= 24 and stats["stone_tiles"] >= 8 and stats["stone_tiles"] <= 16, "Sparse ore quantities respect 6/4 veins of 2..4 cells")
		var clustered := 0
		var forest := 0
		for y in range(map.size.y):
			for x in range(map.size.x):
				var cell := Vector2i(x, y)
				if map.tile_at(cell) != TILE.FOREST:
					continue
				forest += 1
				var neighbors := 0
				for direction in WorldGrid.DIRECTIONS:
					neighbors += int(map.tile_at(cell + direction) == TILE.FOREST)
				clustered += int(neighbors >= 2)
		check(float(clustered) / forest > 0.9, "Forest tiles form clusters rather than isolated random obstacles")
	timings.sort()
	metrics["generation_64x40"] = {"seeds": timings.size(), "ms_median": timings[5], "ms_max": timings[-1], "cpu": OS.get_processor_name()}


func test_corridor_widths() -> void:
	for width in [1, 3, 5]:
		var config := recipe(42)
		config.corridor_width = width
		config.map_size = Vector2i(48, 32)
		config.gold_veins = 1
		config.stone_veins = 1
		var map := BlackForestGenerator.generate(config)
		check(map.valid(), "Smallest map supports width %d" % width)
		if not map.valid():
			continue
		var open_count := 0
		var middle := floori(map.size.x * 0.5)
		for y in range(map.size.y):
			open_count += int(map.tile_at(Vector2i(middle, y)) == TILE.GRASS)
		check(open_count == 3 * width, "Only three exact-width passages cross the initial forest spine")
		check(map.corridors.size() == 3 and map.chokepoints.size() == 3, "Generator exposes route and choke metadata")
		for choke in map.chokepoints:
			var count := 0
			for y in range(choke.position.y, choke.end.y):
				for x in range(choke.position.x, choke.end.x):
					count += int(map.tile_at(Vector2i(x, y)) == TILE.GRASS)
			check(count == width * 5, "Minerals do not block a protected passage")


func test_invalid_recipes() -> void:
	for field in ["map_size", "initial_forest", "corridor_width", "gold_veins", "vein_max_length", "max_attempts", "wood_per_tree"]:
		var config := recipe()
		var invalid: Dictionary = {"map_size": Vector2i(10000, 10000), "initial_forest": NAN,
			"corridor_width": 2, "gold_veins": -1, "vein_max_length": 9, "max_attempts": 0, "wood_per_tree": 0}
		config.set(field, invalid[field])
		var map := BlackForestGenerator.generate(config)
		check(not map.valid() and map.tiles.is_empty() and not map.errors.is_empty(), "Invalid %s rejects before allocating map" % field)
	check(not BlackForestGenerator.generate(null).valid(), "Null recipe is rejected")
	check(BlackForestFactory.create(GeneratedMap.new()) == null, "Factory rejects an invalid result")


func test_bounded_failure() -> void:
	var config := recipe(2)
	config.map_size = Vector2i(48, 32)
	config.initial_forest = 0.75
	config.smoothing_steps = 6
	config.gold_veins = 20
	config.stone_veins = 4
	config.vein_min_length = 5
	config.vein_max_length = 5
	config.max_attempts = 2
	var map := BlackForestGenerator.generate(config)
	check(not map.valid() and map.attempt == 1, "Over-demanded recipe stops after the configured attempts")
	check(map.errors[0].begins_with("Generation exhausted 2"), "Failure explains exhausted retries rather than returning a broken playable map")


func test_large_map() -> void:
	var config := recipe(1525)
	config.map_size = Vector2i(160, 160)
	var started := Time.get_ticks_usec()
	var map := BlackForestGenerator.generate(config)
	check(map.valid(), "160x160 supports the same connectivity invariants")
	metrics["generation_160x160"] = {"ms": (Time.get_ticks_usec() - started) / 1000.0, "statistics": map.statistics()}


func test_runtime_resource_adapter() -> void:
	var world := BlackForestFactory.create(default_map)
	check(world != null and world.agents.size() == 16 and world.housing == 16, "Playable factory provides 16 workers and explicit housing")
	check(world.mission == null and world.combat == null, "Map selection does not enable campaign mechanics")
	check(world.grid.elevations == default_map.elevations, "Height data reaches the authoritative grid")
	var totals := {0: 0, 1: 0, 2: 0, 3: 0}
	var good := true
	for resource: GatherableResource in world.resources.values():
		totals[resource.kind] += resource.remaining
		good = good and world.grid.blockers.get(resource.footprint.position) == resource.id
	check(good, "Each finite tree/ore node owns its static collision cell")
	var stats := default_map.statistics()
	check(totals[2] == stats["gold_tiles"] * 800 and totals[3] == stats["stone_tiles"] * 350, "Factory preserves all finite ore budgets")
	check(totals[0] == 450 and totals[1] == default_map.tiles.count(TILE.FOREST) * 100, "Food grant and finite forest yield are explicit")
	var first: GatherableResource = world.resources.values()[0]
	var cell := first.footprint.position
	var initial := first.remaining
	check(first.take(initial + 1) == initial and first.remaining == 0, "Generated trees cannot duplicate final resources")
	check(world.grid.walkable(cell), "Depleting a generated tree opens its navigation cell")


func test_runtime_gather_and_travel() -> void:
	var world := BlackForestFactory.create(default_map)
	var ids: Array[int] = []
	ids.assign(world.agents.keys())
	var worker: VillagerAgent = world.agents[ids[0]]
	var tree := world.nearest_resource(ResourceKind.Type.WOOD, worker.cell)
	check(tree != null, "Spawn workers can reach a generated tree")
	var before := world.bank.amount(ResourceKind.Type.WOOD)
	world.command_gather([worker.id], tree.id)
	for i in range(2400):
		world.step()
	check(world.bank.amount(ResourceKind.Type.WOOD) > before, "Generated map completes gathering and deposits into the existing HUD bank")
	world.command_stop([worker.id])
	world.command_move(ids, default_map.spawns[1])
	for i in range(3000):
		world.step()
	var arrived := 0
	for agent: VillagerAgent in world.agents.values():
		arrived += int(agent.cell == agent.goal and not agent.in_transit(world.motion_alpha()))
	check(arrived == 16, "All 16 workers cross a generated corridor and settle at distinct goals")
	check(world.occupied_cells(false).size() == 16, "Generated-map travel preserves exclusive destinations")


func soldier(kind: int) -> CombatUnit:
	return CombatUnit.new(1, 0, 0, F.BUNDSCHUH, Vector2.ZERO, CombatUnitCatalog.definition(kind))


func test_height_damage_order() -> void:
	var pike := soldier(T.PIKEMAN)
	var rider := soldier(T.ARMOURED_RITTER)
	pike.elevation = 1.0
	var hit := DamageCalculator.calculate(pike, rider)
	check(hit["normal"] == 2 and hit["bonus"] == 25 and hit["subtotal"] == 27, "Armor and cavalry counter resolve before height")
	check(hit["total"] == 34 and hit["height_bonus"] == 7, "27 x 1.25 rounds half up to 34")
	near(hit["height_multiplier"], 1.25, "High ground coefficient")
	pike.elevation = 100.0
	check(DamageCalculator.calculate(pike, rider)["total"] == 34, "Bonus does not stack per height level")
	rider.melee_armor = 999
	check(DamageCalculator.calculate(pike, rider)["total"] == 33, "Minimum normal 1 + counter 25 becomes 32.5 -> 33")


func test_equal_lower_and_rounding() -> void:
	var pike := soldier(T.PIKEMAN)
	var rider := soldier(T.ARMOURED_RITTER)
	pike.position.y = 500
	check(DamageCalculator.calculate(pike, rider)["total"] == 27, "Screen/map Y never grants high ground")
	rider.elevation = 2
	check(DamageCalculator.calculate(pike, rider)["total"] == 27, "No unrequested low-ground penalty")
	pike.elevation = 2
	check(DamageCalculator.calculate(pike, rider)["total"] == 27, "Equal elevations are neutral")
	check(HighGroundDamage.apply(1, 1, 0) == 1 and HighGroundDamage.apply(2, 1, 0) == 3, "Integer HP rounds exactly once, including ties")
	var preacher := soldier(T.RADICAL_PREACHER)
	preacher.elevation = 10
	check(DamageCalculator.calculate(preacher, rider)["total"] == 0, "Height cannot turn a support unit into an attacker")


func test_bound_terrain_and_actual_center() -> void:
	var sim := RtsSimulation.new(Vector2i(8, 8))
	sim.grid.set_height(Vector2i(1, 1), 1)
	var combat := sim.enable_combat()
	combat.add_player(1, 1, F.SWABIAN_LEAGUE, ResourceBank.new())
	var pike := combat.spawn(T.PIKEMAN, 0, Vector2(1.9, 1.5))
	var rider := combat.spawn(T.ARMOURED_RITTER, 1, Vector2(2.4, 1.5))
	check(pike.elevation == 1 and rider.elevation == 0, "Bound terrain samples floor(actual center)")
	check(not combat.set_elevation(pike.id, 5), "Manual height cannot override bound terrain")
	combat.command_attack(0, pike.id, rider.id)
	sim.step()
	check(rider.hp == rider.max_hp - 34, "The real combat hit uses high-ground total")
	combat.set_position(pike.id, Vector2(2.01, 1.5))
	near(pike.elevation, 0, "Crossing the physical tile edge updates elevation")
	pike.recovery_work = 0
	sim.grid.set_height(Vector2i(2, 1), 3)
	sim.step()
	check(rider.hp == rider.max_hp - 34 - 27, "Both target and attacker resample edited terrain before the next hit")


func test_explicit_height_and_bounds() -> void:
	var combat := CombatWorld.new()
	combat.add_player(0, 0, F.BUNDSCHUH, ResourceBank.new())
	var pike := combat.spawn(T.PIKEMAN, 0, Vector2(-1, -1))
	check(combat.set_elevation(pike.id, -2.0), "Unbound 3D adapter accepts real finite vertical coordinates")
	check(not combat.set_elevation(pike.id, NAN), "Nonfinite height rejected")
	var grid := WorldGrid.new(Vector2i(8, 8))
	check(not combat.bind_terrain(grid), "Binding rejects an existing out-of-map body atomically")
	combat.set_position(pike.id, Vector2.ONE)
	check(combat.bind_terrain(grid), "Binding succeeds with valid bodies")
	check(not combat.set_position(pike.id, Vector2(-0.01, 1)), "Negative fractional centers cannot truncate into the map")
	check(combat.spawn(T.PIKEMAN, 0, Vector2(8, 1)) == null, "Bound terrain rejects out-of-bounds spawn")
	check(not combat.set_position(pike.id, Vector2(INF, 0)), "Nonfinite centers rejected")


func test_flat_building_placement() -> void:
	var sim := RtsSimulation.new(Vector2i(12, 12))
	sim.bank.credit(ResourceKind.Type.WOOD, 1000)
	var builder := sim.add_agent(Vector2i(1, 1), true)
	check(sim.validate_placement("house", Vector2i(4, 4), [builder.id])["ok"], "Flat footprint remains buildable")
	sim.grid.set_height(Vector2i(5, 5), 1)
	check(not sim.validate_placement("house", Vector2i(4, 4), [builder.id])["ok"], "Foundation cannot straddle terrace heights")
	check(sim.grid.walkable(Vector2i(5, 5)), "Height is traversable unless explicitly blocked as a cliff")


func mission_with_guard(config: StealthMissionConfig = null) -> MissionTriggerManager:
	var mission := MissionTriggerManager.new(config)
	mission.register_guard(&"guard_a", 1)
	return mission


func test_partial_exposure_and_filters() -> void:
	var mission := mission_with_guard()
	mission.register_guard(&"friend", 0)
	check(not mission.report_los(&"friend", &"joss_fritz", true), "Friendly observers do not detect hero")
	check(not mission.report_los(&"unknown", &"joss_fritz", true), "Unregistered guard ignored")
	check(not mission.report_los(&"guard_a", &"villager", true), "Other actors ignored")
	mission.report_los(&"guard_a", &"joss_fritz", true)
	advance(mission, 1.0)
	near(mission.meter, 50, "One second produces half exposure")
	check(mission.detections == 0, "Brief contact is not a confirmed detection")
	mission.report_los(&"guard_a", &"joss_fritz", false)
	advance(mission, 0.5)
	near(mission.meter, 25, "Unseen meter decays at configured rate")
	mission.report_los(&"guard_a", &"joss_fritz", true)
	advance(mission, 1.5)
	check(mission.detections == 1 and not mission.armed, "Remaining exposure contributes to the first detection")


func test_overlapping_guards() -> void:
	var mission := mission_with_guard()
	mission.register_guard(&"guard_b", 1)
	for id in [&"guard_a", &"guard_a", &"guard_b"]:
		mission.report_los(id, &"joss_fritz", true)
	advance(mission, 1.0)
	near(mission.meter, 50, "Multiple/duplicate guards do not multiply fill rate")
	mission.report_los(&"guard_a", &"joss_fritz", false)
	advance(mission, 1.0)
	check(mission.detections == 1, "Leaving one guard while another sees hero continues exposure")
	advance(mission, 15.0)
	check(mission.detections == 1 and mission.state == MissionTriggerManager.State.ACTIVE, "One continuous sighting cannot cause three detections")


func test_rearm_and_three_detections() -> void:
	var mission := mission_with_guard()
	var events: Array[Dictionary] = []
	mission.mission_failed.connect(func(event: Dictionary) -> void: events.append(event))
	for episode in range(3):
		mission.report_los(&"guard_a", &"joss_fritz", true)
		advance(mission, 2.0)
		check(mission.detections == episode + 1, "A full rearmed episode counts once")
		if episode < 2:
			mission.report_los(&"guard_a", &"joss_fritz", false)
			advance(mission, 1.0)
			mission.report_los(&"guard_a", &"joss_fritz", true)
			advance(mission, 3.0)
			check(mission.detections == episode + 1 and not mission.armed, "Premature reentry does not count again")
			mission.report_los(&"guard_a", &"joss_fritz", false)
			advance(mission, 2.0)
			check(mission.armed and mission.meter == 0, "Fully unseen/cool meter rearms")
	check(events.size() == 1 and mission.state == MissionTriggerManager.State.FAILED, "Third detection emits exactly one terminal MissionFailed event")
	advance(mission, 30)
	check(events.size() == 1 and not mission.complete(), "Failed mission cannot emit again or be completed later")
	check(not mission.report_los(&"guard_a", &"joss_fritz", false), "Terminal mission ignores new visibility gameplay events")


func test_guard_cleanup_and_pause() -> void:
	var mission := mission_with_guard()
	mission.report_los(&"guard_a", &"joss_fritz", true)
	mission.paused = true
	advance(mission, 3.0)
	near(mission.meter, 0, "Pause freezes exposure")
	mission.paused = false
	advance(mission, 1.0)
	mission.set_guard_enabled(&"guard_a", false)
	advance(mission, 1.0)
	near(mission.meter, 0, "Disabling a guard clears stale sighting")
	check(not mission.report_los(&"guard_a", &"joss_fritz", true), "Disabled guard cannot report exposure")
	mission.set_guard_enabled(&"guard_a", true)
	mission.report_los(&"guard_a", &"joss_fritz", true)
	mission.unregister_guard(&"guard_a")
	advance(mission, 3)
	check(mission.detections == 0 and mission.snapshot()["visible_guards"] == 0, "Guard destruction releases exposure without relying on body_exit")


func test_config_snapshot_and_completion() -> void:
	var config := StealthMissionConfig.new()
	config.exposure_seconds = 1
	config.rearm_unseen_seconds = 3
	config.detection_limit = 1
	var mission := mission_with_guard(config)
	config.detection_limit = 10
	mission.report_los(&"guard_a", &"joss_fritz", true)
	advance(mission, 1, 0.25)
	check(mission.state == MissionTriggerManager.State.FAILED, "Mission snapshots the scenario config")
	var safe := mission_with_guard()
	var events: Array[Dictionary] = []
	safe.mission_completed.connect(func(event: Dictionary) -> void: events.append(event))
	safe.report_los(&"guard_a", &"joss_fritz", true)
	check(safe.complete() and not safe.complete(), "Completion latches once")
	advance(safe, 10)
	check(events.size() == 1 and safe.detections == 0, "Completed mission cannot later fail from LOS")
	config.exposure_seconds = 0
	check(not config.validate().is_empty(), "Zero exposure rejected before divide")
	check(RtsSimulation.new().enable_stealth(config) == null, "Host bridge rejects invalid scenario configuration")


func test_simulation_clock_bridge() -> void:
	var a := RtsSimulation.new(Vector2i(8, 8))
	var mission := a.enable_stealth()
	check(a.enable_stealth() == mission, "Re-enabling does not reset mission counts")
	mission.register_guard(&"guard_a", 1)
	mission.report_los(&"guard_a", &"joss_fritz", true)
	for i in range(40):
		a.step()
	check(mission.detections == 1, "The root simulation advances mission exactly once per tick")
	var other := mission_with_guard()
	other.report_los(&"guard_a", &"joss_fritz", true)
	advance(other, 2.0, 0.25)
	check(other.detections == mission.detections and other.state == mission.state and other.armed == mission.armed,
		"Different host chunk sizes preserve the detection boundary")
	near(other.elapsed, mission.elapsed, "Chunked clocks differ only by floating-point precision")
	near(other.meter, mission.meter, "Chunked clocks agree on exposure")


func body_at(point: Vector2) -> CharacterBody2D:
	var body := CharacterBody2D.new()
	body.position = point
	body.collision_layer = 1
	body.collision_mask = 0
	# Multiple hero shapes still generate one logical body enter/exit episode.
	for offset in [-2, 2]:
		var collider := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 3
		collider.shape = shape
		collider.position.x = offset
		body.add_child(collider)
	return body


func settle_physics() -> void:
	for i in range(4):
		await physics_frame
	await process_frame


func test_real_los_colliders() -> void:
	var scene := Node2D.new()
	root.add_child(scene)
	var hero := body_at(Vector2(100, 0))
	var decoy := body_at(Vector2.ZERO)
	scene.add_child(hero)
	scene.add_child(decoy)
	var mission := mission_with_guard()
	var guards: Array[GuardLosArea] = []
	for index in range(2):
		var guard := GuardLosArea.new()
		guard.collision_layer = 0
		guard.collision_mask = 1
		var collider := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 25
		collider.shape = shape
		guard.add_child(collider)
		guard.configure(mission, StringName("physical_%d" % index), 1, hero)
		scene.add_child(guard)
		guards.append(guard)
	await settle_physics()
	check(mission.snapshot()["visible_guards"] == 0, "Real decoy overlap does not detect the bound protagonist")
	hero.position = Vector2.ZERO
	await settle_physics()
	check(mission.snapshot()["visible_guards"] == 2, "Actual physics enter callbacks register both guards once")
	advance(mission, 2)
	check(mission.detections == 1, "Two shapes/two guards still give one real detection")
	guards[0].set_guard_active(false)
	await settle_physics()
	check(mission.snapshot()["visible_guards"] == 1, "Disabling a live collider removes only its contribution")
	guards[0].set_guard_active(true)
	await settle_physics()
	check(mission.snapshot()["visible_guards"] == 2, "Reenabled overlapping guard resumes observation")
	hero.position = Vector2(100, 0)
	await settle_physics()
	check(mission.snapshot()["visible_guards"] == 0, "Actual physics exit callbacks clear both contributions")
	advance(mission, 2)
	hero.position = Vector2.ZERO
	await settle_physics()
	advance(mission, 2)
	check(mission.detections == 2, "A second real exposure episode counts after rearming")
	guards[0].queue_free()
	await settle_physics()
	check(mission.snapshot()["visible_guards"] == 1, "Freeing a guard inside overlap unregisters its sighting")
	hero.queue_free()
	await settle_physics()
	check(mission.snapshot()["visible_guards"] == 0, "Hero deletion cannot leave ghost exposure")
	scene.queue_free()
	await process_frame
