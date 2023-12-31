extends Node3D

@onready var gun_sprite: AnimatedSprite2D = $CanvasLayer/Control/GunSprite
@onready var gun_rays = $GunRays.get_children()
@onready var flash = preload("res://scenes/Effects/muzzle_flash.tscn")
@onready var blood = preload("res://scenes/Effects/blood.tscn")
var can_shoot = true
var damage = 3

func _ready():
	gun_sprite.play("Idle")
	gun_sprite.frame_changed.connect(on_frame_changed)
	
func check_hit():
	for ray in gun_rays:
		if ray.is_colliding():
			var collider = ray.get_collider()
			if ray.get_collider() is HurboxComponent:
				ray.get_collider().take_damage(damage)
				var new_blood = blood.instantiate()
				get_tree().root.add_child(new_blood)
				new_blood.global_transform.origin = ray.get_collision_point()
				new_blood.emitting = true
				
func make_flash():
	var f = flash.instantiate()
	add_child(f)

func _process(delta):
	if  Input.is_action_pressed("shoot") && can_shoot && PlayerStats.ammo_shells > 0:
		gun_sprite.play("Shoot")
		$FireAudioPlayer.play_random()
		make_flash()
		check_hit()
		PlayerStats.change_shotgun_ammo(-1)
		can_shoot = false
			
		await gun_sprite.animation_finished
		can_shoot = true
		gun_sprite.play("Idle")

func on_Timer_timeout():
	can_shoot = true
	
func on_frame_changed():
	if gun_sprite.frame == 2:
		$ReloadPlayer.play_random()
	if gun_sprite.frame == 13:
		$ReloadPlayer3.play_random()
