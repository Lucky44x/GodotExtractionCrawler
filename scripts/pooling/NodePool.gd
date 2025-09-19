extends Node
class_name NodePool

@export var instance_prefab: PackedScene
@export var starting_size: int

var instance_stack: Array[NodePoolInstance]

func _ready():
	for idx in starting_size:
		create_instance()

func push_instance(node: NodePoolInstance):
	instance_stack.push_back(node)
	node.reparent(self)
	node.OnPush()

func pop_instance() -> NodePoolInstance:
	if len(instance_stack) <= 0:
		create_instance()
	var instance = instance_stack.pop_back()
	instance.OnPop()
	return instance

func create_instance():
	var instance = instance_prefab.instantiate()
	add_child(instance)
	instance._internal_setup_ref()
	instance_stack.append(instance)
	instance.OnInstance()
