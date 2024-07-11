extends MarginContainer
class_name GraphicsMenu


@onready var back_button = $VBoxContainer/back_button as Button
const DEFAULT_RESOLUTION = Vector2i(1152, 648)

func _on_check_box_toggled(toggled_on):
	if toggled_on:
		await get_tree().process_frame
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	else:
		await get_tree().process_frame
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

