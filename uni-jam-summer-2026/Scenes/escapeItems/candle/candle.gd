extends Node3D

func _process(delta):
	rotate_y(0.01)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		print(body.name)
