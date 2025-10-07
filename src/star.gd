extends Control

const STAR_RADIUS := 1000

func _init() -> void:
	custom_minimum_size = Vector2(100, 0)

func _draw() -> void:
	draw_circle(
		Vector2(size.x - STAR_RADIUS, size.y / 2),
		STAR_RADIUS,
		Color.WHITE,
		true,
		-1,
		true
	)
