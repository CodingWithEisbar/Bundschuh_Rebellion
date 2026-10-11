extends SceneTree
## Actual Stage 2 models, no mocks of the clock, calculator, bank or aura.
## Run through tools/verify.py so parse errors cannot masquerade as a pass.

const T = CombatTypes.UnitType
const C = CombatTypes.ArmorClass
const F = CombatTypes.Faction
const G = ResourceKind.Type.GOLD
var failures: Array[String] = []
var completed: Array[String] = []
var checks: int = 0
var metrics: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var cases: Array[Callable] = [
		test_damage_channels_and_counters,
		test_classes_and_independent_definitions,
		test_attack_permissions_and_range,
		test_simultaneous_deaths_and_cleanup,
		test_attack_rate_and_command_spam,
		test_aura_circle_and_allied_owners,
		test_aura_overlap_and_other_modifiers,
		test_aura_movement_and_garrison,
		test_preacher_death_expires_aura,
		test_ownership_changes_clear_buffs_and_orders,
		test_clock_pause_and_chunking,
		test_payroll_deadline_and_shared_bank,
		test_partial_payment_and_once_only_desertion,
		test_exact_payment_and_empty_treasury,
		test_empty_roster_and_disabled_maintenance,
		test_dead_removed_and_garrisoned_payroll,
		test_owner_isolation_and_transferred_roster,
		test_mutineers_attack_former_allies,
		test_late_player_deadline_and_reinforcements,
		test_simulation_bridge,
		test_spatial_hash_matches_exact_circle,
		test_mass_battle_200,
	]
	for test in cases:
		var before := failures.size()
		test.call()
		if failures.size() == before:
			completed.append(test.get_method())
			print("PASS ", test.get_method())
		else:
			print("FAIL ", test.get_method())
	var report := {"passed": completed.size(), "total": cases.size(), "checks": checks,
		"failed_assertions": failures, "metrics": metrics,
		"engine": Engine.get_version_info()["string"]}
	DirAccess.make_dir_recursive_absolute("res://test-results")
	var file := FileAccess.open("res://test-results/stage2.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report, "\t"))
	print("STAGE 2: %d / %d cases; %d checks; %d failures" % [completed.size(), cases.size(), checks, failures.size()])
	quit(0 if failures.is_empty() else 1)


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)


func near(actual: float, expected: float, message: String) -> void:
	check(absf(actual - expected) < 0.00001, "%s: got %.8f, expected %.8f" % [message, actual, expected])


func advance(world: CombatWorld, seconds: float, chunk: float = 0.05) -> void:
	var remaining := seconds
	while remaining > 0.0000001:
		var delta := minf(remaining, chunk)
		world.advance(delta)
		remaining -= delta


func economy(gold: int = 1000) -> ResourceBank:
	var bank := ResourceBank.new()
	bank.credit(G, gold)
	return bank


func world_with_players(payroll: bool = false, gold: int = 1000, wage: int = 1) -> CombatWorld:
	var world := CombatWorld.new()
	world.add_player(0, 0, F.BUNDSCHUH, economy())
	world.add_player(1, 1, F.SWABIAN_LEAGUE, economy(gold), payroll, wage)
	return world


func unit(kind: int, hp: int = -1) -> CombatUnit:
	var result := CombatUnit.new(1, 0, 0, F.BUNDSCHUH, Vector2.ZERO, CombatUnitCatalog.definition(kind))
	if hp > 0:
		result.hp = hp
	return result


func buffed(soldier: CombatUnit) -> bool:
	return soldier.modifiers.has_effect(ZealAura.EFFECT_ID)


