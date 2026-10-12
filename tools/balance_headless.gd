extends SceneTree
## CLI adapter only. No combat formulas live here or in the Python launcher.
## --watch reloads the same engine process; each fight pins its own revision.

var database := UnitDatabase.new()
var arena: BalanceArena
var clock := BalanceClock.new()
var options := {"database": UnitDatabase.DEFAULT_PATH, "output": "res://balance-results/arena.json",
	"left": "peasant_flailman", "right": "heavy_gendarme", "left-count": "100", "right-count": "20",
	"seed": "1524", "seconds": "300", "speed": "10", "max-runs": "0"}
var watching: bool = false
var unpaced: bool = false
var swapped: bool = false
var run_number: int = 0
var last_wall: int = 0
var run_started: int = 0
var next_poll: int = 0
var observed_hash: String = ""
var completed_generation: int = 0
var stopping: bool = false


func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		match argument:
			"--watch": watching = true
			"--unpaced": unpaced = true
			"--swap-sides": swapped = true
			_:
				var pair := argument.trim_prefix("--").split("=", true, 1)
				if not argument.begins_with("--") or pair.size() != 2 or not options.has(pair[0]):
					_fail("Unknown argument: " + argument)
					return
				options[pair[0]] = pair[1]
	for key: String in ["left-count", "right-count", "seed", "max-runs"]:
		if not str(options[key]).is_valid_int():
			_fail("Expected integer: " + key)
			return
	for key: String in ["speed", "seconds"]:
		if not str(options[key]).is_valid_float():
			_fail("Expected number: " + key)
			return
	clock.speed = float(options["speed"])
	if not is_finite(clock.speed) or clock.speed < 0.1 or clock.speed > 100 or int(options["max-runs"]) < 0:
		_fail("Speed must be 0.1..100; max-runs must be nonnegative")
		return
	if not database.reload_file(options["database"]):
		_fail(str(database.errors))
		return
	observed_hash = database.content_sha256
	_start_run()


func _start_run() -> void:
	arena = BalanceArena.new()
	if not arena.setup(database, options["left"], int(options["left-count"]), options["right"],
			int(options["right-count"]), int(options["seed"]), float(options["seconds"]), swapped):
		_fail(str(arena.errors))
		return
	clock.debt_seconds = 0
	run_number += 1
	run_started = Time.get_ticks_usec()
	last_wall = run_started
	print("BALANCE_START " + JSON.stringify({"run": run_number, "sha256": database.content_sha256,
		"generation": database.generation, "speed": clock.speed, "unpaced": unpaced}))


func _process(_delta: float) -> bool:
	if stopping:
		return false
	var now := Time.get_ticks_usec()
	if watching and now >= next_poll:
		next_poll = now + 1000000
		_poll_database()
	if arena == null:
		if database.generation > completed_generation:
			_start_run()
		return false
	clock.pump(arena, float(now - last_wall) / 1000000.0, unpaced)
	last_wall = now
	if arena.finished:
		_finish_run()
	return false


func _poll_database() -> void:
	# One bounded file read per real second, outside CombatWorld.advance(). Invalid
	# edits are logged once and never replace the active revision or current fight.
	var file := FileAccess.open(options["database"], FileAccess.READ)
	if file == null or file.get_length() > UnitDatabase.MAX_BYTES:
		if observed_hash != "unavailable":
			print("BALANCE_RELOAD_REJECTED file missing or larger than 1 MiB; retaining revision")
		observed_hash = "unavailable"
		return
	var text := file.get_buffer(file.get_length()).get_string_from_utf8()
	var candidate_hash := text.sha256_text()
	if candidate_hash == observed_hash:
		return
	observed_hash = candidate_hash
	if database.reload_text(text):
		print("BALANCE_RELOAD_ACCEPTED " + JSON.stringify({"generation": database.generation, "sha256": database.content_sha256,
			"policy": "next fight; current fight retains its snapshot"}))
	else:
		print("BALANCE_RELOAD_REJECTED " + JSON.stringify(Array(database.errors)))


func _finish_run() -> void:
	var report := arena.report()
	var wall_seconds := float(Time.get_ticks_usec() - run_started) / 1000000.0
	report["timing"] = {"mode": "unpaced" if unpaced else "paced", "requested_speed": clock.speed,
		"wall_seconds": wall_seconds, "measured_speed": arena.world.seconds() / maxf(wall_seconds, 0.000001)}
	var output: String = options["output"]
	if watching:
		output = output.get_basename() + ".r%03d.json" % run_number
	var absolute := ProjectSettings.globalize_path(output)
	if DirAccess.make_dir_recursive_absolute(absolute.get_base_dir()) != OK:
		_fail("Cannot create report directory")
		return
	var file := FileAccess.open(absolute, FileAccess.WRITE)
	if file == null:
		_fail("Cannot write report: " + absolute)
		return
	file.store_string(JSON.stringify(report, "\t", true, true) + "\n")
	file.close()
	print("BALANCE_RESULT " + JSON.stringify({"output": absolute, "run": run_number,
		"outcome": report["outcome"], "winner_team": report["winner_team"], "seconds": report["simulation_seconds"],
		"survivors": [report["teams"][0]["survivors"], report["teams"][1]["survivors"]], "timing": report["timing"]}))
	completed_generation = arena.database.generation
	arena = null
	if not watching or (int(options["max-runs"]) > 0 and run_number >= int(options["max-runs"])):
		stopping = true
		quit(0)


func _fail(message: String) -> void:
	printerr("BALANCE_ERROR " + message)
	stopping = true
	quit(2)
