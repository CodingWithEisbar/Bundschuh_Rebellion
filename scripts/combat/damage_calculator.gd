class_name DamageCalculator
extends RefCounted
## Pure damage calculation; ownership, range and cooldown belong to CombatWorld.
## Normal armor only affects the normal channel. Class resistance only affects
## its matching counter. +25 is an ADDITIVE counter, not a 25x multiplier.


static func calculate(attacker: CombatUnit, target: CombatUnit) -> Dictionary:
	if attacker.attack <= 0 or attacker.base_attack_period <= 0.0:
		return {"normal": 0, "bonus": 0, "by_class": {}, "subtotal": 0,
			"height_multiplier": 1.0, "height_bonus": 0, "total": 0}
	var armor := target.melee_armor if attacker.channel == CombatTypes.DamageChannel.MELEE else target.pierce_armor
	var normal := maxi(1, attacker.attack - armor)
	var bonus := 0
	var by_class: Dictionary = {}
	for armor_class: int in attacker.bonuses:
		if not target.armor_classes.has(armor_class):
			continue
		var extra := maxi(0, int(attacker.bonuses[armor_class]) - int(target.bonus_armor.get(armor_class, 0)))
		by_class[armor_class] = extra
		bonus += extra
	var subtotal := normal + bonus
	var factor := HighGroundDamage.multiplier(attacker.elevation, target.elevation)
	var total := HighGroundDamage.apply(subtotal, attacker.elevation, target.elevation)
	return {"normal": normal, "bonus": bonus, "by_class": by_class,
		"subtotal": subtotal, "height_multiplier": factor,
		"height_bonus": total - subtotal, "total": total}
