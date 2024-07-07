extends MarginContainer
class_name OptionsMenu

@onready var graphics_button = $VBoxContainer/graphics_button as Button
@onready var sound_button = $VBoxContainer/sound_button as Button
@onready var controls_button = $VBoxContainer/controls_button as Button
@onready var accessibility_button = $VBoxContainer/accessibility_button as Button
@onready var back_button = $VBoxContainer/back_button as Button

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
