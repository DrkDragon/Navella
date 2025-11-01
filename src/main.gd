extends Control

func _on_mute_button_pressed() -> void:
	$AudioStreamPlayer.stream_paused = $Buttons/MuteButton.button_pressed

func _on_rules_button_pressed() -> void:
	OS.shell_open("https://raw.githubusercontent.com/DrkDragon/Navella/refs/heads/main/Navella.pdf")

func _on_calculator_button_pressed() -> void:
	$Calculator.visible = true
