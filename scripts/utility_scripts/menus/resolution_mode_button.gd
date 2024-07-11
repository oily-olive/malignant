extends HBoxContainer


@onready var option_button = $OptionButton as OptionButton

const RESOLUTION_DICTIONARY: Dictionary = {
	"1152 x 648" : Vector2i(1152, 648),
	"1280 x 720" : Vector2i(1280, 720),
	"1920 x 1080" : Vector2i(1920, 1080)
}

func add_resolution_items():
	for i in RESOLUTION_DICTIONARY:
		option_button.add_item(i)

func _on_option_button_item_selected(index):
	DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])

func _ready():
	add_resolution_items()
