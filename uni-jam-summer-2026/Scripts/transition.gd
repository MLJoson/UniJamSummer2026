extends Control

@onready var animation = $ColorRect/AnimationPlayer

func fade_out():
	animation.play("fade_out")
	
func fade_in():
	animation.play_backwards("fade_out")


func _on_ready() -> void:
	eventBUS.colorChange.connect(color_changed)
	
func color_changed(newColor):
	$ColorRect.color = newColor
