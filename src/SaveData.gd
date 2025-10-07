class_name SaveData
extends Resource

@export var systems: Array[SystemProperties] = []

func get_system_by_name(name: String) -> SystemProperties:
	for system in systems:
		if system.coord_name == name: return system
	return null

func serialize() -> Dictionary[String, Variant]:
	var serialized_systems := []
	for system in systems:
		serialized_systems.append(system.serialize())
	
	return {
		"systems": serialized_systems
	}

func deserialize(structure: Dictionary[String, Variant]) -> void:
	if structure.has("systems"):
		systems.clear()
		
		for system_info in structure["systems"]:
			var system := SystemProperties.new()
			system.deserialize(system_info)
			systems.append(system)
