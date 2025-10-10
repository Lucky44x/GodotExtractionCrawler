extends Node
class_name Interactable

var _current_state: InteractionState = null

## Gets emitted when Interactable is interacted with by an Interactioncontroller
## Use this to set the interaction state (accepted, failed etc..)
## Sig: interaction_query(state: InteractionState)
signal interaction_query()

## Gets emitted when the Query signal has finished processing
## State Handling is up to user
## Sig: interaction_resolve(state: InteractionState)
signal interaction_resolve()

## Gets emitted while this Interactable is "hovered" by an InteractionController
## Sig: hover_update(caller: InteractionController)
signal hover_update()

## Gets emitted when this Interactable enters the "hovered" state of an InteractionController
## Sig: hover_enter(caller: InteractionController)
signal hover_enter()

## Gets emitted when this Interactable exits the "hovered" state of an InteractionController
## Sig: hover_exit(caller: InteractionController)
signal hover_exit()

## Use this to set the "Result-State" of the current interaction
func SetInteractionState(state: GameInfo.InteractionState):
	if _current_state == null: return
	if state as int > _current_state._state as int:
		_current_state._state = state

func TransmitInteraction(caller: InteractionController) -> InteractionResult:
	if _current_state != null: return InteractionResult.new(GameInfo.InteractionState.Invalid)
	_current_state = InteractionState.new(caller, GameInfo.InteractionState.Accepted)

	# query result of interaction
	interaction_query.emit(_current_state)
	# emit resolve signal
	interaction_resolve.emit(_current_state)
	
	##TODO: Doesnt emit???
	
	print("query and resolve interaction finished")
	
	var tmpState: GameInfo.InteractionState = _current_state._state
	_current_state = null
	return InteractionResult.new(tmpState)
