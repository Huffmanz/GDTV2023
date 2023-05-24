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
