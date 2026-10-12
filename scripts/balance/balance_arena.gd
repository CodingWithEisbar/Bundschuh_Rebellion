class_name BalanceArena
extends RefCounted
## Bounded, flat, closed-arena micro test using the real CombatWorld. This local
## steering adapter is NOT the terrain/chokepoint military pathfinder. Bodies
## cannot overlap or tunnel; attacks still require actual weapon range.

const VERSION := 1
const SIZE := Vector2(40, 32)
const CELL_SIZE := 1.0
const TARGET_TICKS := 5
var world: CombatWorld
var database: UnitDatabase
var seed_value: int = 1524
var finished: bool = false
var errors := PackedStringArray()
var max_ticks: int = 6000
var first_hit_tick: int = -1
var blocked_moves: int = 0
var timeline: Array[Dictionary] = []
var initial: Array[Dictionary] = []
var swapped: bool = false
var _targets: Dictionary = {}
var _buckets: Dictionary = {}
var _max_radius: float = 0.0


func setup(source: UnitDatabase, left_id: String = "peasant_flailman", left_count: int = 100,
		right_id: String = "heavy_gendarme", right_count: int = 20, arena_seed: int = 1524,
		limit_seconds: float = 300.0, swap_sides: bool = false) -> bool:
	if world != null:
		errors.append("Create a new arena for every run")
		return false
	if source == null or source.generation == 0 or left_count < 1 or right_count < 1 or left_count + right_count > CombatWorld.MAX_UNITS:
		errors.append("Arena needs a loaded database and 2..200 total units")
		return false
	if not is_finite(limit_seconds) or limit_seconds < 0.05 or limit_seconds > 3600:
		errors.append("Time limit must be 0.05..3600 game seconds")
		return false
	database = source.fork()
	seed_value = arena_seed
	swapped = swap_sides
	max_ticks = ceili(limit_seconds / CombatWorld.FIXED_DT)
	world = CombatWorld.new(database)
	world.hit_resolved.connect(_on_hit)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var ids := [left_id, right_id]
	var counts := [left_count, right_count]
	for team in 2:
		var definition := database.definition(ids[team])
		if definition.is_empty():
			errors.append("Unknown unit: " + ids[team])
			return false
		var record: Dictionary = {}
		for row: Dictionary in database.document()["units"]:
			if row["id"] == definition["definition_id"]:
				record = row
		var side := 1 if record["faction"] == "swabian_league" else 0
		world.add_player(team, team, side, ResourceBank.new()) # No payroll/economic effects.
		var count: int = counts[team]
		var radius := float(definition["body_radius"])
		_max_radius = maxf(_max_radius, radius)
		var spacing := maxf(0.6, radius * 2.0 + 0.15)
		var columns := ceili(sqrt(float(count)))
		var rows := ceili(float(count) / columns)
		var half_width := (columns - 1) * spacing * 0.5
		var half_height := (rows - 1) * spacing * 0.5
		if half_width + radius + 0.03 > 9.0 or half_height + radius + 0.03 > 15.0:
			errors.append("Formation does not fit: reduce count/radius")
			return false
		var field_side := 1 - team if swapped else team
		var center := Vector2(10.0 if field_side == 0 else 30.0, 16.0)
		for i in count:
			var offset := Vector2((i % columns) * spacing - half_width, floori(float(i) / columns) * spacing - half_height)
			# Small seeded deployment jitter changes contact geometry, not hit RNG.
			offset += Vector2(rng.randf_range(-0.025, 0.025), rng.randf_range(-0.025, 0.025))
			if field_side == 1:
				offset.x = -offset.x
			world.spawn_by_id(ids[team], team, center + offset)
		var cost: Dictionary = {}
		for resource: String in definition["cost"]:
			cost[resource] = int(definition["cost"][resource]) * count
		initial.append({"team": team, "unit_id": definition["definition_id"], "count": count,
			"initial_hp": count * int(definition["max_hp"]), "base_army_cost": cost,
			"population": count * int(definition["population"]), "unit_snapshot": record})
	_sample()
	return true


func step() -> void:
	if finished or world == null:
		return
	var ids := world.units.keys()
	ids.sort()
	# Retain targets already in reach to avoid cancelling a legitimate wind-up.
	for id: int in ids:
		var unit: CombatUnit = world.units[id]
		var target: CombatUnit = world.units.get(_targets.get(id, -1))
		if not unit.can_attack():
			continue
		if target == null or (world.tick_count % TARGET_TICKS == 0 and not CombatWorld.in_weapon_range(unit, target)):
			target = _nearest_enemy(unit)
			if target != null and _targets.get(id, -1) != target.id:
				_targets[id] = target.id
				world.command_attack(unit.owner_id, id, target.id)
	_rebuild_buckets()
	# Rotate movement arbitration, so the same low IDs do not always move first.
	for index in ids.size():
		var id: int = ids[(index + world.tick_count) % ids.size()]
		var unit: CombatUnit = world.units[id]
		var target: CombatUnit = world.units.get(_targets.get(id, -1))
		if target != null:
			_move(unit, target)
	world.advance(CombatWorld.FIXED_DT)
	var alive := [0, 0]
	for unit: CombatUnit in world.units.values():
		alive[unit.team_id] += 1
	finished = alive[0] == 0 or alive[1] == 0 or world.tick_count >= max_ticks
	if finished or world.tick_count % 20 == 0:
		_sample()


func _nearest_enemy(unit: CombatUnit) -> CombatUnit:
	var best: CombatUnit = null
	var distance := INF
	for other: CombatUnit in world.units.values():
		if other.team_id == unit.team_id:
			continue
		var candidate := unit.position.distance_squared_to(other.position)
		if candidate < distance or (candidate == distance and (best == null or other.id < best.id)):
			distance = candidate
			best = other
	return best


