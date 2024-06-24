extends Node3D

@onready var rat = $rat

func _process(delta):
	if Engine.time_scale != 0.0:
		rat.rotation_degrees.y += 7.5
	
func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		if body.weapon_handler.Weapons.x == 0:
			body.weapon_handler.Weapons.x = 2
		elif body.weapon_handler.Weapons.y == 0:
			body.weapon_handler.Weapons.y = 2
		elif body.weapon_handler.Weapons.z == 0:
			body.weapon_handler.Weapons.z = 2
		else:
			print("too many weapons!")
		body.weapon_handler.handle_weapons(body.WEAPON)
		queue_free()
