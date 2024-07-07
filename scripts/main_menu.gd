class_name MainMenu
extends Control

@onready var start_button2 = $main_menu_container/HBoxContainer/VBoxContainer/start_button2 as Button
@onready var exit_button = $main_menu_container/HBoxContainer/VBoxContainer/exit_button as Button
@onready var options_button = $main_menu_container/HBoxContainer/VBoxContainer/options_button as Button
@onready var options_menu = $options_menu as OptionsMenu
@onready var controls_menu = $controls_menu as ControlsMenu
@onready var tutorial = load("res://scenes/tutorial_level.tscn") as PackedScene
@onready var test_dungeon = load("res://scenes/test_dungeon.tscn") as PackedScene
@onready var music = $music as AudioStreamPlayer
@onready var camera = $background/Camera3D as Camera3D
@onready var clouds = $background/clouds as MeshInstance3D
@onready var sky = $background/sky as MeshInstance3D


func _process(delta):
	if !music.playing:
		music.play()
	camera.rotation_degrees.y += delta * 2.5
	clouds.rotation_degrees.y -= delta * 1.5
	sky.rotation_degrees.y += delta * 0.5

func _ready():
	connect_buttons()
	back_to_main()

func start_testdungeon():
	get_tree().change_scene_to_packed(test_dungeon)

func start_options_menu():
	change_menu($options_menu)
	
func open_controls_menu():
	change_menu($controls_menu)

func back_to_main():
	change_menu($main_menu_container)

func leave():
	get_tree().quit()

func connect_buttons():
	start_button2.button_down.connect(start_testdungeon)
	options_button.button_down.connect(start_options_menu)
	options_menu.controls_button.button_down.connect(open_controls_menu)
	controls_menu.back_button.button_down.connect(start_options_menu)
	options_menu.back_button.button_down.connect(back_to_main)
	exit_button.button_down.connect(leave)



func change_menu(new_active_menu: Node):
	for menu in get_children():
		if menu is Control:
			if !menu == new_active_menu:
				menu.visible = false
			else:
				menu.visible = true
