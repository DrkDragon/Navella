extends Node2D

@onready var ui := $"../../../../../../UI"
@onready var tab := $"../../../../../Game State"

const FTL_SEGMENTS := 16
const REDRAW_DELAY := 1000

var last_draw := Time.get_ticks_msec()

func _process(_delta: float) -> void:
	if not tab.visible: return
	if (Time.get_ticks_msec() - last_draw) < REDRAW_DELAY: return
	last_draw = Time.get_ticks_msec()
	queue_redraw()

func _draw() -> void:
	var positions: Dictionary[String, Vector2] = ui.get_system_positions()
	var game_state: SaveData = ui.loaded_save
	
	for a in game_state.ftl_routes:
		var a_info := game_state.get_system_by_name(a)
		if a_info == null: continue
		
		for b in game_state.ftl_routes[a]:
			var b_info := game_state.get_system_by_name(b)
			if b_info == null: continue
			
			for i in FTL_SEGMENTS:
				draw_line(
					positions[a].lerp(
						positions[b],
						float(i) / FTL_SEGMENTS
					),
					positions[a].lerp(
						positions[b],
						float(i + 1) / FTL_SEGMENTS
					),
					a_info.color.lerp(
						b_info.color,
						float(i) / (FTL_SEGMENTS + 1)
					)
				)
	
	for system in positions:
		var system_info := game_state.get_system_by_name(system)
		if system_info == null: continue
		
		draw_rect(
			Rect2(positions[system], Vector2.ONE),
			system_info.color
		)
