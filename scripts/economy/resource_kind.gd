class_name ResourceKind
extends RefCounted
## Numeric keys are stable data IDs, not translated display strings.
enum Type { FOOD, WOOD, GOLD, STONE }
const NAMES: Array[String] = ["Food", "Wood", "Gold", "Stone"]
const COLORS: Array[Color] = [
	Color("#c5a561"), Color("#7caa6b"), Color("#e1bf58"), Color("#aab9bf")
]
