extends Control
class_name InventoryDragController

@export var inventory: InventoryController

@export var itemData: ItemData

@onready var _background_grid: GridContainer = $BackgroundGrid
@onready var _foreground_texture: TextureRect = $AspectRatioContainer/ItemTexture

func _ready():
	build_visual()

func _process(_delta: float):
	position = get_viewport().get_mouse_position()

func _check_occupied():
	for x in len(itemData.occupation_mask):
		for y in len(itemData.occupation_mask[x]):
			if not itemData.occupation_mask[x] : continue
	
			var inv_x : int = position.x / GameInfo.InventoryCellWidth + x
			var inv_y : int = position.y / GameInfo.InventoryCellHeight + y
			if inventory.get_occupied(inv_x, inv_y) : print("is occupied: ", inv_x, " : ", inv_y)
	pass

func build_visual():
	custom_minimum_size = Vector2(itemData.occupation_size.x * 64, itemData.occupation_size.y * 64)
	update_minimum_size()
	
	_background_grid.columns = itemData.occupation_size.x
	for i in (itemData.occupation_size.x * itemData.occupation_size.y):
		var newInstance: Panel = Panel.new()
		newInstance.custom_minimum_size = Vector2(GameInfo.InventoryCellWidth, GameInfo.InventoryCellHeight)
		newInstance.update_minimum_size()
		_background_grid.add_child(newInstance)
	
	_foreground_texture.texture = itemData.ui_texture
