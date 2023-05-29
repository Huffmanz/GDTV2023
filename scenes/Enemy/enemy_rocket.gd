extends Area3D

var speed = 15
@onready var splash_damage = $SplashDamage
var rocket_damage = 25

func _ready():
	area_entered.connect(on_body_entered)
	body_entered.connect(on_body_entered)
	$AnimatedSprite3D.play("rocket")

func deal_damage():
	var targets = get_overlapping_bodies()
	for body in targets:
		if body.is_in_group("Player"):
			PlayerStats.take_damage(rocket_damage)
	targets = splash_damage.get_overlapping_bodies()
	for body in targets:
		if body.is_in_group("Player"):
			PlayerStats.take_damage(rocket_damage)
	
func _process(delta):
	translate(Vector3.FORWARD * speed * delta)
	
func on_body_entered(body):
	body = body as Node3D
	set_process(false)
	$ExplosionSoundPlayer.play_random()
	$AnimatedSprite3D.play("explode")
	deal_damage()
	await  $AnimatedSprite3D.animation_finished
	queue_free()
	
