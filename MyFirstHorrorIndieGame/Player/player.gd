extends CharacterBody3D

#***** NODES *****#
@onready var camera_3d = $Camera3D
@onready var origCamPos : Vector3 = camera_3d.position
@onready var floorCast = $FloorDetectRayCast
@onready var player_footstep_sound = $PlayerFootstepSound
@onready var interact_cast = $Camera3D/InteractRayCast

#***** CAMERA *****#
var mouse_sens := 0.15
#***** MOVEMENT *****#
var direction
var isRunning := false
var speed := 5
var jump := 30.0
const  GRAVITY = 5
var distanceFootstep := 0.0
var playFootstep := 3 #lower if we want the sounds to play faster
var _delta := 0.0
var camBobSpeed := 10
var camBobUpDown := 1


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$MeshInstance3D.visible = false

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camera_3d.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	if Input.is_action_just_pressed("run"):
		isRunning = true
	if Input.is_action_just_released("run"):
		isRunning = false
		
	if Input.is_action_just_pressed("interact"):
		var interacted = interact_cast.get_collider()
		if interacted != null and interacted.is_in_group("Interactable") and interacted.has_method("action_use"):
			interacted.action_use()

func _process(delta):
	process_camBob(delta)

	if floorCast.is_colliding():
		var walkingTerrain = floorCast.get_collider().get_parent()
		if walkingTerrain != null:
			var terrainGroup = walkingTerrain.get_groups()[0]
			#print(terrainGroup)
			processGroundSounds(terrainGroup)
	#print(floorCast.get_collider().get_parent())

func processGroundSounds(group: String):
	#Read state machine in the case that you also want the player to play sounds faster or slower
	#depending on if the player is running or crouching
	
	if isRunning:
		playFootstep = 3
	else:
		playFootstep = 6
	
	if playFootstep != 100 and (int(velocity.x) != 0) || (int(velocity.z) != 0):
		distanceFootstep += 0.1
	if distanceFootstep > playFootstep and is_on_floor():
		match group:
			"WoodTerrain":
				player_footstep_sound.stream = load("res://Player/SoundsFootsteps/wood/1.ogg")
			"Grass":
				player_footstep_sound.stream = load("res://Player/SoundsFootsteps/grass/1.ogg")
		player_footstep_sound.pitch_scale = randf_range(0.8, 1.2)
		player_footstep_sound.play()
		distanceFootstep = 0.0

func _physics_process(delta):
	process_movement(delta)
	
func process_movement(delta):
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	
	direction.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	direction.z = -Input.get_action_strength("ui_up") + Input.get_action_strength("ui_down")
	direction = Vector3(direction.x, 0, direction.z).rotated(Vector3.UP, h_rot).normalized()

	var actualSpeed = speed if !isRunning else speed*2
	velocity.x = direction.x * actualSpeed
	velocity.z = direction.z * actualSpeed

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump
	if !is_on_floor():
		velocity.y -= GRAVITY

	move_and_slide()

func process_camBob(delta):
	_delta += delta
	var cam_bob #speed
	var objCam  #how much up or down the camera moves
	if isRunning:
		cam_bob = floor(abs(direction.z) + abs(direction.x)) * _delta * camBobSpeed * 1.5
		objCam = origCamPos + Vector3.UP * sin(cam_bob) * camBobUpDown		
	elif direction != Vector3.ZERO: #The player is moving
		cam_bob = floor(abs(direction.z) + abs(direction.x)) * _delta * camBobSpeed
		objCam = origCamPos + Vector3.UP * sin(cam_bob) * camBobUpDown
	else: #player is not moving
		cam_bob = floor(abs(1) + abs(1)) * _delta * .6
		objCam = origCamPos + Vector3.UP * sin(cam_bob) * camBobUpDown * .1
	
	camera_3d.position = camera_3d.position.lerp(objCam, delta)
