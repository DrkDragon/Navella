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

func serialize() -> Dictionary[String, Variant]:
	var structure: Dictionary[String, Variant] = {}
	
	for property in reflect_properties():
		var value = get(property.name)
		if value is Color:
			value = {
				"r": value.r,
				"g": value.g,
				"b": value.b,
				"a": value.a
			}
		structure[property.name] = value
	
	return structure

func deserialize(structure: Dictionary) -> void:
	for property in reflect_properties():
		if not structure.has(property.name): continue
		
		if get(property.name) is Color:
			if structure[property.name] is String:
				var c = structure[property.name]
				c = c.replace("(", "").replace(")", "")
				c = c.split(", ")
				structure[property.name] = {
					"r": float(c[0]),
					"g": float(c[1]),
					"b": float(c[2]),
					"a": float(c[3])
				}
			
			set(property.name, Color(
				structure[property.name].r,
				structure[property.name].g,
				structure[property.name].b,
				structure[property.name].a
			))
		else:
			set(property.name, structure[property.name])
