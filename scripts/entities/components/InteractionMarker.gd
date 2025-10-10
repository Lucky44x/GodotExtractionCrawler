extends Sprite3D

@export var interactable: Interactable

func _ready():
	interactable.hover_enter.connect(_on_hover_enter)
	interactable.hover_exit.connect(_on_hover_exit)

func _on_hover_exit(_c):
	visible = false

func _on_hover_enter(_c):
	visible = true
