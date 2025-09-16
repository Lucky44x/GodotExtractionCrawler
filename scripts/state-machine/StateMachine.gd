extends Node
class_name StateMachine

@export var initial_state : State

var state_stack : Array[State] = []
var current_state : State

var states : Dictionary = {}

func is_active(state: State) -> bool:
	return state == current_state

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.parent = self
	
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta: float):
	if current_state:
		current_state.Update(delta)
		
func _physics_process(delta: float):
	if current_state:
		current_state.PhysicsUpdate(delta)

func set_current_state(state: State):
	current_state = state
	state.Enter()

func state_transition(caller: State, new_state_name: String):
	if caller != current_state: return
	if new_state_name.contains("trans_"): push_error("State ", new_state_name, " is marked as transient (trans_) and may introduce unintented behaviour by not being treated as such")
	
	var state = states.get(new_state_name.to_lower())
	if not state: return
	
	current_state.Exit()
	set_current_state(state)

func push_transient_state(caller: State, new_state_name: String):
	if caller != current_state: return
	if not new_state_name.contains("trans_"): push_error("State ", new_state_name, " is not marked as transient (trans_) and may introduce unintented behaviour by being treated as such")
	
	var state = states.get(new_state_name.to_lower())
	if not state: return
	
	state_stack.push_back(current_state)
	set_current_state(state)

func pop_transient_state():
	if len(state_stack) <= 0: return
	current_state.Exit()
	current_state = state_stack.pop_back()
