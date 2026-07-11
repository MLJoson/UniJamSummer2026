extends Area3D

@onready var raycast = $RayCast3D
@onready var collisionShape = $CollisionShape3D
@onready var player = get_tree().get_first_node_in_group("Player")

@export var fovDegrees: int = 100

var isPlayerInRadius: bool = false
var canSeePlayer: bool = false
var fov = cos(deg_to_rad(fovDegrees))
signal lostSightOfPlayer

func _ready() -> void:
	# set raycast length to same as detection area radiuswwd
	raycast.target_position = Vector3.FORWARD * collisionShape.shape.radius

func _process(delta: float) -> void:
	# point raycast towards player if within radius
	if isPlayerInRadius == true:
		
		var direction = global_position.direction_to(player.global_position)
		var facing = global_transform.basis.tdotz(direction)
		if facing > fov: # checks if player is within FOV
			raycast.look_at(player.global_position) 
			
			if raycast.is_colliding():
				if raycast.get_collider() == player:
					canSeePlayer = true
				else:
					if canSeePlayer == true: # only emits once
						lostSightOfPlayer.emit()
					canSeePlayer = false
	pass


func _on_body_entered(body: Node3D) -> void:
	if body == player:
		isPlayerInRadius = true


func _on_body_exited(body: Node3D) -> void:
	if body == player:
		isPlayerInRadius = false
		if canSeePlayer == true:
			canSeePlayer = false
			lostSightOfPlayer.emit()
