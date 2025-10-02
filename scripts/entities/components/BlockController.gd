extends Node
class_name BlockController

@export var hit_controller: HitController

var blocking_since: int = -1

func _ready():
	hit_controller._hit_query.connect(_query_hit_legal)

func _query_hit_legal(data: HitData):
	if blocking_since < -1: return
	var block_time: int = Time.get_ticks_msec() - blocking_since
	if block_time <= data.parry_timing: hit_controller.set_hit_result(GameInfo.HitState.Parried)
	else: hit_controller.set_hit_result(GameInfo.HitState.Blocked)

func BeginBlocking():
	blocking_since = Time.get_ticks_msec()

func EndBlocking():
	blocking_since = -1
