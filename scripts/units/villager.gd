class_name VillagerAgent
extends RefCounted
## Data-only unit model: no scene lookup, UI calls or per-unit _process().
## VillagerAI owns jobs; PathService owns routes; TrafficController owns steps.

enum State { IDLE, MOVE, MOVE_TO_RESOURCE, GATHER, RETURN_TO_DROPOFF,
	MOVE_TO_BUILD, BUILD, WAIT_RESOURCE, WAIT_DROPOFF, WAIT_BUILD }
const INVALID_CELL := Vector2i(-1, -1)
const RADIUS := 0.18 # in grid cells; coordinated passing requires radius <= 0.20

var id: int
var cell: Vector2i
var from_cell: Vector2i
var passing: bool = false
var state: State = State.IDLE
var cargo_kind: int = -1
var cargo: int = 0
var capacity: int = 10
var gather_accumulator: float = 0.0
var resource_id: int = -1
var requested_resource_id: int = -1
var building_id: int = -1
var work_cell: Vector2i = INVALID_CELL
var retry_at: float = 0.0
var status: String = "Idle"

var goal: Vector2i = INVALID_CELL
var path: Array[Vector2i] = []
var path_revision: int = -1
var request_generation: int = 0
var request_pending: bool = false
var nav_status: String = "stopped"
var wait_steps: int = 0
var repath_at: float = 0.0


func _init(entity_id: int, start: Vector2i) -> void:
	id = entity_id
	cell = start
	from_cell = start


func in_transit(alpha: float) -> bool:
	return cell != from_cell and alpha < 1.0


func display_position(alpha: float) -> Vector2:
	var t := clampf(alpha, 0.0, 1.0)
	var a := Vector2(from_cell) + Vector2(0.5, 0.5)
	var b := Vector2(cell) + Vector2(0.5, 0.5)
	var point := a.lerp(b, t)
	if passing and from_cell != cell:
		# Opposite walkers take opposite sides of the same one-cell lane.
		# This is a continuous, visible sidestep, not a teleport or phasing.
		var direction := (b - a).normalized()
		point += Vector2(-direction.y, direction.x) * sin(t * PI) * 0.25
	return point


func can_yield() -> bool:
	# Active harvesting/building workers are anchored at interaction slots.
	return state in [State.IDLE, State.WAIT_RESOURCE, State.WAIT_DROPOFF, State.WAIT_BUILD]
