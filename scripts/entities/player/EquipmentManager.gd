extends Node
class_name EquipmentManager

enum EquipmentSlot {
	MainWeapon
}

@export_category("Equipment Slots")
@export var EquipmentSlots: Array[ItemData]
@export var SlotPivots: Array[Node3D]
@export var SlotNames: Array[String]
@export var SlotConstraints: Array[GameInfo.ItemType]

var active_weapon: Weapon

func _ready():
	if EquipmentSlots[0] != null: equip_item(EquipmentSlots[0], EquipmentSlot.MainWeapon)
	
func equip_item(data: ItemData, slot: EquipmentSlot):
	if SlotConstraints[slot] != data.type: return 		# Slot type constraint does not match provided item-type
	EquipmentSlots[slot] = data
	if SlotPivots[slot].get_child_count() > 0:
		SlotPivots[slot].get_child(0).queue_free()		# Delete Model if previously present
	var instance = data.prefab.instantiate()
	SlotPivots[slot].add_child(instance)				# Instantiate and parent model to slot-pivot (hand)
	if instance is Weapon and slot == EquipmentSlot.MainWeapon: active_weapon = instance
