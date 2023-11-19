class_name BlueCassette extends BaseCassette

@export var charged_texture : Texture2D
@export var not_charged_texture : Texture2D

@onready var sprite_2d = $Sprite2D

var is_charged = true

func set_charged(is_charged):
	self.is_charged = is_charged
	sprite_2d.texture = charged_texture if is_charged else not_charged_texture


func _enable_effect():
	get_tree().get_first_node_in_group("player").transition_to_movement_state("airdash")


func _disable_effect():
	get_tree().get_first_node_in_group("player").transition_to_movement_state("normal")
