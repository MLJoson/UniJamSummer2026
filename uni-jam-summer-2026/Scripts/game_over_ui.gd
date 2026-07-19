extends Control

func enable():
	self.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func _on_exit_button_button_down() -> void:
	get_tree().quit()
