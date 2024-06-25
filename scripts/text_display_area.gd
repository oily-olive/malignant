extends Area3D
class_name TextDisplayArea3D

@export var text_to_display: String
@onready var shape = $CollisionShape3D as CollisionShape3D
@onready var area = $area as CollisionShape3D
@onready var sound = $sound as AudioStreamPlayer

@export var timeout_length: float = 2.5

func _ready():
	if text_to_display == "":
		text_to_display = "Add something to display you fucking dumbass"
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		sound.play()
		body.pop_up_text.text = text_to_display

func _on_body_exited(body):
	if body.is_in_group("player"):
		await get_tree().create_timer(timeout_length).timeout
		body.pop_up_text.text = ""
