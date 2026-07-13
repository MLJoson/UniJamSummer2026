@tool
extends Node3D

@export_tool_button("Generate") var start = generate
@export var size := Vector2i(10, 10) :
	set(value):
		size.x = clamp(value.x, 0, 100)
		size.y = clamp(value.y, 0, 100)

var start_pos : Vector2i

func _ready() -> void:
	#this makes it only run when you start the game, not in-editor
	if not Engine.is_editor_hint(): 
		generate()
		$Player.position = Vector3i(start_pos.x * 2, 0, start_pos.y * 2)

#generates everything relating to the labyrinth
func generate() -> void:
	delete_exisiting_tiles()
	create_base_tiles()
	generate_pathing()

#generates the pathing of the labyrinth - eg. which rooms are empty/filled
func generate_pathing() -> void:
	start_pos = Vector2i(randi_range(1, size.x - 1), randi_range(1, size.y - 1))
	print(start_pos)
	$GridMap.set_cell_item(Vector3i(start_pos.x, 0, start_pos.y), -1)
	$GridMap.set_cell_item(Vector3i(start_pos.x, 1, start_pos.y), -1)
	var cur_pos = start_pos
	var flag = true
	var movement_stack = []
	
	while flag:
		var valid_moves = get_valid_moves(cur_pos)
		if valid_moves:
			var direction = valid_moves.pick_random()
			cur_pos += direction #moves cur_pos in that direction
			$GridMap.set_cell_item(Vector3i(cur_pos.x, 0, cur_pos.y), -1)
			$GridMap.set_cell_item(Vector3i(cur_pos.x, 1, cur_pos.y), -1)
			movement_stack.append(direction)
		elif movement_stack.size() > 0:
			cur_pos -= movement_stack.pop_back()
		else:
			flag = false

#gets all possible valid moves for the current position.
#valid moves:
#1. Move into a square that currently is filled
#2. Don't break into areas that have hallways or are outside the map
func get_valid_moves(cur_pos) -> Array:
	var moves = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
	var valid_moves = []
	for move in moves:
		if is_valid(cur_pos, move):
			valid_moves.append(move)
	return valid_moves

func is_valid(pos, dir) -> bool:
	if $GridMap.get_cell_item(Vector3i(pos.x + dir.x, 0, pos.y + dir.y)) == -1:
		return false
	if $GridMap.get_cell_item(Vector3i(pos.x + (dir.x * 2), 0, pos.y + (dir.y * 2))) == -1:
		return false
	
	if dir.x == 0:
		if $GridMap.get_cell_item(Vector3i(pos.x + 1, 0, pos.y + dir.y)) == -1:
			return false
		if $GridMap.get_cell_item(Vector3i(pos.x - 1, 0, pos.y + dir.y)) == -1:
			return false
	else:
		if $GridMap.get_cell_item(Vector3i(pos.x + dir.x, 0, pos.y + 1)) == -1:
			return false
		if $GridMap.get_cell_item(Vector3i(pos.x + dir.x, 0, pos.y - 1)) == -1:
			return false
	return true
#deletes tiles currently on the gridmap to prevent errors with
#previous tiles living through generation attempts
func delete_exisiting_tiles() -> void:
	for x in 100:
		for z in 100:
			$GridMap.set_cell_item(Vector3i(x, -1, z), -1)
			$GridMap.set_cell_item(Vector3i(x, 0, z), -1)
			$GridMap.set_cell_item(Vector3i(x, 1, z), -1)

#creates the rectangle of tiles that make up the map.
#this program takes away tiles to create different paths 
#for the labyrinth
func create_base_tiles() -> void:
	for x in size.x:
		for z in size.y:
			$GridMap.set_cell_item(Vector3i(x, 1, z), 0)
			$GridMap.set_cell_item(Vector3i(x, 0, z), 0)
			$GridMap.set_cell_item(Vector3i(x, -1, z), 0)
