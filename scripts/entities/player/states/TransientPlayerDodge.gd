extends State

@export var dodge_duration: float = 0.14 			# total seconds of the dodge
@export var peak_speed: float = 18.0				# units/sec
@export var control_blend_time: float = 0.06		# final window to lerp back to player control
@export var preserve_momentum: float = 0.2		# fraction of peak speed kep after dash ends
@export var dodge_curve: Curve					# curve for easing

var controller: PlayerController

var direction: Vector3
var current_vel = Vector3.ZERO
var dash_time: float = 0.0
var dashing: bool = false

func _ready():
	controller = $"../.."

func Enter():
	var inputDir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	direction = Vector3.ZERO
	direction += controller.camera_pivot.global_basis.x * inputDir.x
	direction += controller.camera_pivot.global_basis.z * inputDir.y
	if direction == Vector3.ZERO: direction = -controller.global_basis.z
	
	direction = direction.normalized()
	direction.z *= 1.5
	
	current_vel = Vector3.ZERO
	dash_time = 0.0
	dashing = true
	controller.locked = true
	
	if dodge_curve == null:
		dodge_curve = Curve.new()
		# simple default: hit peak early, then ease out
		dodge_curve.add_point(Vector2(0,0))
		dodge_curve.add_point(Vector2(0.25,1.0))
		dodge_curve.add_point(Vector2(1.0,0))

func Exit():
	current_vel = Vector3.ZERO
	dash_time = 0.0
	dashing = false
	controller.locked = false

func PhysicsUpdate(delta: float):
	if not dashing: return
	
	dash_time += delta
	var t = clamp(dash_time / max(dodge_duration, 0.0001), 0.0, 1.0)
	var curve_val = dodge_curve.sample(t)
	var frame_vel = direction * peak_speed * curve_val
	
	if dash_time > dodge_duration - control_blend_time:
		var blend_t = (dash_time - (dodge_duration - control_blend_time)) / max(control_blend_time, 0.0001)
		var blend = lerp(1.0, 0.0, clamp(blend_t, 0.0, 1.0))
		frame_vel *= blend
	
	controller.move_and_collide(frame_vel * delta)
	current_vel = frame_vel

	if dash_time >= dodge_duration:
		var leftover = direction * peak_speed * preserve_momentum * delta
		controller.move_and_collide(direction * -leftover)
		controller.locked = false
		parent.pop_transient_state()
