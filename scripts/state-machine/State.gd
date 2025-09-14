extends Node
class_name State

signal Transitioned # caller state, next state-name, silent entry, silent exit

func Enter():
	pass
	
func Exit():
	pass
	
func Update(delta: float):
	pass

func PhysicsUpdate(delta: float):
	pass
