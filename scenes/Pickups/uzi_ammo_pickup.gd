extends Area3D

@export var display_name: String
@export var ammo: int = 10

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(body):
	if body.is_in_group("Player"):
		PlayerStats.change_uzi_ammo(ammo)
		GameEvents.emit_item_picked_up(display_name, ammo)
		queue_free()
