extends Node
class_name EquipmentHandler

signal hitscan_callback
var isHitscanActive = false
var hitlist: Array[Node3D] = []

var blocking_since: int = -1

@export_group("Meta-Properties")
@export var animator: AnimationPlayer
@export var current_weapon: Weapon

@export_group("Combat Settings")
@export var parryTiming = 50

@export_group("Equipment-Data")
@export var equipped_item_L: ItemData
@export var equipped_item_R: ItemData

@export_group("Pivots")
@export var hand_L: Node3D
@export var hand_R: Node3D

func _ready():
	if equipped_item_L != null:
		equip_item(true, equipped_item_L)
	
	if equipped_item_R != null:
		equip_item(false, equipped_item_R)

func equip_item(left: bool, item: ItemData):
	if not item.prefab:
		push_warning("Item ", item.name, " ", item.resource_name, " does not have a prefab set")
		return

	var instance = item.prefab.instantiate()
	if not instance: 
		push_error("Could not load ", item.resource_name)
		return

	if left:
		hand_L.add_child(instance)
		equipped_item_L = item
	else:
		hand_R.add_child(instance)
		equipped_item_R = item
	
	if instance is Weapon:
		current_weapon = instance

func perform_action(action_name: String):
	animator.play(action_name)

func abort_action():
	animator.stop(false)
	end_hitscan()

func _process(delta: float):
	if not isHitscanActive: return
	
	var hits = current_weapon.hitscan_area.get_overlapping_bodies()
	if not hits or len(hits) == 0: return
	
	for hit in hits:
		if not hitlist.has(hit):
			hitscan_callback.emit(hit)
			hitlist.push_front(hit)

func start_hitscan():
	isHitscanActive = true

func end_hitscan():
	isHitscanActive = false
	hitlist.clear()

func damage():
	pass

func is_blocking() -> bool:
	if blocking_since > -1:
		if not is_parry():
			$"..".move_and_collide($"..".basis.z * 0.5)
		return true
	return false

func is_parry() -> bool:
	if blocking_since == -1: return false
	if Time.get_ticks_msec() - blocking_since <= parryTiming: return true
	return false
