extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	$RigidBody3D/MeshInstance3D.scale = Vector3(3,3,3)
	print($RigidBody3D/MeshInstance3D.scale)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
