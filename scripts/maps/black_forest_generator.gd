class_name BlackForestGenerator
extends RefCounted
## Bounded seeded cellular automata + guaranteed corridors + validated deposits.
## No runtime A* per tree, global RNG side effects, unbounded retry or hidden
## resource grants. A rejected recipe returns errors rather than a broken map.

const T = GeneratedMap.Tile


static func generate(config: BlackForestConfig) -> GeneratedMap:
	var failure := GeneratedMap.new()
	if config == null:
		failure.errors.append("Missing BlackForestConfig.")
		return failure
	failure.errors = config.validate()
	if not failure.errors.is_empty():
		return failure
	# Snapshot the editor Resource; later edits do not mutate an existing map.
	var recipe := config.duplicate(true) as BlackForestConfig
	for attempt in range(recipe.max_attempts):
		var map := _generate_once(recipe, attempt)
		map.errors = validate_map(map)
		if map.errors.is_empty():
			return map
		failure = map
	failure.errors.push_front("Generation exhausted %d bounded attempts." % recipe.max_attempts)
	return failure


static func _rng(seed_value: int, stream: int, attempt: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value ^ stream ^ (attempt * 104729)
	return rng


static func _generate_once(config: BlackForestConfig, attempt: int) -> GeneratedMap:
	var map := GeneratedMap.new()
	map.recipe = config
	map.size = config.map_size
	map.seed_value = config.seed_value
	map.attempt = attempt
	map.tiles.resize(map.size.x * map.size.y)
	map.elevations.resize(map.tiles.size())
	var forest_rng := _rng(config.seed_value, 0x1F123BB5, attempt)
	for i in range(map.tiles.size()):
		map.tiles[i] = T.FOREST if forest_rng.randf() < config.initial_forest else T.GRASS
	for iteration in range(config.smoothing_steps):
		_smooth(map)
	# A continuous five-cell forest spine guarantees that each carved opening
	# really is a chokepoint, rather than decoration beside an unblocked bypass.
	var middle := floori(map.size.x * 0.5)
	for y in range(map.size.y):
		for x in range(map.size.x):
			if x == 0 or y == 0 or x == map.size.x - 1 or y == map.size.y - 1 or absi(x - middle) <= 2:
				map.set_tile(Vector2i(x, y), T.FOREST)
	var home_x := config.spawn_clear_radius + 3
	var center_y := floori(map.size.y * 0.5)
	map.spawns.assign([Vector2i(home_x, center_y), Vector2i(map.size.x - 1 - home_x, center_y)])
	for spawn in map.spawns:
		_carve(map, spawn, config.spawn_clear_radius)
	_carve_routes(map, _rng(config.seed_value, 0x5A17, attempt))
	# Remove inaccessible empty pockets before placing resources. No spawn or
	# deposit is justified by walking diagonally through a pair of trees.
	var reached := map.reachable(map.spawns[0])
	for i in range(map.tiles.size()):
		if map.tiles[i] == T.GRASS and reached[i] == 0:
			map.tiles[i] = T.FOREST
	_place_veins(map, _rng(config.seed_value, 0x73C914, attempt))
	_generate_elevation(map, _rng(config.seed_value, 0x1248AB, attempt))
	return map


static func _smooth(map: GeneratedMap) -> void:
	var next := map.tiles.duplicate()
	for y in range(map.size.y):
		for x in range(map.size.x):
			var count := 0
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if dx != 0 or dy != 0:
						count += int(map.tile_at(Vector2i(x + dx, y + dy)) == T.FOREST)
			next[map.index(Vector2i(x, y))] = T.FOREST if count >= 5 else T.GRASS
	map.tiles = next


static func _carve(map: GeneratedMap, center: Vector2i, radius: int) -> void:
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			var cell := Vector2i(x, y)
			if x > 0 and y > 0 and x < map.size.x - 1 and y < map.size.y - 1:
				map.set_tile(cell, T.GRASS)
				map.protected_cells[cell] = true


static func _carve_routes(map: GeneratedMap, rng: RandomNumberGenerator) -> void:
	var radius := floori(map.recipe.corridor_width * 0.5)
	var middle := floori(map.size.x * 0.5)
	var left := map.spawns[0]
	var right := map.spawns[1]
	for fraction in [0.25, 0.5, 0.75]:
		var lane_y := floori(map.size.y * fraction) + rng.randi_range(-1, 1)
		var approach_x := clampi(left.x + map.recipe.spawn_clear_radius + rng.randi_range(1, 3), left.x + 1, middle - 5)
		var far_x := map.size.x - 1 - approach_x
		var points: Array[Vector2i] = [left, Vector2i(approach_x, left.y),
			Vector2i(approach_x, lane_y), Vector2i(far_x, lane_y), Vector2i(far_x, right.y), right]
		var path: Array[Vector2i] = [left]
		var current := left
		for destination in points.slice(1):
			while current != destination:
				var step := Vector2i(signi(destination.x - current.x), 0) if current.x != destination.x else Vector2i(0, signi(destination.y - current.y))
				current += step
				path.append(current)
		for cell in path:
			_carve(map, cell, radius)
		map.corridors.append(path)
		map.chokepoints.append(Rect2i(Vector2i(middle - 2, lane_y - radius), Vector2i(5, map.recipe.corridor_width)))


static func _place_veins(map: GeneratedMap, rng: RandomNumberGenerator) -> void:
	var candidates: Array[Vector2i] = []
	for y in range(2, map.size.y - 2):
		for x in range(2, map.size.x - 2):
			var cell := Vector2i(x, y)
			if map.tile_at(cell) == T.GRASS and not map.protected_cells.has(cell):
				candidates.append(cell)
	# Fisher-Yates with the local stream; Array.shuffle() would touch global RNG.
	for i in range(candidates.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var previous := candidates[i]
		candidates[i] = candidates[j]
		candidates[j] = previous
	for kind in [T.GOLD, T.STONE]:
		var wanted := map.recipe.gold_veins if kind == T.GOLD else map.recipe.stone_veins
		var placed := 0
		for origin in candidates:
			if placed == wanted:
				break
			var length := rng.randi_range(map.recipe.vein_min_length, map.recipe.vein_max_length)
			var direction := Vector2i.RIGHT if rng.randi_range(0, 1) == 0 else Vector2i.DOWN
			var cells: Array[Vector2i] = []
			var allowed := true
			for offset in range(length):
				var cell := origin + direction * offset
				if not map.contains(cell) or map.tile_at(cell) != T.GRASS or map.protected_cells.has(cell):
					allowed = false
					break
				for neighbor in WorldGrid.DIRECTIONS:
					if map.tile_at(cell + neighbor) in [T.GOLD, T.STONE]:
						allowed = false # Keep different veins separated.
				cells.append(cell)
			if not allowed:
				continue
			for cell in cells:
				map.set_tile(cell, kind)
			if not _all_ground_and_mines_reachable(map):
				for cell in cells:
					map.set_tile(cell, T.GRASS)
				continue
			var amount := map.recipe.gold_per_tile if kind == T.GOLD else map.recipe.stone_per_tile
			map.veins.append({"kind": kind, "cells": cells, "amount": amount})
			placed += 1


static func _all_ground_and_mines_reachable(map: GeneratedMap) -> bool:
	var reached := map.reachable(map.spawns[0])
	for y in range(map.size.y):
		for x in range(map.size.x):
			var cell := Vector2i(x, y)
			var kind := map.tile_at(cell)
			if kind == T.GRASS and reached[map.index(cell)] == 0:
				return false
			if kind in [T.GOLD, T.STONE]:
				var accessible := false
				for direction in WorldGrid.DIRECTIONS:
					var edge := cell + direction
					if map.contains(edge) and reached[map.index(edge)] == 1:
						accessible = true
				if not accessible:
					return false
	return true


static func _generate_elevation(map: GeneratedMap, rng: RandomNumberGenerator) -> void:
	# A coarse random lattice, bilinearly interpolated and quantized to terraces.
	# This is traversable elevation data, not cliffs or extra physics barriers.
	const PERIOD := 12
	var lattice_size := Vector2i(ceili(map.size.x / float(PERIOD)) + 1, ceili(map.size.y / float(PERIOD)) + 1)
	var lattice := PackedFloat32Array()
	for i in range(lattice_size.x * lattice_size.y):
		lattice.append(rng.randf())
	for y in range(map.size.y):
		for x in range(map.size.x):
			var lx := floori(x / float(PERIOD))
			var ly := floori(y / float(PERIOD))
			var fx := (x % PERIOD) / float(PERIOD)
			var fy := (y % PERIOD) / float(PERIOD)
			var i := ly * lattice_size.x + lx
			var upper := lerpf(lattice[i], lattice[i + 1], fx)
			var lower := lerpf(lattice[i + lattice_size.x], lattice[i + lattice_size.x + 1], fx)
			map.elevations[map.index(Vector2i(x, y))] = mini(map.recipe.max_elevation, floori(lerpf(upper, lower, fy) * (map.recipe.max_elevation + 1)))
	for spawn in map.spawns:
		var radius := map.recipe.spawn_clear_radius
		for y in range(spawn.y - radius, spawn.y + radius + 1):
			for x in range(spawn.x - radius, spawn.x + radius + 1):
				map.elevations[map.index(Vector2i(x, y))] = 0


static func validate_map(map: GeneratedMap) -> Array[String]:
	var errors: Array[String] = []
	if map == null or not map.valid():
		errors.append("Missing or malformed generated map data.")
		return errors
	if map.spawns.size() != 2 or not _all_ground_and_mines_reachable(map):
		errors.append("Ground or resource access is disconnected.")
	var gold := 0
	var stone := 0
	for vein in map.veins:
		gold += int(vein["kind"] == T.GOLD)
		stone += int(vein["kind"] == T.STONE)
	if gold != map.recipe.gold_veins or stone != map.recipe.stone_veins:
		errors.append("Not enough safe mineral sites for the requested budget.")
	for cell: Vector2i in map.protected_cells:
		if map.tile_at(cell) != T.GRASS:
			errors.append("A protected spawn/corridor was obstructed.")
			break
	return errors
