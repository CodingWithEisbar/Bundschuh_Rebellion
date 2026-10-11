class_name BuildingCatalog
extends RefCounted
## Costs/build seconds follow GDD Phase 2. Footprints/HP are Stage 1 tuning.
## An unfinished drop-off never accepts cargo. Houses add housing on completion.

const DEFINITIONS: Dictionary = {
	"house": {"name": "House", "size": Vector2i(2, 2), "cost": {1: 25},
		"seconds": 25.0, "hp": 550.0, "accepts": [], "housing": 5},
	"mill": {"name": "Mill", "size": Vector2i(2, 2), "cost": {1: 100},
		"seconds": 35.0, "hp": 600.0, "accepts": [0], "housing": 0},
	"lumber_camp": {"name": "Lumber Camp", "size": Vector2i(2, 2), "cost": {1: 100},
		"seconds": 35.0, "hp": 600.0, "accepts": [1], "housing": 0},
	"mining_camp": {"name": "Mining Camp", "size": Vector2i(2, 2), "cost": {1: 100},
		"seconds": 35.0, "hp": 600.0, "accepts": [2, 3], "housing": 0},
	"town_center": {"name": "Town Center", "size": Vector2i(3, 3),
		"cost": {1: 275, 3: 100}, "seconds": 150.0, "hp": 2400.0,
		"accepts": [0, 1, 2, 3], "housing": 5}
}
const PLACEABLE: Array[String] = ["house", "mill", "lumber_camp", "mining_camp"]


static func definition(key: String) -> Dictionary:
	return DEFINITIONS.get(key, {}).duplicate(true)
