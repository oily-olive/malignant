extends MarginContainer

@onready var input_button = load("res://scenes/menus/options/input_button.tscn") as PackedScene
@onready var list = $ScrollContainer/list as VBoxContainer

var is_remapping: bool = false
var action_to_remap = null
var remapping_button = null

func create_action_list():
	InputMap.load_from_project_settings()
	for item in list.get_children():
		item.queue_free()
	
	for action in InputMap.get_actions():
		var button = input_button.instantiate()
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
		
		

func _ready():
	create_action_list()
