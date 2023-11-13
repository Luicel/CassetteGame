extends CharacterBody2D

signal cassette_thrown

@onready var cassette_pocket = $CassettePocket
@onready var sprite_2d = $Sprite2D
@onready var player_movement_state_machine = $PlayerMovementStateMachine
@onready var cassette_detector_area = $CassetteDetectorArea
@onready var coyote_time_timer = $CoyoteTimeTimer
@onready var wall_jump_timer = $WallJumpTimer
@onready var wall_grace_timer = $WallGraceTimer

@export var initial_movement_state : PlayerMovementState
@export_category("Player Movement")
@export var speed = 300.0
@export var jump_velocity = -400.0
@export var wall_jump_velocity = 800.0
@export_category("Player Physics Movement")
@export var gravity_scale = 1.0
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
var current_movement_state : PlayerMovementState
var movement_states : Dictionary = {}


func _ready():
	for child in player_movement_state_machine.get_children():
		if child is PlayerMovementState:
			movement_states[child.name.to_lower()] = child
	
	if initial_movement_state:
		initial_movement_state.enter()
		current_movement_state = initial_movement_state


func _process(delta):
	if current_movement_state:
		current_movement_state.update(delta)
	
	if is_on_floor() and not can_air_dash:
		can_air_dash = true
		gravity_scale = 1.0
	
	if not cassette_pocket.pocketed_cassette:
		detect_overlapping_colliders()


func _physics_process(delta):
	var was_on_wall = is_on_wall_only()
	if was_on_wall:
		was_wall_normal = get_wall_normal()
	
	if current_movement_state:
		current_movement_state.physics_update(delta)
	
	if was_on_wall and not is_on_wall():
		wall_grace_timer.start()
	
	if Input.is_action_just_pressed("throw"):
		throw_cassette()


func transition_to_movement_state(new_movement_state_name):
	var new_movement_state = movement_states.get(new_movement_state_name.to_lower())
	if not new_movement_state: return
	if current_movement_state == new_movement_state: return
	
	if current_movement_state:
		current_movement_state.exit()
	
	new_movement_state.enter()
	
	current_movement_state = new_movement_state


func _on_cassette_detector_area_body_entered(body):
	var success = cassette_pocket.try_to_pocket_cassette(body)
	if success: body._enable_effect()


func handle_horizontal_movement(delta):
	#if wall_jump_timer.time_left > 0.0 and not is_on_floor(): return
	
	var direction = Input.get_axis("left", "right")
	
	if direction > 0 and velocity.x > 0 or direction < 0 and velocity.x < 0:
		previous_direction = direction
	
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
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_time_timer.time_left > 0.0:
			coyote_time_activated = true
			if not flipped:
				velocity.y = jump_velocity
			else:
				velocity.y = -jump_velocity
	elif Input.is_action_just_released("jump") and not is_on_floor():
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
	if not is_on_floor():
		if not flipped:
			velocity.y += gravity * delta * gravity_scale
		else:
			velocity.y += gravity * delta * gravity_scale * -1.0


func throw_cassette():
	if not cassette_pocket.pocketed_cassette: return
	
	var cassette = cassette_pocket.pocketed_cassette
	cassette.throw(previous_direction)
	cassette._disable_effect()
	cassette_pocket.remove_pocketed_cassette()


func detect_overlapping_colliders():
	for body in cassette_detector_area.get_overlapping_bodies():
		var success = cassette_pocket.try_to_pocket_cassette(body)
		if success:
			body._enable_effect()
			return
