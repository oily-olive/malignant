extends MarginContainer
class_name ControlsMenu

const INPUT_BUTTON = preload("res://scenes/menus/options/input_button.tscn") as PackedScene
@onready var reset_button = $VBoxContainer/reset_button as Button
@onready var back_button = $VBoxContainer/back_button as Button
@onready var list = $ScrollContainer/list as VBoxContainer

var is_remapping: bool = false
var action_to_remap = null
var remapping_button = null

var input_actions = {
	"moveForward": "Move Forward",
	"moveLeft": "Move Left",
	"moveBack": "Move Backward",
	"moveRight": "Move Right",
	"jump": "Jump",
	"primaryFire": "Primary Fire",
	"secondaryFire": "Secondary Fire",
	"tertiaryFire": "Tertiary Fire",
	"melee": "Melee",
	"slide": "Slide/Slam",
	"heal": "Heal",
	"reload": "Reload"
}

func create_action_list():
	InputMap.load_from_project_settings()
	for item in list.get_children():
		item.queue_free()
	
	for action in input_actions:
		var button = INPUT_BUTTON.instantiate()
		#list.add_child(button)
		#
		#await button.tree_entered
		var action_label = button.find_child("Label_action")
		var input_label = button.find_child("Label_key")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if !events.is_empty():
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = "..."
		
		list.add_child(button)
		button.pressed.connect(on_input_button_pressed.bind(button, action))
		

func on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("Label_key").text = "..."

func _input(event):
	if is_remapping:
		if (
			event is InputEventKey ||
			(event is InputEventMouseButton && event.pressed)
		):
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			update_event_list(remapping_button, event)
			
			is_remapping = false
			remapping_button = null
			action_to_remap = null
			
			accept_event()

func update_event_list(button, event):
	button.find_child("Label_key").text = event.as_text().trim_suffix(" (Physical)")

func _ready():
	create_action_list()

func _on_reset_button_pressed():
	create_action_list()
