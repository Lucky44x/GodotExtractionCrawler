extends State

var hitscanActive: bool
var hitlist: Array[Node3D] = []

@export var anim: AnimationPlayer
@export var hitscanArea: Area3D

func Enter():
	anim.animation_finished.connect(on_animation_complete)
	anim.play("Enemy/attack")

func Exit():
	anim.animation_finished.disconnect(on_animation_complete)

func on_animation_complete(id: String):
	Transitioned.emit(self, "follow")

func Update(delta: float):
	if not hitscanActive: return
	
	var hits = hitscanArea.get_overlapping_bodies()
	if not hits or len(hits) == 0: return
	
	for hit in hits:
		if not hitlist.has(hit):
			do_player_hit(hit)
			hitlist.push_front(hit)

func endHitscan():
	hitscanActive = false
	hitlist.clear()

func startHitscan():
	hitscanActive = true

func do_player_hit(target: Node3D):
	if not target: return
	
	var equipmentManager = target.get_child(4)
	if not equipmentManager: return
	
	if equipmentManager.is_blocking():
		if equipmentManager.is_parry():
			print("Is Parried")
			Transitioned.emit(self, "stunned")
