extends CharacterBody3D

@onready var collision_ray = $RayCast3D as RayCast3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var initial_velocity = 2.5
var blood_decal = load("res://scenes/effects/blood_decal.tscn") as PackedScene

func _ready():
	var random_direction = Vector3(0,0,0)
	random_direction.x = randi_range(-25, 25)
	random_direction.z = randi_range(-25, 25)
	var new_velocity_first = Vector3(random_direction.x, 0.0, random_direction.z)
	var new_velocity_second = new_velocity_first.normalized() * initial_velocity
	velocity = Vector3(new_velocity_second.x, 1.0, new_velocity_second.z)

func _process(delta):
	velocity.y -= gravity * delta
	collision_ray.target_position = velocity.normalized()
	move_and_slide()
	if collision_ray.is_colliding():
		if !collision_ray.get_collider() is Player and !collision_ray.get_collider() is Enemy and !collision_ray.get_collider() is Area3D and is_on_wall():
			print("hiiii")
			var spawn_blood = blood_decal.instantiate()
			spawn_blood.spawn(collision_ray.get_collision_point(), collision_ray.get_collision_normal())
			get_parent().add_child(spawn_blood)
			queue_free()
