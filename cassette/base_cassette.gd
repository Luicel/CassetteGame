class_name BaseCassette extends RigidBody2D

@onready var throw_timer = $ThrowTimer
@onready var initial_global_position = global_position

@export var force = 100000
@export var air_resistance = 4
@export var cassette_gravity_scale = 0.0


func _ready():
	freeze = true


func _process(delta):
	sleeping = false


func throw(direction : Vector2):
	gravity_scale = 0
	linear_damp = air_resistance
	throw_timer.start()
	
	reparent(get_tree().root.get_child(0))
	freeze = false
	apply_central_impulse(direction * force)


func _enable_effect():
	pass


func _disable_effect():
	pass


func _on_throw_timer_timeout():
	disable_unique_physics()


func _on_body_entered(body):
	if body.is_in_group("cassette"):
		disable_unique_physics()


func disable_unique_physics():
	linear_velocity = Vector2.ZERO
	linear_damp = 0
	gravity_scale = cassette_gravity_scale


func respawn():
	# Lots of weird checks here. Basically, the physics engine does not like
	# rapid movement, so I'm telling it to shut the fuck up.
	disable_unique_physics()
	set_physics_process(false)
	set_deferred("freeze", true)
	await get_tree().process_frame
	
	global_position = initial_global_position
	rotation = 0
	await get_tree().process_frame
	
	set_physics_process(true)


func _on_area_2d_area_entered(area):
	disable_unique_physics()


func _on_area_2d_body_entered(body):
	disable_unique_physics()
