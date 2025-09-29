extends State

@onready var stat_controller: StatController = $"../../StatController"
@onready var controller: PlayerController = $"../.."
@onready var combo_controller: ComboController = $"../../ComboController"

@export var speed_stat: StatModifier

@export var heavy_attack_hold_time_ms: int

var trans_mod: StatModifierNode

var target: Node3D

var begin_attack_input: int = 0
var heavy_notified: bool = false

func _ready():
	controller = $"../.."

func Enter():
	trans_mod = stat_controller.add_stat_modifier(speed_stat)
	# Initialize Combo Controller
	combo_controller.intialize_state()
	
	# Lock onto the closest Enemy
	target = get_closest_enemy()
	if not target: 
		parent.state_transition(self, "walking")
		return
	
	controller.current_target = target

func Exit():
	trans_mod.die()
	controller.current_target = null

func Update(_delta: float):
	if Input.is_action_pressed("combat_block"): parent.push_transient_state(self, "trans_block")
	elif Input.is_action_just_pressed("lock_enemy"): parent.state_transition(self, "walking")
	elif Input.is_action_just_pressed("combat_dodge"): parent.push_transient_state(self, "trans_dodge")
	elif Input.is_action_just_pressed("combat_attack"):
		begin_attack_input = Time.get_ticks_msec()
	
	if begin_attack_input > -1:
		var hold_time = Time.get_ticks_msec() - begin_attack_input
		if hold_time > heavy_attack_hold_time_ms and not heavy_notified:
			heavy_notified = true
			Input.start_joy_vibration(0, 0.25, 0.1, 0.1)
		
		if Input.is_action_just_released("combat_attack"):
			if heavy_notified:
				parent.push_transient_state(self, "trans_attack_heavy")
			else:
				parent.push_transient_state(self, "trans_attack_light")
			heavy_notified = false
			begin_attack_input = -1

func get_closest_enemy() -> Node3D:
	var targets = $LockonArea.get_overlapping_bodies()
	if not targets or len(targets) <= 0: return null
	
	var closestTarget: Node3D = null
	var closestDistance: float
	for obj in targets:
		var dist = controller.global_position.distance_squared_to(obj.global_position)
		if closestTarget == null or closestDistance > dist:
			closestTarget = obj
			closestDistance = dist
	
	return closestTarget
