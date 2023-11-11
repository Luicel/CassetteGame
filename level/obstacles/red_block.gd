extends StaticBody2D

@onready var collision_shape_2d = $CollisionShape2D

func _ready():
	disable()


func enable():
	visible = true
	collision_shape_2d.set_deferred("disabled", false)


func disable():
	visible = false
	collision_shape_2d.set_deferred("disabled", true)
