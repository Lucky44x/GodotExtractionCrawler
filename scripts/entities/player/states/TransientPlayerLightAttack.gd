extends State

var combat_controller: CombatController
var equipment_controller: EquipmentManager

@export var stat_controller: StatController
@export var speed_stat: StatModifier

var trans_mod: StatModifierNode

var profile: AttackProfile

func _ready():
	combat_controller = $"../../CombatController"
	combat_controller.OnAttackFinished.connect(OnAttackFinished)
	equipment_controller = $"../../Equipment"

func OnAttackFinished(prof: AttackProfile):
	if prof != profile: return
	parent.pop_transient_state()

func Enter():
	trans_mod = stat_controller.add_stat_modifier(speed_stat)
	profile = equipment_controller.get_main_weapon().basic_light_attack
	combat_controller.BeginAttack(profile)

func Exit():
	trans_mod.die()

func Update(_delta: float):
	var abortAttack = false
	
	if Input.is_action_just_pressed("combat_block"):
		abortAttack = true
	
	if not abortAttack: return
	if not combat_controller.AbortAttack(): return
	parent.pop_transient_state()
