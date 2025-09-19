extends State

@export var stat_controller: StatController
@export var speed_stat: StatModifier
@export var stamina_mod: StatModifier

var trans_mod: StatModifierNode
var trans_stamina_mod: StatModifierNode

func Enter():
	trans_mod = stat_controller.add_stat_modifier(speed_stat)
	trans_stamina_mod = stat_controller.add_stat_modifier(stamina_mod)

func Exit():
	trans_mod.die()
	trans_stamina_mod.die()

func Update(_delta: float):
	if Input.is_action_just_pressed("lock_enemy"): parent.state_transition(self, "combat")
	elif not Input.is_action_pressed("combat_dodge"): parent.pop_transient_state()
