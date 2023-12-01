@tool
extends AnimatableBody2D

@onready var collision_polygon_2d = $CollisionPolygon2D
@onready var polygon_2d = $Polygon2D


func _process(delta):
	collision_polygon_2d.polygon = polygon_2d.polygon
