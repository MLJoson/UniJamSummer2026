extends Control

@onready var animation = $ColorRect/AnimationPlayer

func fade_out():
	animation.play("fade_out")
	
func fade_in():
	animation.play_backwards("fade_out")
