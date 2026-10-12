class_name BlackForestFactory
extends RefCounted
## Converts validated data to the SAME finite resources, grid and AI as Stage 1.
## Only the sandbox starter economy/16 villagers are scenario grants. Forests
## are harvestable, so logging can eventually open alternative routes.


static func create(map: GeneratedMap) -> RtsSimulation:
	if map == null or not map.valid():
		return null
	var world := RtsSimulation.new(map.size)
	world.generated_map = map
	world.grid.elevations = map.elevations.duplicate()
	for y in range(map.size.y):
		for x in range(map.size.x):
			var cell := Vector2i(x, y)
			var tile := map.tile_at(cell)
			var kind := -1
			var amount := 0
			match tile:
				GeneratedMap.Tile.FOREST:
					kind = ResourceKind.Type.WOOD
					amount = map.recipe.wood_per_tree
				GeneratedMap.Tile.GOLD:
					kind = ResourceKind.Type.GOLD
					amount = map.recipe.gold_per_tile
				GeneratedMap.Tile.STONE:
					kind = ResourceKind.Type.STONE
					amount = map.recipe.stone_per_tile
			if kind >= 0:
				world.add_resource(kind, Rect2i(cell, Vector2i.ONE), amount)
	var home := map.spawns[0]
	world.add_building("town_center", home - Vector2i.ONE, true)
	for x in range(-1, 2):
		world.add_resource(ResourceKind.Type.FOOD, Rect2i(home + Vector2i(x, -3), Vector2i.ONE), 150)
	for kind in ResourceKind.Type.values():
		world.bank.credit(kind, 800 if kind == ResourceKind.Type.WOOD else 500)
	world.housing = 16
	var radius := map.recipe.spawn_clear_radius
	for y in range(home.y - radius, home.y + radius + 1):
		for x in range(home.x - radius, home.x + radius + 1):
			if world.agents.size() < 16 and world.grid.walkable(Vector2i(x, y)):
				world.add_agent(Vector2i(x, y), true)
	return world
