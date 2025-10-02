extends NodePoolInstance
class_name StatModifierNode

@export var should_die: bool
@export var start_time: int
@export var elapsed_time: int
@export var duration: int
@export var last_recursion_time: int
@export var modifier_data: StatModifier

func setup(mod: StatModifier):
	modifier_data = mod
	elapsed_time = 0
	should_die = false
	start_time = Time.get_ticks_msec()
	last_recursion_time = 0

func is_oneshot() -> bool: return modifier_data.modifier_type == GameInfo.ModifierType.Oneshot
func stacking() -> GameInfo.ModifierStackingRule: return modifier_data.modifier_stacking_rule
func operation() -> GameInfo.ModifierOperation: return modifier_data.modifier_operation

func die():
	should_die = true

func update():
	match(modifier_data.modifier_type):
		GameInfo.ModifierType.Oneshot: should_die = true
		GameInfo.ModifierType.Timed: update_timed()
		GameInfo.ModifierType.Recurring: update_timed()

func update_timed():
	elapsed_time = Time.get_ticks_msec() - start_time
	if elapsed_time > duration and duration > 0: should_die = true

func sample(controller: StatController) -> float:
	var mult: float = 1
	if modifier_data.falloff_tracked_property != GameInfo.ModifierFalloffTarget.None and modifier_data.falloff_operation != null:
		var falloff_value: float = 0.0
		if modifier_data.falloff_tracked_property == GameInfo.ModifierFalloffTarget.Duration:
			if duration != 0:
				falloff_value = duration as float / elapsed_time
		else:
			falloff_value = clamp(controller.GetStat(modifier_data.target_stat) / controller.GetStat(modifier_data.falloff_linked_stat), 0, 1)
		mult = modifier_data.falloff_operation.sample(falloff_value)
	
	match(modifier_data.modifier_type):
		GameInfo.ModifierType.Oneshot: 
			should_die = true
			return modifier_data.modifier_value * mult
		GameInfo.ModifierType.Timed:
			update_timed()
			if should_die: return 0.0
			return modifier_data.modifier_value * mult
		GameInfo.ModifierType.Recurring:
			update_timed()
			var value = 0.0
			if elapsed_time - last_recursion_time >= modifier_data.recurring_frequency_ms:
				# Push value and reset timing
				value = modifier_data.modifier_value
				last_recursion_time = elapsed_time
			return value * mult
	return 0.0
