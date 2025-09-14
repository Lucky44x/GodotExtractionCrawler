extends ItemData
class_name WeaponData

@export var damage: int
# Add in other stuff like effects, types and shit

func _init(p_damage = 1):
	damage = p_damage
