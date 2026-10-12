class_name GuardLosArea
extends Area2D
## Scene adapter only. Author a CollisionShape2D/CollisionPolygon2D LOS volume
## and a collision mask for the hero's PhysicsBody2D layer. Body signals union
## multiple shapes automatically. This is NOT wall-occluding raycast vision.
## No _process/_physics_process per guard; the host steps the mission once.

var _mission: MissionTriggerManager
var _guard_id: StringName
var _guard_team: int
var _hero: WeakRef
var _registered: bool = false
var _enabled: bool = true


func configure(mission: MissionTriggerManager, guard_id: StringName,
		guard_team: int, hero: PhysicsBody2D) -> bool:
	if mission == null or hero == null or guard_id == &"" or guard_team < 0:
		return false
	_detach()
	_mission = mission
	_guard_id = guard_id
	_guard_team = guard_team
	_hero = weakref(hero)
	hero.tree_exiting.connect(_on_hero_exiting)
	if is_inside_tree():
		_register()
		return _registered
	return true


func _enter_tree() -> void:
	_register()
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)


func _exit_tree() -> void:
	_detach()


func _register() -> void:
	if _hero != null:
		var hero := _hero.get_ref() as PhysicsBody2D
		if hero != null and not hero.tree_exiting.is_connected(_on_hero_exiting):
			hero.tree_exiting.connect(_on_hero_exiting)
	if _mission != null and not _registered:
		_registered = _mission.register_guard(_guard_id, _guard_team)
		if _registered:
			_mission.set_guard_enabled(_guard_id, _enabled)
			# Reconfiguration inside an existing overlap has no new enter signal.
			call_deferred("_sync_existing_overlap")


func _sync_existing_overlap() -> void:
	if _registered and _enabled and is_inside_tree() and _hero != null:
		var hero := _hero.get_ref() as PhysicsBody2D
		if hero != null and overlaps_body(hero):
			_on_body_entered(hero)


func set_guard_active(active: bool) -> void:
	_enabled = active
	if _registered:
		_mission.set_guard_enabled(_guard_id, active)
	# Physics can be flushing enter/exit signals. Monitoring changes are deferred.
	set_deferred("monitoring", active)
	if active:
		call_deferred("_sync_existing_overlap")


func _on_body_entered(body: Node2D) -> void:
	if _registered and _enabled and _hero != null and body == _hero.get_ref():
		_mission.report_los(_guard_id, _mission.protagonist_id(), true)


func _on_body_exited(body: Node2D) -> void:
	if _registered and _hero != null and body == _hero.get_ref():
		_mission.report_los(_guard_id, _mission.protagonist_id(), false)


func _on_hero_exiting() -> void:
	if _registered:
		_mission.report_los(_guard_id, _mission.protagonist_id(), false)


func _detach() -> void:
	if _registered:
		_mission.unregister_guard(_guard_id)
	_registered = false
	if _hero != null:
		var hero := _hero.get_ref() as PhysicsBody2D
		if hero != null and hero.tree_exiting.is_connected(_on_hero_exiting):
			hero.tree_exiting.disconnect(_on_hero_exiting)