func test_damage_channels_and_counters() -> void:
	var pike := unit(T.PIKEMAN)
	var rider := unit(T.ARMOURED_RITTER)
	check(DamageCalculator.calculate(pike, rider)["total"] == 27, "Pike: 4 - 2 + 25 = 27")
	rider.melee_armor = 200
	check(DamageCalculator.calculate(pike, rider)["total"] == 26, "Normal armor cannot erase the Cavalry bonus")
	rider.bonus_armor[C.CAVALRY] = 10
	check(DamageCalculator.calculate(pike, rider)["total"] == 16, "Matching class armor reduces only the counter")
	rider.bonus_armor[C.CAVALRY] = 99
	check(DamageCalculator.calculate(pike, rider)["total"] == 1, "Counter resistance cannot heal or make negative damage")
	var bow := unit(T.CROSSBOWMAN)
	rider.pierce_armor = 3
	check(DamageCalculator.calculate(bow, rider)["total"] == 2, "Ranged hit uses pierce, not melee armor")
	var gun := unit(T.ARQUEBUSIER)
	var foot := unit(T.FLAILMAN)
	foot.melee_armor = 100
	foot.pierce_armor = 2
	check(DamageCalculator.calculate(gun, foot)["total"] == 20, "Arquebusier: 16 - 2 + 6 Infantry")
	check(DamageCalculator.calculate(unit(T.RADICAL_PREACHER), foot)["total"] == 0, "Support does not gain the minimum one-damage attack")


func test_classes_and_independent_definitions() -> void:
	var data := CombatUnitCatalog.definition(T.LANDSKNECHT)
	data["armor_classes"].append(C.SPEAR)
	var target := CombatUnit.new(2, 1, 1, F.SWABIAN_LEAGUE, Vector2.ZERO, data)
	check(DamageCalculator.calculate(unit(T.FLAILMAN), target)["total"] == 10, "Duplicate Spear tags do not duplicate +4")
	check(not unit(T.ARQUEBUSIER).armor_classes.has(C.INFANTRY), "Gun unit is Archer, not melee Infantry")
	var a := unit(T.PIKEMAN)
	var b := unit(T.PIKEMAN)
	a.bonuses[C.CAVALRY] = 999
	check(b.bonuses[C.CAVALRY] == 25, "One unit cannot mutate another unit's counter data")
	var skirm := unit(T.SKIRMISHER)
	check(DamageCalculator.calculate(skirm, unit(T.ARQUEBUSIER))["bonus"] == 3, "Skirmisher has one Archer bonus against guns")


func test_attack_permissions_and_range() -> void:
	var world := world_with_players()
	world.add_player(2, 0, F.SWABIAN_LEAGUE, economy())
	var a := world.spawn(T.PIKEMAN, 0, Vector2.ZERO)
	var friend := world.spawn(T.FLAILMAN, 2, Vector2(0.8, 0))
	var b := world.spawn(T.ARMOURED_RITTER, 1, Vector2(8, 0))
	check(not world.command_attack(1, a.id, b.id), "Cannot command another owner's unit")
	check(not world.command_attack(0, a.id, friend.id), "Cannot direct-fire an allied owner")
	check(world.command_attack(0, a.id, b.id), "Out-of-range attack order waits for navigation")
	advance(world, 0.1)
	check(b.hp == 125, "No damage outside weapon range")
	world.set_position(b.id, Vector2(0.8, 0))
	advance(world, 0.05)
	check(b.hp == 98, "An in-range hit applies the counter to actual HP")
	var skirm := world.spawn(T.SKIRMISHER, 0, Vector2(0.8, 0))
	world.command_attack(0, skirm.id, b.id)
	advance(world, 0.05)
	check(b.hp == 98, "Minimum range prevents a point-blank skirmisher shot")


