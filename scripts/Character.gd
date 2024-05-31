extends CharacterBody3D
class_name Player

var SPEED_BOOST = 1.0
@export var NORMAL_SPEED = 6.5
var SPRINT_SPEED = 34.75/13.0
@export var JUMP_VELOCITY = 130.0
@export var WALL_JUMP_VELOCITY = 12.0
@export var WALL_JUMP_COUNTER = 4
var STAMINA = 100.0
@export var MOUSE_SENSITIVITY = 0.005
@export var MAX_STAMINA = 100.0
var MOVE_SPEED = 6.5
var CONCENTRATION = 0.0
@export var MAX_CONCENTRATION = 100.0
@export var STAMINA_REGEN_COOLDOWN = 1.0
@export var STAMINA_REGEN_COOLDOWN_MAX = 1.0
var HP = 100.0
@export var MAX_HP = 100.0
var MAX_OVERHEAL = 2.0 * MAX_HP
var WEAPON = 1
var BOOST_DURATION = 0.0
var db_firemode = 0
var revAMMO = 6
var shotAMMO = 3
var SCORE = 0
var STYLE = 0.0
var STYLE_TIMEOUT = 0.0
var COMBO = 0
var speedCashout = false
var topSpeedChecker = false
var amount_rotated = 0.0
var shotgun_damage
var is_sliding = false
var is_slamming = false
var slam_hit = false
var jump_add = true
var melee_charge = 0.0
var melee_is_charged = false
var damage_since_last_shotgun_reload = 0.0
var dead: bool = false
@onready var neck := $CameraRoot as Node3D
@onready var cam := $CameraRoot/Camera3D as Camera3D
@onready var revolverAnim := $CameraRoot/Camera3D/plchld_revolver_better/AnimationPlayer as AnimationPlayer
@onready var doublebarrelAnim := $CameraRoot/Camera3D/double_shotty/AnimationPlayer as AnimationPlayer
@onready var shottyAnim := $CameraRoot/Camera3D/new_shotgun/AnimationPlayer as AnimationPlayer
@onready var raycast_r := $CameraRoot/Camera3D/hitscan_01 as RayCast3D
@onready var raycast_db_u := $CameraRoot/Camera3D/hitscan_06 as RayCast3D
@onready var raycast_db_l := $CameraRoot/Camera3D/hitscan_07 as RayCast3D
@onready var raycast_melee := $CameraRoot/Camera3D/hitscan_08 as RayCast3D
@onready var raycastEnd_r := $CameraRoot/Camera3D/hitscan_01/hitscan_end as Node3D
@onready var raycastEnd_db_u := $CameraRoot/Camera3D/hitscan_06/hitscan_end as Node3D
@onready var raycastEnd_db_l := $CameraRoot/Camera3D/hitscan_07/hitscan_end as Node3D
@onready var cross_c := $CameraRoot/Camera3D/hitscan_01/crossover_checkas as RayCast3D
@onready var stepsound := $walk_sound as AudioStreamPlayer3D
@onready var gun1 := $CameraRoot/Camera3D/plchld_revolver_better
@onready var gun2 := $CameraRoot/Camera3D/double_shotty
@onready var gun3 := $CameraRoot/Camera3D/new_shotgun
@onready var ch := $CameraRoot2D/ui_container_center/crosshair
@onready var cam_d := $CameraRoot/Camera3D/cam_direction as Node3D
@onready var melee_area = $CameraRoot/Camera3D/melee_area as Area3D

@onready var pop_up_text = $CameraRoot2D/pop_up_container/pop_up_text as Label

# bullet variables
var instanceBullet_s
#@onready var bl := %CameraRoot2D/ui_container_topright/BonusesLabel
@onready var cl := %ComboLabel

#CAM BOBBING FUNCTION WOOO
@export var BOB_FREQUENCY = 1.5
const BOB_AMPLITUDE = 0.08
var t_bob = 0.0

