extends Control

@export var maxSprintValue : float
@export var progress_bar : ProgressBar
@onready var sprint_tween : Tween = create_tween()
@export var player : Node
@export var bar_consumption_speed : float = 1.0 
@onready var sprintValue = float(player.sprint_stamina)
@export var playerHealth : float
@export var criticalHealthThreshhold : float = 10
@export var flashingSpeed : float = 1
@export var damageEffectPanel : Panel
@onready var healthFlashTween = create_tween()
var panelModulateValue 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player == null:
		push_error("Player must be assigned to HUD in inspector")
	progress_bar.visible = false


	panelModulateValue = damageEffectPanel.modulate
	healthFlashTween.tween_property(damageEffectPanel, "modulate", Color(1.0, 1.0, 1.0, 1.0), flashingSpeed)
	healthFlashTween.tween_property(damageEffectPanel, "modulate", panelModulateValue, flashingSpeed)
	healthFlashTween.set_loops(-1)

func _input(event):
	if event.is_action_pressed("sprint"):
		showBar()
	elif event.is_action_released("sprint"):
		hideBar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pollHealth()
	var currentValue = float(player.sprint_stamina)
	#var sprintPercentage = (sprintValue/maxSprintValue) * 100
	var lerpValue = lerp(currentValue, maxSprintValue, delta * bar_consumption_speed)
	progress_bar.value = lerpValue
	if currentValue < 0.01:
		currentValue = 0;
		progress_bar.value = 0

func pollHealth() -> void:
	if playerHealth < criticalHealthThreshhold:
		damageEffectPanel.visible = true
		healthFlashTween.play()
	else:
		damageEffectPanel.modulate = Color(0,0,0,0)
		healthFlashTween.stop()
		
		

	
func showBar() -> void:
	
	progress_bar.visible = true
	progress_bar.pivot_offset = Vector2(progress_bar.size.x/2, progress_bar.size.y/2)
	var original_transparency = progress_bar.modulate
	var original_width = Vector2(progress_bar.custom_minimum_size)
	progress_bar.modulate.a = 0
	progress_bar.custom_minimum_size = Vector2(0, 0)
	
	sprint_tween = reset_tween(sprint_tween)
	sprint_tween.set_parallel(true)
	sprint_tween.tween_property(progress_bar, "modulate", original_transparency, 0.5)
	sprint_tween.tween_property(progress_bar, "custom_minimum_size", original_width, 0.2).set_trans(Tween.TRANS_CUBIC)
	

func hideBar() -> void:
	progress_bar.visible = false

func reset_tween(tween : Tween) -> Tween:
	if tween:
		tween.kill()
	return create_tween()
