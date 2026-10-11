class_name MercenaryMaintenance
extends RefCounted
## A single scheduled settlement for each enabled League player. The caller
## supplies a roster snapshot at the deadline (no prorating in Stage 2).
## Part payment intentionally drains available gold; ordinary building purchases
## still use ResourceBank's existing all-or-nothing transaction semantics.

const DEFAULT_WAGE := 1 # Prototype tuning: Gold / Landsknecht / 30 game seconds.
var settlements: int = 0


func settle(player: CombatPlayer, roster: Dictionary, tick: int) -> Dictionary:
	var mercenaries: Array[int] = []
	for unit: CombatUnit in roster.values():
		# Idle, fighting and garrisoned soldiers are employed; corpses, removed
		# units and former owners' mutineers are not. Recruitment queues aren't units.
		if unit.alive() and unit.owner_id == player.id and unit.kind == CombatTypes.UnitType.LANDSKNECHT:
			mercenaries.append(unit.id)
	mercenaries.sort()
	var due := mercenaries.size() * player.gold_per_mercenary
	var before := player.bank.amount(ResourceKind.Type.GOLD)
	var charged := mini(before, due)
	if charged > 0:
		var paid := player.bank.try_spend({ResourceKind.Type.GOLD: charged})
		assert(paid, "Payroll snapshot must settle on the simulation thread")
	var after := before - charged
	# Literal Stage 2 prompt rule: EXACT payment down to zero also causes mutiny.
	# No army means no desertion, even if the treasury was already empty.
	var deserters: Array[int] = []
	if not mercenaries.is_empty() and after == 0:
		deserters.assign(mercenaries)
	settlements += 1
	return {"owner_id": player.id, "tick": tick, "unit_ids": mercenaries,
		"due": due, "charged": charged, "shortfall": due - charged,
		"gold_before": before, "gold_after": after, "deserter_ids": deserters}
