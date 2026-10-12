class_name VoiceSelector
extends RefCounted
## Cosmetic local RNG; never touches map/combat RNG. Index once at warm-up.
## Avoid the last two takes when at least three valid variants are available.

var _groups: Dictionary = {}
var _recent: Dictionary = {}
var _rng := RandomNumberGenerator.new()


func configure(bank: RtsAudioBank, seed_value: int = 1524) -> void:
	_groups.clear()
	_recent.clear()
	_rng.seed = seed_value
	for line in bank.voices:
		var key := "%d:%s" % [line.faction, line.action]
		if not _groups.has(key):
			_groups[key] = []
		_groups[key].append(line)


func choose(faction: int, action: StringName) -> RtsVoiceLine:
	var key := "%d:%s" % [faction, action]
	var options: Array = _groups.get(key, [])
	if options.is_empty():
		return null
	var recent: Array = _recent.get(key, [])
	var candidates: Array[RtsVoiceLine] = []
	for line: RtsVoiceLine in options:
		if line.id not in recent:
			candidates.append(line)
	if candidates.is_empty():
		candidates.assign(options) # Single-clip banks remain usable.
	var result := candidates[_rng.randi_range(0, candidates.size() - 1)]
	recent.append(result.id)
	while recent.size() > mini(2, options.size() - 1):
		recent.pop_front()
	_recent[key] = recent
	return result
