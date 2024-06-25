extends Node3D

@onready var revolver = $plchld_revolver_better as Node3D
@onready var weapon = load("res://scenes/new_revolver_good.tscn")

func _process(delta):
	revolver.rotation_degrees += 15

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		if !body.all_weapon_slots_full:
			body.cam.add_child(weapon)
			queue_free()
