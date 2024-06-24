extends Node3D

func spawn(pos: Vector3, normal: Vector3):
	position = pos
	await tree_entered
	if normal == Vector3.UP or normal == Vector3.DOWN:
		$Decal.rotation.x = 0
	else:
		look_at(pos + normal)
	rotate(normal, randf_range(0, 2*PI))
	var sprite_randomizer = randi_range(0, 10000)
	if sprite_randomizer == 42:
		return
	else:
		var sprite_randomizer_2 = randi_range(1, 7)
		var sprite_dict = {"1": "res://sprites/blood_splatters/blood_0.png", "2": "res://sprites/blood_splatters/blood_2.png", "3": "res://sprites/blood_splatters/blood_3.png", "4": "res://sprites/blood_splatters/blood_4.png", "5": "res://sprites/blood_splatters/blood_5.png", "6": "res://sprites/blood_splatters/blood_6.png", "7": "res://sprites/blood_splatters/blood_7.png"}
		$Decal.texture_albedo = load(sprite_dict[str(sprite_randomizer_2)])


