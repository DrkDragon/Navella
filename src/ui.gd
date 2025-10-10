extends TabContainer

@onready var system_property_list := $"Galaxy Map/Options/Margin/Properties/PropertyList"
@onready var planet_property_list := $"System Map/Options/Margin/Properties/PropertyList"
@onready var building_list := $Buildings/Layout/List

@onready var system_star := $"System Map/View/Layout/Star"

@onready var add_planet_button := $"System Map/Options/Toolbar/AddButton"
@onready var delete_planet_button := $"System Map/Options/Toolbar/DeleteButton"
@onready var add_building_button := $Buildings/Layout/AddBuildingButton

@onready var galaxy_map := $"Galaxy Map/View/SubViewport/GalaxyMap"
@onready var system_map := $"System Map/View/Layout/System"

var loaded_save := SaveData.new()

func _init() -> void:
	tab_changed.connect(func(tab: int) -> void:
		if (tab + 1) != get_child_count(): return
		current_tab = 0
		
		var json := JSON.stringify(loaded_save.serialize()).to_utf8_buffer()
		
		if OS.get_name() == "Web":
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
	
	print("Connecting to host...")
	
	var connection := http.connect_to_host("https://drkdragon.github.io")
	if connection != OK:
		OS.alert("Game state could not be downloaded from the server.")
		return
	
	print("Waiting for connection...")
	
	while (
		http.get_status() == HTTPClient.STATUS_CONNECTING
	) or (
		http.get_status() == HTTPClient.STATUS_RESOLVING
	):
		http.poll()
		await get_tree().process_frame
	
	print("Requesting game state...")
	
	var error := http.request(HTTPClient.METHOD_GET, "/Navella/game_state.json", PackedStringArray())
	if error != OK:
		http.close()
		OS.alert("Game state could not be downloaded from the server. Error: " + error_string(error))
		return
	
	print("Waiting for game state...")
	
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		await get_tree().process_frame
	
	if http.get_response_code() != 200:
		http.close()
		OS.alert("Game state could not be downloaded from the server. HTTP Code: " + str(http.get_response_code()))
		return
	
	print("Reading game state...")
	
	var body := PackedByteArray()
	while http.get_status() == HTTPClient.STATUS_BODY:
		http.poll()
		await get_tree().process_frame
		body.append_array(http.read_response_body_chunk())
	
	http.close()
	
	print("Deserializing game state...")
	
	loaded_save.deserialize(JSON.parse_string(body.get_string_from_utf8()))
	
	print("Ready!")
	
	var rng := RandomNumberGenerator.new()
	var class_rng := RandomNumberGenerator.new()
	var type_rng := RandomNumberGenerator.new()
	rng.seed = 0
	class_rng.seed = 0
	type_rng.seed = 1
	
	for child in galaxy_map.get_children():
		if child is SystemDisplay:
			var system := SystemProperties.new()
			system.coord_name = child.name
			
			for _i in [1, 2, 4, 6, 8, 10, 12, 14][rng.randi_range(0, 7)]:
				var planet := PlanetProperties.new()
				planet.size = rng.randi_range(1, 10)
				planet.class_level = class_rng.randi_range(1, 10)
				planet.type = type_rng.randi_range(0, 3) as PlanetProperties.PlanetType
				planet.color = Color.from_ok_hsl(rng.randf(), 1, 0.5)
				planet.points_per_turn = planet.class_level * 50
				system.planets.append(planet)
			
			var saved := loaded_save.get_system_by_name(system.coord_name)
			if saved == null:
				loaded_save.systems.append(system)
			else:
				system = saved
			
			child.bind(system)

static func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

static func clear_connections(event: Signal) -> void:
	for connection in event.get_connections():
		event.disconnect(connection.callable)

func add_system_property(property: String, editor: Control) -> void:
	var key_label := Label.new()
	key_label.text = property + ":"
	
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	system_property_list.add_child(key_label)
	system_property_list.add_child(editor)

func add_planet_property(property: String, editor: Control) -> void:
	var key_label := Label.new()
	key_label.text = property + ":"
	
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	planet_property_list.add_child(key_label)
	planet_property_list.add_child(editor)

func display_system_info(system_name: String) -> void:
	clear_children(system_property_list)
	clear_children(planet_property_list)
	clear_children(system_map)
	
	system_star.visible = false
	add_planet_button.disabled = true
	delete_planet_button.disabled = true
	add_building_button.disabled = true
	
	var system := loaded_save.get_system_by_name(system_name)
	if system == null: return
	
	clear_connections(add_planet_button.pressed)
	add_planet_button.pressed.connect(func() -> void:
		system.planets.push_back(PlanetProperties.new())
		display_system_info(system_name)
	)
	
	add_system_property("Coordinate", create_string_display(system, "coord_name"))
	add_system_property("Name", create_string_editor(system, "name"))
	add_system_property("Color", create_color_editor(system, "color"))
	add_system_property("Planets", create_string_display(system, "planets"))
	add_system_property("Notes", create_string_editor(system, "notes"))
	
	for i in len(system.planets):
		var planet := system.planets[i]
		
		var planet_display := PlanetDisplay.new()
		planet_display.bind(planet)
		planet_display.name = system_name + "-" + str(i + 1)
		planet_display.planet_selected.connect(func() -> void:
			clear_connections(delete_planet_button.pressed)
			delete_planet_button.pressed.connect(func() -> void:
				system.planets.erase(planet)
				display_system_info(system_name)
			)
			
			display_planet_info(planet)
		)
		
		system_map.add_child(planet_display)
	
	system_star.visible = true
	add_planet_button.disabled = false

func display_planet_info(planet: PlanetProperties) -> void:
	clear_children(planet_property_list)
	clear_children(building_list)
	
	delete_planet_button.disabled = true
	add_building_button.disabled = true
	
	add_planet_property("Size", create_int_editor(planet, "size"))
	add_planet_property("Class", create_int_editor(planet, "class_level"))
	add_planet_property("Type", create_planet_type_editor(planet))
	add_planet_property("Color", create_color_editor(planet, "color"))
	add_planet_property("Buildings", create_string_display(planet, "buildings"))
	add_planet_property("Points/Turn", create_int_editor(planet, "points_per_turn"))
	
	for building in planet.buildings:
		building_list.add_child(create_building_editor(planet, building))
	
	clear_connections(add_building_button.pressed)
	add_building_button.pressed.connect(func() -> void:
		planet.buildings.append(Building.new())
		display_planet_info(planet)
	)
	
	delete_planet_button.disabled = false
	add_building_button.disabled = false

static func create_string_display(object: Resource, property: String) -> Control:
	var result := Label.new()
	var update := func() -> void:
		var value = object.get(property)
		result.text = str(len(value)) if (
			value is Array or value is Dictionary
		) else str(value)
	
	object.changed.connect(update)
	result.tree_exiting.connect(func() -> void:
		object.changed.disconnect(update)
	)
	
	update.call()
	return result

static func create_string_editor(object: Resource, property: String) -> Control:
	var result := LineEdit.new()
	var update := func() -> void:
		if result.has_focus(): return
		result.text = str(object.get(property))
	
	result.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	object.changed.connect(update)
	result.text_changed.connect(func(value: String) -> void:
		object.set(property, value)
		update.call()
	)
	result.tree_exiting.connect(func() -> void:
		object.changed.disconnect(update)
	)
	
	update.call()
	return result

static func create_int_editor(object: Resource, property: String) -> Control:
	var result := SpinBox.new()
	var update := func() -> void:
		result.value = int(object.get(property))
	
	result.allow_greater = true
	result.allow_lesser = true
	result.get_line_edit().add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	object.changed.connect(update)
	result.value_changed.connect(func(value: float) -> void:
		object.set(property, int(value))
		update.call()
	)
	result.tree_exiting.connect(func() -> void:
		object.changed.disconnect(update)
	)
	
	update.call()
	return result

static func create_color_editor(object: Resource, property: String) -> Control:
	var result := AspectRatioContainer.new()
	var color_square := ColorPickerButton.new()
	var update := func() -> void:
		color_square.color = object.get(property)
	
	color_square.custom_minimum_size = Vector2.ONE
	color_square.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	object.changed.connect(update)
	color_square.color_changed.connect(func(value: Color) -> void:
		object.set(property, value)
		update.call()
	)
	color_square.tree_exiting.connect(func() -> void:
		object.changed.disconnect(update)
	)
	
	result.add_child(color_square)
	
	update.call()
	return result

static func create_planet_type_editor(planet: PlanetProperties) -> Control:
	var result := OptionButton.new()
	var update := func() -> void:
		result.select(planet.type)
	
	result.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for key in PlanetProperties.PlanetType.keys():
		result.add_item(str(key).capitalize())
	
	planet.changed.connect(update)
	result.item_selected.connect(func(index: int) -> void:
		planet.type = index as PlanetProperties.PlanetType
	)
	result.tree_exiting.connect(func() -> void:
		planet.changed.disconnect(update)
	)
	
	update.call()
	return result

static func create_building_editor(planet: PlanetProperties, building: Building) -> Control:
	var result := HBoxContainer.new()
	
	var type_editor := create_string_editor(building, "type")
	type_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result.add_child(type_editor)
	
	result.add_child(create_int_editor(building, "level"))
	
	var delete_button := Button.new()
	delete_button.text = "Remove"
	delete_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	delete_button.pressed.connect(func() -> void:
		planet.buildings.erase(building)
		result.queue_free()
	)
	result.add_child(delete_button)
	
	return result

func _on_galaxy_map_display_system(system: String) -> void:
	display_system_info(system)

func _on_ftl_button_toggled(toggled_on: bool) -> void:
	galaxy_map.show_ftl = toggled_on

func _on_detection_button_toggled(toggled_on: bool) -> void:
	galaxy_map.show_detection = toggled_on

func _on_galaxy_map_request_ftl_routes(system: String, callback: Callable) -> void:
	var result = loaded_save.ftl_routes.get(system)
	if result == null: return
	callback.call(Array(result, TYPE_STRING, "", null))

func _on_add_ftl_button_pressed() -> void:
	if not loaded_save: return
	
	for from in get_tree().get_nodes_in_group("selected_system"):
		for to in get_tree().get_nodes_in_group("selected_system"):
			if from.name == to.name: continue
			
			var from_routes: Array = loaded_save.ftl_routes.get(from.name, [])
			var to_routes: Array = loaded_save.ftl_routes.get(to.name, [])
			
			if from_routes.has(to.name): continue
			elif to_routes.has(from.name): continue
			
			from_routes.append(to.name)
			loaded_save.ftl_routes[from.name] = from_routes
			
			galaxy_map.queue_redraw()

func _on_delete_ftl_button_pressed() -> void:
	if not loaded_save: return
	
	for from in get_tree().get_nodes_in_group("selected_system"):
		for to in get_tree().get_nodes_in_group("selected_system"):
			if from.name == to.name: continue
			
			var from_routes: Array = loaded_save.ftl_routes.get(from.name, [])
			var to_routes: Array = loaded_save.ftl_routes.get(to.name, [])
			
			from_routes.erase(to.name)
			to_routes.erase(from.name)
	
	galaxy_map.queue_redraw()
