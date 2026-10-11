class_name RtsMinimap
extends Control

signal navigated(world_point: Vector2)
var model: RtsSimulation


func _ready() -> void:
	custom_minimum_size = Vector2(220, 138)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#263b31"))
	if model == null:
		return
	var scale_xy := size / Vector2(model.grid.size)
	for cell: Vector2i in model.grid.blockers:
		var color := Color("#152c24") if model.grid.blockers[cell] == -1 else Color("#bca473")
		draw_rect(Rect2(Vector2(cell) * scale_xy, scale_xy), color)
	for agent: VillagerAgent in model.agents.values():
		draw_circle(agent.display_position(model.motion_alpha()) * scale_xy, 1.5, Color("#aee7d4"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("#7e8068"), false, 1)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		navigated.emit(event.position / size * Vector2(model.grid.size) * RtsWorldView.CELL)
		accept_event()
