extends CharacterBody3D
class_name Member3D

enum MemberType {
	HEAD,
	TORSO,
	ARM,
	LEG
}

@export var member_type: MemberType
@export var oil_particles: CPUParticles3D
@export var robot: Robot3D
@export var lost_oil_per_second: float = 1.0
@export var HP: float = 30
@export var mesh: MeshInstance3D
@export var collision: CollisionShape3D

var destroyed: bool = false

func _physics_process(delta: float) -> void:
	if HP <= 0:
		destroy()
	if destroyed:
		start_oil_leak(delta)

func destroy() -> void:
	destroyed = true
	mesh.visible = false
	collision.disabled = true

func start_oil_leak(delta):
	if oil_particles: 
		if robot.oil > 0:
			oil_particles.emitting = true
		else:
			oil_particles.emitting = false
		
	if robot.oil > 0:
		robot.oil -= lost_oil_per_second * delta
