class_name CombatUnitCatalog
extends RefCounted
## Base, unupgraded Phase 2 stats, with the Stage 2 prompt's explicit +25 Pike
## counter. These are scenario allocations, NOT paid recruitment or age unlocks.
## Every call returns fresh data; runtime modifiers never mutate the catalog.

const T = CombatTypes.UnitType
const C = CombatTypes.ArmorClass
const D = CombatTypes.DamageChannel


static func definition(kind: int) -> Dictionary:
	# hp, attack, M/P armor, speed, period, weapon range, classes, bonuses.
	var rows := {
		T.VILLAGER: [25, 3, 0, 0, 0.80, 2.0, 0.5, [], {}],
		T.PIKEMAN: [55, 4, 0, 0, 1.00, 3.0, 0.5, [C.INFANTRY, C.SPEAR], {C.CAVALRY: 25}],
		T.FLAILMAN: [45, 7, 0, 0, 1.10, 2.0, 0.5, [C.INFANTRY], {C.SPEAR: 4}],
		T.RADICAL_PREACHER: [35, 0, 0, 0, 0.85, 0.0, 0.0, [C.CLERGY], {}],
		T.LANDSKNECHT: [65, 6, 1, 0, 0.90, 2.0, 1.0, [C.INFANTRY, C.SPEAR], {C.CAVALRY: 24}],
		T.ARMOURED_RITTER: [125, 12, 2, 2, 1.30, 1.8, 0.5, [C.CAVALRY], {}],
		T.CROSSBOWMAN: [45, 5, 0, 0, 0.96, 2.0, 5.0, [C.ARCHER], {}],
		T.SKIRMISHER: [35, 2, 0, 3, 0.96, 3.0, 4.0, [C.ARCHER], {C.ARCHER: 3, C.SPEAR: 2}],
		T.ARQUEBUSIER: [45, 16, 0, 0, 0.85, 3.5, 6.0, [C.ARCHER], {C.INFANTRY: 6}],
		T.LIGHT_CAVALRY: [80, 7, 0, 2, 1.50, 2.0, 0.5, [C.CAVALRY], {C.CLERGY: 8}],
	}
	if not rows.has(kind):
		return {}
	var row: Array = rows[kind]
	return {
		"kind": kind, "max_hp": row[0], "attack": row[1],
		"melee_armor": row[2], "pierce_armor": row[3], "movement_speed": row[4],
		"attack_period": row[5], "attack_range": row[6], "armor_classes": row[7],
		"bonuses": row[8], "bonus_armor": {}, "body_radius": 0.18,
		"channel": D.PIERCE if kind in [T.CROSSBOWMAN, T.SKIRMISHER, T.ARQUEBUSIER] else D.MELEE,
		"minimum_range": 1.0 if kind == T.SKIRMISHER else 0.0,
	}
