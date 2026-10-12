extends SceneTree
## Unit data, real combat integration, closed-arena geometry and pacing. These
## assert behavioral invariants rather than a particular faction winning.

var failures: Array[String] = []
var checks: int = 0
var passed: int = 0
var metrics: Dictionary = {}
var source_text: String


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	source_text = FileAccess.get_file_as_string(UnitDatabase.DEFAULT_PATH)
	var cases: Array[Callable] = [test_phase2_core_values, test_json_syntax, test_schema_rejection, test_semantic_rejection,
		test_atomic_reload, test_snapshot_isolation, test_existing_units_keep_revision,
		test_stats_drive_real_combat, test_data_driven_aura, test_arena_setup,
		test_arena_collision_and_bounds, test_seeded_replay, test_pacing_equivalence,
		test_catchup_debt, test_timeout_and_draw, test_arena_snapshot_reload]
	for test in cases:
		var before := failures.size()
		test.call()
		if before == failures.size():
			passed += 1
			print("PASS ", test.get_method())
		else:
			print("FAIL ", test.get_method())
	var report := {"passed": passed, "total": cases.size(), "checks": checks,
		"failed_assertions": failures, "metrics": metrics, "engine": Engine.get_version_info()["string"]}
	DirAccess.make_dir_recursive_absolute("res://test-results")
	var file := FileAccess.open("res://test-results/stage5.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t", true, true))
	file.close()
	print("STAGE 5: %d / %d cases; %d checks; %d failures" % [passed, cases.size(), checks, failures.size()])
	quit(0 if failures.is_empty() else 1)


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)


func db() -> UnitDatabase:
	var result := UnitDatabase.new()
	assert(result.reload_text(source_text))
	return result


func battle(data: UnitDatabase) -> CombatWorld:
	var world := CombatWorld.new(data)
	world.add_player(0, 0, 0, ResourceBank.new())
	world.add_player(1, 1, 1, ResourceBank.new())
	return world


func ticks(world: CombatWorld, count: int) -> void:
	for i in count:
		world.advance(0.05)


func test_phase2_core_values() -> void:
	var data := db()
	var expected := {"peasant_flailman": [45, 7, 0, 0, 1.1, 2.0, [45, 15, 0, 0]],
		"radical_preacher": [35, 0, 0, 0, 0.85, 0.0, [0, 0, 100, 0]],
		"landsknecht_pikeman": [65, 6, 1, 0, 0.9, 2.0, [55, 0, 35, 0]],
		"heavy_gendarme": [125, 12, 2, 2, 1.3, 1.8, [90, 0, 100, 0]]}
	for id: String in expected:
		var d := data.definition(id)
		check([d["max_hp"], d["attack"], d["melee_armor"], d["pierce_armor"],
			d["movement_speed"], d["attack_period"], [d["cost"]["food"], d["cost"]["wood"],
			d["cost"]["gold"], d["cost"]["stone"]]] == expected[id], "Exact Phase 2 base values: " + id)
	check(data.definition("armoured_ritter") == data.definition("heavy_gendarme"), "Gendarme maps to base Ritter through explicit alias")
	check(data.definition("peasant_flailman")["bonuses"] == {CombatTypes.ArmorClass.SPEAR: 4}, "Flailman has Spear counter, no splash/Cavalry bonus")
	check(data.definition("landsknecht_pikeman")["bonuses"] == {CombatTypes.ArmorClass.CAVALRY: 24}, "Landsknecht counter remains +24")
	check(data.definition("pikeman")["bonuses"] == {CombatTypes.ArmorClass.CAVALRY: 25}, "Explicit Stage 2 override retained")
	for kind: int in CombatTypes.UnitType.values():
		check(not data.definition_kind(kind).is_empty(), "Legacy roster has JSON data for kind %d" % kind)


func test_schema_rejection() -> void:
	var source := db().document()
	var changed := source.duplicate(true)
	changed["schema_version"] = 2
	check(not BalanceSchema.validate(changed).is_empty(), "Reject unsupported schema version")
	for invalid: Variant in [-1, 0, 1.5, true, "45", INF, NAN]:
		changed = source.duplicate(true)
		changed["units"][0]["combat"]["hp"] = invalid
		check(not BalanceSchema.validate(changed).is_empty(), "Reject invalid HP " + str(invalid))
	changed = source.duplicate(true)
	changed["units"][0]["combat"]["attak"] = 20
	check(not BalanceSchema.validate(changed).is_empty(), "Typo does not silently become an ignored stat")
	changed = source.duplicate(true)
	changed["units"][0]["economy"]["cost"].erase("gold")
	check(not BalanceSchema.validate(changed).is_empty(), "Require explicit zero cost channels")
	changed = source.duplicate(true)
	changed["units"][0]["combat"]["bonus_damage"] = {"dragons": 3}
	check(not BalanceSchema.validate(changed).is_empty(), "Reject unknown armor class")
	changed = source.duplicate(true)
	changed["units"][0]["combat"]["impact_fraction"] = 1
	check(not BalanceSchema.validate(changed).is_empty(), "Contact marker must precede cycle end")


