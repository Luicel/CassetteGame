@tool
extends Area2D

@export var used_phantom_camera_2d : PhantomCamera2D
@export var camera_priority = 10

@onready var camera_visibility_preview = $CameraVisibilityPreview
@onready var path_2d = $Path2D


func _ready():
	if not Engine.is_editor_hint():
		connect("body_entered", _body_entered)
		connect("body_exited", _body_exited)
		camera_visibility_preview.visible = false
		camera_visibility_preview.disabled = true


func _process(delta):
	if Engine.is_editor_hint():
		draw_camera_visibility_preview()


func draw_camera_visibility_preview():
	if not used_phantom_camera_2d: return
	
	var rectangle_shape_2d = RectangleShape2D.new()
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height = ProjectSettings.get_setting("display/window/size/viewport_height")
	width *= (1 / used_phantom_camera_2d.get_zoom().x)
	height *= (1 / used_phantom_camera_2d.get_zoom().y)
	#if path_2d.curve.get_point_count() == 2:
	#	width += abs(path_2d.curve.get_point_position(0).x - path_2d.curve.get_point_position(1).x)
	#	print(abs(path_2d.curve.get_point_position(0).x - path_2d.curve.get_point_position(1).x))
	#	height += abs(path_2d.curve.get_point_position(0).y - path_2d.curve.get_point_position(1).y)
		
	rectangle_shape_2d.size = Vector2(width, height)
	camera_visibility_preview.shape = rectangle_shape_2d


func _body_entered(body):
	if body.is_in_group("player"):
		used_phantom_camera_2d.set_priority(camera_priority)


func _body_exited(body):
	if body.is_in_group("player"):
		used_phantom_camera_2d.set_priority(0)
