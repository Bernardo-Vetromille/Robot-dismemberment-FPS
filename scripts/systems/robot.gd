extends CharacterBody3D
class_name Robot3D

@export var speed: float = 6.0
@export var player: CharacterBody3D
@export var oil: float = 100
@export var label: Label3D
@export var head: Member3D
@export var floor_ray: RayCast3D
@export var vision_ray: RayCast3D


var base_speed: float
var members: Array[Member3D]
var has_torso: bool
var legs: int
var arms: int
var heads: int

var is_locked: bool = false

func _ready() -> void:
	base_speed = speed
	for child in get_children():
		if child is Member3D:
			members.append(child)
#
func _physics_process(delta: float) -> void:
	label.text = "Oil: " + "%.1f" % oil
	
	has_torso = false
	
	for member in members:
		if member.member_type == Member3D.MemberType.TORSO and !member.destroyed:
			has_torso = true
			break
	
	if !has_torso:
		oil = 0.0
		for member in members:
			if member.member_type != Member3D.MemberType.LEG:
				member.destroy()
	
	for member in members:
		match member.member_type:
			Member3D.MemberType.HEAD:
				heads += 1
			Member3D.MemberType.LEG:
				legs += 1
			Member3D.MemberType.ARM:
				arms += 1
	
	if oil <= 0:
		is_locked = true
	
	if !is_locked:
		movement(delta)
		uptade_speed()
	else:
		velocity = Vector3.ZERO
	
	gravity(delta)
	search_player()
	move_and_slide()

func movement(delta):
	if player:
		var dir = (player.global_position - global_position).normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		head.look_at(player.global_position)
		
		var target_position = player.global_transform.origin
		# Mantém a altura atual do robô (y) para não olhar pra cima ou pra baixo
		target_position.y = global_transform.origin.y
		look_at(target_position, Vector3.UP)
	
func gravity(delta):
	floor_ray.force_raycast_update()
	if floor_ray.is_colliding():
		velocity.y = 0.0
	else:
		velocity += get_gravity() * delta
	
func uptade_speed(): 
	var legs := get_alive_legs()
	if legs == 2:
		speed = base_speed
	elif legs == 1:
		speed = base_speed * 0.5
	else:
		start_stun()
		speed = 0.2

func get_alive_legs() -> int:
	var count := 0
	for m in members:
		if m.member_type == Member3D.MemberType.LEG and not m.destroyed:
			count += 1
	return count

func search_player():
	vision_ray.force_raycast_update()
	if vision_ray.is_colliding():
		if vision_ray.get_collider().is_in_group("player"):
			player = vision_ray.get_collider()

func start_stun():
	floor_ray.target_position = Vector3(0,-0.4,0)
	$torso.rotation_degrees.x = -85
	$head.position = Vector3(0.0, 0.124, -0.577)
	$"left arm".rotation_degrees.x = 85
	$"rigth arm".rotation_degrees.x = 85
	$"left arm".position.z = -0.5
	$"rigth arm".position.z = -0.5
	
