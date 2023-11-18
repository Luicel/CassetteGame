extends AnimatableBody2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var collision_shape_2d = $CollisionShape2D


func _input(event):
	if event.is_action_pressed("down"):
		print("down")
		set_collision_mask_value(2, false)
		player.set_collision_mask_value(5, false)
	elif event.is_action_released("down"):
		print("not down")
		set_collision_mask_value(2, true)
		player.set_collision_mask_value(5, true)
