class_name CombatWorld
extends RefCounted
## Stage 2 backend composition root. One central 20 Hz simulation clock drives
## attack recovery; aura uses 20-tick deadlines and payroll 600-tick deadlines.
## No SceneTree timer, per-unit _process(), physics overlap or scene-tree search.
## Command/event consumers operate on IDs; this model never retains a UI Node.

signal hit_resolved(event: Dictionary)
signal unit_died(event: Dictionary)
signal payroll_settled(event: Dictionary)
signal desertion_event(event: Dictionary)

const FIXED_DT := 0.05
const AURA_TICKS := 20
const PAYROLL_TICKS := 600
const MAX_UNITS := 200
const MUTINY_AGGRO_RADIUS := 6.0

var units: Dictionary = {}
var players: Dictionary = {}
var aura := ZealAura.new()
var spatial := CombatSpatialHash.new()
var maintenance := MercenaryMaintenance.new()
var tick_count: int = 0
var paused: bool = false
var attacks_resolved: int = 0
var _next_id: int = 1
var _accumulator: float = 0.0
var _advancing: bool = false
var _orders: Dictionary = {} # attacker ID -> target ID; only active orders tick.
var _events: Array[Dictionary] = []
var _terrain: WorldGrid


func bind_terrain(terrain: WorldGrid) -> bool:
	## Optional 2D adapter. Standalone/3D hosts instead supply explicit elevation.
	if _advancing or terrain == null:
		return false
	for unit: CombatUnit in units.values():
		if not terrain.contains(Vector2i(unit.position.floor())):
			return false
	_terrain = terrain
	for unit: CombatUnit in units.values():
		_sample_elevation(unit)
	return true


func set_elevation(id: int, height: float) -> bool:
	# A bound terrain is authoritative; a second source cannot override it.
	if _advancing or _terrain != null or not units.has(id) or not is_finite(height):
		return false
	units[id].elevation = height
	return true


func _valid_position(point: Vector2) -> bool:
	return point.is_finite() and (_terrain == null or _terrain.contains(Vector2i(point.floor())))


func _sample_elevation(unit: CombatUnit) -> void:
	if _terrain != null:
		unit.elevation = _terrain.height_at(Vector2i(unit.position.floor()))


func add_player(owner: int, team: int, side: int, bank: ResourceBank,
		payroll_enabled: bool = false, wage: int = MercenaryMaintenance.DEFAULT_WAGE) -> bool:
	if _advancing or players.has(owner) or owner < 0 or team < 0 or bank == null or wage <= 0:
		return false
	if side not in CombatTypes.Faction.values():
		return false
	if payroll_enabled and side != CombatTypes.Faction.SWABIAN_LEAGUE:
		return false
	players[owner] = CombatPlayer.new(owner, team, side, bank, payroll_enabled, wage, tick_count + PAYROLL_TICKS)
	return true


func spawn(kind: int, owner: int, position: Vector2) -> CombatUnit:
	## Backend/scenario creation only: the recruitment system must pay and check
	## age/housing before calling this. Combat IDs are local to this registry.
	if _advancing or not players.has(owner) or units.size() >= MAX_UNITS or not _valid_position(position):
		return null
	var data := CombatUnitCatalog.definition(kind)
	if data.is_empty():
		return null
	var player: CombatPlayer = players[owner]
	var unit := CombatUnit.new(_next_id, owner, player.team_id, player.faction, position, data)
	_next_id += 1
	units[unit.id] = unit
	_sample_elevation(unit)
	return unit


func set_position(id: int, actual_center: Vector2) -> bool:
	## Trusted navigation adapter API, not a player-issued teleport command.
	## Caller samples the body trajectory, not an occupied/reserved endpoint.
	if _advancing or not units.has(id) or not _valid_position(actual_center):
		return false
	units[id].position = actual_center
	_sample_elevation(units[id])
	return true


func set_on_field(id: int, deployed: bool) -> bool:
	if _advancing or not units.has(id):
		return false
	var unit: CombatUnit = units[id]
	unit.on_field = deployed
	if not deployed:
		aura.forget(unit)
		_clear_orders_involving(id)
	return true


