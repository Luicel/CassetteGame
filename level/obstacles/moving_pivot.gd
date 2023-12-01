@tool
class_name Moving extends Node2D

signal player_entered

@export_category("Activation")
@export var activation_cassette_pocket : CassettePocket
@export_category("Offsets")
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
@onready var previous_position = get_parent().position
@onready var start_position = get_parent().global_position + start_position_offset
@onready var end_position = get_parent().global_position + end_position_offset

var active = false
var is_moving_forward = true
var is_player_colliding = false
var direction = Vector2.ZERO


func _ready():
	if not Engine.is_editor_hint():
		_update_path_2d()
		
		if not forward_requires_player_detection and not activation_cassette_pocket:
			active = true
		
		if not forward_requires_player_detection:
			_start_stall_timer(forward_stall_time)
		
		if activation_cassette_pocket:
			activation_cassette_pocket.cassette_pocketed.connect(_on_activation_cassette_pocket_activation)
			activation_cassette_pocket.cassette_unpocketed.connect(_on_activation_cassette_pocket_deactivation)


func _process(delta):
	if Engine.is_editor_hint():
		_update_path_2d()


func _physics_process(delta):
	if not Engine.is_editor_hint():
		#constant_linear_velocity = (position - previous_position) / delta
		_handle_movement(delta)
		previous_position = get_parent().position


func _handle_movement(delta):
	if not active and (forward_requires_player_detection or backward_requires_player_detection):
		if is_player_colliding:
			if is_moving_forward and forward_requires_player_detection:
				_start_stall_timer(forward_stall_time)
			elif not is_moving_forward and backward_requires_player_detection:
				_start_stall_timer(backward_stall_time)
			active = true
	elif active and stall_timer.time_left == 0:
		if is_moving_forward:
			if get_parent().position == end_position:
				is_moving_forward = false
				if backward_requires_player_detection:
					active = false
				else:
					_start_stall_timer(backward_stall_time)
			else:
				_move_towards(end_position, delta)
		else:
			if get_parent().position == start_position:
				is_moving_forward = true
				if forward_requires_player_detection:
					active = false
				else:
					_start_stall_timer(forward_stall_time)
			else:
				_move_towards(start_position, delta)


func _move_towards(goal_position, delta):
	var move_towards = get_parent().position.move_toward(goal_position, forward_speed * delta)
	get_parent().constant_linear_velocity.x = (move_towards - get_parent().position).x * delta
	get_parent().position = move_towards


func _start_stall_timer(seconds):
	if seconds == 0: return
	
	stall_timer.wait_time = seconds
	stall_timer.start()


func _update_path_2d():
	if not path_2d: return
	
	path_2d.curve.clear_points()
	path_2d.curve.add_point(start_position_offset)
	path_2d.curve.add_point(end_position_offset)


func _on_player_detection_area_body_entered(body):
	if body == player:
		is_player_colliding = true
		player_entered.emit()


func _on_player_detection_area_body_exited(body):
	if body == player:
		is_player_colliding = false
		if stall_timer.time_left > 0:
			stall_timer.stop()
			stall_timer.emit_signal("timeout")


func _on_stall_timer_timeout():
	if not is_player_colliding:
		if is_moving_forward and forward_requires_player_detection:
			active = false
		elif not is_moving_forward and backward_requires_player_detection:
			active = false


func _on_activation_cassette_pocket_activation():
	active = true


func _on_activation_cassette_pocket_deactivation():
	active = false
