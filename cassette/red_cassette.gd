extends BaseCassette


func _enable_effect():
	print("!")
	get_tree().call_group("red_block", "enable")


func _disable_effect():
	print("!!")
	get_tree().call_group("red_block", "disable")