@onready var revolverBarrel := $CameraRoot/Camera3D/plchld_revolver_better/BarrelEnd as Node3D
@onready var dbBarrel_u := $CameraRoot/Camera3D/double_shotty/Armature/Skeleton3D/Cylinder_001/Cylinder_001/upper_barrel_end as Node3D
@onready var dbBarrel_l := $CameraRoot/Camera3D/double_shotty/Armature/Skeleton3D/Cylinder_001/Cylinder_001/lower_barrel_end as Node3D
@onready var rsBarrel := $CameraRoot/Camera3D/new_shotgun/Cube_002/barrel_end as Node3D

var proyectile #on ready for non hitscan weapons
var bulletTrail = load("res://scenes/bullet_trail.tscn")
var instanceRaycast
var bullet_decal = load("res://scenes/bullet_hole.tscn")

const BASE_FOV = 100 #base camera has 100° FOV
const FOV_MULTIPLIER = 1.01

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func hitstop_standard(legnth):
	if legnth >= 0.25:
		$hitstop_sound.play()
	Engine.time_scale = 0
	await get_tree().create_timer(legnth, true, false, true).timeout
	Engine.time_scale = 1

func _unhandled_input(event): # Window Activity and Camera Movement
	if event.is_action_pressed("ui_cancel"): # ui_cancel = esc key
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var time_s = Engine.time_scale
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * MOUSE_SENSITIVITY * time_s)
			if not is_on_floor():
				amount_rotated += (event.relative.x * time_s) / 1260.0
			cam.rotate_x(-event.relative.y * MOUSE_SENSITIVITY * time_s)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _ready():
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
var just_landed: bool = false
func _physics_process(delta):
	var velocityClamped = clamp(velocity.length(), 0.0, SPRINT_SPEED * MOVE_SPEED * 100000)
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		is_sliding = false
		just_landed = true
		if Input.is_action_just_pressed("slide"):
			ground_slam()
		if raycast_melee.is_colliding() and Input.is_action_just_pressed("melee") and WALL_JUMP_COUNTER > 0 and !raycast_melee.get_collider().is_in_group("enemies") and velocity.normalized().dot(raycast_melee.get_collision_normal()) <= 0.0 and raycast_melee.get_collision_normal().y < 0.55 and raycast_melee.get_collision_normal().y > -0.45 and velocity.x + velocity.z != 0.0:
			velocity = velocity.bounce(raycast_melee.get_collision_normal())
			velocity.y += 3.25
			WALL_JUMP_COUNTER -= 1
	# UI
	$CameraRoot2D/ui_container_bottomleft/StaminaLabel.text = "STAMINA: " + str(int(STAMINA))
	$CameraRoot2D/ui_container_bottomleft/HPLabel.text = "HP: " + str(int(HP))

	if is_on_floor():
		if amount_rotated != 0.0:
			reset_rotation_counter()
		WALL_JUMP_COUNTER = 4
		is_slamming = false
		if Input.is_action_just_pressed("jump"):
			if is_sliding == false and !jump_add:
				velocity.y += 6.5
			if is_sliding == true and STAMINA >= 20.0:
				velocity.y = 6.5
				STAMINA -= 20.0
		if Input.is_action_pressed("jump"):
			if is_sliding == false:
				velocity.y += 6.5
				if jump_add:
					velocity.y += 13
		if just_landed:
			reset_jump()
			just_landed = false
			
	if Engine.time_scale != 0.0:
		if is_sliding == true or $CollisionShape3D2/RayCast3D.is_colliding():
			cam.set_position(Vector3(0, -0.631, 0))
			$CollisionShape3D.disabled = true
			$CollisionShape3D2.disabled = false
		else:
			cam.set_position(Vector3(0, 0.631, 0))
			$CollisionShape3D.disabled = false
			$CollisionShape3D2.disabled = true

		#STAMINA
		if not Input.is_action_pressed("sprint") && STAMINA_REGEN_COOLDOWN == STAMINA_REGEN_COOLDOWN_MAX && STAMINA < MAX_STAMINA && is_on_floor():
			STAMINA = STAMINA + 0.75
		if STAMINA > MAX_STAMINA:
			STAMINA = MAX_STAMINA
		if STAMINA_REGEN_COOLDOWN < STAMINA_REGEN_COOLDOWN_MAX && not Input.is_action_pressed("sprint"):
			STAMINA_REGEN_COOLDOWN = STAMINA_REGEN_COOLDOWN + 0.025
		if Input.is_action_pressed("sprint") or not is_on_floor() or is_sliding == true or is_slamming == true:
			STAMINA_REGEN_COOLDOWN = 0
		if STAMINA_REGEN_COOLDOWN > STAMINA_REGEN_COOLDOWN_MAX:
			STAMINA_REGEN_COOLDOWN = STAMINA_REGEN_COOLDOWN_MAX
		
		
		if BOOST_DURATION == 0.0:
			SPEED_BOOST = 1.0
			
		if BOOST_DURATION > 0.0:
			BOOST_DURATION = BOOST_DURATION - 0.01
			
		if BOOST_DURATION < 0.0:
			BOOST_DURATION = 0.0
	
	if is_sliding == true and velocityClamped <= MOVE_SPEED:
		is_sliding = false
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBack")
	if is_sliding == false and is_slamming == false:
		var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if is_sliding == false and is_on_floor() and Input.is_action_just_pressed("slide") and STAMINA >= 20.0:
			initiate_slide(direction)
		if direction:
			if is_sliding == false:
				if is_on_floor():
					
					#if stepsound.playing == false and (velocity.x != 0 or velocity.z != 0):
						#stepsound.pitch_scale = velocityClamped/10
						#stepsound.play()
					if Input.is_action_pressed("sprint") and STAMINA > 0: #and abs(velocity) <= abs(direction * (SPRINT_SPEED * (MOVE_SPEED * SPEED_BOOST))) + Vector3(1,0,1):
						velocity.x = lerp(velocity.x, direction.x * (SPRINT_SPEED * (MOVE_SPEED * SPEED_BOOST)), delta * 3.5)
						velocity.z = lerp(velocity.z, direction.z * (SPRINT_SPEED * (MOVE_SPEED * SPEED_BOOST)), delta * 3.5)
						#velocity += (direction * (SPRINT_SPEED * (MOVE_SPEED * SPEED_BOOST)))/3.5
						STAMINA = STAMINA - 0.5
					else: #abs(velocity) <= abs(direction * (MOVE_SPEED * SPEED_BOOST)) + Vector3(1,0,1):
						velocity.x = lerp(velocity.x, direction.x * (MOVE_SPEED * SPEED_BOOST), delta * 7.0)
						velocity.z = lerp(velocity.z, direction.z * (MOVE_SPEED * SPEED_BOOST), delta * 7.0)
						#velocity += (direction * (MOVE_SPEED * SPEED_BOOST))/7.0
				else: #abs(velocity) <= abs(direction * (MOVE_SPEED * SPEED_BOOST) * 2) + Vector3(1,0,1):
					velocity.x = lerp(velocity.x, direction.x * (MOVE_SPEED * SPEED_BOOST) * 2, delta * 2.25)
					velocity.z = lerp(velocity.z, direction.z * (MOVE_SPEED * SPEED_BOOST) * 2, delta * 2.25)
					#velocity += (direction * (MOVE_SPEED * SPEED_BOOST) * 2)/2.25
				
		else:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, 0.35)
				velocity.z = move_toward(velocity.z, 0, 0.35)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, 0.25)
			velocity.z = move_toward(velocity.z, 0, 0.25)
	
	#headbob
	if is_sliding == false:
		t_bob += delta * velocity.length() * float(is_on_floor())
		cam.transform.origin = headbob(t_bob)
		$CollisionShape3D.shape.height = 2
	
	#weapon handling
	if WEAPON > 3:
		WEAPON = 1
	if WEAPON < 1:
		WEAPON = 3
	if Input.is_action_just_pressed("weaponScrollUp"):
		WEAPON = WEAPON - 1
	if Input.is_action_just_pressed("weaponScrollDown"):
		WEAPON = WEAPON + 1
	if revAMMO == 0:
		reload_revolver()
	if shotAMMO == 0:
		reload_revshotgun()
	if WEAPON == 1:
		ch.frame = 0
		gun1.visible = true
		gun2.visible = false
		gun3.visible = false
	elif WEAPON == 2:
		ch.frame = 1
		gun1.visible = false
		gun2.visible = true
		gun3.visible = false
	elif WEAPON == 3:
		ch.frame = 5
		gun1.visible = false
		gun2.visible = false
		gun3.visible = true
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if WEAPON == 1:
			shoot_revolver()
			revolver_special()
		if WEAPON == 2:
			shoot_doublebarrel()
			dbshotgun_switch()
		if WEAPON == 3:
			shoot_revshotgun()
		if Input.is_action_pressed("secondaryFire") and WEAPON == 3 and shotAMMO != 5:
			reload_revshotgun()
		if Input.is_action_pressed("tertiaryFire"):
			#hitstop_standard()
			pass
		if Input.is_action_just_pressed("melee"):
			for obj in melee_area.get_overlapping_bodies():
				if obj.is_in_group("enemies"):
					obj.get_hit(0.25)
					obj.parry()
				if obj.is_in_group("projectiles"):
					if obj.is_parryable:
						obj.change_direction((cam.global_position - cam_d.global_position).normalized() * -1, 20, false, true)
						hitstop_standard(0.25)
						stylebonus_parry()
		if Input.is_action_pressed("melee"):
			melee_charge_punch()
		if Input.is_action_just_released("melee"):
			melee_charge = 0.0
			already_punched = false
		
	#FOV
	

	var targetFov = BASE_FOV + (FOV_MULTIPLIER * velocityClamped * 0.75)
	cam.fov = lerp(cam.fov, targetFov, delta * 8)
	
	move_and_slide()
	
	if Engine.time_scale != 0.0:
	#concentration
		if CONCENTRATION > MAX_CONCENTRATION:
			CONCENTRATION = MAX_CONCENTRATION
		if CONCENTRATION < 0.0:
			CONCENTRATION = 0.0
		$CameraRoot2D/ui_container_bottomleft/ConcentrationLabel.text = str(int(CONCENTRATION))
		
		#style
		if STYLE_TIMEOUT < 0:
			STYLE_TIMEOUT = 0
			
		if STYLE_TIMEOUT > 0:
			STYLE_TIMEOUT = STYLE_TIMEOUT - 0.1
		
		if STYLE_TIMEOUT == 0:
			SCORE = SCORE + int(STYLE * COMBO)
			CONCENTRATION += (STYLE / 10.0)
			STYLE = 0
			COMBO = 0
	
	if Input.is_action_just_pressed("heal") and CONCENTRATION >= 50:
		heal()
	
	$CameraRoot2D/ui_container_topright/StyleLabel.text = "STYLE: " + str(int(STYLE))
	$CameraRoot2D/ui_container_topleft/ScoreLabel.text = str(SCORE)
	if COMBO >= 2:
		cl.visible = true
	else:
		cl.visible = false
	cl.text = "COMBO x" + str(COMBO)
	
	stylebonus_speed()
	
	if is_slamming == false:
		$Area3D/CollisionShape3D.set_disabled(true)
	if is_slamming == true:
		$Area3D/CollisionShape3D.set_disabled(false)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and !dead:
		$CameraRoot2D/menu_container.visible = false
	elif !dead:
		$CameraRoot2D/menu_container.visible = true
		Engine.time_scale = 0
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$CameraRoot2D/death_screen.visible = true
		$CameraRoot2D/menu_container.visible = false
		Engine.time_scale = 0
	
	if HP <= 0:
		die()
