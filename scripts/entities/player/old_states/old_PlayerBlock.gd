extends State

var equipment_handler: Node
var controller : PlayerController

func _ready():
	equipment_handler = $"../../Equipment"
	controller = $"../.."
	equipment_handler.animator.animation_finished.connect(on_action_finished)

func Enter():
	if Input.is_action_just_pressed("combat_block"): equipment_handler.perform_action("combat/block_enter_R")
	else: equipment_handler.perform_action("combat/block_R")
	
	equipment_handler.blocking_since = Time.get_ticks_msec()
	controller.speed = 1.5

func Exit():
	equipment_handler.blocking_since = -1
	equipment_handler.perform_action("RESET")

func Update(delta: float):
	if not Input.is_action_pressed("combat_block"):
		Transitioned.emit(self, "combat")
	
	if Input.is_action_just_pressed("combat_attack"):
		Transitioned.emit(self, "light_attack")

func on_action_finished(id: String):
	if id == "combat/block_enter_R":
		equipment_handler.perform_action("combat/block_R")
