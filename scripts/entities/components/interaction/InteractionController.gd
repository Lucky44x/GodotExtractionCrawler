extends Node
class_name InteractionController

@export var search_area: Area3D
var _interactables: Array[Interactable] = []

var _closest_interactable: Interactable = null

func _process(_d: float):
	_search_interactables()
	_find_closest_entity()
	if _closest_interactable != null: _closest_interactable.hover_update.emit(self)

func _search_interactables():
	_interactables.clear()
	for hit in search_area.get_overlapping_bodies():
		var interactable: Interactable = hit.find_child("Interactable")
		if interactable == null: continue
		_interactables.append(interactable)

func _find_closest_entity():
	# No Interactable found so current one should also be invalid
	if len(_interactables) <= 0:
		if _closest_interactable != null:
			_closest_interactable.hover_exit.emit(self)
			_closest_interactable = null
		return
	
	var tmpTarget: Node3D = _interactables[0].get_parent()
	var tmpSelf: Node3D = self.get_parent()
	var minDist = tmpTarget.position.distance_squared_to(tmpSelf.position)
	var closestEntity: Interactable = _interactables[0]
	
	# Search for closest Entity
	for entity in _interactables:
		if closestEntity == entity: continue
		tmpTarget = entity.get_parent()
		var dist = tmpTarget.position.distance_squared_to(tmpSelf.position)
		if dist < minDist:
			closestEntity = entity
			minDist = dist
	
	# Handle events
	if closestEntity == null: return
	if closestEntity != _closest_interactable:
		if _closest_interactable != null: _closest_interactable.hover_exit.emit(self)
		closestEntity.hover_enter.emit(self)
		_closest_interactable = closestEntity

func InteractNearest() -> InteractionResult:
	# Execute
	if _closest_interactable == null: return InteractionResult.new(GameInfo.InteractionState.Invalid)
	return _closest_interactable.TransmitInteraction(self)
