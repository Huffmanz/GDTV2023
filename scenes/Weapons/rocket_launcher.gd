extends Node3D

var can_shoot = true
@onready var gun_sprite = $CanvasLayer/Control/GunSprite
@onready var spawn_location: Marker3D = $Marker3D
@onready var rocket: PackedScene = preload("res://scenes/Weapons/rocket.tscn")

func _ready():
	gun_sprite.play("Idle")

func launch_projectile():
	var new_rocket = rocket.instantiate() as Area3D
	get_tree().root.add_child(new_rocket)
	new_rocket.global_transform = spawn_location.global_transform
	
func _process(delta):
	if Input.is_action_pressed("shoot") and can_shoot and PlayerStats.ammo_rocket > 0:
		gun_sprite.play("Shoot")
		launch_projectile()
		PlayerStats.change_rocket_ammo(-1)
		can_shoot = false
		await gun_sprite.animation_finished
		can_shoot = true
		gun_sprite.play("Idle")

