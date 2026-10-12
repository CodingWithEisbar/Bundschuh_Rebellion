class_name BlackForestConfig
extends Resource
## Editor-tweakable recipe. Generation uses local RNG streams, never global randf.
## This compact Stage 3 map is not the GDD's fully budgeted ranked 160x160 RMS.

@export var seed_value: int = 1524
@export var map_size := Vector2i(64, 40)
@export_range(0.45, 0.75, 0.01) var initial_forest: float = 0.63
@export_range(1, 6, 1) var smoothing_steps: int = 3
@export_range(1, 5, 2) var corridor_width: int = 3
@export_range(3, 6, 1) var spawn_clear_radius: int = 5
@export_range(0, 20, 1) var gold_veins: int = 6
@export_range(0, 20, 1) var stone_veins: int = 4
@export_range(2, 5, 1) var vein_min_length: int = 2
@export_range(2, 5, 1) var vein_max_length: int = 4
@export_range(1, 8, 1) var max_attempts: int = 4
@export_range(0, 4, 1) var max_elevation: int = 2
@export var wood_per_tree: int = 100
@export var gold_per_tile: int = 800
@export var stone_per_tile: int = 350


func validate() -> Array[String]:
	var errors: Array[String] = []
	if map_size.x < 48 or map_size.y < 32 or map_size.x > 192 or map_size.y > 192:
		errors.append("Map size must be between 48x32 and 192x192.")
	if not is_finite(initial_forest) or initial_forest < 0.45 or initial_forest > 0.75:
		errors.append("Initial forest probability must be 0.45..0.75.")
	if smoothing_steps < 1 or smoothing_steps > 6 or corridor_width not in [1, 3, 5]:
		errors.append("Smoothing must be 1..6; corridor width must be 1, 3 or 5.")
	if spawn_clear_radius < 3 or spawn_clear_radius > 6:
		errors.append("Spawn clearing radius must be 3..6.")
	if gold_veins < 0 or stone_veins < 0 or gold_veins + stone_veins > 24:
		errors.append("Vein counts must be nonnegative and total at most 24.")
	if vein_min_length < 2 or vein_max_length > 5 or vein_min_length > vein_max_length:
		errors.append("Vein lengths must satisfy 2 <= min <= max <= 5.")
	if max_attempts < 1 or max_attempts > 8 or max_elevation < 0 or max_elevation > 4:
		errors.append("Attempts must be 1..8; elevation must be 0..4.")
	if wood_per_tree <= 0 or gold_per_tile <= 0 or stone_per_tile <= 0:
		errors.append("Each resource tile must have positive finite integer yield.")
	return errors
