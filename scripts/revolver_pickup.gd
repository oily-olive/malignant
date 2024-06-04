extends Node3D

@onready var rat = $rat

func _process(delta):
	rat.rotation_degrees.y += 10
	

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		if body.weapon_handler.Weapons.x == 0:
			body.weapon_handler.Weapons.x = 1
		elif body.weapon_handler.Weapons.y == 0:
			body.weapon_handler.Weapons.y = 1
		elif body.weapon_handler.Weapons.z == 0:
			body.weapon_handler.Weapons.z = 1
		else:
			print("too many weapons!")
		queue_free()
