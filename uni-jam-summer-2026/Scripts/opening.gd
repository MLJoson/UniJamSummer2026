extends Control

func _ready() -> void:
	Transition.fade_out()
	await get_tree().create_timer(1).timeout
	Dialogic.start("Opening")
	await Dialogic.timeline_ended
	Transition.fade_in()
	# Change to main gameplay loop
	get_tree().change_scene_to_file("res://Scenes/NavTest.tscn")
	Transition.fade_out()
