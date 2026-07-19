extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player_detection = $PlayerDetection
@onready var player_detection_close = $PlayerDetectionClose
@onready var player_detection_far = $PlayerDetectionFar
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var chase_transition_timer = $ChaseTransitionTimer
@onready var player_detection_timer = $PlayerDetectionTimer
@onready var charge_timer = $ChargeWindupTimer
@onready var stun_timer = $StunTimer
@onready var camera: Camera3D = get_viewport().get_camera_3d()

#Movement variables
@export_group("Movement")
@export var acceleration: int = 30
@export var defaultMaxSpeed: float = 2
@export var friction: int = 40
@export var chaseMaxSpeed: float = 3
@export var wander_range: float = 10.0 # determines how far from the player the minotaur's target pos will be in wonder state

#Charge variables
@export_group("Charge")
@export var charge_speed := 10.0
@export var charge_distance := 20.0
@export var charge_windup := 1.0
@export var stun_time := 2.0


@export_group("Other")
# Music should probably be handled in a game manager script instead so maybe change later
@onready var music_manager: AudioStreamPlayer = $MusicManager

#Animation variables
@onready var front_sprite: AnimatedSprite3D = $ChargeFront
@onready var side_sprite: AnimatedSprite3D = $ChargeSide
@onready var idle_sprite: AnimatedSprite3D = $Idle

var charge_destination : Vector3
var charge_direction : Vector3

var currentSpeed = defaultMaxSpeed
var isDetecting := false
var isTransitioningMovementStates: bool = false

var state = WONDER
# state machine
enum {
	CHASE,
	WONDER,
	CHARGE_WINDUP,
	CHARGE,
	STUN,
}
enum CloseState {
	ISCLOSE,
	NOTCLOSE,
}
var current_close_state: CloseState = CloseState.NOTCLOSE
func _ready():
	idle_sprite.play()
	front_sprite.play()
	side_sprite.play()

	idle_sprite.visible = true
	front_sprite.visible = false
	side_sprite.visible = false
	
func _physics_process(delta: float) -> void:
	look_at(global_position + velocity) # makes minotaur look where it's walking
	
	if player:
		#far detection starts a timer
		if player_detection_far.canSeePlayer:
			if !isDetecting:
				player_detection_timer.start()
				isDetecting = true
		else:
			player_detection_timer.stop()
			isDetecting = false
		#close or normal detection is immediate
		if player_detection.canSeePlayer or player_detection_close.canSeePlayer:
			player_detection_timer.stop()
			isDetecting = false
			if state == WONDER:
				if global_position.distance_to(player.global_position) > 8:
					start_charge()
				else:
					change_state(CHASE)
	
	match state:
		CHASE:
			currentSpeed = chaseMaxSpeed
			navigation_agent.set_target_position(player.global_position)
			movement(delta)
		
		WONDER:
			currentSpeed = defaultMaxSpeed
			if navigation_agent.is_navigation_finished():
				set_wonder_position()
			movement(delta)
			
		CHARGE_WINDUP:
			velocity = Vector3.ZERO
		CHARGE:
			velocity = charge_direction * charge_speed
			move_and_slide()
			if global_position.distance_to(charge_destination) < 0.5:
				change_state(STUN)
				stun_timer.start(stun_time)
				
			for i in range(get_slide_collision_count()):
				var collision = get_slide_collision(i)
				if collision:
					state = STUN
					stun_timer.start(stun_time)
					velocity = Vector3.ZERO
					break
		STUN:
			velocity = Vector3.ZERO
	update_sprite_direction()

# used for changing music
func change_close_state(new_state: CloseState):
	if current_close_state == new_state:
		return
	current_close_state = new_state
	if new_state == CloseState.ISCLOSE:
		music_manager.set_current_track(2)
	elif state == WONDER:
		music_manager.set_current_track(0)

func change_state(new_state):
	if state == new_state:
		return

	state = new_state

	match state:
		CHASE:
			music_manager.set_current_track(1)
		WONDER:
			music_manager.set_current_track(0)
		CHARGE_WINDUP:
			pass
		CHARGE:
			pass
		STUN:
			pass

func movement(delta):
	var destination = navigation_agent.get_next_path_position()
	
	if navigation_agent.is_navigation_finished(): # If the minotaur is done, stop moving
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		return
	else: # move towards next point
		var local_destination = destination - global_position
		var direction = local_destination.normalized()
		
		# Calculate velocity based on direction and speed.
		velocity = velocity.move_toward(direction * currentSpeed, acceleration * delta)
		
	
	move_and_slide()

func set_wonder_position(): # choses a random point to walk towards near the player
	var random_offset = Vector3(randf_range(-wander_range, wander_range), 0, randf_range(-wander_range, wander_range))
	navigation_agent.set_target_position(player.global_position + random_offset)

# ends chase state if player is out of sight for long enough
func _on_player_detection_lost_sight_of_player() -> void:
	player_detection_timer.stop()
	isDetecting = false
	chase_transition_timer.start()
	await chase_transition_timer.timeout
	if state != STUN and state != CHARGE:
		change_state(WONDER)

#starts charge
func start_charge():
	change_state(CHARGE_WINDUP)
	velocity = Vector3.ZERO
	charge_direction = -transform.basis.z.normalized()
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position + charge_direction * charge_distance)
	query.exclude = [self]
	var result = space.intersect_ray(query)
	if result:
		charge_destination = result.position
	else:
		charge_destination = global_position + charge_direction * charge_distance
	charge_timer.start(charge_windup)

func _on_charge_windup_timer_timeout() -> void:
	change_state(CHARGE)


func _on_stun_timer_timeout() -> void:
	if player_detection.canSeePlayer:
		change_state(CHASE)
	else:
		change_state(WONDER)


func _on_player_detection_timer_timeout() -> void:
	isDetecting = false
	if global_position.distance_to(player.global_position) > 8:
		start_charge()
	else:
		change_state(CHASE)

func update_sprite_direction():
	if camera == null:
		return
		
	# Default: hide everything
	idle_sprite.visible = false
	front_sprite.visible = false
	side_sprite.visible = false
	
	# Idle while wandering or stunned
	if state == WONDER or state == STUN or state == CHARGE_WINDUP:
		idle_sprite.visible = true
		return
		
	#camera direction relative to enemy
	var to_camera = (camera.global_position - global_position).normalized()
	var forward = -global_transform.basis.z.normalized()
	var right = global_transform.basis.x.normalized()
	var forward_dot = forward.dot(to_camera)
	var side_dot = right.dot(to_camera)
	
	#front view
	if abs(forward_dot) > 0.7:
		front_sprite.visible = true
		
	#side view
	else:
		side_sprite.visible = true
		side_sprite.flip_h = side_dot < 0
