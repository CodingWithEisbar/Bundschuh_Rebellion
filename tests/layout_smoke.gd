extends SceneTree
## Headless layout/input checks use actual Godot Control sizes and font metrics.
## This does not replace a screenshot/GPU check on the target desktop.

var errors: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	var main = scene.instantiate()
	root.add_child(main)
	main.set_physics_process(false)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	for resolution in [Vector2i(1280, 720), Vector2i(1440, 900), Vector2i(1920, 1080)]:
		root.size = resolution
		root.content_scale_size = resolution
		await process_frame
		await process_frame
		await process_frame
		var controls: Array[Control] = []
		_collect(main, controls)
		for control in controls:
			if not control.visible or not (control is Label or control is Button or control is RtsMinimap):
				continue
			var rect := control.get_global_rect()
			if rect.position.x < -1 or rect.position.y < -1 or rect.end.x > resolution.x + 1 or rect.end.y > resolution.y + 1:
				errors.append("%s outside %s: %s" % [control.name, resolution, rect])
		print("LAYOUT checked ", resolution, " — ", controls.size(), " controls")

	main.speed_button.grab_focus()
	var key := InputEventKey.new()
	key.keycode = KEY_SPACE
	key.pressed = true
	Input.parse_input_event(key)
	await process_frame
	if not main.paused or main.speed != 1:
		errors.append("Space must pause while a command button has focus.")

	main.dragging = true
	main.view.selecting = true
	main.drag_start = Vector2.ZERO
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = Vector2(300, root.size.y - 40) # release over bottom HUD
	Input.parse_input_event(release)
	await process_frame
	if main.dragging:
		errors.append("Mouse-up over HUD must end world selection drag.")

	for error in errors:
		push_error(error)
	main.free()
	print("LAYOUT / INPUT: ", "PASS" if errors.is_empty() else "FAIL")
	quit(0 if errors.is_empty() else 1)


func _collect(node: Node, output: Array[Control]) -> void:
	if node is Control:
		output.append(node)
	for child in node.get_children():
		_collect(child, output)
