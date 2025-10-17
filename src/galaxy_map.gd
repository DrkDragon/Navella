extends Node2D

const BACKGROUND := preload("res://background.png")
const DISTORT := preload("res://distort.tres")
const SYSTEM_POINTS := preload("res://system_points.png")
const TILE_SIZE := 25
const TILE_COUNT := 4
const SECTOR_SIZE := TILE_SIZE * TILE_COUNT
const SECTOR_COUNT := 25
const MAP_SIZE := SECTOR_SIZE * SECTOR_COUNT
const POINT_SCALE := 1.0 / 256
const LABEL_SCALE := 1.0 / 2
const LETTERS := "ABCDEFGHIJKLMNOPQRSTUVWXY"
const FTL_SEGMENTS := 4
const GRID_LINE_COLOR := Color(0.25, 0.25, 0.25, 0.5)

signal display_system(system: String)
signal request_ftl_routes(system: String, callback: Callable)
signal zoom_changed

class GridLabel extends Label:
	var fix_index := 0
	var fix_column := false
	
	func _init() -> void:
		add_theme_color_override("font_color", Color.RED)
	
	func fix_to_column(index: int) -> void:
		fix_index = index
		fix_column = true
		horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vertical_alignment = VERTICAL_ALIGNMENT_TOP
		
		text = LETTERS[index]
	
	func fix_to_row(index: int) -> void:
		fix_index = index
		fix_column = false
		horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		text = str(SECTOR_COUNT - index)
	
	func _process(_delta: float) -> void:
		var viewport := get_viewport()
		var camera := viewport.get_camera_2d()
		
		scale = Vector2.ONE / camera.zoom.maxf(LABEL_SCALE)
		size = (Vector2.ONE * SECTOR_SIZE) / scale
		
		var camera_offset := camera.position - (
			Vector2(viewport.size / 2) / camera.zoom
		)
		
		if fix_column:
			position = Vector2(
				fix_index * SECTOR_SIZE,
				camera_offset.y
			)
		else:
			position = Vector2(
				camera_offset.x,
				fix_index * SECTOR_SIZE
			)

var background := Sprite2D.new()
var camera := Camera2D.new()
var show_ftl := false
var show_detection := false

func real_size(size: Vector2) -> Vector2:
	return size * camera.zoom

func _init() -> void:
	background.z_index = -1
	background.centered = false
	background.texture = BACKGROUND
	background.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	background.scale = (Vector2.ONE * MAP_SIZE) / BACKGROUND.get_size()
	background.material = DISTORT
	add_child(background)
	
	camera.position = Vector2.ONE * MAP_SIZE / 2
	add_child(camera)
	
	for i in range(SECTOR_COUNT):
		var row_label := GridLabel.new()
		row_label.fix_to_row(i)
		add_child(row_label)
		
		var column_label := GridLabel.new()
		column_label.fix_to_column(i)
		add_child(column_label)
	
	var system_counts: Dictionary[String, int] = {}
	
	for y in range(MAP_SIZE):
		for x in range(MAP_SIZE):
			if not SYSTEM_POINTS.get_bit(x, y): continue
			
			var tile := Vector2i(x, y) / (Vector2i.ONE * TILE_SIZE)
			var coord := tile / (Vector2i.ONE * TILE_COUNT)
			var subcoord := tile % (Vector2i.ONE * TILE_COUNT)
			
			var coord_text := (
				LETTERS[coord.x] +
				str(SECTOR_COUNT - coord.y) +
				"-" +
				LETTERS[subcoord.x] +
				str(subcoord.y + 1)
			)
			
			if not system_counts.has(coord_text): system_counts[coord_text] = 0
			system_counts[coord_text] += 1
			
			var point := SystemDisplay.new()
			point.coord = coord_text
			point.discriminator = system_counts[coord_text]
			point.position = Vector2(x, y)
			
			point.display_system.connect(display_system.emit)
			
			zoom_changed.connect(func():
				point.scale = ((Vector2.ONE / camera.zoom) * POINT_SCALE).maxf(
					POINT_SCALE / 2
				)
			)
			
			add_child(point)
	
	zoom_changed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= 1.1
			zoom_changed.emit()
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom /= 1.1
			zoom_changed.emit()
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var top_node: SystemDisplay = null
			var top_distance := INF
			
			for node in get_children():
				if node is not SystemDisplay: continue
				
				var distance: float = node.position.distance_to(
					get_local_mouse_position()
				)
				if distance >= top_distance: continue
				
				top_node = node
				top_distance = distance
			
			if top_node != null:
				top_node.select(Input.is_key_pressed(KEY_CTRL))
			else:
				for point in get_tree().get_nodes_in_group("selected_system"):
					point.deselect()
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			camera.position -= event.screen_relative / camera.zoom

func _draw() -> void:
	var line_width := (
		1 if real_size(Vector2.ONE).x > 2 else 2
	) if real_size(Vector2.ONE).x > 1 else -1
	
	draw_line(
		Vector2(0, MAP_SIZE),
		Vector2(MAP_SIZE, MAP_SIZE),
		GRID_LINE_COLOR,
		line_width
	)
	
	for row in range(TILE_SIZE):
		draw_line(
			Vector2(0, row * SECTOR_SIZE),
			Vector2(MAP_SIZE, row * SECTOR_SIZE),
			GRID_LINE_COLOR,
			line_width
		)
		
		if real_size(Vector2.ONE).x > 1:
			for subrow in range(TILE_COUNT):
				var subpos := row * SECTOR_SIZE + subrow * TILE_SIZE
				draw_line(
					Vector2(0, subpos),
					Vector2(MAP_SIZE, subpos),
					GRID_LINE_COLOR
				)
	
	draw_line(
		Vector2(MAP_SIZE, 0),
		Vector2(MAP_SIZE, MAP_SIZE),
		GRID_LINE_COLOR,
		line_width
	)
	
	for column in range(TILE_SIZE):
		draw_line(
			Vector2(column * SECTOR_SIZE, 0),
			Vector2(column * SECTOR_SIZE, MAP_SIZE),
			GRID_LINE_COLOR,
			line_width
		)
		
		if real_size(Vector2.ONE).x > 1:
			for subcolumn in range(TILE_COUNT):
				var subpos := column * SECTOR_SIZE + subcolumn * TILE_SIZE
				draw_line(
					Vector2(subpos, 0),
					Vector2(subpos, MAP_SIZE),
					GRID_LINE_COLOR
				)
	
	for child in get_children():
		if child is not SystemDisplay: continue
		request_ftl_routes.emit(child.name, func(routes: Array[String]) -> void:
			for route in routes:
				var target: SystemDisplay = get_node_or_null(route)
				if target == null: continue
				
				if target.position.y < child.position.y: continue
				elif target.position.y == child.position.y:
					if target.position.x < child.position.x: continue
				
				for i in FTL_SEGMENTS:
					var from: Vector2 = target.position.lerp(
						child.position,
						float(i) / FTL_SEGMENTS
					)
					var to: Vector2 = target.position.lerp(
						child.position,
						float(i + 1) / FTL_SEGMENTS
					)
					var color := target.binding.color.lerp(
						child.binding.color,
						float(i) / (FTL_SEGMENTS + 1)
					)
					draw_line(from, to, color)
		)

static func get_coord(row: int, column: int, subrow: int, subcolumn: int) -> String:
	return LETTERS[column - 1] + str(row) + "-" + LETTERS[subcolumn] + str(subrow + 1)
