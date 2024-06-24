extends Node3D

func spawn(pos: Vector3, normal: Vector3):
	await tree_entered
	if normal == Vector3.UP or normal == Vector3.DOWN:
		$Decal.rotation.x = 0
	else:
		look_at(pos + normal)
	rotate(normal, randf_range(0, 2*PI))
	if randi_range(0, 10000) == 42:
		return
	else:
		var texture_i = randi_range(1, 7)
		var sprite_base = "res://sprites/blood_splatters/blood_*.png"
		var sprites = []
		for i in range(0, 7):
			sprites.append(sprite_base.replace("*", str(i)))
		$Decal.texture_albedo = load(sprites[texture_i])