var already_punched = false
func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQUENCY) * BOB_AMPLITUDE
	pos.x = cos(time * BOB_FREQUENCY / 2) * BOB_AMPLITUDE
	return pos

func shoot_revolver():
	if Input.is_action_pressed("primaryFire"):
		if revAMMO != 0:
			if !revolverAnim.is_playing():
				revolverAnim.play("recoil")
				hitscan(raycast_r, revolverBarrel, raycastEnd_r, 1.0, true, false, false)
				revAMMO -= 1
func reload_revolver():
	if !revolverAnim.is_playing():
		var time = revAMMO
		revAMMO = 0
		await get_tree().create_timer((time + 1) / 3.0).timeout
		revAMMO = 6
var RSp_charge = 0.0
var ricochet = load("res://scenes/ricochet.tscn")
func revolver_special():
	if !revolverAnim.is_playing():
		if Input.is_action_pressed("secondaryFire") and RSp_charge < 4.5:
			RSp_charge += 0.1
		if Input.is_action_just_released("secondaryFire"):
			if 3.0 < RSp_charge and RSp_charge < 4.0:
				revolverAnim.play("recoil")
				hitscan(raycast_r, revolverBarrel, raycastEnd_r, revAMMO, true, false, false)
				if raycast_r.is_colliding():
					if raycast_r.get_collider().is_in_group("enemies"):
						var load_ricochet = ricochet.instantiate()
						load_ricochet.create(raycast_r, raycast_r.get_collider(), revAMMO - 1)
						load_ricochet.position = raycast_r.get_collider().global_position
						get_parent().add_child(load_ricochet)
					else:
						var load_ricochet = ricochet.instantiate()
						load_ricochet.create(raycast_r, null, revAMMO - 1)
						load_ricochet.position = raycast_r.get_collision_point()
						get_parent().add_child(load_ricochet)
			reload_revolver()
			RSp_charge = 0
		%SpeedLabel.text = str(RSp_charge)
