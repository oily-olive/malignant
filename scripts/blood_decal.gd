extends Decal

#shout out to the random redditor that provided this function you were a life saver
func spawn(pos: Vector3, normal: Vector3):
	position = pos
	if normal != Vector3.UP:
		look_at(pos + normal, Vector3.UP)
		transform = transform.rotated_local(Vector3.RIGHT, PI/2.0)
	rotate(normal, randf_range(0, 2*PI))