func transfer_unit(id: int, new_owner: int) -> bool:
	if _advancing or not units.has(id) or not players.has(new_owner):
		return false
	var player: CombatPlayer = players[new_owner]
	var unit: CombatUnit = units[id]
	aura.forget(unit)
	unit.modifiers.clear()
	unit.owner_id = player.id
	unit.team_id = player.team_id
	unit.faction = player.faction
	unit.mutinous = false
	_clear_orders_involving(id)
	return true


func remove_unit(id: int) -> bool:
	## Despawn is not a combat death and does not emit unit_died.
	if _advancing or not units.has(id):
		return false
	_remove(id)
	return true


func command_attack(owner: int, attacker_id: int, target_id: int) -> bool:
	if _advancing or owner < 0 or not units.has(attacker_id) or not units.has(target_id):
		return false
	var attacker: CombatUnit = units[attacker_id]
	var target: CombatUnit = units[target_id]
	if attacker.owner_id != owner or not attacker.can_attack() or not target.alive() or not target.on_field:
		return false
	if not are_enemies(attacker, target):
		return false
	_orders[attacker_id] = target_id
	return true


func command_stop(owner: int, id: int) -> bool:
	if _advancing or owner < 0 or not units.has(id) or units[id].owner_id != owner:
		return false
	_orders.erase(id)
	# Recovery is NOT reset. Spamming Stop/Attack cannot bypass attack speed.
	return true


func seconds() -> float:
	return tick_count * FIXED_DT


func advance(delta: float) -> void:
	## Invoke once from the simulation driver, never once per soldier. The host
	## subdivides larger frame gaps; accepting at most .25s bounds each call.
	assert(is_finite(delta) and delta >= 0.0 and delta <= 0.25)
	assert(not _advancing, "CombatWorld.advance is not reentrant")
	if paused or delta == 0.0:
		return
	_advancing = true
	_accumulator += delta
	while _accumulator >= FIXED_DT - 0.0000001:
		_accumulator = maxf(0.0, _accumulator - FIXED_DT)
		_tick()
	_advancing = false


func _tick() -> void:
	tick_count += 1
	# Account for the elapsed interval using its previous modifier. Membership
	# changes at this tick affect the FOLLOWING interval, not past recovery.
	for unit: CombatUnit in units.values():
		unit.recovery_work = maxf(0.0, unit.recovery_work - FIXED_DT * unit.modifiers.attack_rate)
	_run_payroll()
	if tick_count % AURA_TICKS == 0:
		spatial.rebuild(units)
		aura.refresh(units, spatial)
		_acquire_mutineer_targets()
	_resolve_attacks()
	_emit_events()


func _run_payroll() -> void:
	var owners := players.keys()
	owners.sort()
	for owner: int in owners:
		var player: CombatPlayer = players[owner]
		if not player.maintenance_enabled or tick_count < player.next_payroll_tick:
			continue
		# Advance the deadline BEFORE touching a bank that emits changed signals.
		# Replenishing gold or changing selection never resets the pay schedule.
		player.next_payroll_tick += PAYROLL_TICKS
		var invoice := maintenance.settle(player, units, tick_count)
		_events.append({"type": "payroll", "data": invoice})
		var deserters: Array[int] = invoice["deserter_ids"]
		if deserters.is_empty():
			continue
		var garrisoned: Array[int] = []
		for id in deserters:
			var unit: CombatUnit = units[id]
			aura.forget(unit)
			unit.modifiers.clear()
			unit.owner_id = CombatTypes.MUTINEER_OWNER
			unit.team_id = CombatTypes.MUTINEER_TEAM
			unit.mutinous = true
			# Never invent an exit position inside a wall/another body. Ownership
			# changes now; the host must choose a valid exit before redeployment.
			if not unit.on_field:
				garrisoned.append(id)
			_clear_orders_involving(id)
		_events.append({"type": "desertion", "data": {
			"former_owner_id": owner, "unit_ids": deserters.duplicate(),
			"garrisoned_ids": garrisoned,
			"tick": tick_count, "reason": "treasury_depleted", "invoice": invoice.duplicate(true)}})


