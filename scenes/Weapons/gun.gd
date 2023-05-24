extends Node3D

@onready var gun_sprite = $CanvasLayer/Control/GunSprite
@onready var gun_rays = $GunRays.get_children()
@onready var flash = preload("res://scenes/Effects/muzzle_flash.tscn")
@onready var blood = preload("res://scenes/Effects/blood.tscn")
@export var current_ammo = 0
var can_shoot = true
var damage = 8


func _ready():
	gun_sprite.play("Idle")
	
func check_hit():
	for ray in gun_rays:
		if ray.is_colliding():
			var collider = ray.get_collider()
			if ray.get_collider() is HurboxComponent:
			#if ray.get_collider().is_in_group("Enemy"):
				ray.get_collider().take_damage(damage)
				var new_blood = blood.instantiate()
				get_tree().root.add_child(new_blood)
				new_blood.global_transform.origin = ray.get_collision_point()
				new_blood.emitting = true
				
func make_flash():
	var f = flash.instantiate()
	add_child(f)

func _process(delta):
	if  Input.is_action_pressed("shoot") && can_shoot && PlayerStats.ammo_pistol > 0:
		gun_sprite.play("Shoot")
		make_flash()
		check_hit()
		PlayerStats.change_pistol_ammo(-1)
		can_shoot = false
		await gun_sprite.animation_finished
		can_shoot = true
		gun_sprite.play("Idle")

func on_Timer_timeout():
	can_shoot = true
