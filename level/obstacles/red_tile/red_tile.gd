extends StaticBody2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var collision_shape_2d = $CollisionShape2D
@onready var player_detector_area = $PlayerDetectorArea

var is_player_in_area = false
var is_trying_to_activate = true

func _ready():
	disable()


func enable():
	if not is_player_in_area:
		visible = true
		collision_shape_2d.set_deferred("disabled", false)
	else:
		is_trying_to_activate = true


func disable():
	is_trying_to_activate = false
	visible = false
	collision_shape_2d.set_deferred("disabled", true)


func _on_player_detector_area_body_entered(body):
	if body == player:
		is_player_in_area = true


func _on_player_detector_area_body_exited(body):
	if body == player:
		is_player_in_area = false
		if is_trying_to_activate:
			enable()
