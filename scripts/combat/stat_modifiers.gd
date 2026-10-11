class_name CombatStatModifiers
extends RefCounted
## Named effect slots replace values, never multiply the current stat in place.
## One "zeal" slot means ten overlapping preachers still give exactly 1.15x.
## Different named effects multiply; removing one leaves the others intact.

var _effects: Dictionary = {}
var attack_rate: float = 1.0
var movement_rate: float = 1.0


func set_effect(key: StringName, attack_multiplier: float, movement_multiplier: float) -> void:
	assert(not key.is_empty())
	assert(is_finite(attack_multiplier) and attack_multiplier > 0.0)
	assert(is_finite(movement_multiplier) and movement_multiplier > 0.0)
	var value := Vector2(attack_multiplier, movement_multiplier)
	if _effects.get(key) == value:
		return
	_effects[key] = value
	_recompute()


func remove_effect(key: StringName) -> void:
	if _effects.erase(key):
		_recompute()


func has_effect(key: StringName) -> bool:
	return _effects.has(key)


func clear() -> void:
	_effects.clear()
	_recompute()


func _recompute() -> void:
	attack_rate = 1.0
	movement_rate = 1.0
	var keys := _effects.keys()
	keys.sort() # Stable arithmetic order, regardless of effect arrival order.
	for key: StringName in keys:
		var value: Vector2 = _effects[key]
		attack_rate *= value.x
		movement_rate *= value.y
