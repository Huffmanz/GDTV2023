extends Node3D
@onready var dun_gen = $DunGen
@export var enemy_scene: PackedScene = preload("res://scenes/Enemy/enemy_devastor_zombie.tscn")
@export var player_scene: PackedScene = preload("res://scenes/player.tscn")
@export var chaos_sphere_scene: PackedScene = preload("res://scenes/chaos_sphere.tscn")
var player
var player_room: Vector3 = Vector3.ZERO
var enemies_remaining: int = 0

func _ready():
	dun_gen.generate_full()
	await GameEvents.generation_complete
	player = player_scene.instantiate()
	add_child(player)
	player_room = dun_gen.get_player_spawn()
	player.set_position(dun_gen.map_to_world(player_room))
	GameEvents.enemy_spawned.connect(on_enemy_spawned)
	GameEvents.enemy_died.connect(on_enemy_died)
	var enemies_to_spawn = EnemyManager.enemies_spawned - EnemyManager.enemies_died
	if enemies_to_spawn == 0:
		enemies_to_spawn = 10
	for i in range(enemies_to_spawn):
		var new_enemy = await enemy_scene.instantiate()
		add_child(new_enemy)
		var enemy_room = dun_gen.get_room_except(player_room)
		new_enemy.set_position(dun_gen.map_to_world(enemy_room))
	$LoadingScreen.queue_free()
	$ResetTimer.timeout.connect(reset)
	MusicPlayer.play_pandemonium()
	
func _process(delta):
	var enemies_left = get_tree().get_nodes_in_group("Enemy").size()
	
	if !$ResetTimer.is_stopped():
		if enemies_left > 0:
			$ResetTimer.stop()
			$TimerScreen.hide()
		else:
			$TimerScreen.show()
			$TimerScreen/MarginContainer/VBoxContainer/HBoxContainer/CountDown.text = str(floor($ResetTimer.time_left))
			return
	else:
		$TimerScreen.hide()
	if enemies_left == 0:
		$ResetTimer.start()

func reset():
	EnemyManager.reset()
	LevelManager.change_levels()

func on_enemy_spawned():
	enemies_remaining+=1
	
func on_enemy_died():
	enemies_remaining-=1
