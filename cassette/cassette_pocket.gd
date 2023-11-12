extends Area2D

@onready var pickup_cooldown = $PickupCooldown

var active = true
var pocketed_cassette = null
var previously_pocketed_cassette = null


func try_to_pocket_cassette(potential_cassette):
	if potential_cassette.is_in_group("cassette") and not pocketed_cassette:
		if potential_cassette == previously_pocketed_cassette and pickup_cooldown.time_left > 0.0: 
			return false
		else:
			pocket_cassette(potential_cassette)
			return true
	else:
		return false


func pocket_cassette(cassette):
	pocketed_cassette = cassette
	cassette.rotation = 0
	
	pickup_cooldown.stop()
	pickup_cooldown.emit_signal("timeout")
	
	cassette.call_deferred("reparent", self)
	cassette.set_deferred("freeze", true)
	await get_tree().process_frame
	
	cassette.global_position = global_position


func remove_pocketed_cassette():
	previously_pocketed_cassette = pocketed_cassette
	pocketed_cassette = null
	pickup_cooldown.start()


func _on_body_entered(body):
	try_to_pocket_cassette(body)
