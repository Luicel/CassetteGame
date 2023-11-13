class_name BaseCassette extends RigidBody2D

@onready var throw_timer = $ThrowTimer

@export var force = 100000
@export var air_resistance = 4

func throw(player_direction):
	var direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	if direction == Vector2.ZERO: direction = Vector2(player_direction, 0)
	print(direction)
	gravity_scale = 0
	linear_damp = air_resistance
	throw_timer.start()
	
	reparent(get_tree().root)
	freeze = false
	apply_central_force(direction * force)


func _enable_effect():
	pass


func _disable_effect():
	pass


func _on_throw_timer_timeout():
	disable_unique_physics()


func _on_body_entered(body):
	print("!")
	if body.is_in_group("cassette"):
		disable_unique_physics()


func disable_unique_physics():
	linear_velocity = Vector2.ZERO
	linear_damp = 0
	gravity_scale = 1


func _on_area_2d_area_entered(area):
	disable_unique_physics()


func _on_area_2d_body_entered(body):
	disable_unique_physics()
