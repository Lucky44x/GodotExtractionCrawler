extends State

@export var detectionArea: Area3D
@export var attackArea: Area3D

@export var pivot: Node3D

var target: Node3D

func Enter():
	var overlap = detectionArea.get_overlapping_bodies()
	if len(overlap) == 0: 
		Transitioned.emit(self, "idle")
		return
	target = overlap[0]

func Exit():
	target = null

func Update(delta: float):
	if target == null:
		Transitioned.emit(self, "idle")
		return
	
	if attackArea.overlaps_body(target):
		Transitioned.emit(self, "attack")
		return
	
	pivot.basis = Basis.looking_at(pivot.global_position - target.global_position)
