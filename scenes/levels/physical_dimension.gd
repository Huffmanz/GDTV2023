extends Node3D
@onready var dun_gen = $DunGen
@export var enemy_scene: PackedScene = preload("res://scenes/Enemy/enemy_basic_grunt.tscn")
@export var player_scene: PackedScene = preload("res://scenes/player.tscn")
var player
var player_room: Vector3 = Vector3.ZERO

func _ready():
	dun_gen.generate_full()
	await GameEvents.generation_complete
	player = player_scene.instantiate()
	add_child(player)
	player_room = dun_gen.get_player_spawn()
	player.set_position(dun_gen.map_to_world(player_room))
	for i in range(10):
		var new_enemy = enemy_scene.instantiate()
		add_child(new_enemy)
		var enemy_room = dun_gen.get_room_except(player_room)
		new_enemy.set_position(dun_gen.map_to_world(enemy_room))
