extends State

@export var player_combat_speed = 7

var controller: PlayerController
var target: Node3D

func _ready():
	controller = $"../.."

func Enter():
	# Slow player down during combat
	controller.speed = player_combat_speed
	# Lock onto the closest Enemy
	target = get_closest_enemy()
	if not target: 
		parent.state_transition(self, "walking")
		return
	
	controller.current_target = target

func Exit():
	controller.current_target = null

func Update(_delta: float):
	if Input.is_action_pressed("combat_block"): parent.push_transient_state(self, "trans_block")
	elif Input.is_action_just_pressed("lock_enemy"): parent.state_transition(self, "walking")
	elif Input.is_action_just_pressed("combat_dodge"): parent.push_transient_state(self, "trans_dodge")
	elif Input.is_action_just_released("combat_attack"):
		# Check if strong attack or light attack
		parent.push_transient_state(self, "trans_attack")

func get_closest_enemy() -> Node3D:
	var targets = $LockonArea.get_overlapping_bodies()
	if not targets or len(targets) <= 0: return null
	
	var closestTarget: Node3D
	var closestDistance: float
	for obj in targets:
		var dist = controller.global_position.distance_squared_to(obj.global_position)
		if closestTarget == null or closestDistance > dist:
			closestTarget = obj
			closestDistance = dist
	
	return closestTarget
