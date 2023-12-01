extends StaticBody2D

@export var start_active = false
@export var active_texture : Texture2D
@export var inactive_texture : Texture2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var collision_shape_2d = $CollisionShape2D
@onready var sprite_2d = $Sprite2D
@onready var player_detector_area = $PlayerDetectorArea

var is_active = false
var is_player_in_area = false
var is_trying_to_activate = true

func _ready():
	is_active = start_active
	
	if not start_active:
		disable()


func toggle():
	if is_active:
		disable()
	else:
		enable()


func enable():
	is_active = true
	
	if not is_player_in_area:
		sprite_2d.texture = active_texture
		visible = true
		collision_shape_2d.set_deferred("disabled", false)
	else:
		is_trying_to_activate = true


func disable():
	is_active = false
	
	is_trying_to_activate = false
	sprite_2d.texture = inactive_texture
	visible = false
	collision_shape_2d.set_deferred("disabled", true)
	


func _on_player_detector_area_body_entered(body):
	if body == player:
		is_player_in_area = true


func _on_player_detector_area_body_exited(body):
	if body == player:
		is_player_in_area = false
		if is_trying_to_activate:
			enable()
