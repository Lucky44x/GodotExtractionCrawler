extends CharacterBody3D
class_name PlayerController

@export_group("Movement")
@export var camera_pivot : Node3D
@export_range(0.0, 25.0) var speed = 14

@export_group("Combat")
@export var current_target : Node3D

var target_velocity = Vector3.ZERO

func _physics_process(delta: float):
	handle_movement()
	handle_rotation()

func handle_movement():
	# Movement Dir
	var raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if raw_input == Vector2.ZERO:
		return
	
	var input_direction = Vector3(raw_input.x, 0, raw_input.y)

	var direction = Vector3.ZERO
	direction += camera_pivot.global_basis.x * input_direction.x
	direction += camera_pivot.global_basis.z * input_direction.z
	direction = direction.normalized()
	
	#basis = Basis.looking_at(direction)
	
	target_velocity = direction * speed
	
	velocity = target_velocity
	move_and_slide()

func handle_rotation():
	if not current_target:
		if target_velocity != Vector3.ZERO:
			basis = Basis.looking_at(target_velocity)
		return
	
	basis = Basis.looking_at((current_target.global_position - global_position) * Vector3(1, 0, 1))
