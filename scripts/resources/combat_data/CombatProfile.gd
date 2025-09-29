@tool
extends Resource
class_name CombatProfile

## Global Combat Database for better control
var db: Database = preload("res://dbs/combat.gddb")

@export var attack_dict: Dictionary
@export var stance_dict: Dictionary

# Tool - Specific
var is_adding_attack: bool
var is_adding_stance: bool

var _tool_filter_field: int : set = _tool_invalidate_category_id
var categories: Array
var data_ids: Array

var _tool_id_field: int : set = _tool_invalidate_id
var _tool_name_field: String

var _tool_cancel_button = _tool_cancel_addition
var _tool_confirm_button = _tool_confirm_addition
var _tool_add_attack_button = _tool_add_attack
var _tool_add_stance_button = _tool_add_stance

@export_category("Editor")

func test():
	print(get_script().get_script_property_list())

func _tool_invalidate_category_id(newint: int):
	_tool_filter_field = newint
	_tool_id_field = 0
	if is_adding_attack:
		_tool_get_data_entries("attack_profiles")
	elif is_adding_stance:
		_tool_get_data_entries("stance_profiles")
	property_list_changed.emit()

func _tool_invalidate_id(newid: int):
	_tool_id_field = newid
	if newid == len(data_ids): return
	_tool_name_field = data_ids[newid]

func _tool_add_stance():
	if is_adding_attack: return
	_tool_get_categories("stance_profiles")
	_tool_get_data_entries("stance_profiles")
	is_adding_stance = true
	property_list_changed.emit()

func _tool_add_attack():
	if is_adding_stance: return
	_tool_get_categories("attack_profiles")
	_tool_get_data_entries("attack_profiles")
	is_adding_attack = true
	property_list_changed.emit()

func _tool_confirm_addition():
	if not is_adding_attack and not is_adding_stance: return
	if is_adding_attack:
		attack_dict.set(_tool_name_field, db.fetch_data("attack_profiles", data_ids[_tool_id_field] as StringName))
	elif is_adding_stance:
		stance_dict.set(_tool_name_field, db.fetch_data("stance_profiles", data_ids[_tool_id_field] as StringName))
	
	is_adding_stance = false
	is_adding_attack = false
	property_list_changed.emit()

func _tool_cancel_addition():
	is_adding_attack = false
	is_adding_stance = false
	categories.clear()
	data_ids.clear()
	_tool_filter_field = 0
	_tool_name_field = ""
	property_list_changed.emit()

func _tool_get_categories(collection: StringName) -> Array:
	var tmp_categories = (db._collections_data[collection][&"categories_to_ints"]) as Dictionary
	var arr = tmp_categories.keys()
	arr.push_front("None")
	categories = arr
	return arr

func _tool_get_data_entries(collection: StringName) -> Array:
	var ids = db.fetch_collection_data(collection).keys()
	if _tool_filter_field != 0:
		ids = db.fetch_category_data(collection, categories[_tool_filter_field])
		
	var translation_dict = db._collections_data[collection][&"ints_to_strings"] as Dictionary
	var ret = []
	for id in ids:
		ret.append(translation_dict[id])
	
	data_ids = ret
	return ret

func _get_property_list() -> Array:
	if !Engine.is_editor_hint(): return []
	var ret = []
	
	## Early exit when we are not adding anything
	if not is_adding_attack and not is_adding_stance:
		ret.append({ "name": "_tool_add_attack_button", "class_name": &"", "type": 25, "hint": 39, "hint_string": "Add Attack-Profile", "usage": 4100 })
		ret.append({ "name": "_tool_add_stance_button", "class_name": &"", "type": 25, "hint": 39, "hint_string": "Add Stance-Profile", "usage": 4100 })
		return ret
	
	## Filter
	ret.append({
		"name": &"_tool_filter_field",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(categories)
	})
	
	## ID
	ret.append({
		"name": &"_tool_id_field",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(data_ids)
	})
	
	## Retarget ID to this name for ease of use
	ret.append({ "name": "_tool_name_field", "class_name": &"", "type": 4, "hint": 0, "hint_string": "", "usage": 4102 })
	
	ret.append({ "name": "_tool_confirm_addition", "class_name": &"", "type": 25, "hint": 39, "hint_string": "Confirm", "usage": 4100 })
	ret.append({ "name": "_tool_cancel_addition", "class_name": &"", "type": 25, "hint": 39, "hint_string": "Cancel", "usage": 4100 })
	
	return ret
