extends Node2D

enum Type { STATIC, SWITCHING, DETECTION }
@export var type : Type
@export var spikes_out_texture : Texture2D
@export var spikes_in_texture : Texture2D
@export_category("Switching Type Settings")
@export var switching_time_delay = 1.0
@export_category("Detection Type Settings")
@export var detection_time_delay = 1.0
@export var detection_active_time = 1.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $DeathZone/CollisionShape2D
@onready var switching_timer = $SwitchingTimer
@onready var detection_timer = $DetectionTimer

var is_active = true

func _ready():
	switching_timer.wait_time = switching_time_delay
	detection_timer.wait_time = detection_time_delay
	
	if type == Type.SWITCHING:
		toggle_spikes(false)
		switching_timer.start()
	elif type == Type.DETECTION:
		toggle_spikes(false)


func toggle_spikes(play_sound = true):
	# TODO Add sound that doesn't play with _ready() calls.
	
	is_active = not is_active
	sprite_2d.texture = spikes_out_texture if is_active else spikes_in_texture
	collision_shape_2d.disabled = not is_active


func _on_switching_timer_timeout():
	toggle_spikes()
	switching_timer.start()
	# TODO Add sound (put here, not in toggle)


func _on_player_detection_area_body_entered(body):
	if body == player and type == Type.DETECTION and detection_timer.time_left == 0 and not is_active:
		detection_timer.start()


func _on_detection_timer_timeout():
	toggle_spikes()
	await get_tree().create_timer(detection_active_time).timeout
	
	toggle_spikes()
