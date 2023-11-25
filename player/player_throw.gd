extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var cassette_pocket = $"../CassettePocket"

var current_direction : Vector2


func _process(delta):
	update_direction()
	
	if Input.is_action_just_pressed("throw"):
		throw()


func update_direction():
	current_direction = (get_global_mouse_position() - global_position).normalized()
	# Adding 90 to offset weird math convention mismatch.
	rotation_degrees = rad_to_deg(current_direction.angle()) + 90


func throw():
	if not cassette_pocket.pocketed_cassette: return
	
	var cassette = cassette_pocket.pocketed_cassette
	cassette.throw(current_direction)
	cassette_pocket.pocketed_cassette._disable_effect()
	cassette_pocket.remove_pocketed_cassette()