#behold, the folly of man.
func shoot_doublebarrel():
	if Input.is_action_pressed("primaryFire"):
		if !doublebarrelAnim.is_playing():
			doublebarrelAnim.play("recoil and reload")
			if db_firemode == 0:
				var basis_x = cam.rotation_degrees.x
				var vector_y = (-1 * (basis_x * (10.0 / 9.0))) / 100.0
				var vector_z = abs((((abs(basis_x)) * (10.0 / 9.0)) / 100.0) - 1)
				var gun_direction = neck.transform.basis * Vector3(0,vector_y,vector_z)
				var newvelocity = lerp(velocity, gun_direction * 13, 1)
				velocity += newvelocity
				shotgun_spread(raycast_db_u, dbBarrel_u, raycastEnd_db_u, 0.25, false, false)
				await get_tree().create_timer(0.007).timeout
				shotgun_spread(raycast_db_l, dbBarrel_l, raycastEnd_db_l, 0.25, false, false)
			else:
				if cross_c.is_colliding() and cross_c.get_collider().is_in_group("enemies"):
					hitstop_standard(0.15)
					cross_c.get_collider().get_hit(1.0)
				hitscan(raycast_db_u, dbBarrel_u, raycastEnd_db_u, 0.5, true, true, false)
				hitscan(raycast_db_l, dbBarrel_l, raycastEnd_db_l, 0.5, true, true, false)
