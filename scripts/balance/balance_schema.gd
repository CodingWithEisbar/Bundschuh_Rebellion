class_name BalanceSchema
extends RefCounted
## Validator for the JSON Schema keywords used by units.schema.json. Python
## consumes the SAME schema. New keywords require updating both readers.

const PATH := "res://data/balance/units.schema.json"
static var _schema: Dictionary = {}


static func validate(document: Variant) -> PackedStringArray:
	if _schema.is_empty():
		var parser := JSON.new()
		if parser.parse(FileAccess.get_file_as_string(PATH)) != OK or not parser.data is Dictionary:
			return PackedStringArray(["Cannot load bundled unit schema"])
		_schema = parser.data
	var errors := PackedStringArray()
	_visit(document, _schema, "$", errors)
	if errors.is_empty():
		_semantics(document, errors)
	return errors


static func _visit(value: Variant, rule: Dictionary, path: String, errors: PackedStringArray) -> void:
	if errors.size() >= 32:
		return
	if rule.has("$ref"):
		_visit(value, _schema["$defs"][str(rule["$ref"]).get_slice("/", 2)], path, errors)
		return
	var expected := str(rule.get("type", ""))
	var numeric := typeof(value) in [TYPE_INT, TYPE_FLOAT]
	var valid := true
	match expected:
		"object": valid = value is Dictionary
		"array": valid = value is Array
		"string": valid = value is String
		"boolean": valid = typeof(value) == TYPE_BOOL
		"number": valid = numeric and is_finite(float(value))
		"integer": valid = numeric and is_finite(float(value)) and float(value) == floorf(float(value))
	if not valid:
		errors.append(path + ": expected " + expected)
		return
	if rule.has("enum") and value not in rule["enum"]:
		errors.append(path + ": unsupported value")
	if numeric:
		if rule.has("minimum") and value < rule["minimum"]:
			errors.append(path + ": below minimum")
		if rule.has("maximum") and value > rule["maximum"]:
			errors.append(path + ": above maximum")
		if rule.has("exclusiveMaximum") and value >= rule["exclusiveMaximum"]:
			errors.append(path + ": at/above exclusive maximum")
	if value is String:
		if value.length() < int(rule.get("minLength", 0)) or value.length() > int(rule.get("maxLength", 2147483647)):
			errors.append(path + ": invalid string length")
		if rule.has("pattern") and RegEx.create_from_string(rule["pattern"]).search(value) == null:
			errors.append(path + ": invalid identifier")
	if value is Array:
		if value.size() < int(rule.get("minItems", 0)) or value.size() > int(rule.get("maxItems", 2147483647)):
			errors.append(path + ": invalid array length")
		var seen: Array = []
		for i in value.size():
			if rule.get("uniqueItems", false) and value[i] in seen:
				errors.append(path + ": duplicate array item")
			seen.append(value[i])
			if rule.has("items"):
				_visit(value[i], rule["items"], path + "[%d]" % i, errors)
	if value is Dictionary:
		for key: String in rule.get("required", []):
			if not value.has(key):
				errors.append(path + "." + key + ": missing field")
		var properties: Dictionary = rule.get("properties", {})
		for key: String in value:
			if rule.has("propertyNames"):
				_visit(key, rule["propertyNames"], path + "." + key, errors)
			if properties.has(key):
				_visit(value[key], properties[key], path + "." + key, errors)
			elif rule.get("additionalProperties") is Dictionary:
				_visit(value[key], rule["additionalProperties"], path + "." + key, errors)
			elif rule.get("additionalProperties", true) == false:
				errors.append(path + "." + key + ": unknown field")


static func _semantics(document: Dictionary, errors: PackedStringArray) -> void:
	var names: Dictionary = {}
	var kinds: Dictionary = {}
	var core := {"peasant_flailman": "FLAILMAN", "radical_preacher": "RADICAL_PREACHER",
		"landsknecht_pikeman": "LANDSKNECHT", "heavy_gendarme": "ARMOURED_RITTER"}
	for row: Dictionary in document["units"]:
		var id: String = row["id"]
		for name: String in [id] + row["aliases"]:
			if names.has(name):
				errors.append(id + ": duplicate ID/alias " + name)
			names[name] = true
		if kinds.has(row["kind"]):
			errors.append(id + ": duplicate engine kind")
		kinds[row["kind"]] = true
		if core.get(id) == row["kind"]:
			core.erase(id)
		var combat: Dictionary = row["combat"]
		if combat["minimum_range_tiles"] > combat["range_tiles"]:
			errors.append(id + ": minimum range exceeds maximum")
		if combat["attack"] == 0:
			if combat["attack_period"] != 0 or not combat["bonus_damage"].is_empty() or combat["impact_fraction"] != 0:
				errors.append(id + ": non-attacker needs zero period/marker and no counters")
		elif combat["attack_period"] < 0.05:
			errors.append(id + ": attack period must be at least one 20 Hz tick")
		var zeal: Dictionary = row["zeal"]
		if zeal["enabled"] and (row["kind"] != "RADICAL_PREACHER" or row["faction"] != "bundschuh" or zeal["radius_tiles"] <= 0):
			errors.append(id + ": Zeal requires a Bundschuh Preacher and positive radius")
	if not core.is_empty():
		errors.append("Missing/renamed core unit or wrong kind: " + str(core.keys()))
