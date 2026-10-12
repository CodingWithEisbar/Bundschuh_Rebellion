class_name BalanceClock
extends RefCounted
## 10x means ten simulated seconds per real second, retaining 0.05s fixed ticks.
## A bounded catch-up budget retains debt under load; it never drops game ticks.

var speed: float = 10.0
var debt_seconds: float = 0.0
var max_ticks_per_pump: int = 200


func pump(arena: BalanceArena, wall_delta: float, unpaced: bool = false) -> int:
	assert(is_finite(wall_delta) and wall_delta >= 0)
	assert(is_finite(speed) and speed > 0)
	if arena.finished:
		return 0
	if unpaced:
		debt_seconds = max_ticks_per_pump * CombatWorld.FIXED_DT
	else:
		debt_seconds += wall_delta * speed
	var steps := 0
	while debt_seconds >= CombatWorld.FIXED_DT - 0.0000001 and steps < max_ticks_per_pump and not arena.finished:
		arena.step()
		debt_seconds = maxf(0, debt_seconds - CombatWorld.FIXED_DT)
		steps += 1
	return steps
