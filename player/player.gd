extends CharacterBody2D

signal cassette_thrown

@onready var cassette_pocket = $CassettePocket
@onready var sprite_2d = $Sprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	handle_movement(delta)
	if Input.is_action_just_pressed("throw"):
		throw_cassette()


func handle_movement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _on_cassette_detector_area_body_entered(body):
	var success = cassette_pocket.try_to_pocket_cassette(body)
	if success: body._enable_effect()


func throw_cassette():
	if not cassette_pocket.pocketed_cassette: return
	
	var cassette = cassette_pocket.pocketed_cassette
	cassette.throw()
	cassette._disable_effect()
	cassette_pocket.pocketed_cassette = null
	cassette_pocket.pickup_cooldown.start()
