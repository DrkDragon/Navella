class_name Building
extends Resource

@export var type: String :
	get: return _type
	set(value):
		_type = value.to_lower()
		emit_changed()
var _type := "unknown"

@export var level: int :
	get: return _level
	set(value):
		_level = value
		emit_changed()
var _level := 1

func serialize() -> Dictionary[String, Variant]:
	return {
		"type": type,
		"level": level
	}

func deserialize(structure: Dictionary) -> void:
	type = str(structure.get("type", type))
	level = int(structure.get("level", level))
