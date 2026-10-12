class_name RtsWorldView
extends Node2D
## Greybox renderer only. Grid coordinates remain independent of this top-down
## projection so the Stage 4 isometric sprite pipeline can replace it later.

const CELL := 28.0
var model: RtsSimulation
var selected: Array[int] = []
var placement_key: String = ""
var placement_cell := Vector2i.ZERO
var placement_ok: bool = false
var show_paths: bool = false
var selection_rect := Rect2()
var selecting: bool = false
var font: Font = ThemeDB.fallback_font


func grid_cell(point: Vector2) -> Vector2i:
	return Vector2i(floori(point.x / CELL), floori(point.y / CELL))


func cell_center(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5)) * CELL


func _draw() -> void:
	if model == null:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(model.grid.size) * CELL)
	draw_rect(bounds, Color("#333f32"))
	for y in range(model.grid.size.y):
		for x in range(model.grid.size.x):
			var cell := Vector2i(x, y)
			var rect := Rect2(Vector2(cell) * CELL, Vector2.ONE * CELL)
			if model.grid.height_at(cell) > 0:
				draw_rect(rect, Color(0.72, 0.70, 0.40, 0.07 * model.grid.height_at(cell)))
			if (x + y) % 2 == 0:
				draw_rect(rect, Color(0.6, 0.7, 0.5, 0.025))
			if model.grid.blockers.get(cell, 0) == -1:
				draw_rect(rect, Color("#20392d"))
				var center := cell_center(cell)
				draw_line(center + Vector2(0, 8), center + Vector2(0, -7), Color("#806345"), 3)
				draw_circle(center + Vector2(0, -3), 9, Color("#305542"))
				draw_circle(center + Vector2(3, -6), 5, Color("#42654c"))

	for resource: GatherableResource in model.resources.values():
		if resource.remaining == 0:
			continue
		var center := cell_center(resource.footprint.position)
		if resource.kind == ResourceKind.Type.WOOD:
			draw_line(center + Vector2(0, 9), center + Vector2(0, -7), Color("#806345"), 3)
			draw_circle(center + Vector2(0, -3), 10, Color("#305542"))
			draw_circle(center + Vector2(3, -6), 6, Color("#42654c"))
			continue
		draw_circle(center, 11, ResourceKind.COLORS[resource.kind].darkened(0.3))
		draw_circle(center + Vector2(-2, -2), 8, ResourceKind.COLORS[resource.kind])
		draw_string(font, center + Vector2(-4, 4), ResourceKind.NAMES[resource.kind].left(1),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#162421"))

	for building: RtsBuilding in model.buildings.values():
		var rect := Rect2(Vector2(building.footprint.position) * CELL,
			Vector2(building.footprint.size) * CELL).grow(-2)
		var color := Color("#78674a") if building.finished else Color("#504e3b")
		draw_rect(rect, color)
		draw_rect(rect.grow(-4), Color("#c8b07a") if building.finished else Color("#c49950"), false, 2)
		if not building.finished:
			draw_line(rect.position, rect.end, Color("#c49950"), 2)
			draw_line(Vector2(rect.end.x, rect.position.y), Vector2(rect.position.x, rect.end.y), Color("#c49950"), 2)
		var abbreviations := {"town_center": "TC", "house": "HOUSE", "mill": "MILL",
			"lumber_camp": "WOOD", "mining_camp": "MINE"}
		draw_string(font, rect.position + Vector2(6, 22), abbreviations[building.key],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#fff0ce"))
		draw_rect(Rect2(rect.position + Vector2(0, -7), Vector2(rect.size.x, 4)), Color("#18221d"))
		draw_rect(Rect2(rect.position + Vector2(0, -7),
			Vector2(rect.size.x * building.hp / building.max_hp, 4)), Color("#a9d381"))

	if show_paths:
		var count := 0
		for id in selected:
			var agent: VillagerAgent = model.agents.get(id)
			if agent == null or count >= 8:
				continue
			var previous := cell_center(agent.cell)
			for cell in agent.path:
				var point := cell_center(cell)
				draw_line(previous, point, Color(0.55, 0.83, 0.85, 0.55), 1)
				previous = point
			count += 1

	for agent: VillagerAgent in model.agents.values():
		var point := agent.display_position(model.motion_alpha()) * CELL
		draw_circle(point + Vector2(1, 2), 6, Color(0, 0, 0, 0.28))
		if agent.id in selected:
			draw_arc(point, 8, 0, TAU, 16, Color("#a8e1cc"), 1.5)
		var color := Color("#d8c394")
		if agent.state in [VillagerAgent.State.GATHER, VillagerAgent.State.BUILD]:
			color = Color("#f1c775")
		draw_circle(point, VillagerAgent.RADIUS * CELL, color)
		draw_line(point + Vector2(2, -1), point + Vector2(8, -7), Color("#8b6542"), 2)
		if agent.cargo > 0:
			draw_circle(point + Vector2(-4, 4), 2.5, ResourceKind.COLORS[agent.cargo_kind])

	if placement_key != "":
		var size: Vector2i = BuildingCatalog.DEFINITIONS[placement_key]["size"]
		var color := Color("#79d6a6") if placement_ok else Color("#ef8b80")
		for y in range(size.y):
			for x in range(size.x):
				var rect := Rect2(Vector2(placement_cell + Vector2i(x, y)) * CELL, Vector2.ONE * CELL)
				draw_rect(rect.grow(-1), Color(color, 0.28))
				draw_rect(rect.grow(-1), color, false, 1.5)
				if not placement_ok:
					draw_line(rect.position + Vector2(4, 4), rect.end - Vector2(4, 4), color, 1)
		draw_string(font, Vector2(placement_cell) * CELL + Vector2(0, -10),
			"BUILD" if placement_ok else "BLOCKED", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color)
	if selecting:
		draw_rect(selection_rect.abs(), Color(0.6, 0.85, 0.75, 0.1))
		draw_rect(selection_rect.abs(), Color("#acd5bd"), false, 1)
