extends Area3D

@export var armor_value: int = 20

func _ready():
	body_entered.connect(on_body_entered)


func on_body_entered(body):
	if !body.is_in_group("Player"):
		return
	if PlayerStats.armor != PlayerStats.max_armor:
		GameEvents.emit_item_picked_up("Armor", armor_value)
		PlayerStats.change_armor(armor_value)
		queue_free()
