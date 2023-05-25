extends Node3D
@onready var dun_gen = $DunGen
@export var enemy_scene: PackedScene = preload("res://scenes/Enemy/enemy_basic_grunt.tscn")
@export var player_scene: PackedScene = preload("res://scenes/player.tscn")
@export var chaos_sphere_scene: PackedScene = preload("res://scenes/chaos_sphere.tscn")
var player
var player_room: Vector3 = Vector3.ZERO
var enemies_remaining: int = -1

func _ready():
	dun_gen.generate_full()
	await GameEvents.generation_complete
	player = player_scene.instantiate()
	add_child(player)
	player_room = dun_gen.get_player_spawn()
	player.set_position(dun_gen.map_to_world(player_room))
	var enemies_to_spawn = EnemyManager.enemies_spawned - EnemyManager.enemies_died
	GameEvents.enemy_spawned.connect(on_enemy_spawned)
	GameEvents.enemy_died.connect(on_enemy_died)
	for i in range(EnemyManager.enemies_spawned - EnemyManager.enemies_died):
		var new_enemy = enemy_scene.instantiate()
		add_child(new_enemy)
		var enemy_room = dun_gen.get_room_except(player_room)
		new_enemy.set_position(dun_gen.map_to_world(enemy_room))
	
func _process(delta):
	if enemies_remaining == 0:
		EnemyManager.reset()
		LevelManager.change_levels()

func on_enemy_spawned():
	enemies_remaining+=1
	
func on_enemy_died():
	enemies_remaining-=1
