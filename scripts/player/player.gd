extends CharacterBody3D

@export var speed: float = 6.0
@export var acceleration: float = 30.0
@export var deceleration: float = 20.0

@export var jump_force: float = 5

@export var sensibility: float = 0.25

@onready var camera_mount: Node3D = $camera_mount

var real_speed: float
var no_clip: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sensibility))
		camera_mount.rotation_degrees.x = clamp(camera_mount.rotation_degrees.x, -90, 89)
		
		rotate_y(deg_to_rad(-event.relative.x * sensibility))

func _physics_process(delta: float) -> void:
	movement(delta)
	if !no_clip:
		gravity(delta)
	
	move_and_slide()

func movement(d: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if dir:
		velocity.z = move_toward(velocity.z, dir.z * real_speed, acceleration * d)
		velocity.x = move_toward(velocity.x, dir.x * real_speed, acceleration * d)
		
		velocity.z = move_toward(velocity.z, dir.z * real_speed * 1.5, acceleration * d)
		velocity.x = move_toward(velocity.x, dir.x * real_speed * 1.5, acceleration * d)
	else:
		velocity.z = move_toward(velocity.z, 0, deceleration * d)
		velocity.x = move_toward(velocity.x, 0, deceleration * d)
	
	if Input.is_action_pressed("sprint"):
		$camera_mount/Camera3D.fov = 105
		real_speed = speed * 2
	elif !Input.is_action_pressed("sprint"):
		$camera_mount/Camera3D.fov = 90
		real_speed = speed
	
	if no_clip:
		# fly
		if Input.is_action_pressed("jump"):
			velocity.y = real_speed
		elif Input.is_action_pressed("ctrl"):
			velocity.y = -real_speed
		else:
			velocity.y = 0
		# camera
		
	if Input.is_action_just_pressed("no_clip") and !no_clip:
		no_clip = true
	elif Input.is_action_just_pressed("no_clip") and no_clip:
		no_clip = false


func gravity(d: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * d
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_force
