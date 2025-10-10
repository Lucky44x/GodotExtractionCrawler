extends Node

func _ready():
	$"../Interactable".interaction_resolve.connect(testing_out)

func testing_out(_tmp: InteractionState):
	print("Test")
