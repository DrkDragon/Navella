extends GridContainer

const RED_BOX := preload("res://red_box.tres")
const CIRCLE := preload("res://circle.tres")
const LETTERS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

class SystemPoint extends TextureRect:
	func _init() -> void:
		texture = CIRCLE

func _init() -> void:
	for row in range(26):
		for column in range(26):
			if row == 0 and column == 0:
				var space := Panel.new()
				space.add_theme_stylebox_override("panel", RED_BOX)
				add_child(space)
			elif row == 0 or column == 0:
				var label := Label.new()
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				label.add_theme_color_override("font_color", Color.RED)
				
				if row == 0: label.text = str(LETTERS[column - 1])
				else: label.text = str(row)
				
				var container := PanelContainer.new()
				container.add_theme_stylebox_override("panel", RED_BOX)
				container.add_child(label)
				
				add_child(container)
			else:
				add_child(create_zone(func(_system: String) -> bool:
					return false
				, row, column))

static func create_zone(has_system: Callable, row: int, column: int) -> GridContainer:
	var result := GridContainer.new()
	result.columns = 4
	result.add_theme_constant_override("h_separation", 0)
	result.add_theme_constant_override("v_separation", 0)
	
	for subrow in range(4):
		for subcolumn in range(4):
			var coord := get_coord(row, column, subrow, subcolumn)
			
			var cell := PanelContainer.new()
			cell.custom_minimum_size = Vector2.ONE * 32
			cell.tooltip_text = coord
			cell.add_theme_stylebox_override("panel", RED_BOX)
			
			result.add_child(cell)
			
			if not has_system.call(coord): continue
			
			var center := CenterContainer.new()
			cell.add_child(center)
			
			var point := SystemPoint.new()
			center.add_child(point)
	
	return result

static func get_coord(row: int, column: int, subrow: int, subcolumn: int) -> String:
	return LETTERS[column - 1] + str(row) + "-" + LETTERS[subcolumn] + str(subrow + 1)
