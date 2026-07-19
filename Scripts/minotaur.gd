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
@export var music_manager: AudioStreamPlayer

var charge_destination : Vector3
var charge_direction : Vector3

var currentSpeed = defaultMaxSpeed
var isDetecting := false
var isTransitioningMovementStates: bool = false

var current_state: State = State.WONDER
var current_close_state: CloseState = CloseState.NOTCLOSE
# state machine
enum State {
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
func _ready():
	print(player_detection)
	print(player_detection_close)
	print(player_detection_far)
	
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
			if current_state == State.WONDER:
				if global_position.distance_to(player.global_position) > 8:
					start_charge()
				else:
					change_state(State.CHASE)
	
	if global_position.distance_to(player.global_position) < 18:
		change_close_state(CloseState.ISCLOSE)
	else:
		change_close_state(CloseState.NOTCLOSE)
	
	match current_state:
		State.CHASE:
			currentSpeed = chaseMaxSpeed
			navigation_agent.set_target_position(player.global_position)
			movement(delta)
		
		State.WONDER:
			currentSpeed = defaultMaxSpeed
			if navigation_agent.is_navigation_finished():
				set_wonder_position()
			movement(delta)
			if global_position.distance_to(player.global_position) < 18:
				music_manager.set_current_track(2)
			else:
				music_manager.set_current_track(0)
		
		State.CHARGE_WINDUP:
			velocity = Vector3.ZERO
		State.CHARGE:
			velocity = charge_direction * charge_speed
			move_and_slide()
			if global_position.distance_to(charge_destination) < 0.5:
				change_state(State.STUN)
				stun_timer.start(stun_time)
				
			for i in range(get_slide_collision_count()):
				var collision = get_slide_collision(i)
				if collision:
					change_state(State.STUN)
					stun_timer.start(stun_time)
					velocity = Vector3.ZERO
					break
		State.STUN:
			velocity = Vector3.ZERO

# Use these functions when changing states
func change_state(new_state: State):
	if current_state == new_state:
		return
	else:
		current_state = new_state
		
		if new_state == State.CHASE:
			music_manager.set_current_track(1)
		if new_state == State.WONDER:
			music_manager.set_current_track(0)

# used for changing music
func change_close_state(new_state: CloseState):
	if current_close_state == new_state:
		return
	else:
		current_close_state = new_state
	
	if new_state == CloseState.ISCLOSE:
		music_manager.set_current_track(2)
	if new_state == CloseState.NOTCLOSE:
		if current_state == State.WONDER:
			music_manager.set_current_track(0)

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
	if current_state != State.STUN and current_state != State.CHARGE:
		change_state(State.WONDER)

#starts charge
func start_charge():
	change_state(State.CHARGE_WINDUP)
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
	change_state(State.CHARGE)


func _on_stun_timer_timeout() -> void:
	if player_detection.canSeePlayer:
		change_state(State.CHASE)
	else:
		change_state(State.WONDER)


func _on_player_detection_timer_timeout() -> void:
	isDetecting = false
	if global_position.distance_to(player.global_position) > 8:
		start_charge()
	else:
		change_state(State.CHASE)
