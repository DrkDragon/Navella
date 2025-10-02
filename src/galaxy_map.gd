extends Node2D

const CIRCLE := preload("res://circle.tres")
const SYSTEM_POINTS := preload("res://system_points.png")
const TILE_SIZE := 25
const TILE_COUNT := 4
const SECTOR_SIZE := TILE_SIZE * TILE_COUNT
const SECTOR_COUNT := 25
const MAP_SIZE := SECTOR_SIZE * SECTOR_COUNT
const POINT_SCALE := 1.0 / 512
const LABEL_SCALE := 1.0 / 2
const LETTERS := "ABCDEFGHIJKLMNOPQRSTUVWXY"

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

class SystemPoint extends Sprite2D:
	func _init() -> void:
		texture = CIRCLE
	
	func select() -> void:
		for point in get_tree().get_nodes_in_group("selected_system"):
			point.deselect()
		add_to_group("selected_system")
		queue_redraw()
	
	func deselect() -> void:
		remove_from_group("selected_system")
		queue_redraw()
	
	func _process(_delta: float) -> void:
		if not is_in_group("selected_system"): return
		queue_redraw()
	
	func _draw() -> void:
		if not is_in_group("selected_system"): return
		
		draw_circle(
			Vector2.ZERO,
			texture.get_size().x / 2,
			Color.CYAN.lerp(
				Color.MAGENTA,
				clampf((sin(Time.get_ticks_msec() / 1000.0 * TAU) + 1) / 2, 0, 1)
			),
			false
		)

var camera := Camera2D.new()

func real_size(size: Vector2) -> Vector2:
	return size * camera.zoom

func _init() -> void:
	camera.position = Vector2.ONE * MAP_SIZE / 2
	add_child(camera)
	
	for i in range(SECTOR_COUNT):
		var row_label := GridLabel.new()
		row_label.fix_to_row(i)
		add_child(row_label)
		
		var column_label := GridLabel.new()
		column_label.fix_to_column(i)
		add_child(column_label)
	
	for y in range(MAP_SIZE):
		for x in range(MAP_SIZE):
			if not SYSTEM_POINTS.get_bit(x, y): continue
			
			var point := SystemPoint.new()
			
			point.position = Vector2(x, y)
			
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
			var top_node: SystemPoint = null
			var top_distance := INF
			
			for node in get_children():
				if node is not SystemPoint: continue
				
				var distance: float = node.position.distance_to(
					get_local_mouse_position()
				)
				if distance >= top_distance: continue
				
				top_node = node
				top_distance = distance
			
			if top_node != null:
				top_node.select()
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
		Color.RED,
		line_width
	)
	
	for row in range(TILE_SIZE):
		draw_line(
			Vector2(0, row * SECTOR_SIZE),
			Vector2(MAP_SIZE, row * SECTOR_SIZE),
			Color.RED,
			line_width
		)
		
		if real_size(Vector2.ONE).x > 1:
			for subrow in range(TILE_COUNT):
				var subpos := row * SECTOR_SIZE + subrow * TILE_SIZE
				draw_line(
					Vector2(0, subpos),
					Vector2(MAP_SIZE, subpos),
					Color.RED
				)
	
	draw_line(
		Vector2(MAP_SIZE, 0),
		Vector2(MAP_SIZE, MAP_SIZE),
		Color.RED,
		line_width
	)
	
	for column in range(TILE_SIZE):
		draw_line(
			Vector2(column * SECTOR_SIZE, 0),
			Vector2(column * SECTOR_SIZE, MAP_SIZE),
			Color.RED,
			line_width
		)
		
		if real_size(Vector2.ONE).x > 1:
			for subcolumn in range(TILE_COUNT):
				var subpos := column * SECTOR_SIZE + subcolumn * TILE_SIZE
				draw_line(
					Vector2(subpos, 0),
					Vector2(subpos, MAP_SIZE),
					Color.RED
				)

static func get_coord(row: int, column: int, subrow: int, subcolumn: int) -> String:
	return LETTERS[column - 1] + str(row) + "-" + LETTERS[subcolumn] + str(subrow + 1)
