extends Node3D
class_name WeaponHandler

@onready var player = $"../../.." as Player
var Weapons = Vector3i(2,0,0)
var none = 0
#revolver = 1
#shotgun = 2
#rocket launcher = 3

func handle_weapons(slot: int):
	var weapon_slot
	if slot == 1:
		weapon_slot = Weapons.x
	elif slot == 2:
		weapon_slot = Weapons.y
	elif slot == 3:
		weapon_slot = Weapons.z
	else:
		printerr("error: weapon slot value greater than 3 or less than 1")
	
#thanks to my awesome gf raine for teaching me how dictionaries work <3
	var visible_dict = {
		"0": {
			"revolver": false,
			"shotgun": false,
			"rocket_launcher": false
		},
		"1": {
			"revolver": true,
			"shotgun": false,
			"rocket_launcher": false
		},
		"2": {
			"revolver": false,
			"shotgun": true,
			"rocket_launcher": false
		},
		"3": {
			"revolver": false,
			"shotgun": false,
			"rocket_launcher": true
		}
	}

	player.revolver.visible = visible_dict[str(weapon_slot)]["revolver"]
	player.shotgun.visible = visible_dict[str(weapon_slot)]["shotgun"]
	player.rocket_launcher.visible = visible_dict[str(weapon_slot)]["rocket_launcher"]
		
func get_visible_weapon():
	if player.revolver.visible:
		player.ch.visible = true
		player.ch.frame = 0
		return player.revolver
	elif player.shotgun.visible:
		player.ch.visible = true
		player.ch.frame = 5
		return player.shotgun
	elif player.rocket_launcher.visible:
		player.ch.visible = true
		player.ch.frame = 5
		return player.rocket_launcher
	else:
		player.ch.visible = false
		return null
