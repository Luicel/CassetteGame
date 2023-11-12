class_name PlayerLevitateMovementState extends PlayerMovementState


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var player : CharacterBody2D


func enter():
	player = get_tree().get_first_node_in_group("player")


func physics_update(delta):
	player.velocity.y = -SPEED
	player.handle_horizontal_movement()
	
	player.move_and_slide()
