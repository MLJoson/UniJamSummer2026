extends CharacterBody3D


var speed
var stamina
const MAX_STAMINA = 100
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

var PATH_DIRECTION = Vector3(0 , 0, -1) #default path (forward)
var isLocked = false
var MAXIMUM_ANGLE_RANGE = 95.0 #controls range of movement in front of player

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var gravity = 9.8

@onready var head  = $Head
@onready var camera = $Head/Camera3D
@onready var footsteps: AudioStreamPlayer3D = $Footsteps
@onready var breathing: AudioStreamPlayer3D = $Breathing
@onready var fade_anim_player : AnimationPlayer = $CanvasLayer/Control/AnimationPlayer
@onready var eyes : Sprite3D = $Eyes

@onready var sprint_timer = $sprint_reduce_timer
@onready var sprint_regen_timer = $sprint_regen_timer
var sprint_stamina = 100;
var regen_stamina: bool = true

@onready var can_accept_input : bool = true


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	sprint_timer.wait_time = 0.01
	sprint_regen_timer.wait_time = 4
	footsteps.volume_db = -50.0
	breathing.volume_db = -50.0
	fade_anim_player.play("fade_in")

func _unhandled_input(event):
	if can_accept_input and event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _process(_delta: float) -> void:
	#$"Head/Camera3D/SubViewport/HUD/Bottom HUD/Control/Sprint_Bar".value = sprint_stamina
	#Handles regenerating stamina
	if regen_stamina:
		sprint_stamina += 0.2
		sprint_stamina = clamp(sprint_stamina, 0, 100)
		if sprint_stamina >= 100:
			regen_stamina = false
			

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if can_accept_input:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		# Handle sprint
		if Input.is_action_pressed("sprint") and (sprint_stamina > 0):
			sprint_regen_timer.stop()
			regen_stamina = false
			speed = SPRINT_SPEED
			sprint_stamina += -0.25
			if sprint_stamina <= 5:
				breathing.play()
		elif Input.is_action_just_released("sprint"):
			sprint_regen_timer.start()
		else: 
			speed = WALK_SPEED

		# Get the input direction and handle the movement/deceleration.
		var input_dir = Input.get_vector("left", "right", "up", "down")
		
		#Footstep audio
		var is_walking = input_dir != Vector2.ZERO and is_on_floor()
		if is_walking:
			if !footsteps.playing:
				footsteps.play()
			var horizontal_speed = Vector2(velocity.x, velocity.z).length()
			footsteps.pitch_scale = lerp(0.9, 1.5, horizontal_speed/SPRINT_SPEED)
		else:
			if footsteps.playing:
				footsteps.stop()
		var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if is_on_floor():
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
				velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_bob)
		
		var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
		var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
		
		move_and_slide()
		
	

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time*BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos

func _on_sprint_reduce_timer_timeout() -> void:
	sprint_stamina = sprint_stamina - 0.05

func _on_sprint_regen_timer_timeout() -> void:
	regen_stamina = true
