extends Node3D

@onready var player = $Player

func _physics_process(delta):
	get_tree().call_group("Enemy", "find_path", player.global_transform.origin)
	
