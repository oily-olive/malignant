extends CharacterBody3D
class_name Enemy

@export var nav_agent: NavigationAgent3D
var world: Node3D
var player: Player
@export var max_health: float = 1.5
var health
signal world_found #emitted on find_scene_root success
signal player_found #emitted on find_player success
signal enemy_died
@export var has_head: bool
@export var head: Node3D
var dead: bool = false
@export var max_enemy_radius: float = 1
var temperature: int = 0
var frozen: bool = false
var on_fire: bool = false
var stunned: bool = false

func find_scene_root(obj):
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
			if thing is Node3D:
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
	if head == null and has_head:
		printerr("No head selected for this enemy; deleting...")
		die()
	if nav_agent == null:
		printerr("No navigation agent selected for this enemy; deleting...")
		die()
	health = max_health
	find_scene_root(self)
	await get_tree().create_timer(0.1).timeout
	find_player()

func _process(delta):
	update_nav_target()
	handle_temp()
	if !dead:
		move_and_slide()
	if has_head and player != null:
		head.look_at(player.global_position)
	if health <= 0.0:
		die()

func die():
	dead = true
	visible = false
	for obj in get_children():
		if obj is CollisionShape3D:
			obj.disabled = true
	emit_signal("enemy_died")
	await get_tree().create_timer(0.5).timeout
	queue_free()
func gib():
	print("gibbed")
	player.stylebonus_gibbed()
	die()
signal enemy_hit
func get_hit(damage: float, temperature_gain: int = 0):
	emit_signal("enemy_hit")
	if damage > health:
		if damage > health * 1.5:
			gib()
		else:
			die()
	elif !frozen:
		health -= damage
	else:
		health -= 1.5 * damage
	temperature += temperature_gain

func handle_temp():
	if on_fire and frozen:
		get_hit(5)
		temperature = 0
		on_fire =false
		frozen = false
		
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
	
signal attacking
func attack():
	emit_signal("attacking")

func parry():
	stunned = true
	get_hit(3)
	
