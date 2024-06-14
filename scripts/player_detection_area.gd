extends Area3D
class_name PlayerDetectionArea

signal player_entered


func _on_body_entered(body):
	if body is Player:
		emit_signal('player_entered')
		$"../Spawner".spawn()
		$"../Spawner2".spawn()
		$"../Spawner3".spawn()
		$"../Spawner4".spawn()
		queue_free()
