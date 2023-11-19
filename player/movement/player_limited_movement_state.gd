class_name PlayerLimitedMovementState extends PlayerMovementState

var player : CharacterBody2D


func enter():
	player = get_tree().get_first_node_in_group("player")


func physics_update(delta):
	player.handle_horizontal_movement(delta)
	player.apply_gravity(delta)
	
	player.move_and_slide()
