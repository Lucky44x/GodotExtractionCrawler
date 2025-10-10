class_name InteractionState

var _caller: InteractionController
var _state: GameInfo.InteractionState

func _init(caller: Node, state: GameInfo.InteractionState):
	_caller = caller
	_state = state
