extends Control

func _on_mute_button_pressed() -> void:
	$AudioStreamPlayer.stream_paused = $MuteButton.button_pressed
