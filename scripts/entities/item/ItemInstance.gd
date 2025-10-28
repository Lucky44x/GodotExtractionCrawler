extends RigidBody3D
class_name ItemInstance

@export var data: ItemData
@onready var interactable: Interactable = $Interactable

func _ready():
	interactable.hover_update.connect(hover_update)
	instantiate()

func hover_update(caller):
	print("Hovering Item")

func instantiate():
	if data==null:
		return
	var children: Array[Node] = get_children()
	#if len(children) > 0:
		#children[0].queue_free()	# Delete instance if previously present
	var instance = data.prefab.instantiate()
	add_child(instance)
