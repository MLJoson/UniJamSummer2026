extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player_detection = $PlayerDetection
@onready var player = get_tree().get_first_node_in_group("Player")

@export_group("Movement")
@export var acceleration: int = 30
@export var defaultMaxSpeed: float = 2
@export var friction: int = 40
@export var chaseMaxSpeed: float = 3

var currentSpeed = defaultMaxSpeed


func _unhandled_input(event: InputEvent) -> void:
	pass

func _physics_process(delta: float) -> void:
	# changes move speed depending on if player is close
	if player_detection.canSeePlayer == true:
		currentSpeed = chaseMaxSpeed
	else:
		currentSpeed = defaultMaxSpeed
	
	
	if player: # get player position
		navigation_agent.set_target_position(player.global_position)
	
	var destination = navigation_agent.get_next_path_position()
	
	if navigation_agent.is_navigation_finished(): # If the minotaur is done, stop moving
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		move_and_slide()
		return
	else: # move towards next point
		var local_destination = destination - global_position
		var direction = local_destination.normalized()
		
		# Calculate velocity based on direction and speed.
		velocity = velocity.move_toward(direction * currentSpeed, acceleration * delta)
		
		# Move and slide.
		move_and_slide()
