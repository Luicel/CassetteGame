class_name PlayerUpsideDownMovementState extends PlayerMovementState

@onready var phantom_camera_2d = %PhantomCamera2D

var player : CharacterBody2D


func enter():
	player = get_tree().get_first_node_in_group("player")
	player.up_direction = Vector2.DOWN
	player.scale.y *= -1
	player.velocity.y /= 2
	
	player.just_swapped_verticality_timer.start()


func exit():
	player.up_direction = Vector2.UP
	player.scale.y *= -1
	player.velocity.y /= 2
	
	player.just_swapped_verticality_timer.start()


func physics_update(delta):
	player.handle_horizontal_movement(delta)
	player.handle_jump(true)
	player.handle_wall_jump(true)
	player.apply_gravity(delta, true)
	
	player.move_and_slide()
