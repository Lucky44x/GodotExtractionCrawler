extends State

var combat_controller: CombatController

@export var stat_controller: StatController
@export var speed_stat: StatModifier

var trans_mod: StatModifierNode

func _ready():
	combat_controller = $"../../CombatController"

func Enter():
	trans_mod = stat_controller.add_stat_modifier(speed_stat)
	combat_controller.StartBlocking()
	
func Exit():
	trans_mod.die()
	combat_controller.EndBlocking()

func Update(_delta: float):
	if not Input.is_action_pressed("combat_block"): parent.pop_transient_state()
