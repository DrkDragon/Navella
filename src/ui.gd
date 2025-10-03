extends TabContainer

@onready var property_list := $"Galaxy Map/Options/Properties/PropertyList"
@onready var view_map_button := $"Galaxy Map/Options/Toolbar/ViewMapButton"

var selected_system: String

func display_system_info(system: String) -> void:
	selected_system = system
	
	var properties := SystemProperties.new()
	properties.coord_name = system
	
	for child in property_list.get_children():
		child.queue_free()
	
	for property in properties.reflect_properties():
		var key_label := Label.new()
		key_label.text = property.name.capitalize() + ":"
		
		var value_label := Label.new()
		value_label.text = str(properties.get(property.name))
		
		property_list.add_child(key_label)
		property_list.add_child(value_label)
	
	view_map_button.disabled = false

func _on_galaxy_map_display_system(system: String) -> void:
	display_system_info(system)

func _on_view_map_button_pressed() -> void:
	current_tab = 1

func _on_back_button_pressed() -> void:
	current_tab = 0
