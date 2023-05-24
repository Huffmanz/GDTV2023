extends Node
class_name HealthComponent

signal died
signal health_changed
signal health_decreased

@export var max_health: float = 10
var current_health: float
var dead = false

func _ready():
	current_health = max_health

func damage(damage_amount: float):
	current_health = clamp(current_health-damage_amount, current_health-damage_amount, max_health)
	health_changed.emit()
	if damage_amount > 0:
		health_decreased.emit()
	check_death()
	#Callable(check_death).call_deferred()
	
func heal(heal_amount: float):
	damage(-heal_amount)
	
func get_health_percent():
	if max_health <= 0:
		return 0
	return min(current_health / max_health, 1)
	
func check_death():
	if dead:
		return
	if current_health <= 0:
		dead = true
		Callable(emit_died).call_deferred()
		#owner.queue_free()
	
func emit_died():
	died.emit()
	
