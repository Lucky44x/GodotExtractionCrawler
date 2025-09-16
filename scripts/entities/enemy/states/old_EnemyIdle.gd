extends State

@export var detectionArea: Area3D

func Update(delta: float):
	var bodies = detectionArea.get_overlapping_bodies()
	if len(bodies) == 0: return
	Transitioned.emit(self, "follow")