func test_simultaneous_deaths_and_cleanup() -> void:
	var world := world_with_players()
	var a := world.spawn(T.PIKEMAN, 0, Vector2.ZERO)
	var b := world.spawn(T.PIKEMAN, 1, Vector2(0.8, 0))
	a.hp = 4
	b.hp = 4
	var deaths: Array[Dictionary] = []
	world.unit_died.connect(func(event: Dictionary) -> void: deaths.append(event))
	world.command_attack(0, a.id, b.id)
	world.command_attack(1, b.id, a.id)
	advance(world, 0.05)
	check(a.hp == 0 and b.hp == 0, "Both lethal same-tick swings land")
	check(deaths.size() == 2 and world.units.is_empty(), "Deaths release registry slots exactly once")
	advance(world, 4.0)
	check(deaths.size() == 2 and world.attacks_resolved == 2, "Dead units never attack or die again")
	var replacement := world.spawn(T.PIKEMAN, 0, Vector2.ZERO)
	check(replacement.id > b.id, "No stale event can hit a reused entity ID")


func test_attack_rate_and_command_spam() -> void:
	var counts: Array[int] = []
	for with_aura in [false, true]:
		var world := world_with_players()
		var a := world.spawn(T.FLAILMAN, 0, Vector2.ZERO)
		var b := world.spawn(T.ARMOURED_RITTER, 1, Vector2(0.8, 0))
		b.max_hp = 10000
		b.hp = 10000 # Endurance fixture, not production balance.
		if with_aura:
			world.spawn(T.RADICAL_PREACHER, 0, Vector2(1, 1))
		advance(world, 1.0)
		world.command_attack(0, a.id, b.id)
		advance(world, 0.05)
		for i in range(20):
			world.command_stop(0, a.id)
			world.command_attack(0, a.id, b.id)
		advance(world, 0.05)
		check(world.attacks_resolved == 1, "Stop/reissue cannot reset recovery")
		advance(world, 9.9)
		counts.append(world.attacks_resolved)
		near(a.attack_period(), 2.0 / (1.15 if with_aura else 1.0), "Attack RATE divides period")
	check(counts == [5, 6], "Aura produces more real attacks: expected 5 vs 6 within ten seconds")


func test_aura_circle_and_allied_owners() -> void:
	var world := world_with_players()
	world.add_player(2, 0, F.SWABIAN_LEAGUE, economy())
	var source := world.spawn(T.RADICAL_PREACHER, 0, Vector2(-2, -2))
	var edge := world.spawn(T.ARMOURED_RITTER, 2, Vector2(4, -2))
	var outside := world.spawn(T.PIKEMAN, 0, Vector2(4.001, -2))
	var diagonal := world.spawn(T.PIKEMAN, 0, Vector2(2.3, 2.3))
	var enemy := world.spawn(T.PIKEMAN, 1, Vector2(-2, -2))
	world.spawn(T.RADICAL_PREACHER, 1, Vector2(100, 100))
	var wrong_faction_target := world.spawn(T.PIKEMAN, 1, Vector2(100, 100))
	advance(world, 0.95)
	check(not buffed(edge), "First aura membership scan occurs at one second")
	advance(world, 0.05)
	check(buffed(source) and buffed(edge), "Source and allied different-owner cavalry are eligible")
	check(not buffed(outside) and not buffed(diagonal), "Aura uses an exact inclusive circle, not a square")
	check(not buffed(enemy) and not buffed(wrong_faction_target), "Enemies and non-Bundschuh preachers cannot grant this buff")
	near(edge.movement_speed(), 1.30 * 1.15, "Movement speed uses the same Zeal factor")
	near(edge.movement_budget(0.25), 1.30 * 1.15 * 0.25, "Navigation receives a buffed movement budget")


