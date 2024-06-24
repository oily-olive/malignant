extends CharacterBody3D
class_name Enemy

@export var nav_agent: NavigationAgent3D
var world: GameWorld
var player: Player
@export var max_health: float = 1.5
var health
signal world_found #emitted on find_scene_root success
signal player_found #emitted on find_player success
signal enemy_died
var dead: bool = false
@export var max_enemy_radius: float = 1
var temperature: int = 0
var frozen: bool = false
var on_fire: bool = false
var stunned: bool = false
var blood = load("res://scenes/effects/blood.tscn") as PackedScene
@export var sprite: Sprite3D

func find_scene_root():
	#if obj is Node3D:
		#if not obj.get_parent() is Node3D:
			#world = obj
			#emit_signal("world_found")
		#else:
			#find_scene_root(obj.get_parent())
	#else:
		#printerr("Enemy is not child of a Node3D!")
		#queue_free()
	if world == null:
		for thing in get_tree().get_root().get_children():
			if thing is GameWorld:
				world = thing
				emit_signal("world_found")

func find_player():
	if player == null:
		for thing in world.get_children():
			if thing is Player:
				player = thing

var updating_target: bool = false
func update_nav_target():
	if player != null:
		if !updating_target:
			updating_target = true
			var offset = randf_range(-0.1, 0.1)
			await get_tree().create_timer(0+offset).timeout
			nav_agent.target_position = player.global_position
			updating_target = false

func _ready():
	if nav_agent == null:
		printerr("No navigation agent selected for this enemy; deleting...")
		die()
	health = max_health
	find_scene_root()
	await get_tree().create_timer(0.001).timeout
	find_player()
	world.number_of_living_enemies += 1

@warning_ignore("unused_parameter")
func _process(delta):
	update_nav_target()
	handle_temp()
	if !dead:
		move_and_slide()
	if health <= 0.0:
		die()
	if player != null:
		find_angle()

func die():
	dead = true
	visible = false
	for obj in get_children():
		if obj is CollisionShape3D:
			obj.disabled = true
	emit_signal("enemy_died")
	var create_blood = blood.instantiate()
	create_blood.global_position = Vector3(self.global_position.x, self.global_position.y + (max_enemy_radius * 1.1), self.global_position.z)
	bleed(create_blood, 15)
	print(str(health))
	await get_tree().create_timer(0.5).timeout
	world.number_of_living_enemies -= 1
	queue_free()
func gib():
	print("gibbed")
	player.stylebonus_gibbed()
	var create_blood = blood.instantiate()
	create_blood.global_position = Vector3(self.global_position.x, self.global_position.y + (max_enemy_radius * 1.1), self.global_position.z)
	bleed(create_blood, 15)
	die()
signal enemy_hit
func get_hit(damage: float, temperature_gain: int = 0):
	if !dead:
		emit_signal("enemy_hit")
		var number_of_blood = int(damage * 8)
		if number_of_blood == 0:
			number_of_blood = 1
		var create_blood = blood.instantiate()
		create_blood.global_position = Vector3(self.global_position.x, self.global_position.y + (max_enemy_radius * 1.1), self.global_position.z)
		bleed(create_blood, number_of_blood)
		var actual_damage = damage
		if frozen:
			actual_damage *= 1.5
		if actual_damage >= health:
			if actual_damage >= health * 1.5:
				gib()
			else:
				die()
		else:
			health -= actual_damage
		temperature += temperature_gain

func bleed(blood, number):
	if number != 0:
		get_parent().add_child(blood)
		bleed(blood, number - 1)

var just_burned: bool = false
var burn_reset: bool = false
func handle_temp():
	if on_fire and frozen:
		get_hit(5)
		temperature = 0
		on_fire =false
		frozen = false
	if on_fire and !just_burned:
		just_burned = true
		get_hit(0.25)
		
	if temperature >= 100:
		on_fire = true
	if temperature <= 100:
		await get_tree().create_timer(3).timeout
		on_fire = false
	if temperature > 0:
		temperature -= 1
	
	if temperature <= -100:
		frozen = true
	if temperature >= -100:
		await get_tree().create_timer(3).timeout
		frozen = false
	if temperature < 0:
		temperature += 1
	if just_burned and !burn_reset:
		burn_reset = true
		await get_tree().create_timer(1).timeout
		just_burned = false
		burn_reset = false
	
signal attacking
func attack():
	emit_signal("attacking")

func parry():
	pass
	#stunned = true
	#get_hit(3)
func find_angle():
	if sprite != null:
		var sprite_anchor = sprite.get_parent()
		sprite_anchor.look_at(Vector3(player.position.x, sprite_anchor.global_position.y, player.position.z))
		var rotate_amount
		if sprite_anchor.rotation_degrees.y < 0:
			rotate_amount = 360 + int(sprite_anchor.rotation_degrees.y) + 22.5
		else:
			rotate_amount = int(sprite_anchor.rotation_degrees.y) + 22.5
		sprite.frame = rotate_amount / 45
	