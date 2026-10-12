extends SceneTree
## Real lab scene, simulated quickly without a graphics/audio device requirement.
## Run: godot --headless --path . --script examples/stage4_backend_demo.gd


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := load("res://scenes/stage4_lab.tscn") as PackedScene
	var lab = scene.instantiate()
	root.add_child(lab)
	lab.set_process(false)
	lab.set_physics_process(false)
	lab.select_faction(0)
	# Unlike the accelerated model loop below, audio must see engine frames.
	for i in range(5):
		await process_frame
	lab.begin_combat()
	var damage_before_marker := false
	for i in range(80):
		lab._physics_process(0.05)
		lab._process(0.05)
		# Landsknecht is faster than Pike: first contact at 0.75s after start.
		if i < 15 and lab.world.attacks_resolved > 0:
			damage_before_marker = true
	print("ANIMATION: hits=", lab.world.attacks_resolved, " impact frame=", lab.profiles[0].impact_frame,
		" premature damage=", damage_before_marker)
	print("MUSIC: visible fighters=", lab.sound.director.visible_fighters, " combat mix=", lab.sound.mix)
	print("POOLS: ", lab.pool.capacity, " unit views / ", lab.sound.voice_players.size(), " VO players")
	var passed: bool = not damage_before_marker and lab.world.attacks_resolved > 0 and lab.sound.mix > 0.99
	lab.stop_combat()
	for i in range(230):
		lab._physics_process(0.05)
		lab._process(0.05)
	print("AFTERMATH: eco mix restored=", lab.sound.mix < 0.01)
	passed = passed and lab.sound.mix < 0.01
	lab.sound.stop_voices()
	lab.select_faction(1)
	for i in range(5):
		await process_frame
	print("VOICE: ", lab.caption.text, " (diagnostic tone, not recorded German)")
	passed = passed and lab.sound.voice_starts >= 2
	await lab.sound.shutdown_and_drain()
	lab.free()
	await process_frame
	print("STAGE 4 DEMO: ", "PASS" if passed else "FAIL")
	quit(0 if passed else 1)
