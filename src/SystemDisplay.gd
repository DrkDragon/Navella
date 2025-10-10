class_name SystemDisplay
extends Sprite2D

const CIRCLE := preload("res://circle.tres")

var coord: String :
	get: return _coord
	set(value):
		_coord = value
		name = _coord + "-" + str(discriminator)
var _coord: String

var discriminator: int :
	get: return _discriminator
	set(value):
		_discriminator = value
		name = coord + "-" + str(value)
var _discriminator: int

var binding: SystemProperties

signal display_system(system: String)

func _init() -> void:
	texture = CIRCLE

func bind(data: SystemProperties) -> void:
	if binding: data.changed.disconnect(_on_data_changed)
	binding = data
	if binding:
		data.changed.connect(_on_data_changed)
		_on_data_changed()

func _on_data_changed() -> void:
	modulate = binding.color

func select(addition: bool) -> void:
	if not addition:
		for point in get_tree().get_nodes_in_group("selected_system"):
			point.deselect()
	add_to_group("selected_system")
	display_system.emit(name)
	queue_redraw()

func deselect() -> void:
	remove_from_group("selected_system")
	queue_redraw()

func _process(_delta: float) -> void:
	if not is_in_group("selected_system"): return
	queue_redraw()

func _draw() -> void:
	if not is_in_group("selected_system"): return
	
	var dummy := Label.new()
	
	if get_parent().show_ftl:
		const FTLS := [225, 175, 120, 70, 30]
		const FTL_TIERS := ["T4", "T3", "T2", "T1", "T0"]
		
		for i in len(FTLS):
			draw_circle(
				Vector2.ZERO,
				FTLS[i] / scale.x,
				Color(0.25, 1, 1, 0.1),
				true
			)
			
			draw_string(
				dummy.get_theme_default_font(),
				Vector2(0, FTLS[i] / -scale.x),
				FTL_TIERS[i],
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				3000,
				Color.CYAN
			)
	
	if get_parent().show_detection:
		const DETECTIONS := [315, 220, 150, 90, 40]
		const DETECTION_TIERS := ["T4", "T3", "T2", "T1", "T0"]
		
		for i in len(DETECTIONS):
			draw_circle(
				Vector2.ZERO,
				DETECTIONS[i] / scale.x,
				Color(0, 1, 0, 0.15),
				true
			)
			
			draw_string(
				dummy.get_theme_default_font(),
				Vector2(0, DETECTIONS[i] / -scale.x),
				DETECTION_TIERS[i],
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				3000,
				Color.GREEN
			)
		
		for angle in 8:
			draw_line(
				Vector2.ZERO,
				Vector2(0, DETECTIONS[0]).rotated(angle * TAU / 8) / scale,
				Color.GREEN
			)
			
			draw_string(
				dummy.get_theme_default_font(),
				Vector2(0, -268).rotated(
					(angle * TAU / 8) + (PI / 8)
				) / scale,
				"ABCDEFGH"[angle],
				HORIZONTAL_ALIGNMENT_CENTER,
				-1,
				3000,
				Color.GREEN
			)
	
	draw_circle(
		Vector2.ZERO,
		texture.get_size().x / 2,
		Color.CYAN.lerp(
			Color.MAGENTA,
			clampf((sin(Time.get_ticks_msec() / 1000.0 * TAU) + 1) / 2, 0, 1)
		),
		false
	)
