extends Resource
class_name ItemData

@export var name: String
@export_multiline var descriptor: String
@export var rarity: GameInfo.ItemRarity
@export var prefab: PackedScene

func _init(p_name = "NAN", p_desc = "NAN", p_rarity = GameInfo.ItemRarity.Abundant, p_prefab = null):
	name = p_name
	descriptor = p_desc
	rarity = p_rarity
	prefab = p_prefab
