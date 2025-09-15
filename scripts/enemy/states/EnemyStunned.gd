extends State

@export var anim: AnimationPlayer

func Enter():
	anim.play("Enemy/stunned")
	anim.animation_finished.connect(on_anim_fin)

func Exit():
	anim.animation_finished.disconnect(on_anim_fin)
	anim.play("RESET")

func on_anim_fin(_id: String):
	Transitioned.emit(self, "idle")
