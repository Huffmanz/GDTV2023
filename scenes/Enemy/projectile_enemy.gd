extends CharacterBody3D


#@onready var nav: NavigationRegion3D = get_tree().get_nodes_in_group("NavMesh")[0]
@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision = $CollisionShape3D
@onready var hearing_sense = $HearingSense
@onready var visual_sense:RayCast3D = $VisualSense
@onready var shoot_timer = $ShootTimer
@export var projectile: PackedScene = preload("res://scenes/Enemy/enemy_rocket.tscn")
@export var speed = 3.0
@export var health = 20.0
var path = [] #hold the paht coordinates from the enemy to the player
var path_index = 0


var move = true
var searching = false
var shooting = false
var dead = false
var damage = 8


func _ready():
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	nav_agent.radius = collision.shape.radius
	nav_agent.max_speed = speed
	$AnimatedSprite3D.play("walking")
	hearing_sense.body_entered.connect(hearing_sense_on_body_entered)
	shoot_timer.timeout.connect(on_shoot_timer_timeout)
	GameEvents.emit_enemy_spawned()
	$HurtboxComponent.hit.connect(on_hit)
	$HealthComponent.died.connect(on_death)
	health = health * (1 + .1 * LevelManager.current_level)
	shoot_timer.wait_time = shoot_timer.wait_time * (1 + .1 * LevelManager.current_level)
	
func on_hit():
	move = false
	$HurtAudioPlayer.play_random()
	$AnimatedSprite3D.play("hit")
	await $AnimatedSprite3D.animation_finished
	move = true
	
				
func _physics_process(delta):
	if dead:
		return
		
	look_at_player()
	if searching and not shooting:
		if nav_agent.is_navigation_finished():
			find_path(player.global_transform.origin)
		var next_path_position: Vector3 = nav_agent.get_next_path_position()
		var new_velocity: Vector3 = next_path_position - global_position
		new_velocity = (new_velocity.normalized()) * speed
		velocity = velocity.move_toward(new_velocity, .25)
		if move:
			$AnimatedSprite3D.play("walking")
			move_and_slide()
	else:
		if not shooting:
			$AnimatedSprite3D.play("idle")
		
func look_at_player():
	visual_sense.look_at(player.global_transform.origin)
	if visual_sense.is_colliding():
		if visual_sense.get_collider().is_in_group("Player"):
			searching = true
		else:
			check_hearing()
	else:
		check_hearing()
		
func check_hearing():
	searching = false
	var check_hear = hearing_sense.get_overlapping_bodies()
	for body in check_hear:
		if body.is_in_group("Player"):
			searching = true
			return
					
	
func find_path(target):
	nav_agent.target_position = target
	
func on_death():
	dead = true
	
	$CollisionShape3D.disabled = true
	if $HealthComponent.current_health < -20:
		$GibAudioPlayer.play_random()
		$AnimatedSprite3D.play("explode")
	else:
		$DeathAudioPlayer.play_random()
		$AnimatedSprite3D.play("die")
	await $AnimatedSprite3D.animation_finished
	GameEvents.emit_enemy_died()
	queue_free()
	
func shoot():
	if searching and not dead and not shooting:
		
		$FireAudioPlayer.play_random()
		$AnimatedSprite3D.play("shoot")
		shooting = true
		await $AnimatedSprite3D.frame_changed
		launch_projectile()
		#if visual_sense.is_colliding():
		#	if visual_sense.get_collider().is_in_group("Player"):
		#		PlayerStats.take_damage(damage)
		await $AnimatedSprite3D.animation_finished
		shooting = false
	
func hearing_sense_on_body_entered(body):
	if body.is_in_group("Player"):
		searching = true
	
func on_shoot_timer_timeout():
	shoot()
	
func launch_projectile():
	var new_projectile = projectile.instantiate() as Area3D
	get_tree().root.add_child(new_projectile)
	new_projectile.global_transform = global_transform
	new_projectile.global_position += Vector3.UP
	new_projectile.look_at(player.global_position + Vector3.UP)
	$FireAudioPlayer.play_random()


