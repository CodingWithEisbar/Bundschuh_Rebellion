extends SceneTree
## Run: godot --headless --path . --script examples/stage3_backend_demo.gd -- --seed=1524

const T = CombatTypes.UnitType
var failed_events: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config := load("res://data/maps/black_forest_default.tres").duplicate(true) as BlackForestConfig
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--seed="):
			var text := argument.trim_prefix("--seed=")
			if not text.is_valid_int():
				push_error("Seed must be an integer.")
				quit(1)
				return
			config.seed_value = text.to_int()
	var map := BlackForestGenerator.generate(config)
	if not map.valid():
		push_error("Map generation failed: %s" % map.errors)
		quit(1)
		return
	var world := BlackForestFactory.create(map)
	print("BLACK FOREST: ", map.statistics())
	print("Playable economy: ", world.agents.size(), " villagers, ", world.resources.size(), " finite resource nodes")

	# Separate tiny combat fixture: two body centers on opposite terrace cells.
	var battle := RtsSimulation.new(Vector2i(8, 8))
	battle.grid.set_height(Vector2i(1, 1), 1)
	var combat := battle.enable_combat()
	combat.add_player(1, 1, CombatTypes.Faction.SWABIAN_LEAGUE, ResourceBank.new())
	var pike := combat.spawn(T.PIKEMAN, 0, Vector2(1.7, 1.5))
	var rider := combat.spawn(T.ARMOURED_RITTER, 1, Vector2(2.3, 1.5))
	combat.command_attack(0, pike.id, rider.id)
	battle.step()
	print("HIGH GROUND: Pike 27 -> ", rider.max_hp - rider.hp, " damage (25% after armor/counter)")

	# Collider scenes feed these same events through GuardLosArea. This CLI
	# fixture explicitly drives three separated exposures on the game clock.
	var mission_config := load("res://data/missions/secret_oath_default.tres") as StealthMissionConfig
	var mission := world.enable_stealth(mission_config)
	mission.register_guard(&"gate_guard", 1)
	mission.detection_confirmed.connect(_on_detection)
	mission.mission_failed.connect(_on_mission_failed)
	for episode in range(3):
		mission.report_los(&"gate_guard", &"joss_fritz", true)
		for tick in range(40):
			world.step()
		mission.report_los(&"gate_guard", &"joss_fritz", false)
		for tick in range(40):
			world.step()
	var passed := failed_events == 1 and mission.detections == 3 and rider.max_hp - rider.hp == 34
	print("STAGE 3 DEMO: ", "PASS" if passed else "FAIL")
	quit(0 if passed else 1)


func _on_detection(event: Dictionary) -> void:
	print("Joß Fritz detected: ", event["detections"], "/", event["limit"])


func _on_mission_failed(_event: Dictionary) -> void:
	failed_events += 1
	print("MISSION FAILED — third confirmed exposure")
