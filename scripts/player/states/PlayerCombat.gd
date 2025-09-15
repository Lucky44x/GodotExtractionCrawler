extends State
var controller : PlayerController

func _ready():
	controller = $"../.."

func Enter():
	controller.speed = 7
	var target = get_enemy()
	if not target:
		Transitioned.emit(self, "exploration")
		return
	
	controller.current_target = target

func Exit():
	controller.current_target = null

func Update(delta: float):
	if Input.is_action_just_pressed("lock_enemy"): Transitioned.emit(self, "exploration")
	if Input.is_action_just_pressed("combat_dodge"): Transitioned.emit(self, "dodge", false, true)
	if Input.is_action_pressed("combat_block"): Transitioned.emit(self, "block", false, true)
	if Input.is_action_just_released("combat_attack"): Transitioned.emit(self, "light_attack", false, true)

func get_enemy() -> Node3D:
	# Set tracking-target to closest enemy
	var enemies = $LockonArea.get_overlapping_bodies()
	if len(enemies) == 0: 
		return null

	var target = find_closest_node(enemies).get_parent_node_3d()	
	return target

func find_closest_node(arr: Array[Node3D]) -> Node3D:
	var closestNode : Node3D
	var closestDist : float = 0.0
	for node in arr:
		var mydist = node.global_position.distance_squared_to(controller.global_position)
		
		if closestNode == null:
			closestNode = node
			closestDist = mydist
			continue
		elif mydist < closestDist:
			closestNode = node
			closestDist = mydist
	
	return closestNode
