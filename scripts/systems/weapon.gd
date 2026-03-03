extends Node3D
class_name Weapon3D

@export var infinite_ammo: bool = false
@export var fire_range: float
@export var bullets: int
@export var fire_rate: float
@export var reload_time: float
@export var ray: RayCast3D
@export var bullets_label: Label
@export var shoot_sound: AudioStreamPlayer3D
@export var damage: float = 10
@export var camera: Camera3D
@export var animation_player: AnimationPlayer

var can_shoot: bool = true
var remaining_bullets: int
var reloading: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	remaining_bullets = bullets
	ray.target_position = Vector3(0.0, 0.0, -fire_range)
	


func _physics_process(delta: float) -> void:
	if visible:
		if Input.is_action_just_pressed("LMB"):
			if not infinite_ammo:
				if remaining_bullets > 0:
					fire()
				else:
					reload()
			elif infinite_ammo:
				fire()
		
		if Input.is_action_just_pressed("reload"):
			reload()
		if reloading:
			bullets_label.text = "Balas: " + "Recarregando..."
		elif infinite_ammo:
			bullets_label.text = "Balas: " + "infinitas"
		else:
			bullets_label.text = "Balas: " + str(remaining_bullets)

func fire_rate_time():
	can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func fire():
	if can_shoot:
		if animation_player:
			animation_player.play("shoot")
		camera.trigger_shake()
		shoot_sound.play()
		remaining_bullets -= 1
		if ray.is_colliding():
			var collision_point = ray.get_collision_point()
			var collider = ray.get_collider()

			if collider is Member3D:
				collider.HP -= damage
				 
			if collider is RigidBody3D:
				var local_point = collider.to_local(collision_point)
				var force = -ray.global_transform.basis.z * damage
				collider.apply_impulse(force, local_point)
			
		fire_rate_time()


func reload():
	reloading = true
	
	await get_tree().create_timer(reload_time).timeout
	
	reloading = false
	remaining_bullets = bullets

func reset_weapon() -> void:
	can_shoot = true
	reloading = false

	if ray:
		ray.target_position = Vector3(0.0, 0.0, -fire_range)

	if bullets_label:
		bullets_label.text = "Balas: " + str(remaining_bullets)
