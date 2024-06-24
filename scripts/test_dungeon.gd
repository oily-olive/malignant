extends Node3D
class_name GameWorld

@onready var dungeon_generator = $DungeonGenerator3D as DungeonGenerator3D
var player: Player
var finished: bool
var stop_adding_walls: bool
var number_of_living_enemies: int = 0
var enemy_control: bool = false
signal all_enemies_dead

func _process(delta):
	#if $music.playing == false: 
		#$music.play()
	
	if player == null:
		for node in get_children():
			if node.is_in_group("player"):
				player = node
	
	if number_of_living_enemies < 0:
		number_of_living_enemies = 0
	
	if number_of_living_enemies > 0  and !enemy_control:
		enemy_control = true
	
	if number_of_living_enemies == 0 and enemy_control:
		enemy_control = false
		emit_signal("all_enemies_dead")

#func splat():
	#player.stylebonus_splat()

func _on_out_of_bounds_body_entered(body):
	if body.is_in_group("player"):
		body.set_position(Vector3(0,1,0))
		print("Shit, looks like i forgot to fix that...")


func _on_dungeon_generator_3d_done_generating():
	for room in dungeon_generator._rooms_placed:
		for door in room.get_doors():
			if door.get_room_leads_to() != null and door.optional:
				for wall in door.door_node.get_children():
					wall.queue_free()
	spawn_player(self)

func spawn_player(node):
	for child in node.get_children():
		if child.is_in_group("player_spawner"):
			child.spawn()
			return
		else:
			spawn_player(child)
