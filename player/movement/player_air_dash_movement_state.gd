class_name PlayerAirDashMovementState extends PlayerMovementState

@onready var air_dash_timer = %AirDashTimer

var player : CharacterBody2D
var can_air_dash = true
var air_dash_velocity : Vector2


func enter():
	player = get_tree().get_first_node_in_group("player")


func physics_update(delta):
	if air_dash_timer.time_left == 0.0:
		if not player.is_on_floor() and Input.is_action_just_pressed("jump") and can_air_dash and air_dash_timer.time_left == 0.0:
			can_air_dash = false
			handle_air_dash()
			return
		else:
			player.handle_horizontal_movement()
			player.handle_jump()
			player.handle_wall_jump()
			player.apply_gravity(delta)
		
		if player.is_on_floor():
			can_air_dash = true
	else:
		if player.is_on_floor():
			can_air_dash = true
			air_dash_timer.stop()
			physics_update(delta) # Re-calculate physics update
		else:
			player.velocity = player.velocity.move_toward(Vector2.ZERO, player.air_dash_resistance)
			#print(player.velocity)
			pass
	
	player.move_and_slide()


func handle_air_dash():
	await get_tree().create_timer(player.air_dash_wait_time).timeout
	
	air_dash_timer.start()
	player.velocity = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized() * player.air_dash_force
