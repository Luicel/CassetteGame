extends BaseCassette


func _enable_effect():
	get_tree().get_first_node_in_group("player").transition_to_movement_state("upsidedown")


func _disable_effect():
	get_tree().get_first_node_in_group("player").transition_to_movement_state("normal")
