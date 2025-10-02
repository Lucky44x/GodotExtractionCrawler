extends BasicEntity
class_name CombatEntity

@onready var hit_controller: HitController = $HitController

@export var health_base_mod: StatModifier
@export var max_health_base_mod: StatModifier

@export var health_bar: ProgressBar3D

func _ready():
	if hit_controller != null: hit_controller._hit_resolve.connect(_on_hit)
	if stat_controller != null: 
		stat_controller.StatUpdated.connect(_on_stat_changed)
		stat_controller.ApplyModifier(max_health_base_mod)
		stat_controller.ApplyModifier(health_base_mod)

func _on_hit(hit_data: HitData):
	if hit_data.state != GameInfo.HitState.Accepted: return
	stat_controller.ApplyModifiers(hit_data.mods)

func _on_stat_changed(stat: GameInfo.StatType, val: float):
	if stat == GameInfo.StatType.Health: health_bar.SetValue(val)
	elif stat == GameInfo.StatType.MaxHealth: health_bar.SetRange(0, val)
