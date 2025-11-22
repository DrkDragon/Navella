extends Window

@onready var value := $Background/Layout/Main/Value

func _init() -> void:
	close_requested.connect(func() -> void:
		visible = false
	)

func _ready() -> void:
	var line: LineEdit = value.get_line_edit()
	line.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _on_clear_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	line.text = "0"
	_on_equal_pressed()

func _on_equal_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	line.text_submitted.emit(line.text)

func _on_0_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	if line.text == "0": line.text = ""
	line.text += "0"

func _on_1_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	if line.text == "0": line.text = ""
	line.text += "1"

func _on_2_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	if line.text == "0": line.text = ""
	line.text += "2"

func _on_3_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	if line.text == "0": line.text = ""
	line.text += "3"

func _on_4_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	if line.text == "0": line.text = ""
	line.text += "4"

func _on_5_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	if line.text == "0": line.text = ""
	line.text += "5"

func _on_6_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	if line.text == "0": line.text = ""
	line.text += "6"

func _on_7_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	if line.text == "0": line.text = ""
	line.text += "7"

func _on_8_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	if line.text == "0": line.text = ""
	line.text += "8"

func _on_9_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	if line.text == "0": line.text = ""
	line.text += "9"

func _on_add_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	line.text = "(" + line.text + ")+"

func _on_subtract_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	line.text = "(" + line.text + ")-"

func _on_multiply_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	line.text = "(" + line.text + ")*"

func _on_divide_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	line.text = "(" + line.text + ")/"

func _on_decimal_pressed() -> void:
	var line: LineEdit = value.get_line_edit()
	line.text = line.text + "."
