extends Node3D

var current_level: int = 0

func _ready():
	GameEvents.generation_complete.connect(on_level_generated)

func on_level_generated():
	current_level += 1
	GameEvents.emit_level_changed(0)
