extends Node
var pauseScene 
var paused = false

func _input(event) -> void:
	if event.is_action_pressed("pause") && paused == false:
		pauseGame()
	elif event.is_action_pressed("pause") && paused == true:
		unpauseGame()

func pauseGame() -> void:
	get_node(".").visible = true
	var currentScene = get_tree()
	currentScene.paused = true 
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	paused = true
	
func unpauseGame() -> void:
	get_node(".").visible = false
	var currentScene = get_tree()
	currentScene.paused = false 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	paused = false
	
	
func _on_continue_button_pressed() -> void:
	unpauseGame()


func _on_exit_button_button_down() -> void:
	get_tree().quit()
