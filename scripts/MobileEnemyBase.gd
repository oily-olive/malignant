extends Enemy
class_name MobileEnemy

@export var affected_by_gravity: bool = true
@export var speed: float = 10.0
@export var fall_damage_detection: RayCast3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var splatted: bool = false
func _physics_process(delta):
	if !dead:
		fall_damage_detection.set_target_position(velocity.normalized() * max_enemy_radius * 2)
		if !is_on_floor():
			velocity.y -= gravity * delta
			var absolute_velocity = abs(velocity.x) + abs(velocity.y) + abs(velocity.z)
			if fall_damage_detection.is_colliding() and absolute_velocity >= 40.0 and !splatted:
				splatted = true
				if player != null:
					player.stylebonus_splat()
		var current_location = global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = (next_location - current_location).normalized() * speed
		if is_on_floor():
			velocity = lerp(velocity, new_velocity, delta * 7.0)
		look_at(Vector3(nav_agent.get_next_path_position().x, self.position.y, nav_agent.get_next_path_position().z))

func get_launched_by_punch(direction: Vector3):
		if not is_on_floor():
			velocity = direction * 45.0
		else:
			velocity = (direction * 45.0) / 4

func get_launched_by_slam():
	velocity.y += 20.0
	
