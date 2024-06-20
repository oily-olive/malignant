extends Decal

func _ready():
	var random_time = randf_range(-1.0, 1.0)
	await get_tree().create_timer(3 + random_time).timeout
	var fade = get_tree().create_tween()
	fade.tween_property(self, "modulate:a", 0, 0.75)
	await get_tree().create_timer(0.75).timeout
	queue_free()

#shout out to the random redditor that provided this function you were a life saver
func spawn(pos: Vector3, normal: Vector3):
	position = pos
	if normal != Vector3.UP:
		look_at(pos + normal, Vector3.UP)
		transform = transform.rotated_local(Vector3.RIGHT, PI/2.0)
	rotate(normal, randf_range(0, 2*PI))
