extends State

@export var player_blocking_speed = 1.5

var controller: PlayerController
var previous_speed: float

func _ready():
	controller = $"../.."

func Enter():
	# Slow player down during bocking, but remember previous speed to reset on exit
	previous_speed = controller.speed
	controller.speed = player_blocking_speed

func Exit():
	controller.speed = previous_speed

func Update(_delta: float):
	if not Input.is_action_pressed("combat_block"): parent.pop_transient_state()
