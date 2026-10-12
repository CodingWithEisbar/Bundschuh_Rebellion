class_name BalanceJson
extends RefCounted
## Godot JSON accepts trailing commas and some non-JSON numbers. This bounded
## syntax pass rejects ambiguous duplicate keys and malformed edits consistently
## with the Python preflight. Values are still decoded by the engine afterwards.

var text: String
var cursor: int = 0
var error: String = ""
var number := RegEx.create_from_string("-?(0|[1-9][0-9]*)(\\.[0-9]+)?([eE][+-]?[0-9]+)?")


static func validate(source: String) -> String:
	var reader := BalanceJson.new()
	reader.text = source
	reader._value(0)
	reader._space()
	if reader.error.is_empty() and reader.cursor != source.length():
		reader._fail("Unexpected trailing content")
	return reader.error


func _fail(message: String) -> void:
	if error.is_empty():
		error = "JSON character %d: %s" % [cursor, message]


func _space() -> void:
	while cursor < text.length() and text[cursor] in [" ", "\t", "\r", "\n"]:
		cursor += 1


func _take(character: String) -> bool:
	_space()
	if cursor < text.length() and text[cursor] == character:
		cursor += 1
		return true
	return false


func _value(depth: int) -> void:
	_space()
	if not error.is_empty():
		return
	if depth > 32 or cursor >= text.length():
		_fail("Missing value or nesting exceeds 32")
		return
	var start := text[cursor]
	if start == "{" or start == "[":
		cursor += 1
		var closing := "}" if start == "{" else "]"
		if _take(closing):
			return
		var keys: Dictionary = {}
		while error.is_empty():
			if start == "{":
				_space()
				var key := _string()
				if keys.has(key):
					_fail("Duplicate object key: " + key)
				keys[key] = true
				if not _take(":"):
					_fail("Expected colon")
			_value(depth + 1)
			if _take(closing):
				return
			if not _take(","):
				_fail("Expected comma or closing delimiter")
		return
	if start == "\"":
		_string()
		return
	for literal: String in ["true", "false", "null"]:
		if text.substr(cursor, literal.length()) == literal:
			cursor += literal.length()
			return
	var match_value := number.search(text, cursor)
	if match_value == null or match_value.get_start() != cursor:
		_fail("Expected JSON value")
	else:
		cursor = match_value.get_end()


func _hex4() -> int:
	if cursor + 4 > text.length():
		_fail("Incomplete Unicode escape")
		return -1
	var digits := text.substr(cursor, 4)
	for character in digits:
		if character.to_lower() not in "0123456789abcdef":
			_fail("Invalid Unicode escape")
			return -1
	cursor += 4
	return digits.hex_to_int()


func _string() -> String:
	var begin := cursor
	if not _take("\""):
		_fail("Expected string")
		return ""
	while cursor < text.length() and error.is_empty():
		var character := text[cursor]
		cursor += 1
		if character == "\"":
			return JSON.parse_string(text.substr(begin, cursor - begin))
		if character.unicode_at(0) < 32:
			_fail("Unescaped control character")
		elif character == "\\":
			if cursor >= text.length():
				break
			var escape := text[cursor]
			cursor += 1
			if escape == "u":
				var code := _hex4()
				if code >= 0xd800 and code <= 0xdbff:
					if text.substr(cursor, 2) != "\\u":
						_fail("Unpaired high surrogate")
					else:
						cursor += 2
						var low := _hex4()
						if low < 0xdc00 or low > 0xdfff:
							_fail("Invalid low surrogate")
				elif code >= 0xdc00 and code <= 0xdfff:
					_fail("Unpaired low surrogate")
			elif escape not in ["\"", "\\", "/", "b", "f", "n", "r", "t"]:
				_fail("Invalid escape")
	_fail("Unterminated string")
	return ""