func _acquire_mutineer_targets() -> void:
	for unit: CombatUnit in units.values():
		if not unit.mutinous or not unit.can_attack():
			continue
		var best: CombatUnit = null
		var best_distance := INF
		for candidate in spatial.query_circle(unit.position, MUTINY_AGGRO_RADIUS):
			if not are_enemies(unit, candidate):
				continue
			var distance := unit.position.distance_squared_to(candidate.position)
			if distance < best_distance or (distance == best_distance and (best == null or candidate.id < best.id)):
				best = candidate
				best_distance = distance
		if best != null:
			_orders[unit.id] = best.id
		else:
			_orders.erase(unit.id)


func _resolve_attacks() -> void:
	# Snapshot all valid swings before applying HP changes: equal-tick attacks
	# are simultaneous, so unit ID/insertion order cannot win a lethal trade.
	var hits: Array[Dictionary] = []
	var damage_by_target: Dictionary = {}
	var attackers := _orders.keys()
	attackers.sort()
	for id: int in attackers:
		var attacker: CombatUnit = units.get(id)
		var target: CombatUnit = units.get(_orders[id])
		if attacker == null or target == null or not attacker.can_attack() or not target.alive() or not target.on_field:
			_orders.erase(id)
			continue
		if not are_enemies(attacker, target):
			_orders.erase(id)
			continue
		if attacker.recovery_work > 0.000001 or not in_weapon_range(attacker, target):
			continue
		# Sample both physical centers at the hit, including terrain edits since
		# the last movement event. Never sample a reserved navigation endpoint.
		_sample_elevation(attacker)
		_sample_elevation(target)
		var result := DamageCalculator.calculate(attacker, target)
		var damage := int(result["total"])
		hits.append({"attacker_id": id, "target_id": target.id, "damage": damage,
			"breakdown": result, "tick": tick_count})
		damage_by_target[target.id] = int(damage_by_target.get(target.id, 0)) + damage
		attacker.recovery_work = attacker.base_attack_period
		attacks_resolved += 1
	var killed: Array[int] = []
	for id: int in damage_by_target:
		var target: CombatUnit = units[id]
		target.receive_damage(int(damage_by_target[id]))
		if not target.alive():
			killed.append(id)
	for hit in hits:
		# damage is the computed hit, possibly overkill; final HP is after the
		# whole simultaneous batch. Do not use it as actual-damage lifesteal.
		hit["target_hp_after"] = units[hit["target_id"]].hp
		_events.append({"type": "hit", "data": hit})
	for id in killed:
		var unit: CombatUnit = units[id]
		_events.append({"type": "death", "data": {"unit_id": id,
			"owner_id": unit.owner_id, "tick": tick_count}})
		_remove(id)


func _remove(id: int) -> void:
	var unit: CombatUnit = units[id]
	unit.on_field = false
	aura.forget(unit)
	unit.modifiers.clear()
	_clear_orders_involving(id)
	units.erase(id)
	spatial.clear()


func _clear_orders_involving(id: int) -> void:
	_orders.erase(id)
	for attacker: int in _orders.keys():
		if int(_orders[attacker]) == id:
			_orders.erase(attacker)


func _emit_events() -> void:
	# Observers see completed transactions. They must queue commands for after
	# advance() returns; synchronous mutation APIs reject calls during a tick.
	for event in _events:
		var data: Dictionary = event["data"].duplicate(true)
		match event["type"]:
			"hit": hit_resolved.emit(data)
			"death": unit_died.emit(data)
			"payroll": payroll_settled.emit(data)
			"desertion": desertion_event.emit(data)
	_events.clear()


static func are_enemies(a: CombatUnit, b: CombatUnit) -> bool:
	return a.team_id != b.team_id


static func in_weapon_range(attacker: CombatUnit, target: CombatUnit) -> bool:
	# GDD melee range is measured outside body radii. Ranged range uses centers.
	var distance := attacker.position.distance_to(target.position)
	if attacker.channel == CombatTypes.DamageChannel.MELEE:
		distance = maxf(0.0, distance - attacker.body_radius - target.body_radius)
	return distance >= attacker.minimum_range and distance <= attacker.attack_range
