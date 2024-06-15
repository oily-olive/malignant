extends Node3D

@onready var block_0 = $block0 as CyclopsBlock
@onready var block_1 = $block1 as CyclopsBlock
@onready var area = $"../Area3D" as PlayerDetectionArea
var door_closed: bool = false
var world: GameWorld

func _ready():
	world = get_parent().get_parent().get_parent().get_parent()
	
func close_door():
	door_closed = true

func open_door():
	door_closed = false

func _process(delta):
	if door_closed:
		block_0.position.x = lerp(block_0.position.x, 0.0, delta * 5)
		block_1.position.x = lerp(block_1.position.x, -3.0, delta * 5)
	else:
		block_0.position.x = lerp(block_0.position.x, 4.0, delta * 5)
		block_1.position.x = lerp(block_1.position.x, -7.0, delta * 5)
	
	if !door_closed:
		if area != null:
			await area.player_entered
			close_door()
			return
		else:
			return
	
	if door_closed:
		await world.all_enemies_dead
		open_door()
		return
	


