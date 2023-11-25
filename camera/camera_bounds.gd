extends Area2D

@onready var collision_shape_2d = $CollisionShape2D


func _ready():
	var camera = get_viewport().get_camera_2d()
	
	camera.limit_left = collision_shape_2d.global_position.x - collision_shape_2d.shape.size.x / 2
	camera.limit_right = collision_shape_2d.global_position.x + collision_shape_2d.shape.size.x / 2
	camera.limit_top = collision_shape_2d.global_position.y - collision_shape_2d.shape.size.y / 2
	camera.limit_bottom = collision_shape_2d.global_position.y + collision_shape_2d.shape.size.y / 2
