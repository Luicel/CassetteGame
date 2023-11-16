@tool
extends AnimatableBody2D

@export_category("General Movement")
@export var active = true
@export var start_position_offset : Vector2
@export var end_position_offset : Vector2
@export_category("Forward Movement")
@export var forward_speed : float
@export var forward_stall_time : float
@export var forward_requires_player_detection = false
@export_category("Backward Movement")
@export var backward_speed : float
@export var backward_stall_time : float
@export var backward_requires_player_detection = false

@onready var path_2d = $Path2D
@onready var stall_timer = $StallTimer
@onready var player = get_tree().get_first_node_in_group("player")
@onready var previous_position = position
@onready var start_position = global_position + start_position_offset
@onready var end_position = global_position + end_position_offset

var is_moving_forward = true
var is_player_colliding = false
var direction = Vector2.ZERO


func _ready():
	if not Engine.is_editor_hint():
		
		_update_path_2d()
		_start_stall_timer(forward_stall_time)


func _process(delta):
	if Engine.is_editor_hint():
		_update_path_2d()


func _physics_process(delta):
	if not Engine.is_editor_hint():
		constant_linear_velocity = (position - previous_position) / delta
		_handle_movement(delta)
		previous_position = position


func _handle_movement(delta):
	if active && stall_timer.time_left == 0:
		if is_moving_forward:
			if position == end_position:
				is_moving_forward = false
				_start_stall_timer(backward_stall_time)
			else:
				position = position.move_toward(end_position, forward_speed * delta)
		else:
			if position == start_position:
				is_moving_forward = true
				_start_stall_timer(forward_stall_time)
			else:
				position = position.move_toward(start_position, backward_speed * delta)


func _start_stall_timer(seconds):
	stall_timer.wait_time = seconds
	stall_timer.start()


func _update_path_2d():
	if not path_2d: return
	
	path_2d.curve.clear_points()
	path_2d.curve.add_point(start_position_offset)
	path_2d.curve.add_point(end_position_offset)
