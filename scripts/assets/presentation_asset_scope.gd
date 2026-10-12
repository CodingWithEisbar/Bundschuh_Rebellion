class_name PresentationAssetScope
extends RefCounted
## Loading-screen scope. Only call load_threaded_get AFTER LOADED: otherwise it
## can block the main thread. No load() is used in selection/combat callbacks.
## Consumers must stop players/release views before releasing their resources.

enum State { EMPTY, LOADING, READY, FAILED }
var state: State = State.EMPTY
var resource: Resource
var error: String = ""
var _path: String = ""


func request(path: String) -> bool:
	if state == State.LOADING or not path.begins_with("res://") or not ResourceLoader.exists(path):
		return false
	resource = null
	error = ""
	_path = path
	var result := ResourceLoader.load_threaded_request(path, "", false, ResourceLoader.CACHE_MODE_REUSE)
	state = State.LOADING if result == OK else State.FAILED
	if result != OK:
		error = "Asset request failed: " + error_string(result)
	return result == OK


func poll() -> State:
	if state != State.LOADING:
		return state
	match ResourceLoader.load_threaded_get_status(_path):
		ResourceLoader.THREAD_LOAD_LOADED:
			resource = ResourceLoader.load_threaded_get(_path)
			state = State.READY if resource != null else State.FAILED
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			state = State.FAILED
			error = "Asset loading failed: " + _path
	return state


func release() -> bool:
	# Godot has no cancellation API here. Drain an in-flight request first.
	if state == State.LOADING:
		return false
	resource = null
	_path = ""
	state = State.EMPTY
	return true
