extends Area3D
class_name HurboxComponent

signal hit

@export var health_component: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	health_component.died.connect(on_death)

func take_damage(damage_amount):
	health_component.damage(damage_amount)
	if health_component.current_health > 0:
		hit.emit()
	
func on_death():
	pass
