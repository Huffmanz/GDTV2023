extends Node

signal level_changed(number: int)

func emit_level_changed(number: int):
	level_changed.emit(number)

signal generation_complete()
func emit_generation_complete():
	generation_complete.emit()

signal enemy_spawned
func emit_enemy_spawned():
	enemy_spawned.emit()

signal enemy_died()
func emit_enemy_died():
	enemy_died.emit()
	
signal item_picked_up(name: String, amount: int)
func emit_item_picked_up(name: String, amount: int):
	$PickupAudioPlayer.play_random()
	item_picked_up.emit(name, amount)
