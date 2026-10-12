class_name CombatUnitCatalog
extends RefCounted
## Compatibility facade for Stage 2–4 enum callers. JSON is the sole source of
## combat base stats. Loaded once before spawning; every lookup returns a copy.

static var _database: UnitDatabase


static func default_database() -> UnitDatabase:
	if _database == null:
		_database = UnitDatabase.new()
		if not _database.reload_file():
			push_error("Default unit database rejected: " + str(_database.errors))
	return _database


static func definition(kind: int) -> Dictionary:
	return default_database().definition_kind(kind)
