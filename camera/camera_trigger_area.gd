extends Area2D

@export var used_phantom_camera_2d : PhantomCamera2D


func _ready():
	connect("body_entered", _body_entered)
	connect("body_exited", _body_exited)


func _body_entered(body):
	if body is CharacterBody2D:
		used_phantom_camera_2d.set_priority(20)


func _body_exited(body):
	if body is CharacterBody2D:
		used_phantom_camera_2d.set_priority(0)
