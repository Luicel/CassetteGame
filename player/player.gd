extends CharacterBody2D

signal cassette_thrown

@onready var initial_position = global_position
@onready var cassette_pocket = $CassettePocket
@onready var sprite_2d = $Sprite2D
@onready var player_movement_state_machine = $PlayerMovementStateMachine
@onready var cassette_detector_area = $CassetteDetectorArea
@onready var coyote_time_timer = $CoyoteTimeTimer
@onready var wall_jump_timer = $WallJumpTimer
@onready var wall_grace_timer = $WallGraceTimer
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var just_swapped_verticality_timer = $JustSwappedVerticalityTimer
@onready var phantom_camera_2d = %PhantomCamera2D
@onready var wall_stick_timer = $WallStickTimer
@onready var collision_shape_2d = $CollisionShape2D

@export var initial_movement_state : PlayerMovementState
@export var camera_pivot : Vector2
@export_category("Player Movement")
@export var speed = 300.0
@export var jump_velocity = -400.0
@export var wall_jump_velocity = 800.0
@export_category("Player Physics Movement")
@export var gravity_scale = 1.0
@export var wall_slide_gravity_multiplier = 1.0
@export var acceleration = 0.0
@export var friction = 0.0
@export var air_acceleration = 0.0
@export var air_resistance = 0.0
@export_category("Player Air Dash Movement")
@export var air_dash_force = 0.0
@export var air_dash_resistance = 0.0
@export var air_dash_wait_time = 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_time_activated = false
var was_wall_normal = Vector2.ZERO
var previous_direction = 0.0
var can_air_dash = true
var checkpoint : Checkpoint
var additional_velocity = Vector2.ZERO
var added_platform_velocity = Vector2.ZERO

var current_movement_state : PlayerMovementState
var movement_states : Dictionary = {}


func _ready():
	# Initalize movement states.
	for child in player_movement_state_machine.get_children():
		if child is PlayerMovementState:
			movement_states[child.name.to_lower()] = child
	
	# If a configured initial movement state is valid, call its enter function.
	if initial_movement_state:
		initial_movement_state.enter()
		current_movement_state = initial_movement_state
	
	# Set PhantomCamera2D target offset to match configured pivot.
	phantom_camera_2d._camera_offset = camera_pivot


func _process(delta):
	# Call update function on current movement state.
	if current_movement_state:
		current_movement_state.update(delta)
	
	# If on floor and can't air dash, enable air dash.
	if is_on_floor() and not can_air_dash:
		can_air_dash = true
		gravity_scale = 1.0
	
	# If cassette pocket is empty, check if player is colliding with a cassette.
	if not cassette_pocket.pocketed_cassette:
		detect_overlapping_colliders()
	
	# Attempt to recharge all blue cassettes.
	try_to_recharge_blue_cassettes()
	
	# Reload the scene upon appropriate input.
	if Input.is_action_just_pressed("reset_level"):
		LevelManager.reload_level()


func _physics_process(delta):
	# Check and cache physics states prior to processing physics movement.
	var was_on_wall = is_on_wall_only()
	if was_on_wall:
		was_wall_normal = get_wall_normal()
	var was_on_floor = is_on_floor()
	
	# Process physics movement.
	if current_movement_state:
		current_movement_state.physics_update(delta)
	
	# Compare current and cached physics states and act accordingly. 
	if was_on_wall and not is_on_wall():
		wall_grace_timer.start()
	if not was_on_wall and is_on_wall():
		wall_stick_timer.start()
	if was_on_floor != is_on_floor():
		pass
	
	# If player is on floor after a delay of swapping verticality, update camera pivot.
	if is_on_floor() and just_swapped_verticality_timer.time_left == 0:
		handle_camera_pivot()


func handle_camera_pivot():
	var multiplier = 1 if up_direction == Vector2.UP else -1
	phantom_camera_2d.set_follow_target_offset(camera_pivot * multiplier)


func transition_to_movement_state(new_movement_state_name):
	var new_movement_state = movement_states.get(new_movement_state_name.to_lower())
	if not new_movement_state: return
	if current_movement_state == new_movement_state: return
	
	if current_movement_state:
		current_movement_state.exit()
	
	new_movement_state.enter()
	
	current_movement_state = new_movement_state


func handle_horizontal_movement(delta):
	# Calculate horizontal input direction.
	var direction = Input.get_axis("left", "right")
	if not direction and not velocity: return
	
	# If direction is different than before, change previous_direction.
	if direction > 0 and velocity.x > 0 or direction < 0 and velocity.x < 0:
		previous_direction = direction
	
	# Stop player at camera bounds. Else, execute horizontal movement physics calculations.
	if direction <= 0 and global_position.x <= get_viewport().get_camera_2d().limit_left:
		velocity.x = 0
	elif direction >= 0 and global_position.x >= get_viewport().get_camera_2d().limit_right:
		velocity.x = 0
	else:
		# Handle horizontal movement physics calculations.
		apply_acceleration(direction, delta)
		apply_friction(direction, delta)
		apply_air_acceleration(direction, delta)
		apply_air_resistance(direction, delta)


