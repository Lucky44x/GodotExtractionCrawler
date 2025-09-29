@tool
extends ItemData
class_name WeaponData

@export var hit_modifiers: Array[StatModifier]
@export var initial_stance: StringName

#region Editor DATABASE link

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
	initial_stance = _tool_stance_ids[_tool_selected_stance]
	notify_property_list_changed()

#endregion

func _get_property_list() -> Array:
	if not Engine.is_editor_hint(): return []
	var ret = _tool_setup_editor()
	return ret
