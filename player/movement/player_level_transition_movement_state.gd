class_name PlayerLevelTransitionMovementState extends PlayerMovementState

@onready var player = get_tree().get_first_node_in_group("player")


func physics_update(delta):
	player.apply_gravity(delta)
	player.velocity.x = player.speed / 2.0
	
	player.move_and_slide()
