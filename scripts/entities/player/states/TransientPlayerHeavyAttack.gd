extends State

@onready var attack_controller: AttackController = $"../../AttackController"
@onready var combo_controller: ComboController = $"../../ComboController"
@onready var stat_controller: StatController = $"../../StatController"
@export var speed_stat: StatModifier

var trans_mod: StatModifierNode

var profile: AttackProfile

func _ready():
	attack_controller.OnAttackFinished.connect(OnAttackFinished)

func OnAttackFinished(prof: AttackProfile):
	if prof != profile: return
	parent.pop_transient_state()

func Enter():
	trans_mod = stat_controller.ApplyModifier(speed_stat)
	profile = combo_controller.choose_next_heavy_attack()
	if profile == null:
		parent.pop_transient_state()
		return
	
	attack_controller.BeginAttack(profile)

func Exit():
	trans_mod.die()

func Update(_delta: float):
	var abortAttack = false
	
	if Input.is_action_just_pressed("combat_block"):
		abortAttack = true
	
	if not abortAttack: return
	if not attack_controller.AbortAttack(): return
	parent.pop_transient_state()
