extends Label

const MAX_LINES = 5
var pickups_info: Array[String] = []

func _ready():
	text = ""
	GameEvents.item_picked_up.connect(add_pickups_info)
	$RemoveInfoTimer.timeout.connect(remove_pickups_info)
		
func add_pickups_info(pickup_name: String, amount: int):
	$RemoveInfoTimer.start()
	pickups_info.push_back("Picked up " + str(amount) + " " + pickup_name)		
	while pickups_info.size() >= MAX_LINES:
		pickups_info.pop_front()
	update_display()
	

func remove_pickups_info():
	if pickups_info.size() > 0:
		pickups_info.pop_front()
	
	update_display()

func update_display():
	text = ""
	for pickup_info in pickups_info:
		text += pickup_info + "\n"
