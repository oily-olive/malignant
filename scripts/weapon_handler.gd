extends Node3D
class_name WeaponHandler

@onready var player = $"../../.." as Player
var Weapons = Vector3i(2,0,0)
#var active_weapon = [get_visible_weapon(), player.WEAPON]

#no weapon = 0
#revolver = 1
#shotgun = 2
#rocket launcher = 3
#cryogun = 4

func pickup_weapon(id: int):
	# HACK: terrible way to find first open slot, someone kill me
	if Weapons.x == 0:
		Weapons.x = id
	elif Weapons.y == 0:
		Weapons.y = id
	elif Weapons.z == 0:
		Weapons.z = id
	else:
		printerr("error: no open weapon slots")

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
# you can thank her again for rewriting this as an array
	var weapon_states = [
		{
			"revolver": false,
			"shotgun": false,
			"rocket_launcher": false,
			"cryogun": false
		},
		{
			"revolver": true,
			"shotgun": false,
			"rocket_launcher": false,
			"cryogun": false
		},
		{
			"revolver": false,
			"shotgun": true,
			"rocket_launcher": false,
			"cryogun": false
		},
		{
			"revolver": false,
			"shotgun": false,
			"rocket_launcher": true,
			"cryogun": false
		},
		{
			"revolver": false,
			"shotgun": false,
			"rocket_launcher": false,
			"cryogun": true
		}
	]

	for weapon in [player.revolver, player.shotgun, player.rocket_launcher, player.cryogun]:
		weapon.visible = weapon_states[weapon_slot][weapon.name]
		
func get_visible_weapon():
	# this looks longer now, but it repeats less and is more readable
	var weapon_frame = -1
	var visible_weapon = null
	if player.revolver.visible:
		visible_weapon = player.revolver
		weapon_frame = 0
	elif player.shotgun.visible:
		visible_weapon = player.shotgun
		weapon_frame = 1
	elif player.rocket_launcher.visible:
		visible_weapon = player.rocket_launcher
		weapon_frame = 2
	elif player.cryogun.visible:
		visible_weapon = player.cryogun
		weapon_frame = 5
	player.ch.visible = visible_weapon != null
	if visible_weapon:
		player.ch.frame = weapon_frame
	return visible_weapon
