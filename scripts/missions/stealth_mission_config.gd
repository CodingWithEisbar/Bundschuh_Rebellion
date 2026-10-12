class_name StealthMissionConfig
extends Resource
## Scenario tuning, measured in GAME seconds. This Joß Fritz prototype follows
## the Stage 3 request; it is not the older Allstedt chase scenario in the GDD.

@export var protagonist_id: StringName = &"joss_fritz"
@export var protagonist_team: int = 0
@export_range(0.1, 30.0, 0.1) var exposure_seconds: float = 2.0
@export_range(1.0, 1000.0, 1.0) var decay_per_second: float = 50.0
@export_range(0.0, 30.0, 0.1) var rearm_unseen_seconds: float = 2.0
@export_range(1, 10, 1) var detection_limit: int = 3


func validate() -> Array[String]:
	var errors: Array[String] = []
	if protagonist_id == &"" or protagonist_team < 0:
		errors.append("A protagonist ID and nonnegative team are required.")
	if not is_finite(exposure_seconds) or exposure_seconds < 0.1 or exposure_seconds > 30.0:
		errors.append("Exposure must be 0.1..30 seconds.")
	if not is_finite(decay_per_second) or decay_per_second < 1.0 or decay_per_second > 1000.0:
		errors.append("Decay must be 1..1000 meter points per second.")
	if not is_finite(rearm_unseen_seconds) or rearm_unseen_seconds < 0.0 or rearm_unseen_seconds > 30.0:
		errors.append("Rearm delay must be 0..30 seconds.")
	if detection_limit < 1 or detection_limit > 10:
		errors.append("Detection limit must be 1..10.")
	return errors
