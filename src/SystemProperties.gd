class_name SystemProperties
extends Resource

@export_custom(PROPERTY_HINT_OBJECT_ID, "") var coord_name := ""
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
	var structure: Dictionary[String, Variant] = {}
	
	for property in reflect_properties():
		var value = get(property.name)
		
		if value is Array:
			var new_value := []
			for i in len(value): new_value.push_back(value[i].serialize())
			value = new_value
		
		structure[property.name] = value
	
	return structure

func deserialize(structure: Dictionary) -> void:
	for property in reflect_properties():
		if not structure.has(property.name): continue
		var value = structure[property.name]
		
		if property.name == "planets":
			planets.clear()
			for planet_info in value:
				var planet := PlanetProperties.new()
				planet.deserialize(planet_info)
				planets.append(planet)
		else:
			set(property.name, value)
