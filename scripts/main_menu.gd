class_name MainMenu
extends Control

@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/start_button as Button
@onready var start_button2 = $MarginContainer/HBoxContainer/VBoxContainer/start_button2 as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/exit_button as Button
@onready var testworld = load("res://scenes/testworld.tscn") as PackedScene
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
	start_button.button_down.connect(start_testworld)
	start_button2.button_down.connect(start_testdungeon)
	exit_button.button_down.connect(leave)

func start_testworld() -> void:
	get_tree().change_scene_to_packed(testworld)

func start_testdungeon() -> void:
	get_tree().change_scene_to_packed(test_dungeon)

func leave() -> void:
	get_tree().quit()
