class_name DemoFactory
extends RefCounted
## Repeatable greybox scenarios. Debug spawns/bank grants are clearly separate
## from the GDD's standard 3-villager skirmish opening and recruitment rules.


static func create(stress: bool = false) -> RtsSimulation:
	var world := RtsSimulation.new(Vector2i(64, 40))
	for kind in ResourceKind.Type.values():
		world.bank.credit(kind, 500 if kind != ResourceKind.Type.WOOD else 800)
	# Black Forest barrier: exactly one walkable row through a five-tile pass.
	for y in range(40):
		for x in range(29, 34):
			if y != 19:
				world.grid.set_blocked(Vector2i(x, y), -1)
	world.add_building("town_center", Vector2i(7, 16), true)
	world.add_building("mill", Vector2i(14, 8), true)
	world.add_building("lumber_camp", Vector2i(10, 28), true)
	world.add_building("mining_camp", Vector2i(19, 28), true)
	for i in range(5):
		world.add_resource(ResourceKind.Type.FOOD, Rect2i(Vector2i(17 + i, 7), Vector2i.ONE), 150)
		world.add_resource(ResourceKind.Type.WOOD, Rect2i(Vector2i(6 + i, 32), Vector2i.ONE), 200)
		world.add_resource(ResourceKind.Type.GOLD, Rect2i(Vector2i(21 + i, 31), Vector2i.ONE), 180)
		world.add_resource(ResourceKind.Type.STONE, Rect2i(Vector2i(42 + i, 13), Vector2i.ONE), 180)
	world.add_building("town_center", Vector2i(48, 24), true)
	var target := 200 if stress else 16
	# Give only the scenario's explicit starting housing, not free House tech.
	world.housing = target
	for y in range(5, 27):
		for x in range(2, 27):
			if world.agents.size() < target and world.grid.walkable(Vector2i(x, y)):
				world.add_agent(Vector2i(x, y), true)
	return world
