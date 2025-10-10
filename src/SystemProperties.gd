class_name SystemProperties
extends Resource

@export var coord_name: String :
	get: return _coord_name
	set(value):
		_coord_name = value
		emit_changed()
var _coord_name := ""

@export var name: String :
	get: return _name
	set(value):
		_name = value
		emit_changed()
var _name := ""

@export var color: Color :
	get: return _color
	set(value):
		_color = value
		emit_changed()
var _color := Color.WHITE

@export var planets: Array[PlanetProperties] = []

@export var notes: String :
	get: return _notes
	set(value):
		_notes = value
		emit_changed()
var _notes := ""

func serialize() -> Dictionary[String, Variant]:
	var serialized_planets := []
	for planet in planets:
		serialized_planets.append(planet.serialize())
	
	return {
		"coord_name": coord_name,
		"name": name,
		"color": {
			"r": color.r,
			"g": color.g,
			"b": color.b,
			"a": color.a
		},
		"planets": serialized_planets,
		"notes": notes
	}

func deserialize(structure: Dictionary) -> void:
	coord_name = str(structure.get("coord_name", ""))
	name = str(structure.get("name", ""))
	notes = str(structure.get("notes", ""))
	
	if structure.has("color") and structure.color is Dictionary:
		color = Color(
			structure.color.get("r", 1.0),
			structure.color.get("g", 1.0),
			structure.color.get("b", 1.0),
			structure.color.get("a", 1.0)
		)
	
	if structure.has("planets") and structure.planets is Array:
		planets.clear()
		
		for planet_info in structure.planets:
			var planet := PlanetProperties.new()
			planet.deserialize(planet_info)
			planets.append(planet)
