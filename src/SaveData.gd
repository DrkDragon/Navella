class_name SaveData
extends Resource

@export var systems: Array[SystemProperties] = []

func get_system_by_name(name: String) -> SystemProperties:
	for system in systems:
		if system.coord_name == name: return system
	return null
