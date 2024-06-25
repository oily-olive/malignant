extends Node3D

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent_node_3d().is_in_group("player_camera"):
		player = get_parent_node_3d().get_parent_node_3d().get_parent_node_3d()
		if player.gun1 == null:
			player.gun1 = self
		elif player.gun2 == null:
			player.gun2 = self
		elif player.gun3 == null:
			player.gun3 = self

func _process(delta):
	if player.revAMMO == 0:
		reload_revolver()

func shoot_revolver():
	if Input.is_action_pressed("primaryFire"):
		if player.revAMMO != 0:
			if !player.revolverAnim.is_playing():
				player.revolverAnim.play("recoil")
				player.hitscan(player.raycast_r, player.revolverBarrel, player.raycastEnd_r, 1.0, true, false, false)
				player.revAMMO -= 1
func reload_revolver():
	if !player.revolverAnim.is_playing():
		var time = player.revAMMO
		player.revAMMO = 0
		await get_tree().create_timer((time + 1) / 3.0).timeout
		player.revAMMO = 6
var RSp_charge = 0.0
var ricochet = load("res://scenes/ricochet.tscn")
func revolver_special():
	if !player.revolverAnim.is_playing():
		if Input.is_action_pressed("secondaryFire") and RSp_charge < 4.5:
			RSp_charge += 0.1
		if Input.is_action_just_released("secondaryFire"):
			if 3.0 < RSp_charge and RSp_charge < 4.0:
				player.revolverAnim.play("recoil")
				player.hitscan(player.raycast_r, player.revolverBarrel, player.raycastEnd_r, player.revAMMO, true, false, false)
				if player.raycast_r.is_colliding():
					if player.raycast_r.get_collider().is_in_group("enemies"):
						var load_ricochet = ricochet.instantiate()
						load_ricochet.create(player.raycast_r, player.raycast_r.get_collider(), player.revAMMO - 1)
						load_ricochet.position = player.raycast_r.get_collider().global_position
						get_parent().add_child(load_ricochet)
					else:
						var load_ricochet = ricochet.instantiate()
						load_ricochet.create(player.raycast_r, null, player.revAMMO - 1)
						load_ricochet.position = player.raycast_r.get_collision_point()
						get_parent().add_child(load_ricochet)
			reload_revolver()
			RSp_charge = 0