func test_aura_overlap_and_other_modifiers() -> void:
	var world := world_with_players()
	var a := world.spawn(T.FLAILMAN, 0, Vector2.ZERO)
	a.modifiers.set_effect(&"test_technology", 1.2, 1.1)
	var sources: Array[int] = []
	for i in range(10):
		sources.append(world.spawn(T.RADICAL_PREACHER, 0, Vector2(i * 0.1, 0)).id)
	advance(world, 20.0)
	near(a.modifiers.attack_rate, 1.2 * 1.15, "Twenty refreshes and ten sources apply Zeal only once")
	near(a.movement_speed(), 1.1 * 1.1 * 1.15, "Base movement never accumulates buff multiplications")
	world.remove_unit(sources.pop_back())
	advance(world, 1.0)
	check(buffed(a), "One removed source does not cancel overlapping surviving sources")
	for id in sources:
		world.remove_unit(id)
	advance(world, 1.0)
	near(a.modifiers.attack_rate, 1.2, "Removing Zeal preserves unrelated attack tech")
	near(a.movement_speed(), 1.1 * 1.1, "Removing Zeal restores the correct movement stat")


func test_aura_movement_and_garrison() -> void:
	var world := world_with_players()
	var source := world.spawn(T.RADICAL_PREACHER, 0, Vector2.ZERO)
	var a := world.spawn(T.PIKEMAN, 0, Vector2(1, 0))
	advance(world, 1.0)
	world.set_position(a.id, Vector2(8, 0))
	advance(world, 0.95)
	check(buffed(a), "Leaving between scans has bounded sampled-membership latency")
	advance(world, 0.05)
	check(not buffed(a), "Leaving loses Zeal at the next one-second scan")
	world.set_position(a.id, Vector2(1, 0))
	advance(world, 1.0)
	world.set_on_field(source.id, false)
	advance(world, 1.0)
	check(not buffed(a), "Garrisoned source cannot emit aura")
	world.set_on_field(source.id, true)
	advance(world, 1.0)
	check(buffed(a), "Redeployed preacher can grant aura again")
	world.set_on_field(a.id, false)
	check(not buffed(a) and a.movement_budget(1.0) == 0.0, "Garrisoned target immediately loses aura and movement")


func test_preacher_death_expires_aura() -> void:
	var world := world_with_players()
	var source := world.spawn(T.RADICAL_PREACHER, 0, Vector2.ZERO)
	var a := world.spawn(T.PIKEMAN, 0, Vector2(1, 1))
	var killer := world.spawn(T.LIGHT_CAVALRY, 1, Vector2(0.8, 0))
	source.hp = 1
	advance(world, 1.0)
	world.command_attack(1, killer.id, source.id)
	advance(world, 0.05)
	check(not world.units.has(source.id), "Dead preacher is removed from the emitter roster")
	advance(world, 0.95)
	check(not buffed(a), "Preacher death cannot leave a permanent buff")


func test_ownership_changes_clear_buffs_and_orders() -> void:
	var world := world_with_players()
	world.spawn(T.RADICAL_PREACHER, 0, Vector2.ZERO)
	var a := world.spawn(T.PIKEMAN, 0, Vector2(1, 0))
	var b := world.spawn(T.PIKEMAN, 1, Vector2(1.8, 0))
	advance(world, 1.0)
	world.command_attack(0, a.id, b.id)
	world.transfer_unit(a.id, 1)
	check(not buffed(a) and a.team_id == 1, "Transfer clears former team's aura immediately")
	advance(world, 1.0)
	check(b.hp == b.max_hp, "Stale attack order cannot hit a new ally")
	check(not world.command_attack(0, a.id, b.id), "Former owner loses command authority")


func test_clock_pause_and_chunking() -> void:
	for chunk in [0.01, 0.05, 0.25]:
		var world := world_with_players(true, 10)
		world.spawn(T.LANDSKNECHT, 1, Vector2.ZERO)
		advance(world, 29.5, chunk)
		world.paused = true
		advance(world, 90.0, chunk)
		check(world.tick_count == 590 and world.aura.scans == 29, "Pause advances neither aura nor payroll clock")
		world.paused = false
		advance(world, 0.5, chunk)
		check(world.tick_count == 600 and world.players[1].bank.amount(G) == 9, "Deadline independent of frame subdivision")
		check(world.maintenance.settlements == 1 and world.aura.scans == 30, "No repeated deadline or per-render-frame scan")


