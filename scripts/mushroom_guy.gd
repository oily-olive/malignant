extends Node3D

@export var DEFAULT_HP := 20
@export var DAMAGE := 1

signal hit(dam)

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

func get_shot():
	emit_signal("hit", DAMAGE)
