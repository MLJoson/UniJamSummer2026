extends Control

@export var start_scene : PackedScene
var start_scene_path

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	#start_scene.instantiate()
	#var sceneInstance = start_scene.instantiate()
	get_tree().change_scene_to_packed(start_scene)
