#attatch this to a container of buttons 
extends Node

var targets 
var tween := create_tween()
@export var animation_length : float
@export var animation_pause_length : float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	targets = get_children()
	for button_node in targets:
		if button_node is Button:
			reset_tween()
			tween.tween_property(button_node, "theme_override_colors/font_color", Color.WHITE, animation_length)
			await get_tree().create_timer(animation_pause_length).timeout
	connectButtons(targets)

#this works apparently 
func connectButtons(target) -> void:
	for button_node in target:
			button_node.mouse_entered.connect(_on_mouse_entered.bind(button_node))
			button_node.mouse_exited.connect(_on_mouse_exited.bind(button_node))
		
func _on_mouse_entered(button : Button) -> void:
	var tx_edit : TextEdit = button.get_child(0)
	var greek_button_text = tx_edit.text
	var normal_button_text = tx_edit.placeholder_text
	playHoverAnimation(button, greek_button_text, button.position)

func _on_mouse_exited(button : Button) -> void:
	button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	var tx_edit : TextEdit = button.get_child(0)
	var normal_button_text = tx_edit.placeholder_text
	playExitAnimation(button, normal_button_text)

func playHoverAnimation(button : Button, text_transition : String, original_position: Vector2) -> void:
	reset_tween()
	button.text = text_transition
	tween.set_parallel(true)
	tween.tween_property(button, "modulate", Color.RED, 0.1)
	tween.set_loops()
	var offset = Vector2(15, 0)
	tween.tween_property(button, "position", original_position + offset, 0.01)
	tween.tween_property(button, "position", original_position - offset, 0.05)
	tween.tween_property(button, "position", original_position, 0.01)
	tween.finished.connect(_on_tween_completed.bind([button, original_position]))
	button.position = original_position
	
#resets the position of the button (note this is not working idk why)
func _on_tween_completed(button, button_original_position : Vector2):
	button.position = button_original_position
	
	
func playExitAnimation(button : Button, text_transition : String) -> void:
	button.text = text_transition
	reset_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "modulate", Color.WHITE, 0.01)


func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
