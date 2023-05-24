extends Node
class_name HealthComponent

signal died
signal health_changed
signal health_decreased

@export var max_health: float = 10
var current_health: float

func _ready():
	current_health = max_health



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
