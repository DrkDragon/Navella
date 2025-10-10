class_name PlanetProperties
extends Resource

enum PlanetType { BARREN, GAS, TERRAIN, LIQUID }

@export var size: int :
	get: return _size
	set(value):
		_size = value
		emit_changed()
var _size := 1

@export var class_level: int :
	get: return _class_level
	set(value):
		_class_level = value
		emit_changed()
var _class_level := 1

@export var type: PlanetType :
	get: return _type
	set(value):
		_type = value
var _type := PlanetType.BARREN

@export var color: Color :
	get: return _color
	set(value):
		_color = value
		emit_changed()
var _color := Color.MAGENTA

@export var buildings: Array[Building] = []

@export var points_per_turn: int :
	get: return _points_per_turn
	set(value):
		_points_per_turn = value
		emit_changed()
var _points_per_turn := 0

func serialize() -> Dictionary[String, Variant]:
	var serialized_buildings := []
	for building in buildings:
		serialized_buildings.append(building.serialize())
	
	return {
		"size": size,
		"class_level": class_level,
		"color": {
			"r": color.r,
			"g": color.g,
			"b": color.b,
			"a": color.a
		},
		"buildings": serialized_buildings,
		"points_per_turn": points_per_turn
	}

func deserialize(structure: Dictionary) -> void:
	size = int(structure.get("size", size))
	class_level = int(structure.get("class_level", class_level))
	points_per_turn = int(structure.get("points_per_turn", points_per_turn))
	
	if structure.has("color") and structure.color is Dictionary:
		color = Color(
			structure.color.get("r", 0.0),
			structure.color.get("g", 0.0),
			structure.color.get("b", 0.0),
			structure.color.get("a", 1.0)
		)
	
	if structure.has("buildings") and structure.buildings is Array:
		buildings.clear()
		
		for building_info in structure.buildings:
			var building := Building.new()
			building.deserialize(building_info)
			buildings.append(building)
