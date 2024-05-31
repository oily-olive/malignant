extends Area3D
class_name TextDisplayArea3D

@export var text_to_display: String
@onready var shape = $CollisionShape3D as CollisionShape3D
@onready var area = $area as CollisionShape3D
@onready var sound = $sound as AudioStreamPlayer


func _ready():
	if text_to_display == "":
		text_to_display = "you are using this node incorrectly. please add something for it to display."
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		sound.play()
		body.pop_up_text.text = text_to_display
func _on_body_exited(body):
	if body.is_in_group("player"):
		await get_tree().create_timer(2.5).timeout
		body.pop_up_text.text = ""
