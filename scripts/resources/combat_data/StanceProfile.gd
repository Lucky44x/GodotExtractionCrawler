@tool
extends Resource
class_name StanceProfile

@export var stance_animation: String
@export var next_light_attacks: Array[StringName]
@export var next_heavy_attacks: Array[StringName]

#region Editor DATABASE link

# EDITOR OPTIONS TODO: Unload DB in build, for perf
const _db: Database = preload("res://dbs/combat.gddb")
var _tool_selected_category: int : set = _tool_invalidate_category
var _tool_selected_attack: int : set = _tool_invalidate_attack
var _tool_category_ids: Array
var _tool_attack_ids: Array
var _tool_add_attack_button = _tool_add_attack

func _init():
	_tool_refresh_categories()

func _tool_add_attack():
	var selected_name: StringName = _tool_attack_ids[_tool_selected_attack]
	var ref: AttackProfile = _db.fetch_data(&"attack_profiles", selected_name)
	
	if ref.attack_type == GameInfo.AttackType.Light:
		if next_light_attacks.has(selected_name):
			push_warning("Light-Attack with id ", selected_name, " is already present for this state")
			return
		next_light_attacks.append(_tool_attack_ids[_tool_selected_attack])
	elif ref.attack_type == GameInfo.AttackType.Heavy:
		if next_heavy_attacks.has(selected_name):
			push_warning("Heavy-Attack with id ", selected_name, " is already present for this state")
			return
		next_heavy_attacks.append(_tool_attack_ids[_tool_selected_attack])
	else:
		push_error("AttackProfile is set to charged... please configure properly (Or finally add Charged Attacks to Stance Profiles)")
	
	notify_property_list_changed()

func _tool_setup_editor() -> Array:
	if not Engine.is_editor_hint(): return []
	if len(_tool_category_ids) == 0:
		_tool_refresh_categories()
	
	var ret = []
	## Header
	ret.append({
		"name": &"Attack-Tool",
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
		"name": &"_tool_selected_attack",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(_tool_attack_ids)
	})
	
	ret.append({ "name": "_tool_add_attack_button", "class_name": &"", "type": 25, "hint": 39, "hint_string": "Add Attack-Profile,ToolAddNode", "usage": 4100 })
	return ret

func _tool_refresh_categories():
	var tmp_categories = (_db._collections_data[&"attack_profiles"][&"categories_to_ints"]) as Dictionary
	var arr = tmp_categories.keys()
	arr.push_front("None")
	_tool_category_ids = arr
	_tool_refresh_names()

func _tool_refresh_names():
	_tool_selected_attack = 0
	var ids = _db.fetch_collection_data(&"attack_profiles").keys()
	if _tool_selected_category > 0:
		ids = _db.fetch_category_data(&"attack_profiles", _tool_category_ids[_tool_selected_category]).keys()

	var translation_dict = _db._collections_data[&"attack_profiles"][&"ints_to_strings"] as Dictionary
	var ret: Array[StringName] = []
	for id in ids:
		ret.append(translation_dict[id])
	_tool_attack_ids = ret

func _tool_invalidate_category(new_cat: int):
	_tool_selected_category = new_cat
	_tool_refresh_names()
	notify_property_list_changed()

func _tool_invalidate_attack(new_id: int):
	_tool_selected_attack = new_id
	notify_property_list_changed()

#endregion

func _get_property_list():
	if not Engine.is_editor_hint(): return []
	var ret = _tool_setup_editor()
	return ret
