class_name PlayerFloatMovementState extends PlayerMovementState

var player : CharacterBody2D


func enter():
	player = get_tree().get_first_node_in_group("player")
	player.velocity.y = 0


func physics_update(delta):
	player.handle_horizontal_movement(delta)
	
	player.move_and_slide()
