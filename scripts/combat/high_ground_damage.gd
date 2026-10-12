class_name HighGroundDamage
extends RefCounted
## Stage 3 overrides the old GDD's no-height-damage rule. Apply once AFTER
## normal armor and class counters. Integer HP rounds half up once at the end.

const MULTIPLIER := 1.25


static func multiplier(attacker_height: float, defender_height: float) -> float:
	assert(is_finite(attacker_height) and is_finite(defender_height))
	return MULTIPLIER if attacker_height > defender_height else 1.0


static func apply(subtotal: int, attacker_height: float, defender_height: float) -> int:
	assert(subtotal >= 0)
	return floori(subtotal * multiplier(attacker_height, defender_height) + 0.5)
