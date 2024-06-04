extends Node3D
class_name WeaponHandler

@onready var player = $"../../.." as Player
var Weapons = Vector3i(0,0,0)
var none = 0
var revolver = 1
var shotgun = 2

func handle_weapons(slot: int):
	if slot == 1:
		if Weapons.x == 0:
			player.revolver.visible = false
			player.shotgun.visible = false
		if Weapons.x == 1:
			player.revolver.visible = true
			player.shotgun.visible = false
		if Weapons.x == 2:
			player.revolver.visible = false
			player.shotgun.visible = true
	if slot == 2:
		if Weapons.y == 0:
			player.revolver.visible = false
			player.shotgun.visible = false
		if Weapons.y == 1:
			player.revolver.visible = true
			player.shotgun.visible = false
		if Weapons.y == 2:
			player.revolver.visible = false
			player.shotgun.visible = true
	if slot == 3:
		if Weapons.z == 0:
			player.revolver.visible = false
			player.shotgun.visible = false
		if Weapons.z == 1:
			player.revolver.visible = true
			player.shotgun.visible = false
		if Weapons.z == 2:
			player.revolver.visible = false
			player.shotgun.visible = true

func get_visible_weapon():
	if player.revolver.visible:
		player.ch.frame = 0
		return player.revolver
	if player.shotgun.visible:
		player.ch.frame = 5
		return player.shotgun
