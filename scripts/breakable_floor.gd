extends StaticBody3D

func break_o():
	#godot you fucking asshole, just let me use break as the function name >:(
	$CollisionShape3D.disabled = true
	await get_tree().create_timer(0.25).timeout
	$"../..".queue_free()
