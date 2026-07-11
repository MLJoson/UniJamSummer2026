extends Area3D

@onready var raycast = $RayCast3D
@onready var collisionShape = $CollisionShape3D
@onready var player = get_tree().get_first_node_in_group("Player")

var isPlayerInRadius: bool = false
var canSeePlayer: bool = false

func _ready() -> void:
	# set raycast length to same as detection area radius
	raycast.target_position = Vector3.FORWARD * collisionShape.shape.radius

func _process(delta: float) -> void:
	# point raycast towards player if within radius
	if isPlayerInRadius == true:
		raycast.look_at(player.global_position) 
		
		if raycast.get_collider() == player:
			canSeePlayer = true
		else:
			canSeePlayer = false
	pass


func _on_body_entered(body: Node3D) -> void:
	if body == player:
		isPlayerInRadius = true


func _on_body_exited(body: Node3D) -> void:
	if body == player:
		isPlayerInRadius = false
