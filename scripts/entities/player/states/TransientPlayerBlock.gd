extends State

@onready var block_controller: BlockController = $"../../BlockController"

@export var stat_controller: StatController
@export var speed_stat: StatModifier

var trans_mod: StatModifierNode

func Enter():
	trans_mod = stat_controller.ApplyModifier(speed_stat)
	block_controller.BeginBlocking()
	
func Exit():
	trans_mod.die()
	block_controller.EndBlocking()

func Update(_delta: float):
	if not Input.is_action_pressed("combat_block"): parent.pop_transient_state()
