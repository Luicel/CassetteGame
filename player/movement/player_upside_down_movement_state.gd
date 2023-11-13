class_name PlayerUpsideDownMovementState extends PlayerMovementState

var player : CharacterBody2D


func enter():
	player = get_tree().get_first_node_in_group("player")
	player.up_direction = Vector2.DOWN
	player.scale.y *= -1


func exit():
	player.up_direction = Vector2.UP
	player.scale.y *= -1


func physics_update(delta):
	player.handle_horizontal_movement()
	player.handle_jump(true)
	player.handle_wall_jump(true)
	player.apply_gravity(delta, true)
	
	player.move_and_slide()
