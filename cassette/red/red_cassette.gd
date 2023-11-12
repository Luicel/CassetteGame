extends BaseCassette


func _enable_effect():
	get_tree().call_group("red_block", "enable")


func _disable_effect():
	get_tree().call_group("red_block", "disable")
