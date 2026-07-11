extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player_detection = $PlayerDetection
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var chase_transition_timer = $ChaseTransitionTimer

@export_group("Movement")
@export var acceleration: int = 30
@export var defaultMaxSpeed: float = 2
@export var friction: int = 40
@export var chaseMaxSpeed: float = 3
@export var wander_range: float = 10.0 # determines how far from the player the minotaur's target pos will be in wonder state

var currentSpeed = defaultMaxSpeed
var isTransitioningMovementStates: bool = false

var state = WONDER
# state machine
enum {
	CHASE,
	WONDER,
}

func _physics_process(delta: float) -> void:
	look_at(global_position + velocity) # makes minotaur look where it's walking
	
	if player: # set state to chase if player is visible
		if player_detection.canSeePlayer == true:
			state = CHASE
	
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
	chase_transition_timer.start()
	await chase_transition_timer.timeout
	state = WONDER
