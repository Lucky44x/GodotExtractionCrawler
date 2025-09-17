extends State

@export var player_attacking_speed = 1.5

var controller: PlayerController
var combat_controller: CombatController
var equipment_controller: EquipmentManager
var previous_speed: float

func _ready():
	controller = $"../.."
	combat_controller = $"../../CombatController"
	equipment_controller = $"../../Equipment"

func Enter():
	# Slow player down during bocking, but remember previous speed to reset on exit
	previous_speed = controller.speed
	controller.speed = player_attacking_speed

func Exit():
	controller.speed = previous_speed

func Update(_delta: float):
	if Input.is_action_just_pressed("combat_block"):
		parent.pop_transient_state()
