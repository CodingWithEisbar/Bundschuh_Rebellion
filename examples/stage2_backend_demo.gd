extends SceneTree
## Runnable backend example. No scene/art setup required:
## godot --headless --path . --script examples/stage2_backend_demo.gd
## This simulates 90 game seconds as fast as possible, not 90 real seconds.

const T = CombatTypes.UnitType
const F = CombatTypes.Faction
const G = ResourceKind.Type.GOLD


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var sim := RtsSimulation.new(Vector2i(32, 24))
	sim.faction = "league"
	sim.bank.credit(G, 5)
	var combat := sim.enable_combat(1, 1, true, 1)
	combat.add_player(0, 0, F.BUNDSCHUH, ResourceBank.new())
	combat.payroll_settled.connect(func(event: Dictionary) -> void:
		print("PAYROLL ", JSON.stringify(event)))
	combat.desertion_event.connect(func(event: Dictionary) -> void:
		print("DESERTION ", JSON.stringify(event)))

	# Two overlapping sources; only one named Zeal modifier reaches the Pike.
	combat.spawn(T.RADICAL_PREACHER, 0, Vector2(1, 1))
	combat.spawn(T.RADICAL_PREACHER, 0, Vector2(2, 1))
	var pike := combat.spawn(T.PIKEMAN, 0, Vector2(2, 2))
	var rider := combat.spawn(T.ARMOURED_RITTER, 1, Vector2(2.8, 2))
	var first := combat.spawn(T.LANDSKNECHT, 1, Vector2(15, 10))
	var second := combat.spawn(T.LANDSKNECHT, 1, Vector2(15, 11))
	combat.spawn(T.VILLAGER, 1, Vector2(15.8, 10))
	for i in range(20):
		sim.step()
	print("ZEAL ", JSON.stringify({"movement_tiles_per_second": pike.movement_speed(),
		"attack_period_seconds": pike.attack_period(), "sources": combat.aura.sources_last_scan}))
	print("PIKE_VS_RITTER ", JSON.stringify(DamageCalculator.calculate(pike, rider)))
	combat.command_attack(0, pike.id, rider.id)
	sim.step()
	combat.command_stop(0, pike.id)
	print("RITTER_HP_AFTER_ONE_HIT ", rider.hp)

	# Gold: 5 -> 3 at 30s -> 1 at 60s -> 0 at 90s. Both mercenaries mutiny.
	while combat.tick_count < 1800:
		sim.step()
	var ok := rider.hp == 98 and sim.bank.amount(G) == 0 and first.mutinous and second.mutinous
	print("BACKEND DEMO: ", "PASS" if ok else "FAIL")
	quit(0 if ok else 1)
