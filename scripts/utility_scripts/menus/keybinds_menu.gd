extends MarginContainer
class_name ControlsMenu

const INPUT_BUTTON = preload("res://scenes/menus/options/input_button.tscn") as PackedScene
const BACK_BUTTON = preload("res://scenes/menus/options/back_button.tscn") as PackedScene
var back_button = BACK_BUTTON.instantiate() as Button
@onready var list = $ScrollContainer/list as VBoxContainer

var is_remapping: bool = false
var action_to_remap = null
var remapping_button = null

func create_action_list():
	InputMap.load_from_project_settings()
	for item in list.get_children():
		item.queue_free()
	
	for action in InputMap.get_actions():
		var button = INPUT_BUTTON.instantiate()
		#list.add_child(button)
		#
		#await button.tree_entered
		var action_label = button.find_child("Label_action")
		var input_label = button.find_child("Label_key")
		
		action_label.text = action
		
		var events = InputMap.action_get_events(action)
		if !events.is_empty():
			input_label.text = events[0].as_text()
		else:
			input_label.text = "..."
		
		if !action_label.text.begins_with("ui_"):
			list.add_child(button)
		
	await get_tree().process_frame
	list.add_child(Control.new())
	list.add_child(Control.new())
	list.add_child(Control.new())
	list.add_child(Control.new())
	list.add_child(back_button)

func _ready():
	create_action_list()
