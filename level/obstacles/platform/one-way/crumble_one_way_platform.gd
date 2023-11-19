extends AnimatableBody2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var collision_shape_2d = $CollisionShape2D
@onready var standing_timer = $StandingTimer
@onready var respawn_timer = $RespawnTimer

var is_player_colliding = false


func _process(delta):
	if is_player_colliding and player.is_on_floor() and standing_timer.time_left == 0 and respawn_timer.time_left == 0:
		standing_timer.start()


func _on_standing_timer_timeout():
	respawn_timer.start()
	visible = false
	collision_shape_2d.disabled = true


func _on_respawn_timer_timeout():
	visible = true
	collision_shape_2d.disabled = false


func _on_area_2d_body_entered(body):
	if body == player:
		is_player_colliding = true


func _on_area_2d_body_exited(body):
	if body == player:
		is_player_colliding = false
