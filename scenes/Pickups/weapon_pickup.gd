extends Area3D
class_name  WeaponPickup
@export var display_name: String
@export var weapon: PackedScene = preload("res://scenes/Weapons/shotgun.tscn")
@export var starting_ammo: int = 10
@export var current_ammo = 0

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(body):
	if body.is_in_group("Player"):
		var has_gun = false
		for gun in PlayerStats.guns_carried:
			if gun.resource_name == weapon.resource_name:
				has_gun = true
				break;
		if !has_gun:
			PlayerStats.carried_guns.append(weapon)
			queue_free()
