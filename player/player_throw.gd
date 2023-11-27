extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var cassette_pocket = $"../CassettePocket"
@onready var sprite_2d = $Sprite2D
@onready var visual_timer = $VisualTimer

var current_direction : Vector2


func _process(delta):
	update_direction()
	update_visuals()
	
	if Input.is_action_just_pressed("throw"):
		throw()


func _input(event):
	if event is InputEventMouseMotion:
		visual_timer.start()


func update_direction():
	current_direction = (get_global_mouse_position() - global_position).normalized()


func update_visuals():
	if cassette_pocket.pocketed_cassette and visual_timer.time_left > 0:
		visible = true
		if player.up_direction == Vector2.DOWN:
			current_direction.y *= -1
		# Adding 90 to offset weird math convention mismatch.
		rotation_degrees = rad_to_deg(current_direction.angle()) + 90
	else:
		visible = false


func throw():
	if not cassette_pocket.pocketed_cassette: return
	if LevelManager.is_transitioning: return
	
	var cassette = cassette_pocket.pocketed_cassette
	cassette.throw(current_direction)
	cassette_pocket.pocketed_cassette._disable_effect()
	cassette_pocket.remove_pocketed_cassette()


func _on_cassette_pocket_cassette_pocketed():
	visual_timer.start()
