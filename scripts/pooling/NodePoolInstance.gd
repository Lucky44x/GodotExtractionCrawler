extends Node
class_name NodePoolInstance

var ParentPool: NodePool

func _internal_setup_ref():
	ParentPool = get_parent()

## Call this to "destroy" this node and push it back onto the Pool
func Destroy():
	ParentPool.push_instance(self)

## Gets called when the Node is originally Instantiated by the Pool
func OnInstance():
	pass

## Gets called when the Node is pushed back onto the Pool
func OnPush():
	pass

## Gtes called when the Node is popped from the Pool
func OnPop():
	pass