func test_json_syntax() -> void:
	for bad: String in ["{\"a\":1,}", "[1,]", "{\"a\":1,\"a\":2}", "01", "NaN", "1e", "\"bad\ntext\"", '"\\ud800"', '[1 2]', '"\\q"']:
		check(not BalanceJson.validate(bad).is_empty(), "Strict JSON guard rejects " + bad)
	check(BalanceJson.validate('{"text":"\\ud83d\\ude00", "number":-1.2e+2, "list":[true,false,null]}').is_empty(), "Valid escapes, numbers and literals pass syntax guard")


func test_semantic_rejection() -> void:
	var source := db().document()
	var changed := source.duplicate(true)
	changed["units"][1]["id"] = changed["units"][0]["id"]
	check(not BalanceSchema.validate(changed).is_empty(), "Duplicate ID cannot overwrite another definition")
	changed = source.duplicate(true)
	changed["units"][0]["aliases"] = ["heavy_gendarme"]
	check(not BalanceSchema.validate(changed).is_empty(), "Alias cannot shadow a real ID")
	changed = source.duplicate(true)
	changed["units"][0]["combat"]["minimum_range_tiles"] = 2
	check(not BalanceSchema.validate(changed).is_empty(), "Reject inverted range")
	changed = source.duplicate(true)
	changed["units"][1]["combat"]["attack_period"] = 2
	check(not BalanceSchema.validate(changed).is_empty(), "Support cannot receive a ghost attack period")
	changed = source.duplicate(true)
	changed["units"][0]["zeal"]["enabled"] = true
	check(not BalanceSchema.validate(changed).is_empty(), "Arbitrary unit cannot silently become a Preacher source")


func test_atomic_reload() -> void:
	var data := db()
	var events: Array[Dictionary] = []
	data.reloaded.connect(func(event: Dictionary) -> void: events.append(event))
	var hash_value := data.content_sha256
	check(not data.reload_text("{broken") and data.generation == 1 and data.content_sha256 == hash_value, "Malformed JSON preserves revision")
	check(not data.reload_file("res://absent-unit-db.json") and data.generation == 1, "Missing file preserves revision")
	var changed := data.document()
	changed["units"][0]["combat"]["hp"] = -1
	check(not data.reload_text(JSON.stringify(changed)) and data.definition("peasant_flailman")["max_hp"] == 45, "Invalid candidate is never partially published")
	check(data.reload_text(source_text) and data.generation == 1 and events.is_empty(), "Identical reload is idempotent")
	changed["units"][0]["combat"]["hp"] = 55
	check(data.reload_text(JSON.stringify(changed)) and data.generation == 2 and events.size() == 1, "Valid revision publishes once")
	check(data.content_sha256 != hash_value and data.errors.is_empty(), "Revision carries a content hash and clears old errors")


func test_snapshot_isolation() -> void:
	var data := db()
	var exported := data.document()
	exported["units"][0]["combat"]["attack"] = 999
	var definition := data.definition("peasant_flailman")
	definition["bonuses"][CombatTypes.ArmorClass.SPEAR] = 900
	definition["cost"]["food"] = 0
	check(data.definition("peasant_flailman")["attack"] == 7 and data.definition("peasant_flailman")["cost"]["food"] == 45, "Read API cannot mutate stored definitions")
	var pinned := data.fork()
	data.reload_text(JSON.stringify(exported))
	check(pinned.definition("peasant_flailman")["attack"] == 7 and data.definition("peasant_flailman")["attack"] == 999, "Pinned revision survives source reload")


func test_existing_units_keep_revision() -> void:
	var data := db()
	var world := battle(data)
	var old := world.spawn_by_id("peasant_flailman", 0, Vector2.ZERO)
	old.receive_damage(12)
	old.recovery_work = 1.2
	var changed := data.document()
	changed["units"][0]["combat"]["hp"] = 90
	changed["units"][0]["combat"]["attack"] = 17
	data.reload_text(JSON.stringify(changed))
	var fresh := world.spawn_by_id("peasant_flailman", 0, Vector2(2, 2))
	check(old.hp == 33 and old.max_hp == 45 and old.attack == 7 and old.recovery_work == 1.2, "Reload never heals old HP or resets old cooldown")
	check(fresh.hp == 90 and fresh.attack == 17 and fresh.database_generation == 2, "New spawn uses accepted revision")
	check(old.database_sha256 != fresh.database_sha256 and old.database_generation == 1, "Mixed experimental spawns remain traceable")


