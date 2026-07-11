@tool
extends Node3D

@export_tool_button("Generate") var generate = generate_map
@export var size := Vector2i(30, 20) :
	set(value):
		size.x = clamp(value.x, 0, 100)
		size.y = clamp(value.y, 0, 100)

func generate_map() -> void:
	delete_exisiting_tiles()
	create_base_tiles()
	$GridMap.set_cell_item(Vector3i(1, 1, 0), -1)

#deletes tiles currently on the gridmap to prevent errors with
#previous tiles living through generation attempts
func delete_exisiting_tiles() -> void:
	for x in 100:
		for z in 100:
			$GridMap.set_cell_item(Vector3i(x, 0, z), -1)

#creates the rectangle of tiles that make up the map.
#this program takes away tiles to create different paths 
#for the labyrinth
func create_base_tiles() -> void:
	for x in size.x:
		for z in size.y:
			$GridMap.set_cell_item(Vector3i(x, 0, z), 0)
