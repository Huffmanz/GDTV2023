extends Node3D
@onready var dun_gen = $DunGen
@export var enemy_scene: Array[PackedScene]
@export var player_scene: PackedScene = preload("res://scenes/player.tscn")

@onready var level_load_timer = $LevelLoadTimer

var player
var player_room: Vector3 = Vector3.ZERO

func _ready():
	dun_gen.generate_full()
	await GameEvents.generation_complete
	player = player_scene.instantiate()
	add_child(player)
	player_room = dun_gen.get_player_spawn()
	player.set_position(dun_gen.map_to_world(player_room))
	var enemies_to_spawn = (EnemyManager.enemies_spawned - EnemyManager.enemies_died) * 2
	if enemies_to_spawn == 0: # for testing the scene stand-alone
		enemies_to_spawn = 20
	for i in range(enemies_to_spawn):
		var new_enemy = enemy_scene[randi_range(0, enemy_scene.size() - 1)].instantiate()
		add_child(new_enemy)
		var enemy_room = dun_gen.get_enemy_room()
		new_enemy.set_position(dun_gen.map_to_world(enemy_room))
	$ResetTimer.timeout.connect(reset)
	MusicPlayer.play_pandemonium()
	level_load_timer.timeout.connect(on_level_load_timer_timeout)
	level_load_timer.start()
	
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
	
func on_level_load_timer_timeout():
	$LoadingScreen.queue_free()

