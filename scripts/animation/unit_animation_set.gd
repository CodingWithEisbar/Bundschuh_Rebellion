class_name UnitAnimationSet
extends Resource
## Shared immutable sprite library. Author Idle/Run/Attack/Die in SpriteFrames.
## Optional eight directions use idle_e, idle_se, idle_s ...; never auto-mirror
## historically asymmetric weapons. Compile ONCE during loading, not per unit.

@export var frames: SpriteFrames
@export var directions := PackedStringArray(["s"])
@export var impact_frame: int = 3
@export var reference_run_speed: float = 0.8 # tiles/sec represented by authored Run
@export var blend_seconds: float = 0.10
@export var corpse_seconds: float = 2.0
@export var pivot := Vector2(32, 54)
var clips: Dictionary = {} # name -> {textures, ends, duration}; shared, not copied
var impact_fraction: float = 0.0


func compile() -> Array[String]:
	var errors: Array[String] = []
	clips.clear()
	if frames == null or directions.size() not in [1, 8]:
		return ["SpriteFrames and one or eight directions are required."]
	if not is_finite(reference_run_speed) or reference_run_speed <= 0 or not is_finite(blend_seconds) or blend_seconds < 0 or blend_seconds > 0.5 or not is_finite(corpse_seconds) or corpse_seconds < 0:
		return ["Invalid locomotion/blend/corpse tuning."]
	var names: Dictionary = {}
	var marker := -1.0
	for direction in directions:
		if names.has(direction) or direction.is_empty():
			errors.append("Directions must have unique nonempty suffixes.")
		names[direction] = true
		for state in ["idle", "run", "attack", "die"]:
			var key := StringName(state + "_" + direction)
			if not frames.has_animation(key) or frames.get_frame_count(key) == 0 or frames.get_animation_speed(key) <= 0:
				errors.append("Missing or empty animation: " + str(key))
				continue
			var textures: Array[Texture2D] = []
			var ends := PackedFloat32Array()
			var duration := 0.0
			for index in range(frames.get_frame_count(key)):
				var texture := frames.get_frame_texture(key, index)
				if texture == null:
					errors.append("Missing frame texture in " + str(key))
				textures.append(texture)
				duration += frames.get_frame_duration(key, index) / frames.get_animation_speed(key)
				ends.append(duration)
			clips[key] = {"textures": textures, "ends": ends, "duration": duration}
			if state == "attack":
				if impact_frame < 0 or impact_frame >= textures.size():
					errors.append("Impact frame is outside Attack clip.")
					continue
				var fraction := 0.0 if impact_frame == 0 else ends[impact_frame - 1] / duration
				if marker >= 0 and not is_equal_approx(marker, fraction):
					errors.append("All directions must place the impact at the same normalized time.")
				marker = fraction
	impact_fraction = maxf(0.0, marker)
	if not errors.is_empty():
		clips.clear()
	return errors


func key(state: String, facing: Vector2) -> StringName:
	var index := 0
	if directions.size() == 8:
		# Ordered E, SE, S, SW, W, NW, N, NE in Godot's top-down +Y convention.
		index = posmod(roundi(facing.angle() / (PI / 4.0)), 8)
	return StringName(state + "_" + directions[index])


func frame_index(key_name: StringName, seconds: float) -> int:
	var ends: PackedFloat32Array = clips[key_name]["ends"]
	for i in range(ends.size()):
		if seconds < ends[i] - 0.000001:
			return i
	return ends.size() - 1
