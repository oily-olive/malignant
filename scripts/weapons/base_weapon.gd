extends Sprite2D
class_name BaseWeapon

@export var number_of_possible_upgrades: int = 3
#TODO: add thingy for the types of upgrades the weapon can accept
var upgrades = []

func get_number_of_upgrades():
	var number_of_upgrade_slots_used = 0
	for item in upgrades:
		number_of_upgrade_slots_used += 1
