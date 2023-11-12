extends Area2D

@onready var pickup_cooldown = $PickupCooldown

var pocketed_cassette = null
var active = true


func try_to_pocket_cassette(potential_cassette):
	print("a")
	if potential_cassette.is_in_group("cassette") and not pocketed_cassette and pickup_cooldown.time_left == 0:
		print("b")
		pocket_cassette(potential_cassette)
		print("c")
		return true
	else:
		return false


func pocket_cassette(cassette):
	pocketed_cassette = cassette
	cassette.rotation = 0
	
	cassette.call_deferred("reparent", self)
	cassette.set_deferred("freeze", true)
	await get_tree().process_frame
	
	cassette.global_position = global_position


func _on_body_entered(body):
	try_to_pocket_cassette(body)
