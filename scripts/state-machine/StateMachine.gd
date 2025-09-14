extends Node

@export var initial_state : State

var current_state : State
var states : Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta: float):
	if current_state:
		current_state.Update(delta)
		
func _physics_process(delta: float):
	if current_state:
		current_state.PhysicsUpdate(delta)

func on_child_transition(state: State, new_state_name: String, silent_entry: bool = false, silent_exit: bool = false):
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state and not silent_exit: current_state.Exit()
	current_state = new_state
	if not silent_entry: current_state.Enter()
