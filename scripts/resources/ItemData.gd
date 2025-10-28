@tool
extends Resource
class_name ItemData

@export var name: String
@export var type: GameInfo.ItemType
@export_multiline var descriptor: String
@export var rarity: GameInfo.ItemRarity
@export var prefab: PackedScene

@export var passive_modifiers: Array[StatModifier]

@export_category("UI-Data")
@export var ui_texture: Texture2D
@export var occupation_size: Vector2i : set = _invalidate_occupation_mask
@export var occupation_mask: Array[Array]

func _invalidate_occupation_mask(newSize: Vector2i):
	occupation_size = newSize
	occupation_mask.clear()
	for i in newSize.x:
		var arr: Array
		for iy in newSize.y:
			arr.append(true)
		occupation_mask.append(arr)

func _init(p_name = "NAN", p_desc = "NAN", p_rarity = GameInfo.ItemRarity.Abundant, p_prefab = null):
	name = p_name
	descriptor = p_desc
	rarity = p_rarity
	prefab = p_prefab
