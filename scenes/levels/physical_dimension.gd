extends Node3D
@onready var dun_gen = $DunGen
@export var enemy_scene: PackedScene = preload("res://scenes/Enemy/enemy_basic_grunt.tscn")
@export var player_scene: PackedScene = preload("res://scenes/player.tscn")
@export var chaos_sphere_scene: PackedScene = preload("res://scenes/chaos_sphere.tscn")
@onready var level_load_timer = $LevelLoadTimer


var player
var player_room: Vector3 = Vector3.ZERO

func _ready():
	var current_level = LevelManager.current_level
	dun_gen.room_number = current_level + 2
	dun_gen.generate_full()
	await GameEvents.generation_complete
	player = player_scene.instantiate()
	add_child(player)
	player_room = dun_gen.get_player_spawn()
	player.set_position(dun_gen.map_to_world(player_room))
	for i in range(max(3 * current_level + 1, 8)):
		var new_enemy = enemy_scene.instantiate()
		add_child(new_enemy)
		var enemy_room = dun_gen.get_enemy_room()
		new_enemy.set_position(dun_gen.map_to_world(enemy_room))
	var chaos_sphere = chaos_sphere_scene.instantiate()
	add_child(chaos_sphere)
	var room = dun_gen.get_spawnable_room(true)
	chaos_sphere.set_position(dun_gen.map_to_world(room))
	MusicPlayer.play_normal()
	level_load_timer.timeout.connect(on_level_load_timer_timeout)
	level_load_timer.start()
	
func _physics_process(delta):
	if player == null:
		return
	get_tree().call_group("Enemy", "set_target_location", player.global_transform.origin)
	
func on_level_load_timer_timeout():
	$LoadingScreen.queue_free()
