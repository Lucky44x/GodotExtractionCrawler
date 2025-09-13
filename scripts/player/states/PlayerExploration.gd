extends State

func Enter():
	$"../..".speed = 14
	
func Exit():
	pass
	
func Update(delta: float):
	if Input.is_action_just_pressed("lock_enemy"):
		Transitioned.emit(self, "combat")
