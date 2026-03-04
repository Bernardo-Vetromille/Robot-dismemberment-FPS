extends CharacterBody3D
class_name Robot3D

@export var speed: float = 6.0
@export var player: CharacterBody3D
@export var nf_player: CharacterBody3D
@export var oil: float = 100
@export var label: Label3D
@export var head: Member3D
@export var floor_ray: RayCast3D
@export var vision_ray: RayCast3D
@export var vision_area: Area3D
@export var look_at_player: bool

var base_speed: float
var members: Array[Member3D]
var has_torso: bool
var legs: int
var arms: int
var heads: int
var is_in_vision: bool = false
var is_locked: bool = false

enum States {
	IDLE,
	WALK,
	JUMP,
	CHASE,
	ATTACK,
	LOCK
}

var state: States = States.IDLE

func _ready() -> void:
	base_speed = speed
	for child in get_children():
		if child is Member3D:
			members.append(child)

func _physics_process(delta: float) -> void:
	
	gravity(delta)
	
	match state:
		States.IDLE:
			idle_behavior()
		States.WALK:
			walk_behavior()
		States.CHASE:
			chase_behavior()

	move_and_slide()

func idle_behavior():
	search_player()
	if player:
		state = States.CHASE
	else: 
		await get_tree().create_timer(1).timeout
		state = States.WALK
	

func walk_behavior():
	var dir = randi_range(0, 4)
	
	if dir == 0:
		rotate_y(deg_to_rad(90))
		velocity.z = speed
		await get_tree().create_timer(1).timeout
	elif dir == 1:
		rotate_y(deg_to_rad(180))
		velocity.z = speed
		await get_tree().create_timer(1).timeout
	elif dir == 2:
		rotate_y(deg_to_rad(260))
		velocity.z = speed
		await get_tree().create_timer(1).timeout
	elif dir == 3:
		rotate_y(deg_to_rad(360))
		velocity.z = speed
		await get_tree().create_timer(1).timeout
	
	
	state = States.IDLE

func chase_behavior():
	look_at(player.global_position)
	head.look_at(player.global_position)
	global_rotation.x = 0.0
	
	var dir = (player.global_position - global_position).normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

func jump_behavior():
	pass

func attack_behavior():
	pass

func lock_behavior():
	pass

func search_player():
	var colliders = vision_area.get_overlapping_bodies()
	
	if colliders:
		for collider in colliders: 
			if collider.is_in_group("player"):
				head.look_at(collider.global_position)
				player = collider

func gravity(delta):
	floor_ray.force_raycast_update()
	if floor_ray.is_colliding():
		velocity.y = 0
	else:
		velocity += get_gravity() * delta