func test_stats_drive_real_combat() -> void:
	var data := db()
	var document := data.document()
	document["units"][0]["combat"]["attack"] = 19
	document["units"][0]["combat"]["attack_period"] = 0.5
	document["units"][0]["combat"]["impact_fraction"] = 0.5
	document["units"][0]["movement"]["speed_tiles_per_second"] = 2.2
	data.reload_text(JSON.stringify(document))
	var world := battle(data)
	var a := world.spawn_by_id("peasant_flailman", 0, Vector2.ZERO)
	var b := world.spawn_by_id("heavy_gendarme", 1, Vector2(0.8, 0))
	world.command_attack(0, a.id, b.id)
	ticks(world, 5)
	check(b.hp == 125, "JSON impact marker delays authoritative damage")
	ticks(world, 1)
	check(b.hp == 108, "JSON attack and armor produce 19-2 = 17 through real calculator")
	check(is_equal_approx(a.movement_budget(0.5), 1.1), "JSON movement speed controls physical budget")
	ticks(world, 10)
	check(b.hp == 91 and world.attacks_resolved == 2, "JSON period controls subsequent cadence")


func test_data_driven_aura() -> void:
	var data := db()
	var changed := data.document()
	changed["units"][1]["zeal"]["radius_tiles"] = 2
	changed["units"][1]["zeal"]["attack_rate_multiplier"] = 1.25
	data.reload_text(JSON.stringify(changed))
	var world := battle(data)
	world.spawn_by_id("radical_preacher", 0, Vector2.ZERO)
	world.spawn_by_id("radical_preacher", 0, Vector2(0, 0.1))
	var near := world.spawn_by_id("peasant_flailman", 0, Vector2(1, 0))
	var far := world.spawn_by_id("peasant_flailman", 0, Vector2(3, 0))
	ticks(world, 20)
	check(is_equal_approx(near.modifiers.attack_rate, 1.25) and is_equal_approx(near.modifiers.movement_rate, 1.15), "JSON aura tunes each stat without stacking sources")
	check(far.modifiers.attack_rate == 1.0, "JSON aura radius filters recipients")


func test_arena_setup() -> void:
	var arena := BalanceArena.new()
	check(arena.setup(db()), "Default closed arena accepts 100 vs 20")
	check(arena.world.units.size() == 120 and geometry_valid(arena), "120 distinct non-overlapping spawn bodies inside walls")
	var report := arena.report()
	check(report["teams"][0]["initial_hp"] == 4500 and report["teams"][1]["initial_hp"] == 2500, "Initial HP uses base unit counts")
	check(report["teams"][0]["base_army_cost"] == {"food": 4500, "wood": 1500, "gold": 0, "stone": 0}, "Base cost is not silently discounted")
	check(not BalanceArena.new().setup(db(), "peasant_flailman", 181, "heavy_gendarme", 20), "Population overflow rejected")
	check(not BalanceArena.new().setup(db(), "unknown", 1, "heavy_gendarme", 1), "Unknown roster ID rejected")


func geometry_valid(arena: BalanceArena) -> bool:
	var units := arena.world.units.values()
	for i in units.size():
		var unit: CombatUnit = units[i]
		if unit.position.x < unit.body_radius - 0.00001 or unit.position.y < unit.body_radius - 0.00001 or unit.position.x > BalanceArena.SIZE.x - unit.body_radius + 0.00001 or unit.position.y > BalanceArena.SIZE.y - unit.body_radius + 0.00001:
			return false
		for j in range(i + 1, units.size()):
			var other: CombatUnit = units[j]
			if unit.position.distance_to(other.position) < unit.body_radius + other.body_radius - 0.00001:
				return false
	return true


func test_arena_collision_and_bounds() -> void:
	var data := db()
	var changed := data.document()
	for index in [0, 3]:
		changed["units"][index]["movement"]["speed_tiles_per_second"] = 10
		changed["units"][index]["movement"]["body_radius_tiles"] = 0.45
	data.reload_text(JSON.stringify(changed))
	var arena := BalanceArena.new()
	arena.setup(data, "peasant_flailman", 20, "heavy_gendarme", 8, 41, 45)
	var valid := true
	while not arena.finished:
		arena.step()
		valid = valid and geometry_valid(arena)
	check(valid, "Swept movement preserves non-overlap and walls at high speed with larger bodies")
	check(arena.first_hit_tick > 1 and arena.world.attacks_resolved > 0, "AI closes distance before real range-gated combat")


