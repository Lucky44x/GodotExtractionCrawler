extends Control
class_name InventoryController

@export var width: int
@export var height: int

@export var inventory_grid : GridContainer
var occupied_matrix : Array[bool]

func _ready():
	build_inventory()

func build_inventory():
	inventory_grid.columns = width
	for i in (width * height):
		var newInstance: Panel = Panel.new()
		inventory_grid.add_child(newInstance)
		newInstance.custom_minimum_size = Vector2(GameInfo.InventoryCellWidth, GameInfo.InventoryCellHeight)
		newInstance.update_minimum_size()
		if len(occupied_matrix) > i: continue
		occupied_matrix.append(false)

func get_occupied(x: int, y: int) -> bool:
	if x < 0 or y < 0 or x > width or y > height: return true
	var ma_x: int = (x % width)
	@warning_ignore("integer_division")
	var ma_y: int = floori(y / height)
	var ma_i: int = ma_x + (width * ma_y)
	return occupied_matrix[ma_i]

func set_occupied(x: int, y: int, state: bool):
	if x < 0 or y < 0 or x > width or y > height: return
	var ma_x: int = (x % width)
	@warning_ignore("integer_division")
	var ma_y: int = floori(y / height)
	var ma_i: int = ma_x + (width * ma_y)
	occupied_matrix[ma_i] = state
