extends State

@export var player_run_speed = 20

var controller: PlayerController
var previousSpeed: float

func _ready():
	controller = $"../.."

func Enter():
	# Set player speed to running-speed and cache previous speed for deinit
	previousSpeed = controller.speed
	controller.speed = player_run_speed

func Exit():
	controller.speed = previousSpeed

func Update(_delta: float):
	if Input.is_action_just_pressed("lock_enemy"): parent.state_transition(self, "combat")
	elif not Input.is_action_pressed("combat_dodge"): parent.pop_transient_state()