func dbshotgun_switch():
	if Input.is_action_pressed("secondaryFire"):
		if !doublebarrelAnim.is_playing():
			doublebarrelAnim.play("reload")
			if db_firemode == 0:
				db_firemode = 1
			else:
				db_firemode = 0
				
func shoot_revshotgun():
	if Input.is_action_pressed("primaryFire"):
		if shotAMMO != 0:
			if !shottyAnim.is_playing():
				shottyAnim.play("recoil")
				shotAMMO = shotAMMO - 1
				if shotAMMO != 2:
					hitscan(raycast_r, rsBarrel, raycastEnd_r, 2.0 + abs(amount_rotated), true, true, true)
				else:
					shotgun_spread(raycast_r, rsBarrel, raycastEnd_r, 0.25, false, true)
func reload_revshotgun():
	if !shottyAnim.is_playing():
		shottyAnim.play("reload")
		if shotAMMO > 0 and damage_since_last_shotgun_reload > 0.0:
			var basis_x = cam.rotation_degrees.x
			var vector_y = (-1 * (basis_x * (10.0 / 9.0))) / 100.0
			var vector_z = abs((((abs(basis_x)) * (10.0 / 9.0)) / 100.0) - 1)
			var gun_direction = neck.transform.basis * Vector3(0,vector_y * -1,vector_z * -1)
			velocity = gun_direction * damage_since_last_shotgun_reload * 7.5
		shotAMMO = 3
		damage_since_last_shotgun_reload = 0.0
		

