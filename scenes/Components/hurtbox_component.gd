extends Area3D
class_name HurboxComponent

signal hit

@export var health_component: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
