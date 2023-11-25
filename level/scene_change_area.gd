extends Area2D

@export var scene : PackedScene

@onready var player = get_tree().get_first_node_in_group("player")


func _on_body_entered(body):
	if body == player:
		get_tree().change_scene_to_packed(scene)
