@tool
extends Node
class_name EquipmentManager

enum EquipmentSlot {
	MainWeapon
}

@export_category("Equipment Slots")
@export var EquipmentSlots: Array[ItemData] : set = invalidate_slots_arr
@export var SlotPivots: Array[Node3D]
@export var SlotNames: Array[String]
@export var SlotConstraints: Array[GameInfo.ItemType]

func invalidate_slots_arr(newArr):
	EquipmentSlots = newArr
	SlotPivots.resize(len(EquipmentSlots))
	SlotNames.resize(len(EquipmentSlots))
	SlotConstraints.resize(len(EquipmentSlots))

func _ready():
	if EquipmentSlots[0] != null: equip_item(EquipmentSlots[0], EquipmentSlot.MainWeapon)
	
func equip_item(data: ItemData, slot: EquipmentSlot):
	if SlotConstraints[slot] != data.type: return 		# Slot type constraint does not match provided item-type
	EquipmentSlots[slot] = data
	if SlotPivots[slot].get_child_count() > 0:
		SlotPivots[slot].get_child(0).queue_free()		# Delete Model if previously present
	var instance = data.prefab.instantiate()
	SlotPivots[slot].add_child(instance)				# Instantiate and parent model to slot-pivot (hand)
