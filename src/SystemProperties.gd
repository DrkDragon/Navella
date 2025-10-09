class_name SystemProperties
extends Resource

@export var coord_name := ""
@export var name := ""
@export var planets: Array[PlanetProperties] = []
@export var notes := ""

func reflect_properties() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	var ignore: Array[String] = []
	for property in Resource.new().get_property_list():
		ignore.append(property.name)
	
	for property in get_property_list():
		if not (property.usage & PROPERTY_USAGE_STORAGE): continue
		if ignore.has(property.name): continue
		result.append(property)
	
	return result

func serialize() -> Dictionary[String, Variant]:
	var serialized_planets := []
	for planet in planets:
		serialized_planets.append(planet.serialize())
	
	return {
		"coord_name": coord_name,
		"name": name,
		"planets": serialized_planets,
		"notes": notes
	}

func deserialize(structure: Dictionary) -> void:
	coord_name = str(structure.get("coord_name", ""))
	name = str(structure.get("name", ""))
	notes = str(structure.get("notes", ""))
	
	if structure.has("planets") and structure.planets is Array:
		planets.clear()
		
		for planet_info in structure.planets:
			var planet := PlanetProperties.new()
			planet.deserialize(planet_info)
			planets.append(planet)
