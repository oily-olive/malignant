extends Node3D

var player: Player

@onready var oob = $out_of_bounds
@onready var moving_door_1 = $non_navigable_geometry/moving_door_1
@onready var enemy_spawner_01 = $enemy_spawner_01 as Spawner

func _ready():
	await get_tree().create_timer(.1).timeout # ??
	for node in get_children():
		if node.is_in_group("player"):
			player = node

func _physics_process(delta):
	#if $music.playing == false: 
		#$music.play()
	pass

func splat():
	player.stylebonus_splat()

func _on_out_of_bounds_body_entered(body):
	if body.is_in_group("player"):
		body.set_position(Vector3(4,2,6))
		print("Shit, looks like i forgot to fix that...")

func _on_revolver_pick_up_detect_body_entered(body):
	if body.is_in_group("player"):
		enemy_spawner_01.spawn()
		moving_door_1.position.y -= 10.0
		$revolver_pick_up_detect.queue_free()
	
