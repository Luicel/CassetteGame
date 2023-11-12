extends CharacterBody2D

signal cassette_thrown

@onready var cassette_pocket = $CassettePocket
@onready var sprite_2d = $Sprite2D
@onready var player_movement_state_machine = $PlayerMovementStateMachine

@export var initial_movement_state : PlayerMovementState

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var can_air_jump = true
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
	
	if is_on_floor() and not can_air_jump:
		can_air_jump = true


func _physics_process(delta):
	if current_movement_state:
		current_movement_state.physics_update(delta)
	
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


func handle_horizontal_movement():
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


func handle_jump(flipped = false):
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		if not flipped:
			velocity.y = JUMP_VELOCITY
		else:
			velocity.y = -JUMP_VELOCITY


func handle_air_jump():
	if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and can_air_jump:
		velocity.y = JUMP_VELOCITY * 1.5
		can_air_jump = false


func apply_gravity(delta, flipped = false):
	if not is_on_floor():
		if not flipped:
			velocity.y += gravity * delta
		else:
			velocity.y += gravity * delta * -1.0


func throw_cassette():
	if not cassette_pocket.pocketed_cassette: return
	
	var cassette = cassette_pocket.pocketed_cassette
	cassette.throw()
	cassette._disable_effect()
	cassette_pocket.remove_pocketed_cassette()
