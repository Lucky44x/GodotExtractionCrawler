extends State

var combat_controller: CombatController
var equipment_controller: EquipmentManager

@export var stat_controller: StatController
@export var speed_stat: StatModifier

var trans_mod: StatModifierNode

func _ready():
	combat_controller = $"../../CombatController"
	equipment_controller = $"../../Equipment"

func Enter():
	trans_mod = stat_controller.add_stat_modifier(speed_stat)

func Exit():
	trans_mod.die()

func Update(_delta: float):
	if Input.is_action_just_pressed("combat_block"):
		parent.pop_transient_state()