func test_payroll_deadline_and_shared_bank() -> void:
	var world := world_with_players(true, 20, 3)
	var bank: ResourceBank = world.players[1].bank
	world.spawn(T.LANDSKNECHT, 1, Vector2.ZERO)
	world.spawn(T.LANDSKNECHT, 1, Vector2(1, 0))
	world.spawn(T.ARMOURED_RITTER, 1, Vector2(2, 0))
	var invoices: Array[Dictionary] = []
	var snapshots: Array[Dictionary] = []
	world.payroll_settled.connect(func(e: Dictionary) -> void: invoices.append(e))
	bank.changed.connect(func(e: Dictionary) -> void: snapshots.append(e))
	advance(world, 29.95)
	check(bank.amount(G) == 20 and invoices.is_empty(), "No early payroll")
	advance(world, 0.05)
	check(bank.amount(G) == 14 and invoices[0]["due"] == 6, "Wage multiplies only the active Landsknecht count")
	check(snapshots.size() == 1 and snapshots[0][G] == 14, "Global bank signal carries the real remaining gold")
	advance(world, 30.0)
	check(bank.amount(G) == 8 and invoices.size() == 2, "Second bill is at 60s, not reset by first payment")


func test_partial_payment_and_once_only_desertion() -> void:
	var world := world_with_players(true, 3, 2)
	var soldiers: Array[CombatUnit] = []
	for i in range(4):
		soldiers.append(world.spawn(T.LANDSKNECHT, 1, Vector2(i, 0)))
	world.set_on_field(soldiers[0].id, false)
	var events: Array[Dictionary] = []
	var invoices: Array[Dictionary] = []
	world.desertion_event.connect(func(e: Dictionary) -> void: events.append(e))
	world.payroll_settled.connect(func(e: Dictionary) -> void: invoices.append(e))
	advance(world, 30.0)
	check(world.players[1].bank.amount(G) == 0, "Insufficient positive balance drains to zero, never negative")
	check(invoices[0]["charged"] == 3 and invoices[0]["shortfall"] == 5, "Partial payment is explicit in the invoice")
	check(events.size() == 1 and events[0]["unit_ids"].size() == 4, "One group desertion event for four soldiers")
	check(events[0]["garrisoned_ids"] == [soldiers[0].id] and not soldiers[0].on_field,
		"Garrisoned mutiny loses ownership but waits for the host to place a safe exit")
	for soldier in soldiers:
		check(soldier.mutinous and soldier.owner_id == -1 and soldier.team_id == -1, "Desertion changes actual ownership and diplomacy")
	advance(world, 60.0)
	check(events.size() == 1, "Former owner's next deadlines do not desert the same soldiers again")
	world.players[1].bank.credit(G, 50)
	advance(world, 30.0)
	check(world.players[1].bank.amount(G) == 50 and soldiers[0].mutinous, "Later deposits do not auto-rehire or bill mutineers")


func test_exact_payment_and_empty_treasury() -> void:
	for starting_gold in [0, 1]:
		var world := world_with_players(true, starting_gold)
		var soldier := world.spawn(T.LANDSKNECHT, 1, Vector2.ZERO)
		var events: Array[Dictionary] = []
		world.desertion_event.connect(func(e: Dictionary) -> void: events.append(e))
		advance(world, 29.95)
		check(not soldier.mutinous, "Empty balance is evaluated at the payroll deadline")
		advance(world, 0.05)
		check(events.size() == 1 and soldier.mutinous, "Zero remaining gold, including exact payment, triggers prompt's rule")


