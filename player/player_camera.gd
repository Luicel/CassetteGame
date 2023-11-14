extends Camera2D

@export var lookahead_factor = 0.2
@export var shift_time = 1.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var starting_position = position

var facing = 0
var target_offset = 0.0
var active_tween : Tween


func _process(delta):
	_check_facing_direction()


func _check_facing_direction():
	var new_facing = player.previous_direction
	if new_facing != 0 and new_facing != facing:
		facing = new_facing
		target_offset = get_viewport_rect().size.x * lookahead_factor * facing
		_shift_camera()


func _shift_camera():
	if active_tween:
		active_tween.kill()
	
	active_tween = get_tree().create_tween()
	active_tween.set_trans(Tween.TRANS_SINE)
	active_tween.set_ease(Tween.EASE_OUT)
	active_tween.tween_property(self, "position:x", target_offset, shift_time)
	#await tween.finished


func update_grounded(is_on_floor):
	drag_vertical_enabled = not is_on_floor
