class_name GeneratedMap
extends RefCounted
## Serializable map data, separate from scene nodes and runtime resource IDs.
## Forest/mineral tiles block movement until depleted by the economy adapter.

enum Tile { GRASS, FOREST, GOLD, STONE }
const GENERATOR_VERSION := 1
var size := Vector2i.ZERO
var seed_value: int = 0
var attempt: int = 0
var tiles := PackedByteArray()
var elevations := PackedInt32Array()
var spawns: Array[Vector2i] = []
var protected_cells: Dictionary = {}
var corridors: Array = [] # Ordered center-cell paths, not A* requests.
var chokepoints: Array[Rect2i] = []
var veins: Array[Dictionary] = [] # {kind: Tile, cells: Array[Vector2i], amount: int}
var recipe: BlackForestConfig
var errors: Array[String] = []


func valid() -> bool:
	return errors.is_empty() and recipe != null and size.x > 0 and size.y > 0 \
		and tiles.size() == size.x * size.y and elevations.size() == tiles.size() and spawns.size() == 2


func contains(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


func index(cell: Vector2i) -> int:
	return cell.y * size.x + cell.x


func tile_at(cell: Vector2i) -> int:
	return tiles[index(cell)] if contains(cell) else Tile.FOREST


func set_tile(cell: Vector2i, kind: int) -> void:
	tiles[index(cell)] = kind


func reachable(start: Vector2i) -> PackedByteArray:
	## Orthogonal flood fill, same connectivity convention as WorldGrid A*.
	var seen := PackedByteArray()
	seen.resize(tiles.size())
	if not contains(start) or tile_at(start) != Tile.GRASS:
		return seen
	var queue: Array[Vector2i] = [start]
	seen[index(start)] = 1
	var head := 0
	while head < queue.size():
		var current := queue[head]
		head += 1
		for direction in WorldGrid.DIRECTIONS:
			var next := current + direction
			if contains(next) and tile_at(next) == Tile.GRASS and seen[index(next)] == 0:
				seen[index(next)] = 1
				queue.append(next)
	return seen


func signature() -> String:
	## Pinned-engine regression fingerprint, not a cross-version network format.
	var meta := "%d|%d|%d|%s|%s|%s" % [GENERATOR_VERSION, seed_value, attempt,
		size, spawns, veins]
	return (meta + tiles.hex_encode() + elevations.to_byte_array().hex_encode()).sha256_text()


func statistics() -> Dictionary:
	var forest := 0
	var gold := 0
	var stone := 0
	for kind in tiles:
		forest += int(kind == Tile.FOREST)
		gold += int(kind == Tile.GOLD)
		stone += int(kind == Tile.STONE)
	return {"seed": seed_value, "attempt": attempt, "size": str(size),
		"forest_fraction": float(forest) / maxi(1, tiles.size()),
		"gold_tiles": gold, "stone_tiles": stone, "veins": veins.size(),
		"signature": signature(), "generator_version": GENERATOR_VERSION}
