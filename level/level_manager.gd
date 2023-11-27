extends Node

@onready var animation_player = $AnimationPlayer


var is_transitioning = false


func _ready():
	if get_player():
		await get_tree().process_frame
		walk_into_frame()


func walk_player_to_scene(scene : PackedScene):
	if animation_player.is_playing(): return
	
	walk_out_of_frame_to_scene(scene)
	await get_tree().create_timer(2).timeout
	
	walk_into_frame()


func walk_out_of_frame_to_scene(scene : PackedScene):
	is_transitioning = true
	
	get_player().transition_to_movement_state("leveltransition")
	await get_tree().create_timer(0.5).timeout
	
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_packed(scene)


func walk_into_frame():
	get_player().transition_to_movement_state("leveltransition")
	animation_player.play("fade_from_black")
	await animation_player.animation_finished
	
	get_player().transition_to_movement_state("normal")
	
	is_transitioning = false


func get_player():
	return get_tree().get_first_node_in_group("player")
