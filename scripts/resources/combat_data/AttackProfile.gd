@tool
extends Resource
class_name AttackProfile

@export var animation: String
@export var colliders: Array[HitscanCollider]
@export var hit_effects: Array[StatModifier]
@export var attack_type: GameInfo.AttackType : set = invalidate_type

var next_stance: StringName

# Charged State Specifics
var charging_entry_animation: String = ""
var charging_animation: String = ""
var begin_charge_time_ms: int = 50
var charging_tiers: Array[ChargeTier] = []
var heavy_charge_tier: ChargeTier : set = set_proxy_tier

#region Editor DATABASE link

# EDITOR OPTIONS TODO: Unload DB in build, for perf
const _db: Database = preload("res://dbs/combat.gddb")
var _tool_selected_category: int : set = _tool_invalidate_category
var _tool_selected_stance: int : set = _tool_invalidate_stance
var _tool_category_ids: Array
var _tool_stance_ids: Array

func _init():
	_tool_refresh_categories()

func _tool_setup_editor() -> Array:
	if not Engine.is_editor_hint(): return []
	if len(_tool_category_ids) == 0:
		_tool_refresh_categories()
	
	var ret = []
	##H Header
	ret.append({
		"name": &"Stance-Tool",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_CATEGORY
	})
	## Filter
	ret.append({
		"name": &"_tool_selected_category",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(_tool_category_ids)
	})
	## ID
	ret.append({
		"name": &"_tool_selected_stance",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(_tool_stance_ids)
	})
	return ret

func _tool_refresh_categories():
	var tmp_categories = (_db._collections_data[&"stance_profiles"][&"categories_to_ints"]) as Dictionary
	var arr = tmp_categories.keys()
	arr.push_front("None")
	_tool_category_ids = arr
	_tool_refresh_names()

func _tool_refresh_names():
	_tool_selected_stance = 0
	var ids = _db.fetch_collection_data(&"stance_profiles").keys()
	if _tool_selected_category > 0:
		ids = _db.fetch_category_data(&"stance_profiles", _tool_category_ids[_tool_selected_category]).keys()

	var translation_dict = _db._collections_data[&"stance_profiles"][&"ints_to_strings"] as Dictionary
	var ret: Array[StringName] = []
	for id in ids:
		ret.append(translation_dict[id])
	_tool_stance_ids = ret

func _tool_invalidate_category(new_cat: int):
	_tool_selected_category = new_cat
	_tool_refresh_names()
	notify_property_list_changed()

func _tool_invalidate_stance(new_id: int):
	if len(_tool_stance_ids) <= 0: return
	_tool_selected_stance = new_id
	next_stance = _tool_stance_ids[_tool_selected_stance]
	notify_property_list_changed()

#endregion

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
		GameInfo.AttackType.Charged:
			heavy_charge_tier = null
			charging_tiers.clear()
			pass
			#charging_tiers.clear()
	
	notify_property_list_changed()

func _get_property_list():
	if not Engine.is_editor_hint(): return []
	var ret = _tool_setup_editor()
	
	## Header
	ret.append({
		"name": &"Type-Specifics",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_CATEGORY
	})
	
	match(attack_type):
		GameInfo.AttackType.Light: return ret
		GameInfo.AttackType.Heavy: return ret # No big diff between light and heavy attacks, charge time is relegated to Input specifics instead
			# ret.append({ "name": &"begin_charge_time_ms", "class_name": &"", "type": TYPE_INT, "usage": 4102 })
			# ret.append({ "name": &"charging_entry_animation", "class_name": &"", "type": 4, "hint": 0, "hint_string": "", "usage": 4102 })
			# ret.append({ "name": &"charging_animation", "class_name": &"", "type": 4, "hint": 0, "hint_string": "", "usage": 4102 })
			# ret.append({
			#	"name": &"heavy_charge_tier",
			#	"class_name": &"ChargeTier",
			#	"type": TYPE_OBJECT,
			#	"hint": PROPERTY_HINT_RESOURCE_TYPE,
			#	"hint_string": "ChargeTier"
			#})
		GameInfo.AttackType.Charged:
			ret.append({ "name": &"begin_charge_time_ms", "class_name": &"", "type": TYPE_INT, "usage": 4102 })
			ret.append({ "name": &"charging_entry_animation", "class_name": &"", "type": 4, "hint": 0, "hint_string": "", "usage": 4102 })
			ret.append({ "name": &"charging_animation", "class_name": &"", "type": 4, "hint": 0, "hint_string": "", "usage": 4102 })
			ret.append({
				"name": &"charging_tiers",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "24/17:ChargeTier",
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})
			pass
	return ret
