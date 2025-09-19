@tool
extends Resource
class_name AttackProfile

@export var animation: String
@export var colliders: Array[HitscanCollider]
@export var attack_type: GameInfo.AttackType : set = invalidate_type

## Charged State Specifics
var charging_animation: String
var begin_charge_time_ms: int
var charging_tiers: Array[ChargeTier] = []
var heavy_charge_tier: ChargeTier : set = set_proxy_tier

func set_proxy_tier(tier: ChargeTier):
	if len(charging_tiers) != 1: charging_tiers.resize(1)
	charging_tiers.set(0, tier)
	heavy_charge_tier = tier

func invalidate_type(newType):
	attack_type = newType
	match(attack_type):
		GameInfo.AttackType.Light:
			heavy_charge_tier = null
			charging_tiers = []
		GameInfo.AttackType.Heavy:
			charging_tiers.clear()
			charging_tiers.resize(1)
		GameInfo.AttackType.Charged:
			heavy_charge_tier = null
			charging_tiers.clear()
			pass
			#charging_tiers.clear()
	
	notify_property_list_changed()

func _get_property_list():
	if not Engine.is_editor_hint(): return []
	var ret = []
	match(attack_type):
		GameInfo.AttackType.Light: return []
		GameInfo.AttackType.Heavy: 
			ret.append({
				"name": &"charging_animation",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_TYPE_STRING
			})
			ret.append({
				"name": &"heavy_charge_tier",
				"class_name": &"ChargeTier",
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "ChargeTier"
			})
		GameInfo.AttackType.Charged:
			ret.append({
				"name": &"charging_animation",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_TYPE_STRING
			})
			ret.append({
				"name": &"charging_tiers",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "24/17:ChargeTier",
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})
			pass
	return ret
