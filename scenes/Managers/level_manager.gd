extends Node3D

var current_level: int = 0
@onready var pause_screen = preload("res://scenes/UI/how_to_play.tscn")

func _ready():
	GameEvents.generation_complete.connect(on_level_generated)
	
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_screen.instantiate())
		get_tree().root.set_input_as_handled()

func on_level_generated():
	current_level += 1
	GameEvents.emit_level_changed(current_level)
	
func change_levels():
	if(EnemyManager.enemies_spawned == 0):
		get_tree().change_scene_to_file("res://scenes/levels/physical_dimension.tscn")
	if EnemyManager.enemies_spawned > EnemyManager.enemies_died:
		get_tree().change_scene_to_file("res://scenes/levels/pandemonium_dimension.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/levels/physical_dimension.tscn")

func main_menu():
	reset()
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
	
func death_screen():
	get_tree().change_scene_to_file("res://scenes/UI/death_screen.tscn")
	
	
func reset():
	current_level = 0
	PlayerStats.reset()
	ItemDropManager.reset()
	EnemyManager.reset()
