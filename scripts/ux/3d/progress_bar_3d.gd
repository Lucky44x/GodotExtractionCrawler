extends Sprite3D
class_name ProgressBar3D

@onready var _progress_bar: ProgressBar = $SubViewport/Panel/ProgressBar

func SetRange(min: float, max: float):
	_progress_bar.min_value = min
	_progress_bar.max_value = max

func SetValue(val: float):
	_progress_bar.value = val