func test_seeded_replay() -> void:
	var data := db()
	var first := BalanceArena.new()
	var repeat := BalanceArena.new()
	var other := BalanceArena.new()
	seed(9876)
	var expected := randi()
	seed(9876)
	first.setup(data)
	check(randi() == expected, "Deployment seed does not perturb global gameplay RNG")
	repeat.setup(data)
	other.setup(data, "peasant_flailman", 100, "heavy_gendarme", 20, 1525)
	check(first.world.units[1].position == repeat.world.units[1].position and first.world.units[1].position != other.world.units[1].position, "Same seed reproduces deployment; another seed changes it")
	var valid := true
	while not first.finished:
		first.step()
		if first.world.tick_count % 100 == 0:
			valid = valid and geometry_valid(first)
	while not repeat.finished:
		repeat.step()
	check(first.report() == repeat.report(), "Full 100-vs-20 replay is identical, independent of wall time")
	check(first.finished and first.report()["outcome"] == "elimination" and valid, "Baseline resolves a real battle with bounded bodies")
	var report := first.report()
	for team: Dictionary in report["teams"]:
		check(team["survivors"] + team["casualties"] == team["count"] and team["remaining_hp"] >= 0 and team["remaining_hp"] <= team["initial_hp"], "Report conserves roster and clamps HP")
	metrics["baseline"] = {"seconds": report["simulation_seconds"], "winner_team": report["winner_team"],
		"survivors": [report["teams"][0]["survivors"], report["teams"][1]["survivors"]],
		"hp": [report["teams"][0]["remaining_hp"], report["teams"][1]["remaining_hp"]], "sha256": data.content_sha256}


func test_pacing_equivalence() -> void:
	var slow := BalanceArena.new()
	var fast := BalanceArena.new()
	slow.setup(db(), "peasant_flailman", 10, "heavy_gendarme", 2, 7, 60)
	fast.setup(db(), "peasant_flailman", 10, "heavy_gendarme", 2, 7, 60)
	var normal := BalanceClock.new()
	normal.speed = 1
	var accelerated := BalanceClock.new()
	accelerated.speed = 10
	while not slow.finished:
		normal.pump(slow, 0.02)
	while not fast.finished:
		accelerated.pump(fast, 0.02)
	check(slow.report() == fast.report(), "1x and 10x pump the same fixed-tick result")


func test_catchup_debt() -> void:
	var arena := BalanceArena.new()
	arena.setup(db(), "radical_preacher", 1, "radical_preacher", 1, 1, 20)
	var clock := BalanceClock.new()
	clock.max_ticks_per_pump = 3
	check(clock.pump(arena, 1) == 3 and is_equal_approx(clock.debt_seconds, 9.85), "Catch-up budget retains 10x clock debt")
	while clock.debt_seconds > 0.000001:
		clock.pump(arena, 0)
	check(arena.world.tick_count == 200 and not arena.finished, "Catch-up does not skip or invent fixed ticks")


func test_timeout_and_draw() -> void:
	var arena := BalanceArena.new()
	arena.setup(db(), "radical_preacher", 1, "radical_preacher", 1, 1, 1)
	while not arena.finished:
		arena.step()
	check(arena.report()["outcome"] == "timeout" and arena.report()["winner_team"] == null and arena.report()["first_hit_seconds"] == null, "Noncombatants time out with no invented winner or hit")
	var data := db()
	var changed := data.document()
	changed["units"][0]["combat"]["attack"] = 100
	data.reload_text(JSON.stringify(changed))
	var duel := BalanceArena.new()
	duel.setup(data, "peasant_flailman", 1, "peasant_flailman", 1, 1, 60)
	while not duel.finished:
		duel.step()
	check(duel.report()["outcome"] == "draw" and duel.report()["winner_team"] == null, "Simultaneous lethal attacks produce a draw")


func test_arena_snapshot_reload() -> void:
	var source := db()
	var arena := BalanceArena.new()
	arena.setup(source, "peasant_flailman", 10, "heavy_gendarme", 2)
	var changed := source.document()
	changed["units"][0]["combat"]["hp"] = 999
	source.reload_text(JSON.stringify(changed))
	var reinforcement := arena.world.spawn_by_id("peasant_flailman", 0, Vector2(1, 1))
	check(reinforcement.max_hp == 45 and arena.database.content_sha256 != source.content_sha256, "Arena pins the entire revision, even for a later spawn")
	var next := BalanceArena.new()
	next.setup(source, "peasant_flailman", 10, "heavy_gendarme", 2)
	check(next.world.units[1].max_hp == 999, "Next fight uses the new revision without engine restart")
