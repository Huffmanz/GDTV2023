extends Area3D

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(other_body):
	if other_body.is_in_group("Player"):
		LevelManager.change_levels()
