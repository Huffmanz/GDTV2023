extends Node3D

var current_level: int = 0

func _ready():
	GameEvents.generation_complete.connect(on_level_generated)

func on_level_generated():
	current_level += 1
	GameEvents.emit_level_changed(current_level)
	
func change_levels():
	if(EnemyManager.enemies_spawned == 0):
		get_tree().change_scene_to_file("res://scenes/levels/physical_dimension.tscn")
	#var percent_to_change: float = float(EnemyManager.enemies_died) / float(EnemyManager.enemies_spawned)
	if EnemyManager.enemies_spawned > EnemyManager.enemies_died:
		get_tree().change_scene_to_file("res://scenes/levels/pandemonium_dimension.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/levels/physical_dimension.tscn")
