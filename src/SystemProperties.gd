class_name SystemProperties
extends Resource

@export var coord_name := ""

@export var notes := ""

func reflect_properties():
	var result: Array[Dictionary] = []
	
	var ignore: Array[String] = []
	for property in Resource.new().get_property_list():
		ignore.append(property.name)
	
	for property in get_property_list():
		if not (property.usage & PROPERTY_USAGE_STORAGE): continue
		if ignore.has(property.name): continue
		result.append(property)
	
	return result