#style
func style_timeout():
	STYLE_TIMEOUT = STYLE_TIMEOUT + (20.0 / (COMBO))
func stylebonus_speed():
	var velocityClamped = clamp(velocity.length(), 0.0, SPRINT_SPEED * MOVE_SPEED * 100000)
	if velocityClamped >= 40 and topSpeedChecker == false: # djh
		speedCashout = true # hg
	if speedCashout == true:
		STYLE += 100 # Same thing as STYLE = STYLE + 100 but shorter lmao
		COMBO += 1 # Same thing as above
		style_timeout()
		#bl.text = str(bl.text) + ("+ SPEED DEMON")
		topSpeedChecker = true
		speedCashout = false
	if velocityClamped < 30:
		topSpeedChecker = false
func stylebonus_360():
	STYLE += 250
	COMBO += 1
	style_timeout()
func stylebonus_splat():
	STYLE += 100
	COMBO += 1
	style_timeout()
func stylebonus_parry():
	STYLE += 250
	COMBO += 1
	style_timeout()

func get_hit_p(damage):
	HP -= damage
	
func reset_rotation_counter():
	await get_tree().create_timer(0.25).timeout
	amount_rotated = 0.0

func hitscan(raycast, barrel, raycast_end, damage: float, draw_tracer: bool, destroy_projectiles: bool, record_damage: bool):
	instanceRaycast = bulletTrail.instantiate()
	var bullet_hole = bullet_decal.instantiate()
	if raycast.is_colliding():
		if draw_tracer == true:
			instanceRaycast.init(barrel.global_position, raycast.get_collision_point())
		if raycast.get_collider().is_in_group("enemies"):
			raycast.get_collider().get_hit(damage)
			if record_damage:
				damage_since_last_shotgun_reload += damage
		if raycast.get_collider().is_in_group("projectiles") and destroy_projectiles:
			raycast.get_collider().explode()
		if !raycast.get_collider().is_in_group("enemies") and !raycast.get_collider().is_in_group("projectiles"):
			instanceRaycast.trigger_particle(raycast.get_collision_point(), barrel.global_position)
			bullet_hole.position = raycast.get_collision_point()
			if raycast.get_collision_normal() != Vector3.UP and raycast.get_collision_normal() != Vector3.DOWN:
				bullet_hole.set_rotation_degrees(raycast.get_collision_normal() * 180)
	elif draw_tracer == true:
		instanceRaycast.init(barrel.global_position, raycast_end.global_position)
	get_parent().add_child(instanceRaycast)
	get_parent().add_child(bullet_hole)

func initiate_slide(direction):
	if direction != Vector3(0,0,0):
		is_sliding = true
		var new_velocity = direction * (17.0 * SPEED_BOOST)
		velocity.x += new_velocity.x
		velocity.z += new_velocity.z
		STAMINA -= 20.0

