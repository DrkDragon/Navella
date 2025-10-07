extends TabContainer

@onready var system_property_list := $"Galaxy Map/Options/Margin/Properties/PropertyList"
@onready var planet_property_list := $"System Map/Options/Margin/Properties/PropertyList"

@onready var view_map_button := $"Galaxy Map/Options/Toolbar/ViewMapButton"

@onready var galaxy_map := $"Galaxy Map/View/SubViewport/GalaxyMap"
@onready var system_map := $"System Map/View/Layout"

var loaded_save: SaveData

func _ready() -> void:
	loaded_save = preload("res://default_save.tres")
	
	var rng := RandomNumberGenerator.new()
	rng.seed = 0
	
	for child in $"Galaxy Map/View/SubViewport/GalaxyMap".get_children():
		if child is SystemDisplay:
			var system := SystemProperties.new()
			system.coord_name = child.name
			
			for _i in [1, 2, 4, 6, 8, 10, 12, 14][rng.randi_range(0, 7)]:
				var planet := PlanetProperties.new()
				planet.size = rng.randi_range(1, 10)
				planet.color = Color.from_ok_hsl(rng.randf(), 1, 0.5)
				system.planets.append(planet)
			
			if loaded_save.get_system_by_name(system.coord_name) == null:
				loaded_save.systems.append(system)

func display_system_info(system: String) -> void:
	for child in system_property_list.get_children(): child.queue_free()
	for child in planet_property_list.get_children(): child.queue_free()
	
	while system_map.get_child_count() > 1:
		var child := system_map.get_child(1)
		system_map.remove_child(child)
		child.queue_free()
	
	view_map_button.disabled = true
	
	var properties := loaded_save.get_system_by_name(system)
	if properties == null: return
	
	create_property_grid(system_property_list, properties)
	
	for i in len(properties.planets):
		var planet := properties.planets[i]
		
		var planet_display := PlanetDisplay.new()
		planet_display.bind(planet)
		planet_display.name = system + "-" + str(i + 1)
		planet_display.planet_selected.connect(func() -> void:
			for child in planet_property_list.get_children(): child.queue_free()
			
			create_property_grid(planet_property_list, planet)
		)
		
		system_map.add_child(planet_display)
	
	view_map_button.disabled = false

func create_property_grid(grid, target) -> void:
	for property in target.reflect_properties():
		var key_label := Label.new()
		key_label.text = property.name.capitalize() + ":"
		
		var value = target.get(property.name)
		
		var value_label: Control
		
		if value is Color:
			value_label = AspectRatioContainer.new()
			
			var color_square := ColorRect.new()
			color_square.color = value
			color_square.custom_minimum_size = Vector2.ONE
			
			value_label.add_child(color_square)
		else:
			value_label = Label.new()
			value_label.text = str(len(value)) if value is Array else str(value)
		
		grid.add_child(key_label)
		grid.add_child(value_label)

func _on_galaxy_map_display_system(system: String) -> void:
	display_system_info(system)

func _on_view_map_button_pressed() -> void:
	current_tab = 1

func _on_back_button_pressed() -> void:
	current_tab = 0

func _on_ftl_button_toggled(toggled_on: bool) -> void:
	galaxy_map.show_ftl = toggled_on

func _on_detection_button_toggled(toggled_on: bool) -> void:
	galaxy_map.show_detection = toggled_on
