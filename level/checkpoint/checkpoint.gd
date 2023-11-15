class_name Checkpoint extends Area2D

@onready var respawn_point = $RespawnPoint
@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("player")


func _on_body_entered(body):
	if body == player:
		player.checkpoint = self