func shotgun_spread(raycast, barrel, raycast_end, damage, draw_tracer, record_damage):
	raycast.set_rotation_degrees(Vector3(3,0,0))
	hitscan(raycast, barrel, raycast_end, damage, draw_tracer, false, record_damage)
	await get_tree().create_timer(0.0001).timeout
	raycast.set_rotation_degrees(Vector3(-3,0,0))
	hitscan(raycast, barrel, raycast_end, damage, draw_tracer, false, record_damage)
	await get_tree().create_timer(0.0001).timeout
	raycast.set_rotation_degrees(Vector3(0,3,0))
	hitscan(raycast, barrel, raycast_end, damage, draw_tracer, false, record_damage)
	await get_tree().create_timer(0.0001).timeout
	raycast.set_rotation_degrees(Vector3(0,-3,0))
	hitscan(raycast, barrel, raycast_end, damage, draw_tracer, false, record_damage)
	await get_tree().create_timer(0.0001).timeout
	raycast.set_rotation_degrees(Vector3(2,2,0))
	hitscan(raycast, barrel, raycast_end, damage, draw_tracer, false, record_damage)
	await get_tree().create_timer(0.0001).timeout
	raycast.set_rotation_degrees(Vector3(2,-2,0))
	hitscan(raycast, barrel, raycast_end, damage, draw_tracer, false, record_damage)
	await get_tree().create_timer(0.0001).timeout
	raycast.set_rotation_degrees(Vector3(-2,2,0))
	hitscan(raycast, barrel, raycast_end, damage, draw_tracer, false, record_damage)
	await get_tree().create_timer(0.0001).timeout
	raycast.set_rotation_degrees(Vector3(-2,-2,0))
	hitscan(raycast, barrel, raycast_end, damage, draw_tracer, false, record_damage)
	await get_tree().create_timer(0.0001).timeout
	raycast.set_rotation_degrees(Vector3(0,0,0))
	hitscan(raycast, barrel, raycast_end, damage, draw_tracer, false, record_damage)


func _on_area_3d_body_entered(body):
	if body.is_in_group("enemies") and is_slamming == true:
		body.get_launched_by_slam()

func ground_slam():
	if STAMINA >= 20.0:
		is_slamming = true
		slam_hit = true
		jump_add = true
		velocity.y -= 20.0
		velocity.x = 0.0
		velocity.z = 0.0
		STAMINA -= 20.0

func reset_jump():
	await get_tree().create_timer(1.5).timeout
	jump_add = false

func heal():
	await get_tree().create_timer(1).timeout
	if Input.is_action_pressed("heal") and CONCENTRATION >= 50:
		HP += 25.0
		CONCENTRATION -= 50.0

func melee_charge_punch():
	if !already_punched:
		melee_charge += 0.05
		if melee_charge > 1.0 and melee_is_charged == false:
			HP -= 25.0
			melee_is_charged = true
		if melee_is_charged == true:
			for obj in melee_area.get_overlapping_bodies():
				if obj.is_in_group("enemies"):
					obj.get_hit(0.5)
					var direction = (cam.global_position - cam_d.global_position).normalized() * -1
					obj.get_launched_by_punch(direction)
					obj.parry()
					HP += 25.0
				if obj.is_in_group("projectiles"):
					if obj.is_parryable:
						obj.change_direction((cam.global_position - cam_d.global_position).normalized() * -1, 40, true, true)
						hitstop_standard(0.35)
						HP += 25.0
						stylebonus_parry()
			melee_is_charged = false
			melee_charge = 0.0
			already_punched = true

func _on_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Engine.time_scale = 1
var main_menu = load("res://scenes/menus/main_menu.tscn") as PackedScene
func _on_button_2_pressed():
	get_tree().change_scene_to_packed(main_menu)

func die():
	dead = true

func _on_menu_button_pressed():
	get_tree().change_scene_to_packed(main_menu)
