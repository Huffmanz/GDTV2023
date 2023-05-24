extends Node3D

var enemies_spawned: int
var enemies_died: int

func _ready():
	GameEvents.enemy_spawned.connect(on_enemy_spawned)
	GameEvents.enemy_died.connect(on_enemy_died)

func on_enemy_spawned():
	enemies_spawned+=1
	
func on_enemy_died():
	enemies_died += 1

