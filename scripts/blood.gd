extends CharacterBody3D

@onready var collision_ray = $RayCast3D as RayCast3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var initial_velocity = 2.5
var blood_decal = load("res://scenes/effects/blood_decal.tscn") as PackedScene

func _ready():
	var random_direction = Vector3(rand_range(-50, 50), 0, rand_range(-50, 50))
	var new_velocity = random_direction.normalized() * initial_velocity
	velocity = Vector3(new_velocity.x, 1.0, new_velocity.z)

func _process(delta):
	velocity.y -= gravity * delta
	collision_ray.target_position = velocity.normalized()
	move_and_slide()

	if collision_ray.is_colliding():
		var collider = collision_ray.get_collider()
		if !(collider is Player) and !(collider is Enemy) and !(collider is Area3D) and is_on_wall():
			var spawn_blood = blood_decal.instance()
			spawn_blood.spawn(collision_ray.get_collision_point(), collision_ray.get_collision_normal())
			get_parent().add_child(spawn_blood)
			queue_free()