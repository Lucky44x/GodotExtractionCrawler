extends Node
class_name NodePoolInstance

var ParentPool: NodePool

func _internal_setup_ref():
	ParentPool = get_parent()

func Destroy():
	ParentPool.push_instance(self)

func OnInstance():
	pass

func OnPush():
	pass

func OnPop():
	pass
