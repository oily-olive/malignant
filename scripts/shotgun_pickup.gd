extends Node3D

@onready var rat = $rat

func _process(delta):
	if Engine.time_scale != 0.0:
		rat.rotation_degrees.y += 7.5
	
func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		body.weapon_handler.pickup_weapon(2)
		body.weapon_handler.handle_weapons(body.WEAPON)
		queue_free()
