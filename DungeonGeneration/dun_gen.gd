@tool
extends Node3D

#signal generation_complete
@onready var grid_map : GridMap = $GridMap

@export var start : bool = false : set = set_start
@export var ModularCells: PackedScene = preload("res://Assets/Levels/doom_cell_2.tscn")
func set_start(val:bool)->void:
	if Engine.is_editor_hint():
		await generate_full()

@export_range(0,1) var survival_chance : float = 0.25
@export var border_size : int = 20 : set = set_border_size
func set_border_size(val : int)->void:
	border_size = val
	if Engine.is_editor_hint():
		visualize_border()
		
@export var room_number : int = 4
@export var room_margin : int = 1
@export var room_recursion : int = 15
@export var min_room_size : int = 2 
@export var max_room_size : int = 4
@export_multiline var custom_seed : String = "" : set = set_seed 
func set_seed(val:String)->void:
	custom_seed = val
	seed(val.hash())

var room_tiles : Array[PackedVector3Array] = []
var room_positions : PackedVector3Array = []
var spawnable_tiles: Array[PackedVector3Array] = []
var spawnable_rooms: PackedVector3Array = []
var enemies_in_room: Array[int] = []

func get_random_room() -> Vector3:
	var idx = randi_range(0, room_positions.size())
	return room_positions[idx]

func get_random_position_in_room(room: Vector3) -> Vector3:
	var room_idx=0
	for i in range(0, spawnable_rooms.size()):
		if spawnable_rooms[i] == room:
			room_idx = i
			break
	var idx = randi_range(0, spawnable_tiles[room_idx].size()-1)
	return spawnable_tiles[room_idx][idx]

func get_enemy_room():
	var min: int = 999
	var idx: int = 0
	for i in range(spawnable_rooms.size()):
		if enemies_in_room[i] < min:
			idx = i
			min = enemies_in_room[i]
	enemies_in_room[idx] = enemies_in_room[idx] + 1
	return  get_random_position_in_room(spawnable_rooms[idx])

func get_spawnable_room(center: bool = false):
	var idx = randi_range(0, spawnable_rooms.size()-1)
	var room = spawnable_rooms[idx]
	if center:
		return room
	else:
		return get_random_position_in_room(room)

func get_player_spawn():
	var room= Vector3.ZERO
	for i in room_positions:
		for j in room_positions:
			if i == j:
				continue
			if room == Vector3.ZERO:
				room = i
			else:
				if i - j > i - room:
					room = i
	print(room)
	print(spawnable_rooms)
	for i in range(spawnable_rooms.size()):
		if room == spawnable_rooms[i]:
			spawnable_rooms.remove_at(i)
			spawnable_tiles.remove_at(i)
			enemies_in_room.remove_at(i)
			break
	return room 

func map_to_world(map_location: Vector3) -> Vector3:
	return map_location * grid_map.cell_size + Vector3.UP

func visualize_border():
	grid_map.clear()
	for i in range(-1,border_size+1):
		grid_map.set_cell_item( Vector3i(i,0,-1),3)
		grid_map.set_cell_item( Vector3i(i,0,border_size),3)
		grid_map.set_cell_item( Vector3i(border_size,0,i),3)
		grid_map.set_cell_item( Vector3i(-1,0,i),3)

func generate_full():
	room_number = clamp(room_number, 3, 10)
	await generate()
	$NavigationRegion3D/DunMesh.dun_cell_scene = ModularCells
	$NavigationRegion3D/DunMesh.create_dungeon()
	await $NavigationRegion3D/DunMesh.generation_complete
	print("Level Generated")
	grid_map.clear()
	CreateNavMesh()
	await $NavigationRegion3D.bake_finished
	print("NavMesh Baked")
	GameEvents.emit_generation_complete()
	
func CreateNavMesh():
	var on_thread: bool = true
	$NavigationRegion3D.bake_navigation_mesh(on_thread)

