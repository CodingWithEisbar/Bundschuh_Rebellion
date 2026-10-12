class_name UnitDatabase
extends RefCounted
## Transactional data: validate/compile a candidate before publishing a revision.
## Spawned units own copies; reload never heals HP or resets an in-flight swing.

signal reloaded(event: Dictionary)
const DEFAULT_PATH := "res://data/balance/units.v1.json"
const MAX_BYTES := 1048576
var generation: int = 0
var content_sha256: String = ""
var balance_id: String = ""
var errors := PackedStringArray()
var _document: Dictionary = {}
var _definitions: Dictionary = {}
var _aliases: Dictionary = {}
var _kinds: Dictionary = {}


func reload_file(path: String = DEFAULT_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors = PackedStringArray(["Cannot open unit database: " + path])
		return false
	if file.get_length() > MAX_BYTES:
		errors = PackedStringArray(["Unit database exceeds 1 MiB"])
		return false
	return reload_text(file.get_buffer(file.get_length()).get_string_from_utf8())


func reload_text(text: String) -> bool:
	if text.to_utf8_buffer().size() > MAX_BYTES:
		errors = PackedStringArray(["Unit database exceeds 1 MiB"])
		return false
	var syntax_error := BalanceJson.validate(text)
	if not syntax_error.is_empty():
		errors = PackedStringArray([syntax_error])
		return false
	var parser := JSON.new()
	if parser.parse(text) != OK:
		errors = PackedStringArray(["JSON line %d: %s" % [parser.get_error_line(), parser.get_error_message()]])
		return false
	errors = BalanceSchema.validate(parser.data)
	if not errors.is_empty():
		return false
	var hash_value := text.sha256_text()
	if hash_value == content_sha256:
		return true
	var definitions: Dictionary = {}
	var aliases: Dictionary = {}
	var kinds: Dictionary = {}
	for row: Dictionary in parser.data["units"]:
		var id: String = row["id"]
		var definition := _compile(row)
		definition["database_sha256"] = hash_value
		definition["database_generation"] = generation + 1
		definitions[id] = definition
		kinds[definition["kind"]] = id
		for alias: String in row["aliases"]:
			aliases[alias] = id
	_document = parser.data.duplicate(true)
	_definitions = definitions
	_aliases = aliases
	_kinds = kinds
	content_sha256 = hash_value
	balance_id = _document["balance_id"]
	generation += 1
	reloaded.emit({"generation": generation, "sha256": content_sha256, "balance_id": balance_id})
	return true


func definition(id: String) -> Dictionary:
	return _definitions.get(_aliases.get(id, id), {}).duplicate(true)


func definition_kind(kind: int) -> Dictionary:
	return definition(_kinds.get(kind, ""))


func document() -> Dictionary:
	return _document.duplicate(true)


func fork() -> UnitDatabase:
	## A whole arena pins one revision, including later spawns. No file I/O and no
	## reparsing during a match; the live designer database advances separately.
	var result := UnitDatabase.new()
	result.generation = generation
	result.content_sha256 = content_sha256
	result.balance_id = balance_id
	result._document = _document.duplicate(true)
	result._definitions = _definitions.duplicate(true)
	result._aliases = _aliases.duplicate()
	result._kinds = _kinds.duplicate()
	return result


static func _class_map(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: String in source:
		result[CombatTypes.ArmorClass[key.to_upper()]] = int(source[key])
	return result


static func _compile(row: Dictionary) -> Dictionary:
	var c: Dictionary = row["combat"]
	var cost: Dictionary = {}
	for resource: String in row["economy"]["cost"]:
		cost[resource] = int(row["economy"]["cost"][resource])
	var classes: Array[int] = []
	for key: String in c["armor_classes"]:
		classes.append(CombatTypes.ArmorClass[key.to_upper()])
	return {"definition_id": row["id"], "kind": CombatTypes.UnitType[row["kind"]],
		"max_hp": int(c["hp"]), "attack": int(c["attack"]),
		"melee_armor": int(c["armor"]["melee"]), "pierce_armor": int(c["armor"]["pierce"]),
		"channel": CombatTypes.DamageChannel[c["damage_type"].to_upper()],
		"armor_classes": classes, "bonuses": _class_map(c["bonus_damage"]), "bonus_armor": _class_map(c["bonus_armor"]),
		"attack_period": float(c["attack_period"]), "attack_range": float(c["range_tiles"]),
		"minimum_range": float(c["minimum_range_tiles"]), "impact_fraction": float(c["impact_fraction"]),
		"movement_speed": float(row["movement"]["speed_tiles_per_second"]),
		"body_radius": float(row["movement"]["body_radius_tiles"]),
		"cost": cost, "population": int(row["economy"]["population"]),
		"train_seconds": float(row["economy"]["train_seconds"]), "zeal": row["zeal"].duplicate()}