func test_empty_roster_and_disabled_maintenance() -> void:
	var empty := world_with_players(true, 0)
	var events: Array[Dictionary] = []
	empty.desertion_event.connect(func(e: Dictionary) -> void: events.append(e))
	advance(empty, 60.0)
	check(events.is_empty(), "Empty army never raises an empty DesertionEvent")
	var disabled := world_with_players(false, 0)
	var soldier := disabled.spawn(T.LANDSKNECHT, 1, Vector2.ZERO)
	advance(disabled, 90.0)
	check(not soldier.mutinous and disabled.maintenance.settlements == 0, "Unconfigured sandbox has no hidden upkeep")
	check(not disabled.add_player(3, 3, F.BUNDSCHUH, economy(), true), "Only League owners can enable mercenary maintenance")


func test_dead_removed_and_garrisoned_payroll() -> void:
	var world := world_with_players(true, 20)
	var corpse := world.spawn(T.LANDSKNECHT, 1, Vector2.ZERO)
	var removed := world.spawn(T.LANDSKNECHT, 1, Vector2(10, 0))
	var garrisoned := world.spawn(T.LANDSKNECHT, 1, Vector2(20, 0))
	var killer := world.spawn(T.FLAILMAN, 0, Vector2(0.8, 0))
	corpse.hp = 1
	world.command_attack(0, killer.id, corpse.id)
	world.remove_unit(removed.id)
	world.set_on_field(garrisoned.id, false)
	advance(world, 30.0)
	check(not world.units.has(corpse.id), "Combat death is reflected in payroll roster")
	check(world.players[1].bank.amount(G) == 19, "Dead/despawned soldiers excluded, garrisoned living soldier still paid")


func test_owner_isolation_and_transferred_roster() -> void:
	var world := world_with_players(true, 10)
	var bank2 := economy(20)
	world.add_player(2, 1, F.SWABIAN_LEAGUE, bank2, true, 2)
	var a := world.spawn(T.LANDSKNECHT, 1, Vector2.ZERO)
	world.spawn(T.LANDSKNECHT, 2, Vector2(1, 0))
	world.transfer_unit(a.id, 2)
	advance(world, 30.0)
	check(world.players[1].bank.amount(G) == 10 and bank2.amount(G) == 16, "Allied owners pay only their current own roster")


func test_mutineers_attack_former_allies() -> void:
	var world := world_with_players(true, 0)
	var merc := world.spawn(T.LANDSKNECHT, 1, Vector2.ZERO)
	var former_ally := world.spawn(T.VILLAGER, 1, Vector2(0.8, 0))
	var far_enemy := world.spawn(T.PIKEMAN, 0, Vector2(100, 0))
	world.command_attack(1, merc.id, far_enemy.id)
	advance(world, 30.0)
	check(former_ally.hp == 19, "Mutineer automatically damages a nearby former ally on deadline")
	check(not world.command_stop(1, merc.id), "Former owner cannot stop a hostile soldier")
	check(not world.command_attack(-1, merc.id, former_ally.id), "Hostile-band orders belong to AI, not player command API")
	check(far_enemy.hp == far_enemy.max_hp, "Old player's stale target does not receive a phantom attack")


func test_late_player_deadline_and_reinforcements() -> void:
	var world := world_with_players()
	advance(world, 0.65)
	var bank := economy(1)
	world.add_player(2, 2, F.SWABIAN_LEAGUE, bank, true)
	var first := world.spawn(T.LANDSKNECHT, 2, Vector2(100, 0))
	advance(world, 29.95)
	check(not first.mutinous, "A late player's first invoice is 30 seconds after registration")
	advance(world, 0.05)
	check(first.mutinous, "Late registration deadline is not rounded to a global minute")
	bank.credit(G, 10)
	var next := world.spawn(T.LANDSKNECHT, 2, Vector2(200, 0))
	advance(world, 30.0)
	check(bank.amount(G) == 9 and not next.mutinous, "Fresh recruits are paid on the existing schedule")


