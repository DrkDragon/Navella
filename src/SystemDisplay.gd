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

signal display_system(system: String)

func _init() -> void:
	texture = CIRCLE

func select() -> void:
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
	
	if get_parent().show_ftl:
		for ftl in [30, 70, 120, 175, 225]:
			draw_circle(
				Vector2.ZERO,
				ftl / scale.x,
				Color(0, 1, 1, 0.1),
				true
			)
	
	if get_parent().show_detection:
		for detection in [40, 90, 150, 220, 315]:
			draw_circle(
				Vector2.ZERO,
				detection / scale.x,
				Color(0, 1, 0, 0.15),
				true
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
