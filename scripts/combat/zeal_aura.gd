class_name ZealAura
extends RefCounted
## Stage 2 ruleset: all living, deployed allies (same team, including the source)
## receive +15% attack RATE and movement speed. This replaces, rather than adds
## to, the old GDD damage aura. Membership is sampled every simulation second.

const EFFECT_ID: StringName = &"radical_preacher_zeal"
const RADIUS := 6.0
const RATE := 1.15
var _recipients: Dictionary = {}
var scans: int = 0
var sources_last_scan: int = 0
var targets_last_scan: int = 0


func refresh(units: Dictionary, spatial: CombatSpatialHash) -> void:
	var next: Dictionary = {}
	sources_last_scan = 0
	for source: CombatUnit in units.values():
		if not source.alive() or not source.on_field or source.mutinous:
			continue
		if source.kind != CombatTypes.UnitType.RADICAL_PREACHER or source.faction != CombatTypes.Faction.BUNDSCHUH or not source.zeal.get("enabled", false):
			continue
		sources_last_scan += 1
		for target in spatial.query_circle(source.position, float(source.zeal["radius_tiles"])):
			if target.team_id == source.team_id:
				# Strongest value per stat wins; never multiply by source count.
				var rates: Vector2 = next.get(target.id, Vector2.ONE)
				rates.x = maxf(rates.x, float(source.zeal["attack_rate_multiplier"]))
				rates.y = maxf(rates.y, float(source.zeal["movement_rate_multiplier"]))
				next[target.id] = rates
	for id: int in _recipients:
		if not next.has(id) and units.has(id):
			units[id].modifiers.remove_effect(EFFECT_ID)
	for id: int in next:
		var target: CombatUnit = units[id]
		var rates: Vector2 = next[id]
		target.modifiers.set_effect(EFFECT_ID, rates.x, rates.y)
	_recipients = next
	targets_last_scan = next.size()
	scans += 1


func forget(unit: CombatUnit) -> void:
	unit.modifiers.remove_effect(EFFECT_ID)
	_recipients.erase(unit.id)
