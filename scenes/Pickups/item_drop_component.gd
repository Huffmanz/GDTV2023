extends Node

@export var health_component: HealthComponent
@export_range(0,1) var chance_to_drop: float
@export var drops: Resource
var total_weight: float = 0.0

func _ready():
	health_component.died.connect(on_died)
	for i in drops.drop_chances:
		total_weight += i

func on_died():
	if chance_to_drop > randf():
		drop_item()
		
func drop_item():
	var iteration_sum = 0.0
	var chosen_item: int = 0
	var chosen_weight = randf_range(0, total_weight)
	#var drops = drops as DropTable
	var max_iter = 100
	var iter = 0
	while(chosen_weight > iteration_sum || iter > max_iter):
		iter += 1 
		chosen_item = randi_range(0, drops.drop_chances.size() - 1)
		iteration_sum += drops.drop_chances[chosen_item]
	
	var drop_instance = drops.pickup[chosen_item].instantiate()
	get_tree().get_first_node_in_group("Level").add_child(drop_instance)
	var spawn_position = (owner as Node3D).global_position 
	drop_instance.global_position = spawn_position
	
	
