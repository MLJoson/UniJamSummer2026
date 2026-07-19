extends Control

@onready var game_over = $TextureRect/AnimationPlayer
@onready var box = $VBoxContainer1
@onready var box_anim = $VBoxContainer1/AnimationPlayer

func _ready() -> void:
	box.modulate = Color.TRANSPARENT
	await get_tree().create_timer(2).timeout
	game_over.play("GameOver")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "GameOver":
		await get_tree().create_timer(1).timeout
		box_anim.play("fade_in")

func _on_retry_pressed() -> void:
	Transition.fade_in()
	#change to main game
	get_tree().change_scene_to_file("res://Scenes/labyrinth-stuff/labyrinth_maker.tscn")
	Transition.fade_out()

func _on_quit_pressed() -> void:
	get_tree().quit()
