extends CharacterBody3D


#@onready var nav: NavigationRegion3D = get_tree().get_nodes_in_group("NavMesh")[0]
@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision = $CollisionShape3D
@onready var hearing_sense = $HearingSense
@onready var visual_sense:RayCast3D = $VisualSense
@onready var shoot_timer = $ShootTimer
@export var speed = 3.0
@export var health = 20.0
@export var damage = 8
	
var move = true
var searching = false
var shooting = false
var dead = false
var can_attack_target = false


func _ready():
	$AnimatedSprite3D.play("walking")
	hearing_sense.body_entered.connect(hearing_sense_on_body_entered)
	shoot_timer.timeout.connect(on_shoot_timer_timeout)
	GameEvents.emit_enemy_spawned()
	$HurtboxComponent.hit.connect(on_hit)
	$HealthComponent.died.connect(on_death)
	#shoot_timer.wait_time = randf_range(shoot_timer.wait_time / 1.25, shoot_timer.wait_time * 1.25)
	#speed = randf_range(speed / 1.25, speed * 1.25)
	speed = speed * (1 + .1 * LevelManager.current_level)
	
func set_target_location(target_location):
	nav_agent.set_target_position(target_location)
	
func on_hit():
	move = false
	$HurtAudioPlayer.play_random()
	$AnimatedSprite3D.play("hit")
	await $AnimatedSprite3D.animation_finished
	move = true
				
func _physics_process(delta):
	if dead:
		return
	var next_path_position: Vector3 = nav_agent.get_next_path_position()	
	var current_location = global_transform.origin
	look_at_player()
	if searching and not shooting:
		if nav_agent.is_navigation_finished():
			find_path(player.global_transform.origin)
		
		var new_velocity: Vector3 = (next_path_position - global_transform.origin).normalized() * speed
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
			can_attack_target = true
		else:
			check_hearing()
			can_attack_target = false
	else:
		check_hearing()
		can_attack_target = false
		
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
	#$AnimatedSprite3D.billboard = 0
	
func shoot():
	if can_attack_target and not dead and not shooting:
		$FireAudioPlayer.play_random()
		$AnimatedSprite3D.play("shoot")
		shooting = true
		await $AnimatedSprite3D.frame_changed
		if visual_sense.is_colliding():
			if visual_sense.get_collider().is_in_group("Player"):
				PlayerStats.take_damage(damage)
		await $AnimatedSprite3D.animation_finished
		shooting = false
	
func hearing_sense_on_body_entered(body):
	if body.is_in_group("Player"):
		searching = true
	
func on_shoot_timer_timeout():
	shoot()

