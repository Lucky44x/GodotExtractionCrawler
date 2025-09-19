extends CharacterBody3D
class_name PlayerController

@export var stat_controller: StatController

@export_group("Movement")
@export var locked : bool
@export var camera_pivot : Node3D

@export_group("Combat")
@export var current_target : Node3D

var target_velocity = Vector3.ZERO

func _physics_process(delta: float):
	handle_movement()
	handle_rotation()

func handle_movement():
	if locked: return
	
	# Movement Dir
	#get_actual_input_vector("move_left", "move_right", "move_up", "move_down")
	var raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if raw_input == Vector2.ZERO:
		return

	var direction = Vector3.ZERO
	direction += camera_pivot.global_basis.x * (raw_input.x / 1.5)
	direction += camera_pivot.global_basis.z * raw_input.y
	
	target_velocity = direction * stat_controller.GetStat(GameInfo.StatType.Speed)
	
	velocity = lerp(velocity, target_velocity, 0.5)
	move_and_slide()

func handle_rotation():
	if not current_target:
		if target_velocity != Vector3.ZERO:
			basis = lerp(basis, Basis.looking_at(target_velocity), 0.25)
		return
	
	basis = lerp(basis, Basis.looking_at((current_target.global_position - global_position) * Vector3(1, 0, 1)), 0.25)
