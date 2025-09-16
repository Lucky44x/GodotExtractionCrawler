extends State

var equipment_handler: Node
var controller : PlayerController

func _ready():
	equipment_handler = $"../../Equipment"
	controller = $"../.."
	equipment_handler.animator.animation_finished.connect(on_action_finished)

func on_action_finished(_arg: String):
	Transitioned.emit(self, "combat", true, false)

func Enter():
	equipment_handler.hitscan_callback.connect(on_hitscan_connect)
	equipment_handler.perform_action("combat/light_attack_R")
	controller.speed = 1.5
	#controller.locked = true

func Exit():
	equipment_handler.hitscan_callback.disconnect(on_hitscan_connect)
	controller.speed = 7
	#controller.locked = false

func Update(delta: float):
	if Input.is_action_just_pressed("combat_dodge"):
		equipment_handler.abort_action()
		Transitioned.emit(self, "dodge", false, false)

func on_hitscan_connect(collision):
	print("Hit ", collision)
	Input.start_joy_vibration(0, 0.25, 0, 0.1)
