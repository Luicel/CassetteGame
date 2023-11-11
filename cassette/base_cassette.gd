class_name BaseCassette extends RigidBody2D

@onready var throw_timer = $ThrowTimer

@export var force = 100000
@export var air_resistance = 4

func throw():
	var direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	var tween = get_tree().create_tween().EASE_OUT
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
	linear_velocity = Vector2.ZERO
	linear_damp = 0
	gravity_scale = 1
