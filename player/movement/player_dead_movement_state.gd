class_name PlayerDeadMovementState extends PlayerMovementState

@onready var player = get_tree().get_first_node_in_group("player")


func enter():
	#player.collision_shape_2d.disabled = true
	player.visible = false


func exit():
	#player.collision_shape_2d.disabled = false
	player.visible = true


func physics_update(delta):
	pass
