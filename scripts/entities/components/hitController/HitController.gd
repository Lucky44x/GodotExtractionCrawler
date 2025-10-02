extends Node
class_name  HitController

## Gets called first to query if the Hit happened...
signal _hit_query
## Gets called second with the HitData (gets called when accepted and parried or blocked... state can be queried via data.state)
signal _hit_resolve

var _current_data: HitData = null

func set_hit_result(state: GameInfo.HitState):
	if _current_data == null: return
	if state > _current_data.state: _current_data.state = state

func transmit_hit(mods: Array[StatModifier], parry: int = 250) -> HitResult:
	if not _current_data == null: return HitResult.new(GameInfo.HitState.Invalid)
	
	# Instantiate new Instances
	var _current_result = HitResult.new(GameInfo.HitState.Accepted)
	_current_data = HitData.new()
	# Setup Data Objects
	_current_data.mods = mods
	_current_data.parry_timing = parry
	_current_data.state = GameInfo.HitState.Accepted
	
	# Query for Blocked/Parry state
	_hit_query.emit(_current_data)
	
	# Signal a hit
	_hit_resolve.emit(_current_data)
	
	_current_result._init(_current_data.state)
	_current_data = null
	return _current_result
