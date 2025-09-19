extends State

@export var stat_controller: StatController
@export var walking_stat: StatModifier
@export var stamina_stat: StatModifier

func _ready():
	await get_tree().process_frame
	stat_controller.add_stat_modifier(walking_stat)
	stat_controller.add_stat_modifier(stamina_stat)

func Update(_delta: float):
	if Input.is_action_just_pressed("lock_enemy"): parent.state_transition(self, "combat")
	elif Input.is_action_pressed("combat_dodge"): parent.push_transient_state(self, "trans_running")
