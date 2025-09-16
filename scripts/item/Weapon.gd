extends Item
class_name Weapon

@export var hitscan_area: Area3D
@export var effects: Node

func collect_effects(stat_type: GameInfo.StatType) -> float:
	var value: float = 0.0
	for node in effects.get_children():
		if not node is WeaponEffect: continue
		if node.stat_type != stat_type: continue
		value += node.value
	return value
