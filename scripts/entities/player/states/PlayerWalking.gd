extends State

@export var player_walk_speed = 14

var controller: PlayerController

func _ready():
	controller = $"../.."

func Enter():
	# Reset Players speed to original value
	controller.speed = player_walk_speed

func Update(_delta: float):
	if Input.is_action_just_pressed("lock_enemy"): parent.state_transition(self, "combat")
	elif Input.is_action_pressed("combat_dodge"): parent.push_transient_state(self, "trans_running")
