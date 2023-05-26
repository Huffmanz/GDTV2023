extends Node3D
@onready var dun_gen = $DunGen
@export var enemy_scene: PackedScene = preload("res://scenes/Enemy/enemy_basic_grunt.tscn")
@export var player_scene: PackedScene = preload("res://scenes/player.tscn")
@export var chaos_sphere_scene: PackedScene = preload("res://scenes/chaos_sphere.tscn")
var player
var player_room: Vector3 = Vector3.ZERO

func _ready():
	var current_level = LevelManager.current_level
	print (current_level)
	dun_gen.room_number = current_level + 2
	dun_gen.generate_full()
	await GameEvents.generation_complete
	player = player_scene.instantiate()
	add_child(player)
	player_room = dun_gen.get_player_spawn()
	player.set_position(dun_gen.map_to_world(player_room))
	for i in range(max(2 * current_level + 1, 10)):
		var new_enemy = enemy_scene.instantiate()
		add_child(new_enemy)
		var enemy_room = dun_gen.get_room_except(player_room)
		new_enemy.set_position(dun_gen.map_to_world(enemy_room))
	var chaos_sphere = chaos_sphere_scene.instantiate()
	add_child(chaos_sphere)
	var room = dun_gen.get_room_except(player_room, true)
	chaos_sphere.set_position(dun_gen.map_to_world(room))
	MusicPlayer.play_normal()
	$LoadingScreen.queue_free()