func generate():
	room_tiles.clear()
	room_positions.clear()
	spawnable_tiles.clear()
	room_positions.clear()
	var t : int = 0
	if custom_seed : set_seed(custom_seed)
	visualize_border()
	for i in room_number:
		t+=1
		make_room(room_recursion)
		if t%17 == 16: await get_tree().create_timer(0).timeout
	
	var rpv2 : PackedVector2Array = []
	var del_graph : AStar2D = AStar2D.new()
	var mst_graph : AStar2D = AStar2D.new()
	
	for p in room_positions:
		rpv2.append(Vector2(p.x,p.z))
		del_graph.add_point(del_graph.get_available_point_id(),Vector2(p.x,p.z))
		mst_graph.add_point(mst_graph.get_available_point_id(),Vector2(p.x,p.z))
	
	var delaunay : Array = Array(Geometry2D.triangulate_delaunay(rpv2))
	
	for i in delaunay.size()/3:
		var p1 : int = delaunay.pop_front()
		var p2 : int = delaunay.pop_front()
		var p3 : int = delaunay.pop_front()
		del_graph.connect_points(p1,p2)
		del_graph.connect_points(p2,p3)
		del_graph.connect_points(p1,p3)
	
	var visited_points : PackedInt32Array = []
	visited_points.append(randi() % room_positions.size())
	while visited_points.size() != mst_graph.get_point_count():
		var possible_connections : Array[PackedInt32Array] = []
		for vp in visited_points:
			for c in del_graph.get_point_connections(vp):
				if !visited_points.has(c):
					var con : PackedInt32Array = [vp,c]
					possible_connections.append(con)
					
		var connection : PackedInt32Array = possible_connections.pick_random()
		for pc in possible_connections:
			if rpv2[pc[0]].distance_squared_to(rpv2[pc[1]]) <\
			rpv2[connection[0]].distance_squared_to(rpv2[connection[1]]):
				connection = pc
		
		visited_points.append(connection[1])
		mst_graph.connect_points(connection[0],connection[1])
		del_graph.disconnect_points(connection[0],connection[1])
	
	var hallway_graph : AStar2D = mst_graph
	
	for p in del_graph.get_point_ids():
		for c in del_graph.get_point_connections(p):
			if c>p:
				var kill : float = randf()
				if survival_chance > kill :
					hallway_graph.connect_points(p,c)
					
	create_hallways(hallway_graph)
	
func create_hallways(hallway_graph:AStar2D):
	var hallways : Array[PackedVector3Array] = []
	for p in hallway_graph.get_point_ids():
		for c in hallway_graph.get_point_connections(p):
			if c>p:
				var room_from : PackedVector3Array = room_tiles[p]
				var room_to : PackedVector3Array = room_tiles[c]
				var tile_from : Vector3 = room_from[0]
				var tile_to : Vector3 = room_to[0]
				for t in room_from:
					if t.distance_squared_to(room_positions[c])<\
					tile_from.distance_squared_to(room_positions[c]):
						tile_from = t
				for t in room_to:
					if t.distance_squared_to(room_positions[p])<\
					tile_to.distance_squared_to(room_positions[p]):
						tile_to = t
				var hallway : PackedVector3Array = [tile_from,tile_to]
				hallways.append(hallway)
				grid_map.set_cell_item(tile_from,2)
				grid_map.set_cell_item(tile_to,2)
	
	var astar : AStarGrid2D = AStarGrid2D.new()
	astar.size = Vector2i.ONE * border_size
	astar.update()
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	
	for t in grid_map.get_used_cells_by_item(0):
		astar.set_point_solid(Vector2i(t.x,t.z))
	var _t : int = 0
	for h in hallways:
		_t +=1
		var pos_from : Vector2i = Vector2i(h[0].x,h[0].z)
		var pos_to : Vector2i = Vector2i(h[1].x,h[1].z)
		var hall : PackedVector2Array = astar.get_point_path(pos_from,pos_to)
		
		for t in hall:
			var pos : Vector3i = Vector3i(t.x,0,t.y)
			if grid_map.get_cell_item(pos) <0:
				grid_map.set_cell_item(pos,1)
		if _t%16 == 15: await  get_tree().create_timer(0).timeout
	
func make_room(rec:int):
	if !rec>0:
		return
	
	var width : int = (randi() % (max_room_size - min_room_size)) + min_room_size
	var height : int = (randi() % (max_room_size - min_room_size)) + min_room_size
	
	var start_pos : Vector3i 
	start_pos.x = randi() % (border_size - width + 1)
	start_pos.z = randi() % (border_size - height + 1)
	
	for r in range(-room_margin,height+room_margin):
		for c in range(-room_margin,width+room_margin):
			var pos : Vector3i = start_pos + Vector3i(c,0,r)
			if grid_map.get_cell_item(pos) == 0:
				make_room(rec-1)
				return
	
	var room : PackedVector3Array = []
	var spawnable_room: PackedVector3Array = []
	for r in height:
		for c in width:
			var pos : Vector3i = start_pos + Vector3i(c,0,r)
			grid_map.set_cell_item(pos,0)
			room.append(pos)
			if r == height || c == width:
				continue
			if r == 0 || c == 0:
				continue
			spawnable_room.append(pos)
	room_tiles.append(room)
	spawnable_tiles.append(spawnable_room)
	var avg_x : float = start_pos.x + (float(width)/2)
	var avg_z : float = start_pos.z + (float(height)/2)
	var pos : Vector3 = Vector3(avg_x,0,avg_z)
	room_positions.append(pos)
	spawnable_rooms.append(pos)
	enemies_in_room.append(0)
