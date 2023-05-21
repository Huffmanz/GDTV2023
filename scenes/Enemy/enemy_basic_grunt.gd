extends CharacterBody3D


#@onready var nav: NavigationRegion3D = get_tree().get_nodes_in_group("NavMesh")[0]
@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision = $CollisionShape3D
@onready var hearing_sense = $HearingSense
@onready var visual_sense:RayCast3D = $VisualSense
@onready var shoot_timer = $ShootTimer


var path = [] #hold the paht coordinates from the enemy to the player
var path_index = 0
var speed = 3.0
var health = 20.0
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
	
			
func take_damage(dmg_amount):
	health -= dmg_amount
	if health <= 0:
		death()
		return
	move = false
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
			print("I see you")
		else:
			searching = false
			var check_hear = hearing_sense.get_overlapping_bodies()
			for body in check_hear:
				if body.is_in_group("Player"):
					searching = true
					return
	
func find_path(target):
	nav_agent.target_position = target
	
func death():
	dead = true

	$CollisionShape3D.disabled = true
	if health < -20:
		$AnimatedSprite3D.play("explode")
	else:
		$AnimatedSprite3D.play("die")
	await $AnimatedSprite3D.animation_finished
	queue_free()
	#$AnimatedSprite3D.billboard = 0
	
func shoot():
	if searching and not dead and not shooting:
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
		print("i hear you")
		searching = true
	
func on_shoot_timer_timeout():
	shoot()