func test_simulation_bridge() -> void:
	var sim := RtsSimulation.new(Vector2i(8, 8))
	check(sim.combat == null, "Existing Stage 1 fixtures don't silently enable combat")
	sim.faction = "league"
	sim.bank.credit(G, 3)
	var backend := sim.enable_combat(7, 2, true)
	check(backend != null and backend.players[7].bank == sim.bank, "Stage 2 uses the original economy, not a copied wallet")
	backend.spawn(T.LANDSKNECHT, 7, Vector2.ZERO)
	backend.spawn(T.LANDSKNECHT, 7, Vector2(1, 0))
	for i in range(600):
		sim.step()
	check(sim.bank.amount(G) == 1 and backend.tick_count == 600, "Root simulation steps combat and payroll once")
	check(sim.enable_combat() == backend, "Repeated enable cannot reset clocks or duplicate payroll")


func test_spatial_hash_matches_exact_circle() -> void:
	var world := world_with_players()
	var rng := RandomNumberGenerator.new()
	rng.seed = 1989
	for i in range(200):
		world.spawn(T.PIKEMAN, i % 2, Vector2(rng.randf_range(-150, 150), rng.randf_range(-150, 150)))
	world.spatial.rebuild(world.units)
	for i in range(40):
		var center := Vector2(rng.randf_range(-150, 150), rng.randf_range(-150, 150))
		var actual: Array[int] = []
		var expected: Array[int] = []
		for candidate in world.spatial.query_circle(center, 6.0):
			actual.append(candidate.id)
		for candidate: CombatUnit in world.units.values():
			if candidate.position.distance_squared_to(center) <= 36.0:
				expected.append(candidate.id)
		actual.sort()
		expected.sort()
		check(actual == expected, "Hash matches brute-force circle query %d" % i)
	check(world.spatial.candidate_checks < 800, "Spread-out queries avoid forty full 200-unit scans")


func test_mass_battle_200() -> void:
	var world := world_with_players(true, 100000)
	var left: Array[CombatUnit] = []
	var right: Array[CombatUnit] = []
	for i in range(20):
		world.spawn(T.RADICAL_PREACHER, 0, Vector2(-1, 0))
	for i in range(90):
		var a := world.spawn(T.PIKEMAN, 0, Vector2.ZERO)
		var b := world.spawn(T.LANDSKNECHT, 1, Vector2(0.8, 0))
		a.max_hp = 1000000
		b.max_hp = 1000000
		a.hp = 1000000
		b.hp = 1000000
		left.append(a)
		right.append(b)
		world.command_attack(0, a.id, b.id)
		world.command_attack(1, b.id, a.id)
	check(world.spawn(T.PIKEMAN, 0, Vector2.ZERO) == null, "Explicit 200-unit backend cap")
	var samples: Array[float] = []
	for i in range(1200):
		var started := Time.get_ticks_usec()
		world.advance(0.05)
		samples.append((Time.get_ticks_usec() - started) / 1000.0)
	samples.sort()
	check(world.units.size() == 200 and world.attacks_resolved > 4000, "Two hundred live units execute thousands of real hits")
	check(world.aura.scans == 60 and world.spatial.builds == 60, "Crowded battle scans only once a second")
	check(world.players[1].bank.amount(G) == 99820, "Two payroll periods bill ninety Landsknechts each")
	near(left[0].modifiers.attack_rate, 1.15, "Twenty overlapping sources remain one buff in mass combat")
	check(world.spatial.candidate_checks == 4000, "Dense worst case is 20 x 200 candidates per second, not per tick")
	metrics["combat_200"] = {"units": 200, "preachers": 20, "attack_orders": 180,
		"simulated_seconds": world.seconds(), "hits": world.attacks_resolved,
		"aura_scans": world.aura.scans, "candidate_checks_last_scan": world.spatial.candidate_checks,
		"step_ms_p50": samples[600], "step_ms_p95": samples[1140], "step_ms_max": samples[-1],
		"cpu": OS.get_processor_name(), "rendering": "excluded / headless",
		"positions": "synthetic dense overlap to measure backend worst case; not navigation"}
