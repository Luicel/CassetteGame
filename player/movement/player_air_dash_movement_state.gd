class_name PlayerAirDashMovementState extends PlayerMovementState

@onready var player = get_tree().get_first_node_in_group("player")
@onready var air_dash_timer = %AirDashTimer

var can_air_dash = true
var air_dash_velocity : Vector2
var active_blue_cassette : BaseCassette


func enter():
	active_blue_cassette = player.cassette_pocket.pocketed_cassette
	if not can_air_dash and active_blue_cassette.is_charged:
		can_air_dash = true


func physics_update(delta):
	if air_dash_timer.time_left == 0.0:
		if not _is_player_wall_jumping() and _did_player_input_successful_air_dash():
			can_air_dash = false
			handle_air_dash()
			return
		else:
			player.handle_horizontal_movement(delta)
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
		elif player.is_on_ceiling() or player.is_on_wall():
			air_dash_timer.stop()
			physics_update(delta) # Re-calculate physics update
		else:
			player.velocity = player.velocity.move_toward(Vector2.ZERO, player.air_dash_resistance * delta)
			pass
	
	player.move_and_slide()


func _is_player_wall_jumping():
	return player.is_on_wall_only() or player.wall_grace_timer.time_left > 0


func _did_player_input_successful_air_dash():
	return not player.is_on_floor() and Input.is_action_just_pressed("jump") and can_air_dash and air_dash_timer.time_left == 0.0


func execute_basics(delta):
	player.handle_horizontal_movement(delta)
	player.handle_jump()
	player.handle_wall_jump()
	player.apply_gravity(delta)


func handle_air_dash():
	air_dash_timer.start()
	await get_tree().create_timer(player.air_dash_wait_time).timeout
	
	var direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	if direction == Vector2.ZERO: direction = Vector2(player.previous_direction, 0)
	player.velocity = direction * player.air_dash_force
	active_blue_cassette.set_charged(false)
