@tool
extends Resource
class_name StatModifier

## When set to LogicHook, will call the function_name on the effect-subject. This will require said function to take the following parameters:
##
## - One float, that is passed into the function via the falloff curve if applicable
## - All of the custom arguments defined on the hook in the inspector
##
## Should these requirements not be met, the additional arguments of the inspector will be ignored and only the falloff value will be passed
##
## Keep in mind, this function will be called on the effect-subject NOT on the effect-holder (A sword may hold this effect, but it could be applied to it's hit target)
@export var target_stat: GameInfo.StatType : set = invalidate_stat_type
@export var modifier_operation: GameInfo.ModifierOperation
@export var modifier_value: float
@export_range(0, 1, 0.05) var modifier_activation_prob: float = 1

@export var modifier_stacking_rule: GameInfo.ModifierStackingRule
@export var modifier_stacking_space: GameInfo.ModifierStackingSpace

@export var modifier_type: GameInfo.ModifierType : set = invalidate_mod_type

var modifier_id: String
var modifier_tier: int

var hook_function: String
var hook_args: Array

## If negative -> will run indefinetly
var duration_ms: int = 1000
var falloff_operation: Curve
var falloff_tracked_property: GameInfo.ModifierFalloffTarget
var falloff_linked_stat: GameInfo.StatType
var recurring_frequency_ms: int = 250

#@export_tool_button("Tests") var b = test

func test():
	print(get_script().get_script_property_list())

func invalidate_stat_type(newType: GameInfo.StatType):
	target_stat = newType
	notify_property_list_changed()

func invalidate_mod_stack(newStack: GameInfo.ModifierStackingRule):
	modifier_stacking_rule = newStack
	notify_property_list_changed()

func invalidate_mod_type(newMod: GameInfo.ModifierType):
	modifier_type = newMod
	notify_property_list_changed()

func _get_property_list():
	if not Engine.is_editor_hint(): return []
	var ret = []
	
	if not modifier_type == GameInfo.ModifierType.Oneshot:
		ret.append({ "name": &"modifier_id", "class_name": &"", "type": 4, "hint": 0, "hint_string": "", "usage": 4102 })
		ret.append({ "name": &"modifier_tier", "class_name": &"", "type": TYPE_INT, "hint": 0, "hint_string": "", "usage": 4102 })
	
	# if target_stat == GameInfo.StatType.LogicHook:
	#	ret.append({ "name": &"hook_function", "class_name": &"", "type": 4, "hint": 0, "hint_string": "", "usage": 4102 })
	#	ret.append({ "name": &"hook_args", "class_name": &"", "type": 28, "hint": 0, "hint_string": "", "usage": 4102 })
	
	if modifier_type == GameInfo.ModifierType.Timed or modifier_type == GameInfo.ModifierType.Recurring:
		ret.append({
			"name": &"duration_ms",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT
		})
		ret.append({ 
			"name": &"falloff_operation", 
			"class_name": &"Curve", 
			"type": 24, 
			"hint": 17, 
			"hint_string": "Curve", 
			"usage": 4102 
		})
		ret.append({
			"name": &"falloff_tracked_property", 
			"class_name": &"GameInfo.ModifierFalloffTarget", 
			"type": 2, 
			"hint": 2, 
			"hint_string": ",".join(GameInfo.ModifierFalloffTarget.keys()), 
			"usage": 69638 
		})
		ret.append({ 
			"name": &"falloff_linked_stat", 
			"class_name": &"GameInfo.StatType", 
			"type": 2, 
			"hint": 2, 
			"hint_string": ",".join(GameInfo.StatType.keys()), 
			"usage": 69638 
		})
	
	if modifier_type == GameInfo.ModifierType.Recurring:
		ret.append({
			"name": &"recurring_frequency_ms",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	return ret
