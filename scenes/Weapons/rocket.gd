extends Area3D

var speed = 20
@onready var splash_damage = $SplashDamage
var rocket_damage = 25

func _ready():
	body_entered.connect(on_body_entered)
	$AnimatedSprite3D.play("rocket")

func deal_damage():
	var enemies = get_overlapping_bodies()
	for body in enemies:
		if body.is_in_group("Enemy"):
			body.take_damage(rocket_damage)
	enemies = splash_damage.get_overlapping_bodies()
	for body in enemies:
		if body.is_in_group("Enemy"):
			body.take_damage(rocket_damage)
	
func _process(delta):
	translate(Vector3.FORWARD * speed * delta)
	
func on_body_entered(body):
	if body.is_in_group("Player"):
		return
	set_process(false)
	$AnimatedSprite3D.play("explode")
	deal_damage()
	await  $AnimatedSprite3D.animation_finished
	queue_free()
	
