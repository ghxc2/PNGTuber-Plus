extends Node
var settings_window: Window
func _on_settings_button_pressed() -> void:
	if settings_window != null:
		settings_window.popup_centered()
		return

	settings_window = preload("res://main_scenes/AvatarAutomation/RedemptionSettings.tscn").instantiate()

	settings_window.close_requested.connect(
		func():
			settings_window.queue_free()
			settings_window = null
	)

	add_child(settings_window)
	settings_window.popup_centered()
