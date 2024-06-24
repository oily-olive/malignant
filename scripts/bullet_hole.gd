extends Node3D

func _ready():
	var random_time = randf_range(-1.0, 1.0)
	await get_tree().create_timer(3 + random_time).timeout
	get_tree().create_tween().tween_property($Decal, "modulate:a", 0, 0.75)
	await get_tree().create_timer(0.75).timeout
	queue_free()

func spawn(pos: Vector3, normal: Vector3):
	position = pos
	await tree_entered
	if normal == Vector3.UP or normal == Vector3.DOWN:
		$Decal.rotation.x = 0
	else:
		look_at(pos + normal)
	rotate(normal, randf_range(0, 2*PI))
