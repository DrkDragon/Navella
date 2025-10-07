class_name PlanetProperties
extends Resource

@export var size := 1
@export var color := Color.MAGENTA
@export var buildings: Dictionary[String, int] = {}
@export var points_per_turn := 0

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
