extends Area3D

@export var health_value: int = 20

func _ready():
	body_entered.connect(on_body_entered)


func on_body_entered(body):
	if body.is_in_group("Player"):
		PlayerStats.change_health(health_value)
		queue_free()
