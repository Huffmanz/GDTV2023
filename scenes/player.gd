extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var pivot = $Pivot
@onready var pistol = preload("res://scenes/Weapons/pistol.tscn")
@onready var shotgun = preload("res://scenes/Weapons/shotgun.tscn")
@onready var uzi = preload("res://scenes/Weapons/uzi.tscn")
@onready var rocket_launcher = preload("res://scenes/Weapons/rocket_launcher.tscn")

var current_gun = 0
#@onready var carried_guns = [pistol, shotgun, uzi, rocket_launcher]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	change_gun(0)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		$Pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, deg_to_rad(-30), deg_to_rad(30))
	
func change_gun(gun):
	if $Pivot/Gun.get_child_count() > 0:
		$Pivot/Gun.get_child(0).queue_free()
	var new_gun = PlayerStats.carried_guns[current_gun].instantiate()
	$Pivot/Gun.add_child(new_gun)
	PlayerStats.current_gun = new_gun.name
	
func _process(delta):
	if Input.is_action_just_pressed("next_gun"):
		current_gun += 1
		if current_gun > len(PlayerStats.carried_guns) - 1:
			current_gun = 0
		change_gun(current_gun)
	elif Input.is_action_just_pressed("previous_gun"):
		current_gun -= 1
		if current_gun < 0:
			current_gun = len(PlayerStats.carried_guns) - 1
		change_gun(current_gun)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
