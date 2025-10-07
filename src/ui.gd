extends TabContainer

@onready var system_property_list := $"Galaxy Map/Options/Margin/Properties/PropertyList"
@onready var planet_property_list := $"System Map/Options/Margin/Properties/PropertyList"

@onready var view_map_button := $"Galaxy Map/Options/Toolbar/ViewMapButton"

@onready var galaxy_map := $"Galaxy Map/View/SubViewport/GalaxyMap"
@onready var system_map := $"System Map/View/Layout"

var loaded_save := SaveData.new()

func _init() -> void:
	tab_changed.connect(func(tab: int) -> void:
		if tab != 2: return
		current_tab = 0
		
		var json := JSON.stringify(loaded_save.serialize()).to_utf8_buffer()
		
		if OS.get_name() == "web":
			JavaScriptBridge.download_buffer(
				json,
				"game_state.json",
				"application/json"
			)
		else:
			var dialog := FileDialog.new()
			dialog.access = FileDialog.ACCESS_FILESYSTEM
			dialog.use_native_dialog = true
			dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			dialog.add_filter("*.json", "JSON File")
			dialog.file_selected.connect(func(path: String) -> void:
				var file := FileAccess.open(path, FileAccess.WRITE)
				file.store_buffer(json)
				file.close()
			)
			dialog.close_requested.connect(func() -> void:
				dialog.queue_free()
			)
			add_child(dialog)
			dialog.show()
	)

func _ready() -> void:
	var http := HTTPClient.new()
	http.blocking_mode_enabled = true
	var connection := http.connect_to_host("https://drkdragon.github.io")
	if connection != OK:
		OS.alert("Game state could not be downloaded from the server.")
		return
	
	while (
		http.get_status() == HTTPClient.STATUS_CONNECTING
	) or (
		http.get_status() == HTTPClient.STATUS_RESOLVING
	):
		http.poll()
	
	http.request(HTTPClient.METHOD_GET, "/Navella/game_state.json", PackedStringArray())
	if http.get_response_code() != 200:
		http.close()
		OS.alert("Game state could not be downloaded from the server.")
		return
	
	var body := PackedByteArray()
	while body.size() < http.get_response_body_length():
		body.append_array(http.read_response_body_chunk())
	
	http.close()
	
	loaded_save.deserialize(JSON.parse_string(body.get_string_from_utf8()))
	
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
	var property_names: Array[String] = []
	if target is Dictionary:
		for key in target.keys():
			property_names.append(key)
	else:
		for property in target.reflect_properties():
			property_names.append(property.name)
	
	for property in property_names:
		var key_label := Label.new()
		key_label.text = property.capitalize() + ":"
		
		var value = target.get(property)
		
		var value_label: Control
		
		if value is Color:
			value_label = AspectRatioContainer.new()
			
			var color_square := ColorPickerButton.new()
			color_square.color = value
			color_square.custom_minimum_size = Vector2.ONE
			color_square.color_changed.connect(func(result: Color) -> void:
				target.set(property, result)
			)
			
			value_label.add_child(color_square)
		elif value is Dictionary:
			value_label = GridContainer.new()
			create_property_grid(value_label, value)
		elif value is int:
			value_label = SpinBox.new()
			value_label.value = value
			var line_edit: LineEdit = value_label.get_line_edit()
			line_edit.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
			value_label.value_changed.connect(func(result: float) -> void:
				target.set(property, int(result))
			)
		elif value is String:
			value_label = LineEdit.new()
			value_label.text = value
			value_label.text_changed.connect(func(text: String) -> void:
				target.set(property, text)
			)
		else:
			value_label = Label.new()
			value_label.text = str(len(value)) if value is Array else str(value)
		
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_label.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		
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
