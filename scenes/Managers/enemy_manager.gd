extends Node3D

var enemies_spawned: int = 0
var enemies_died: int = 0

func _ready():
	GameEvents.enemy_spawned.connect(on_enemy_spawned)
	GameEvents.enemy_died.connect(on_enemy_died)

func on_enemy_spawned():
	enemies_spawned+=1
	
func on_enemy_died():
	enemies_died += 1
	
func reset():
	enemies_spawned = 0
	enemies_died = 0