func apply_acceleration(direction, delta):
	if not is_on_floor(): return
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)


func apply_friction(direction, delta):
	if direction and direction != previous_direction and is_on_floor():
		previous_direction = direction
		velocity.x = move_toward(velocity.x, 0, friction * delta * 5)
	elif not direction and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)


func apply_air_acceleration(direction, delta):
	if is_on_floor(): return
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, air_acceleration * delta)


func apply_air_resistance(direction, delta):
	if not direction and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_resistance * delta)


func handle_jump(flipped = false):
	if not is_on_floor() and not coyote_time_activated:
		coyote_time_activated = true
		coyote_time_timer.start()
	elif is_on_floor():
		coyote_time_activated = false
	
	if Input.is_action_just_pressed("jump") or jump_buffer_timer.time_left > 0:
		if jump_buffer_timer.time_left == 0: jump_buffer_timer.start()
		if is_on_floor() or coyote_time_timer.time_left > 0.0:
			coyote_time_activated = true
			if not flipped:
				velocity.y = jump_velocity
			else:
				velocity.y = -jump_velocity
	if Input.is_action_just_released("jump") and not is_on_floor():
		if not flipped:
			if velocity.y <= jump_velocity / 2.0:
				velocity.y = jump_velocity / 2.0
		else:
			if velocity.y >= -jump_velocity / 2.0:
				velocity.y = -jump_velocity / 2.0


func handle_wall_jump(flipped = false):
	if Input.is_action_just_pressed("jump") and (is_on_wall_only() or wall_grace_timer.time_left > 0):
		var wall_normal = was_wall_normal if wall_grace_timer.time_left > 0 else get_wall_normal()
		velocity.x = wall_normal.x * wall_jump_velocity
		if not flipped:
			velocity.y = jump_velocity
		else:
			velocity.y = -jump_velocity
		#wall_jump_timer.start()


func apply_gravity(delta, flipped = false):
	#if wall_stick_timer.time_left > 0:
	#	velocity.y = 0
	if is_player_against_wall() and not flipped and velocity.y > 0:
		velocity.y += (gravity * wall_slide_gravity_multiplier) * gravity_scale * delta
	elif is_player_against_wall() and flipped and velocity.y < 0:
		velocity.y -= (gravity * wall_slide_gravity_multiplier) * gravity_scale * delta
	elif not is_on_floor():
		if not flipped:
			velocity.y += gravity * delta * gravity_scale
		else:
			velocity.y += gravity * delta * gravity_scale * -1.0


func is_player_against_wall():
	if is_on_wall_only() and get_wall_normal() == Vector2.LEFT and Input.is_action_pressed("right"):
		return true
	elif is_on_wall_only() and get_wall_normal() == Vector2.RIGHT and Input.is_action_pressed("left"):
		return true
	else:
		return false


func respawn_cassette():
	if not cassette_pocket.pocketed_cassette: return
	
	cassette_pocket.pocketed_cassette._disable_effect()
	cassette_pocket.pocketed_cassette.call_deferred("reparent", get_tree().root.get_child(0))
	cassette_pocket.pocketed_cassette.set_deferred("freeze", false)
	cassette_pocket.pocketed_cassette.respawn()
	
	cassette_pocket.remove_pocketed_cassette()
	


func detect_overlapping_colliders():
	for body in cassette_detector_area.get_overlapping_bodies():
		if body.is_in_group("cassette"):
			_on_cassette_detector_area_body_entered(body)


func _on_cassette_detector_area_body_entered(body):
	var previous_socket = body.get_parent()
	var success = cassette_pocket.try_to_pocket_cassette(body)
	if success:
		body._enable_effect()
		if previous_socket is CassettePocket:
			previous_socket.remove_pocketed_cassette()
		return


func respawn():
	respawn_cassette()
	for cassette in get_tree().get_nodes_in_group("cassette"):
		cassette.respawn()
	
	if checkpoint:
		global_position = checkpoint.respawn_point.global_position
	else:
		global_position = initial_position
	
	phantom_camera_2d.global_position = global_position + camera_pivot


func try_to_recharge_blue_cassettes():
	if not is_on_floor(): return
	
	for cassette in get_tree().get_nodes_in_group("cassette"):
		if cassette is BlueCassette:
			cassette.set_charged(true)
