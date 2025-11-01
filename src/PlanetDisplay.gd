class_name PlanetDisplay
extends CenterContainer

const SCALE := 20.0
const DOT_SIZE := 2

var binding: PlanetProperties
var render := ColorRect.new()

signal planet_selected

func _init() -> void:
	render.show_behind_parent = true
	render.mouse_filter = Control.MOUSE_FILTER_IGNORE
	render.material = ShaderMaterial.new()
	render.material.shader = preload("res://gradient_circle.gdshader")
	add_child(render)
	
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			select()

func bind(data: PlanetProperties) -> void:
	if binding: binding.changed.disconnect(_on_data_changed)
	binding = data
	if binding:
		binding.changed.connect(_on_data_changed)
		_on_data_changed()

func _on_data_changed() -> void:
	render.color = binding.color
	custom_minimum_size = Vector2.ONE * binding.size * SCALE
	render.custom_minimum_size = custom_minimum_size
	
	var texture: Texture2D = preload("res://blank_texture.png")
	match binding.type:
		PlanetProperties.PlanetType.BARREN:
			texture = preload("res://barren_texture.tres")
		PlanetProperties.PlanetType.GAS:
			texture = preload("res://gas_texture.tres")
		PlanetProperties.PlanetType.LIQUID:
			texture = preload("res://liquid_texture.tres")
		PlanetProperties.PlanetType.TERRAIN:
			texture = preload("res://terrain_texture.png")
		PlanetProperties.PlanetType.ASTEROID_BELT:
			texture = preload("res://debris_texture.png")
		PlanetProperties.PlanetType.SHATTERED:
			texture = preload("res://shattered_texture.png")
	render.material.set_shader_parameter("texture_overlay", texture)

func select() -> void:
	for point in get_tree().get_nodes_in_group("selected_planet"):
		point.deselect()
	add_to_group("selected_planet")
	planet_selected.emit()
	queue_redraw()

func deselect() -> void:
	remove_from_group("selected_planet")
	queue_redraw()

func _process(_delta: float) -> void:
	if not is_in_group("selected_planet"): return
	queue_redraw()

func _draw() -> void:
	if binding:
		var count := len(binding.buildings)
		var columns := ceili(sqrt(count))
		
		var width := columns * (DOT_SIZE * 2.0)
		var x := (size.x / 2) - (width / 2)
		var y := ((size.y / 2) - (render.size.x / 2)) - (DOT_SIZE * 2)
		
		while count > 0:
			var row := columns if count > columns else count
			var row_width := row * DOT_SIZE * 2.0
			for i in row:
				draw_circle(
					Vector2(
						x + (((i + 1.0) / row) * row_width) + ((width / 2) - (row_width / 2)),
						y
					),
					DOT_SIZE / 2.0,
					Color.WHITE
				)
			y -= DOT_SIZE * 2
			count -= row
	
	if not is_in_group("selected_planet"): return
	
	draw_circle(
		size / 2,
		render.size.x / 2,
		Color.CYAN.lerp(
			Color.MAGENTA,
			clampf((sin(Time.get_ticks_msec() / 1000.0 * TAU) + 1) / 2, 0, 1)
		),
		false
	)