func _move(unit: CombatUnit, target: CombatUnit) -> void:
	if CombatWorld.in_weapon_range(unit, target):
		return
	var delta := target.position - unit.position
	var distance := delta.length()
	var reach := unit.attack_range
	if unit.channel == CombatTypes.DamageChannel.MELEE:
		reach += unit.body_radius + target.body_radius
	var direction := delta.normalized()
	var desired := maxf(0, distance - reach + 0.002)
	if distance < unit.minimum_range:
		direction = -direction
		desired = unit.minimum_range - distance + 0.002
	var budget := minf(unit.movement_budget(CombatWorld.FIXED_DT), desired)
	var hand := 1.0 if (unit.id + seed_value) % 2 == 0 else -1.0
	# Sliding candidates let rear ranks flow around occupied front ranks. Swept
	# tests prevent crossing another body even when designers increase speed.
	for angle: float in [0.0, hand * PI / 4, -hand * PI / 4, hand * PI / 2, -hand * PI / 2]:
		var endpoint := unit.position + direction.rotated(angle) * budget
		if _clear_segment(unit, endpoint):
			var old_cell := _cell(unit.position)
			world.set_position(unit.id, endpoint)
			var new_cell := _cell(endpoint)
			if old_cell != new_cell:
				_buckets[old_cell].erase(unit.id)
				if not _buckets.has(new_cell):
					_buckets[new_cell] = []
				_buckets[new_cell].append(unit.id)
			return
	blocked_moves += 1


func _clear_segment(unit: CombatUnit, endpoint: Vector2) -> bool:
	var radius := unit.body_radius
	if endpoint.x < radius or endpoint.y < radius or endpoint.x > SIZE.x - radius or endpoint.y > SIZE.y - radius:
		return false
	var padding := Vector2.ONE * (radius + _max_radius)
	var low := _cell(unit.position.min(endpoint) - padding)
	var high := _cell(unit.position.max(endpoint) + padding)
	var segment := endpoint - unit.position
	var length_squared := segment.length_squared()
	for y in range(low.y, high.y + 1):
		for x in range(low.x, high.x + 1):
			for id: int in _buckets.get(Vector2i(x, y), []):
				if id == unit.id:
					continue
				var other: CombatUnit = world.units[id]
				var t := clampf((other.position - unit.position).dot(segment) / length_squared, 0, 1) if length_squared > 0 else 0.0
				var nearest := unit.position + segment * t
				if nearest.distance_squared_to(other.position) < pow(radius + other.body_radius + 0.00001, 2):
					return false
	return true


func _rebuild_buckets() -> void:
	_buckets.clear()
	for unit: CombatUnit in world.units.values():
		var cell := _cell(unit.position)
		if not _buckets.has(cell):
			_buckets[cell] = []
		_buckets[cell].append(unit.id)


static func _cell(position: Vector2) -> Vector2i:
	return Vector2i((position / CELL_SIZE).floor())


func _on_hit(event: Dictionary) -> void:
	if first_hit_tick < 0:
		first_hit_tick = int(event["tick"])


func _sample() -> void:
	var alive := [0, 0]
	var hp := [0, 0]
	for unit: CombatUnit in world.units.values():
		alive[unit.team_id] += 1
		hp[unit.team_id] += unit.hp
	timeline.append({"tick": world.tick_count, "seconds": world.seconds(), "alive": alive, "hp": hp})


func report() -> Dictionary:
	var survivors := [0, 0]
	var hp := [0, 0]
	for unit: CombatUnit in world.units.values():
		survivors[unit.team_id] += 1
		hp[unit.team_id] += unit.hp
	var teams: Array[Dictionary] = []
	for team in 2:
		var row := initial[team].duplicate(true)
		row["survivors"] = survivors[team]
		row["casualties"] = int(row["count"]) - survivors[team]
		row["survival_rate"] = float(survivors[team]) / int(row["count"])
		row["remaining_hp"] = hp[team]
		row["hp_retention_rate"] = float(hp[team]) / int(row["initial_hp"])
		row["mean_survivor_hp"] = float(hp[team]) / survivors[team] if survivors[team] else 0.0
		teams.append(row)
	var outcome := "running"
	var winner: Variant = null
	if finished:
		outcome = "timeout"
		if survivors[0] == 0 and survivors[1] == 0:
			outcome = "draw"
		elif survivors[0] == 0 or survivors[1] == 0:
			outcome = "elimination"
			winner = 0 if survivors[0] > 0 else 1
	return {"report_version": 1, "arena_version": VERSION, "seed": seed_value,
		"database_sha256": database.content_sha256, "database_generation": database.generation,
		"balance_id": database.balance_id, "stat_basis": "base_before_faction_and_tech",
		"engine": Engine.get_version_info()["string"], "fixed_dt": CombatWorld.FIXED_DT,
		"arena_tiles": [SIZE.x, SIZE.y], "swapped_sides": swapped, "max_ticks": max_ticks,
		"outcome": outcome, "winner_team": winner, "ticks": world.tick_count,
		"simulation_seconds": world.seconds(),
		"first_hit_seconds": first_hit_tick * CombatWorld.FIXED_DT if first_hit_tick >= 0 else null,
		"attacks_resolved": world.attacks_resolved, "blocked_move_attempts": blocked_moves,
		"teams": teams, "timeline": timeline.duplicate(true),
		"assumptions": ["Flat closed arena; no fog, obstacles, upgrades, economy, payroll or player micro.",
			"Seeded deployment, greedy targeting and swept-circle steering; not the full military pathfinder.",
			"Costs are base recruitment vectors, not equal-resource armies or actual spending.",
			"A repeatable micro scenario is not a skirmish win rate or a final balance verdict."]}
