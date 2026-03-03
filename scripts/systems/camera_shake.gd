extends Camera3D

@export var max_shake: float = 0.1
@export var shake_fade: float = 10.0

var shake_strength: float = 0.0

func trigger_shake() -> void:
	shake_strength = max_shake

func _physics_process(delta: float) -> void:
	if shake_strength > 0.0:
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		
		h_offset = randf_range(-shake_strength, shake_strength)
		v_offset = randf_range(-shake_strength, shake_strength)
