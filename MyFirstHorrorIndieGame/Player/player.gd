extends CharacterBody3D

#***** NODES *****#
@onready var camera_3d = $Camera3D
#***** CAMERA *****#
var mouse_sens := 0.15
#***** MOVEMENT *****#
var direction
var speed := 5
var jump := 30.0
const  GRAVITY = 5


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$MeshInstance3D.visible = false

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camera_3d.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
func _physics_process(delta):
	process_movement(delta)
	
func process_movement(delta):
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	
	direction.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	direction.z = -Input.get_action_strength("ui_up") + Input.get_action_strength("ui_down")
	direction = Vector3(direction.x, 0, direction.z).rotated(Vector3.UP, h_rot).normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump
	if !is_on_floor():
		velocity.y -= GRAVITY

	move_and_slide()
